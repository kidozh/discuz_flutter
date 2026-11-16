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

class ReplyDraftStore {
  ReplyDraftStore(
    String site,
    int uid,
    this.tid, {
    Future<Directory> Function()? root,
  }) : _root = root ?? getApplicationSupportDirectory,
       _key = sha256
           .convert(utf8.encode(jsonEncode([site, uid, tid])))
           .toString();

  final int tid;
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

  Future<void> _write(Directory folder, ReplyDraft draft) async {
    final record = File('${folder.path}/draft.json');
    if (draft.empty && !await record.exists()) return;
    if (draft.empty) {
      await record.delete();
    } else {
      await folder.create(recursive: true);
      final temp = File('${folder.path}/draft.tmp');
      await temp.writeAsString(jsonEncode(draft.toJson()), flush: true);
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
