import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' show parseFragment;
import 'package:path_provider/path_provider.dart';

import '../entity/Discuz.dart';
import '../entity/User.dart';
import 'NetworkUtils.dart';
import 'URLUtils.dart';
import 'forum_image_url.dart';
import 'forum_local_records.dart';
import 'post_locator.dart';

typedef AttachmentProgress = void Function(int received, int? total);
typedef AttachmentTransfer = Future<File> Function(
  Directory directory,
  AttachmentProgress progress,
);

class ForumAttachmentReference {
  const ForumAttachmentReference(this.tid, this.pid, this.aid);

  final int tid, pid, aid;

  static ForumAttachmentReference? fromUrl(Uri uri, {int? tid, int? pid}) {
    final token = uri.queryParameters['aid'];
    if (!isForumAttachmentUrl(uri) || token == null || token.length > 512) {
      return null;
    }
    try {
      final parts = ascii.decode(base64Decode(token)).split('|');
      final aid = int.tryParse(parts.first);
      final encodedTid = parts.length == 5 ? int.tryParse(parts.last) : null;
      final thread = encodedTid != null && encodedTid > 0 ? encodedTid : tid;
      if (aid == null || aid <= 0 || thread == null || thread <= 0) return null;
      return ForumAttachmentReference(
        thread,
        thread == tid || tid == null ? pid ?? 0 : 0,
        aid,
      );
    } on FormatException {
      return null;
    }
  }

  factory ForumAttachmentReference.fromRecord(ForumRecord record) =>
      ForumAttachmentReference(
        record['tid'] as int,
        record['pid'] as int,
        record['aid'] as int,
      );

  String get id => '$tid:$aid';

  Future<Uri> reload(Discuz forum, User? user) async {
    final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    try {
      final location = await PostLocator.locate(dio, forum.baseURL, tid, pid);
      final variables = location.result.threadVariables;
      if (variables.member_uid != (user?.uid ?? 0)) {
        throw const FormatException('Forum account expired');
      }
      final post = variables.postList.firstWhere((post) => post.pid == pid);
      if (post.attachmentMapper.values
              .where((item) => item.aid == aid)
              .firstOrNull
          case final attachment?) {
        if (attachment.price > 0 && !attachment.payed) {
          throw const FormatException('Attachment purchase required');
        }
        final target =
            URLUtils.getAttachmentUrl(forum, attachment.aidEncode) ??
            resolveForumImageUri(
              forumBaseUri(forum),
              attachment.getAttachmentRealUrl(forum),
            );
        if (target != null) return target;
      }
      final base = forumBaseUri(forum)!;
      for (final link in parseFragment(
        post.message,
      ).querySelectorAll('a[href]')) {
        final target = resolveForumImageUri(
          base,
          link.attributes['href'] ?? '',
        );
        if (target != null &&
            target.origin == base.origin &&
            target.path == base.resolve('forum.php').path &&
            fromUrl(target, tid: tid)?.aid == aid) {
          return target;
        }
      }
      throw const FormatException('Attachment unavailable');
    } finally {
      dio.close();
    }
  }
}

class ForumAttachmentHistory {
  ForumAttachmentHistory._(this.records);

  static final _instances = <ForumLocalRecords, ForumAttachmentHistory>{};

  factory ForumAttachmentHistory(Discuz forum, User? user) {
    final records = ForumLocalRecords('attachment_history', forum, user);
    return _instances.putIfAbsent(
      records,
      () => ForumAttachmentHistory._(records),
    );
  }

  final ForumLocalRecords records;
  final progress = ValueNotifier<Map<String, double?>>(const {});

  Future<Directory> _directory() async {
    final documents = await getApplicationDocumentsDirectory();
    return Directory('${documents.path}/forum-downloads').create();
  }

  Future<File?> localFile(ForumRecord record) async {
    final folder = record['folder'];
    final filename = record['filename'];
    if (folder is! String ||
        !RegExp(r'^attachment-[a-zA-Z0-9]+$').hasMatch(folder) ||
        filename is! String ||
        filename.contains(RegExp(r'[/\\]')) ||
        filename == '.' ||
        filename == '..') {
      return null;
    }
    final directory = await _directory();
    final file = File('${directory.path}/$folder/$filename');
    return await file.exists() ? file : null;
  }

  Future<File?> start(
    ForumAttachmentReference reference, {
    required String name,
    required AttachmentTransfer transfer,
    required bool Function() isCurrent,
  }) async {
    final id = reference.id;
    if (progress.value.containsKey(id)) return null;
    progress.value = {...progress.value, id: null};
    File? file;
    Map<String, dynamic>? record;
    try {
      await records.ready;
      final previous = records.value
          .where((entry) => entry['id'] == id)
          .firstOrNull;
      final cached = previous == null ? null : await localFile(previous);
      if (cached != null) {
        if (!isCurrent()) throw StateError('Forum account changed');
        return cached;
      }
      if (!isCurrent()) throw StateError('Forum account changed');
      record = {
        'id': id,
        'tid': reference.tid,
        'pid': reference.pid,
        'aid': reference.aid,
        'filename': name,
        'state': 'pending',
        'time': DateTime.now().millisecondsSinceEpoch,
      };
      await records.put(record);
      final folder = await _directory();
      file = await transfer(folder, (received, total) {
        if (total == null || total <= 0) return;
        final fraction = (received / total).clamp(0.0, 1.0);
        if (fraction - (progress.value[id] ?? 0) >= .02 || fraction == 1) {
          progress.value = {...progress.value, id: fraction};
        }
      });
      if (!isCurrent()) throw StateError('Forum account changed');
      await records.put({
        ...record,
        'state': 'complete',
        'filename': file.uri.pathSegments.last,
        'folder': file.parent.uri.pathSegments
            .where((part) => part.isNotEmpty)
            .last,
      });
      return file;
    } catch (_) {
      if (file != null) await file.parent.delete(recursive: true);
      if (record != null) await records.put({...record, 'state': 'failed'});
      rethrow;
    } finally {
      progress.value = {...progress.value}..remove(id);
    }
  }
}
