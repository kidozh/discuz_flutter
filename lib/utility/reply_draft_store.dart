import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';

import '../entity/Post.dart';
import 'discuz_json.dart';

class ReplyDraftAttachment {
  const ReplyDraftAttachment(this.id, this.name, this.image);
  final String id;
  final String name;
  final bool image;

  static final validId = RegExp(r'^[a-f0-9]{32}$');
  String get token =>
      image ? '[draftimg]$id[/draftimg]' : '[draftfile]$id[/draftfile]';

  String get filename {
    final suffix = RegExp(r'\.[a-zA-Z0-9]{1,12}$').firstMatch(name)?.group(0);
    return '$id${suffix ?? ''}';
  }

  Map<String, Object> toJson() => {'id': id, 'name': name, 'image': image};

  static ReplyDraftAttachment? fromJson(Object? value) {
    final map = discuzMap(value);
    final id = discuzString(map['id']);
    final name = discuzString(map['name']);
    if (!validId.hasMatch(id) || name.isEmpty) return null;
    return ReplyDraftAttachment(id, name, map['image'] == true);
  }
}

class ReplyDraft {
  const ReplyDraft({
    required this.text,
    this.quote,
    this.attachments = const [],
    this.names = const {},
  });
  final String text;
  final Post? quote;
  final List<ReplyDraftAttachment> attachments;
  final Map<String, String> names;

  bool get empty => text.trim().isEmpty && quote == null && attachments.isEmpty;

  Map<String, Object?> toJson() => {
    'text': text,
    'attachments': attachments.map((item) => item.toJson()).toList(),
    'names': names,
    if (quote case final post?)
      'quote': {
        'pid': post.pid,
        'tid': post.tid,
        'author': post.author,
        'message': post.message.length > 8192
            ? post.message.substring(0, 8192)
            : post.message,
        'date': post.publishAt.millisecondsSinceEpoch,
      },
  };

  static ReplyDraft fromJson(Object? value, int tid) {
    final map = discuzMap(value);
    final raw = discuzMap(map['quote']);
    final date = discuzInt(raw['date']);
    final quote =
        discuzInt(raw['tid']) == tid &&
            discuzInt(raw['pid']) > 0 &&
            date > 0 &&
            date <= 8640000000000000
        ? (Post()
            ..tid = tid
            ..pid = discuzInt(raw['pid'])
            ..author = discuzString(raw['author'])
            ..message = discuzString(raw['message'])
            ..publishAt = DateTime.fromMillisecondsSinceEpoch(date))
        : null;
    final attachments = map['attachments'];
    return ReplyDraft(
      text: discuzString(map['text']),
      names: discuzMap(map['names'])
          .map((key, value) => MapEntry(key, discuzString(value))),
      quote: quote,
      attachments: [
        if (attachments is List)
          for (final item in attachments)
            if (ReplyDraftAttachment.fromJson(item) case final attachment?)
              attachment,
      ],
    );
  }
}

class ReplyDraftSummary {
  const ReplyDraftSummary(
    this.site,
    this.uid,
    this.tid,
    this.title,
    this.updated,
    this.draft,
  );
  final String site, title;
  final int uid, tid;
  final DateTime updated;
  final ReplyDraft draft;
}

class ReplyDraftStore {
  ReplyDraftStore(
    this.site,
    this.uid,
    this.tid, {
    Future<Directory> Function()? root,
    this.title = '',
  }) : _root = root ?? getApplicationSupportDirectory,
       _key = sha256
           .convert(utf8.encode(jsonEncode([site, uid, tid])))
           .toString();

  final int tid, uid;
  final String site;
  String title;
  final Future<Directory> Function() _root;
  final String _key;
  static final _random = Random.secure();
  static final _writes = <String, Future<void>>{};

  late final Future<Directory> _folder = _root().then(
    (root) => Directory('${root.path}/reply-drafts/$_key'),
  );

  Future<File> file(ReplyDraftAttachment attachment) async =>
      File('${(await _folder).path}/${attachment.filename}');

  Future<ReplyDraft?> read() async {
    final folder = await _folder;
    await _writes[folder.path]?.then<void>(
      (_) {},
      onError: (Object _, StackTrace __) {},
    );
    return _read(folder);
  }

  Future<ReplyDraft?> _read(Directory folder) async {
    final record = File('${folder.path}/draft.json');
    if (!await record.exists()) return null;
    return ReplyDraft.fromJson(jsonDecode(await record.readAsString()), tid);
  }

  Future<ReplyDraftAttachment> add({
    required String name,
    required Stream<List<int>> bytes,
    required bool image,
  }) async {
    final id = List.generate(
      16,
      (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    final attachment = ReplyDraftAttachment(id, name, image);
    final saved = await file(attachment);
    await saved.parent.create(recursive: true);
    final sink = saved.openWrite();
    var succeeded = false;
    try {
      try {
        await sink.addStream(bytes);
      } finally {
        await sink.close();
      }
      if (await saved.length() == 0)
        throw const FileSystemException('Empty attachment');
      succeeded = true;
      return attachment;
    } finally {
      if (!succeeded && await saved.exists()) await saved.delete();
    }
  }

  Future<void> write(ReplyDraft draft) async {
    final folder = await _folder;
    final previous = _writes[folder.path];
    final pending = (previous ?? Future<void>.value())
        .then<void>((_) {}, onError: (Object _, StackTrace __) {})
        .then((_) => _write(folder, draft));
    _writes[folder.path] = pending;
    try {
      await pending;
    } finally {
      if (identical(_writes[folder.path], pending)) _writes.remove(folder.path);
    }
  }

  Future<void> delete() async {
    await write(const ReplyDraft(text: ''));
    // Files use a grace period, so an editor or in-flight upload still holding
    // a snapshot cannot lose its attachment underneath it.
  }

  static Future<Map<String, Set<int>>> indexedAccounts({
    Future<Directory> Function()? root,
  }) async {
    final base = await (root ?? getApplicationSupportDirectory)();
    final folder = Directory('${base.path}/reply-drafts');
    final accounts = <String, Set<int>>{};
    if (!await folder.exists()) return accounts;
    await for (final item in folder.list(followLinks: false)) {
      if (item is! Directory) continue;
      try {
        final record = File('${item.path}/draft.json');
        if (!await record.exists()) continue;
        final data = discuzMap(jsonDecode(await record.readAsString()));
        final site = discuzString(data['site']);
        final uid = discuzInt(data['uid']), tid = discuzInt(data['tid']);
        if (site.isEmpty || uid <= 0 || tid <= 0) continue;
        final store = ReplyDraftStore(site, uid, tid);
        if (item.uri.pathSegments.where((s) => s.isNotEmpty).last != store._key)
          continue;
        (accounts[site] ??= {}).add(uid);
      } on FileSystemException {
        continue;
      } on FormatException {
        continue;
      }
    }
    return accounts;
  }

  static Future<List<ReplyDraftSummary>> listFor(
    String site,
    int uid, {
    Map<int, String> knownThreads = const {},
    Future<Directory> Function()? root,
  }) async {
    final base = await (root ?? getApplicationSupportDirectory)();
    final directory = Directory('${base.path}/reply-drafts');
    if (!await directory.exists()) return [];
    final result = <ReplyDraftSummary>[];
    final found = <int>{};
    await for (final item in directory.list(followLinks: false)) {
      if (item is! Directory) continue;
      try {
        final record = File('${item.path}/draft.json');
        if (!await record.exists()) continue;
        final data = discuzMap(jsonDecode(await record.readAsString()));
        final indexed = data.containsKey('site');
        final tid = discuzInt(
          indexed ? data['tid'] : discuzMap(data['quote'])['tid'],
        );
        if (tid <= 0 ||
            (indexed &&
                (data['site'] != site || discuzInt(data['uid']) != uid)))
          continue;
        final store = ReplyDraftStore(site, uid, tid, root: () async => base);
        if (item.uri.pathSegments.where((s) => s.isNotEmpty).last != store._key)
          continue;
        final saved = await store.read();
        if (saved == null || saved.empty) continue;
        found.add(tid);
        result.add(
          ReplyDraftSummary(
            site,
            uid,
            tid,
            discuzString(data['title']).isNotEmpty
                ? discuzString(data['title'])
                : knownThreads[tid] ?? '',
            await record.lastModified(),
            saved,
          ),
        );
      } on FileSystemException {
        continue;
      } on FormatException {
        continue;
      }
    }
    // Pre-index drafts were addressed only by a hash. Recover their IDs from
    // locally known threads without assigning them to another account.
    for (final thread in knownThreads.entries) {
      if (thread.key <= 0 || found.contains(thread.key)) continue;
      final store = ReplyDraftStore(
        site,
        uid,
        thread.key,
        root: () async => base,
      );
      try {
        final saved = await store.read();
        if (saved == null || saved.empty) continue;
        final record = File('${(await store._folder).path}/draft.json');
        result.add(
          ReplyDraftSummary(
            site,
            uid,
            thread.key,
            thread.value,
            await record.lastModified(),
            saved,
          ),
        );
      } on FileSystemException {
        continue;
      } on FormatException {
        continue;
      }
    }
    result.sort((a, b) => b.updated.compareTo(a.updated));
    return result;
  }

  Future<void> _write(Directory folder, ReplyDraft draft) async {
    final record = File('${folder.path}/draft.json');
    if (draft.empty && !await record.exists()) return;
    if (draft.empty) {
      await record.delete();
    } else {
      await folder.create(recursive: true);
      final temp = File('${folder.path}/draft.tmp');
      await temp.writeAsString(
        jsonEncode({
          ...draft.toJson(),
          'site': site,
          'uid': uid,
          'tid': tid,
          'title': title,
          'updated': DateTime.now().millisecondsSinceEpoch,
        }),
        flush: true,
      );
      await temp.rename(record.path);
    }
    if (!draft.empty) return;
    // Expire only unreferenced files. Keep recent ones available for undo and
    // for an in-flight reply that still owns an earlier editor snapshot.
    final retained = draft.attachments
        .map((attachment) => attachment.filename)
        .toSet();
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    await for (final item in folder.list(followLinks: false)) {
      final filename = item.uri.pathSegments.last;
      if (item is File &&
          !retained.contains(filename) &&
          ReplyDraftAttachment.validId.hasMatch(filename.split('.').first) &&
          (await item.lastModified()).isBefore(cutoff)) {
        try {
          await item.delete();
        } on FileSystemException {
          // A secondary composer can be closing the same draft directory.
        }
      }
    }
  }
}
