import 'package:discuz_flutter/client/ForumInteractionClient.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:html/parser.dart' as html;

import 'AiPostText.dart';
import 'NetworkUtils.dart';
import 'discuz_json.dart';

class WatchSessionExpired implements Exception {}

int watchNotificationThreadID(
  String baseURL,
  int fromID,
  String fromType,
  String note,
) {
  if (fromType == 'tid' && fromID > 0) return fromID;
  final base = Uri.parse('$baseURL/');
  for (final anchor in html.parseFragment(note).querySelectorAll('a[href]')) {
    final uri = base.resolve(anchor.attributes['href']!);
    if (uri.host != base.host || !{'https', 'http'}.contains(uri.scheme)) {
      continue;
    }
    final rewritten = RegExp(r'(?:^|/)thread-(\d+)-').firstMatch(uri.path);
    final id =
        int.tryParse(
          uri.queryParameters['ptid'] ??
              uri.queryParameters['tid'] ??
              rewritten?[1] ??
              '',
        ) ??
        0;
    if (id > 0) return id;
  }
  return 0;
}

/// Full text is split into transport-sized parts, rather than truncated. No
/// cookies or formhash are included in a response to the watch.
Map<String, Object> watchReadingPart(
  List<Map<String, Object>> entries, {
  required int part,
  required String title,
  required int page,
  required bool hasNextPage,
  required bool canReply,
}) {
  final blocks = <Map<String, Object>>[];
  for (final entry in entries) {
    final chunks = AiPostText.chunks(
      AiPostText.plainText(entry['body'] as String),
      limit: 1200,
    );
    for (var index = 0; index < chunks.length; index++) {
      blocks.add({
        'id': '${entry['id']}-$index',
        'author': index == 0
            ? String.fromCharCodes(
                AiPostText.plainText(entry['author'] as String).runes.take(60),
              )
            : '',
        'body': chunks[index],
      });
    }
  }
  const perPart = 8; // <= 38.4 KB of UTF-8 text, plus small metadata.
  return {
    'title': String.fromCharCodes(AiPostText.plainText(title).runes.take(150)),
    'page': page,
    'part': part,
    'blocks': blocks.skip(part * perPart).take(perPart).toList(),
    'hasNextPart': blocks.length > (part + 1) * perPart,
    'hasNextPage': hasNextPage,
    'canReply': canReply,
  };
}

bool watchThreadClosed(Object? value) => value == true || discuzInt(value) > 0;

/// Uses only the phone's authenticated client. A fresh identity and permission
/// check is required immediately before each write; writes are never retried.
class WatchReader {
  final ForumInteractionClient client;
  final int uid;
  final bool Function() sameAccount;
  WatchReader(this.client, this.uid, this.sameAccount);

  void check(ForumReply result) {
    if (!sameAccount()) throw StateError('account_changed');
    if (discuzInt(result.variables['member_uid']) != uid) {
      throw WatchSessionExpired();
    }
  }

  Future<ForumReply> _thread(int id, int page) async {
    final result = await client.request('viewthread', {
      'tid': id,
      'page': page,
      'ppp': 3,
    });
    check(result);
    result.requireData('postlist');
    if (discuzInt(discuzMap(result.variables['thread'])['tid']) != id) {
      throw StateError('content_changed');
    }
    return result;
  }

  Future<ForumReply> _messages(int id, int page) async {
    final result = await client.request('mypm', {
      'subop': 'view',
      'touid': id,
      'page': page,
    });
    check(result);
    result.requireData('list');
    return result;
  }

  int threadID(String section, Map<String, Object> item) => section == 'threads'
      ? item['id'] as int
      : (item['threadID'] as int? ?? 0);

  Future<Map<String, Object>> load(
    String section,
    Map<String, Object> item,
    int page,
    int part,
  ) async {
    if (section == 'messages') {
      final result = await _messages(item['id'] as int, page);
      final vars = result.variables;
      final entries = forumRows(vars['list']).map(discuzMap).toList();
      return watchReadingPart(
        [
          for (final row in entries)
            {
              'id': discuzInt(row['pmid']),
              'author': discuzString(row['msgfrom']),
              'body': discuzString(row['message']),
            },
        ],
        part: part,
        title: item['title'] as String,
        page: page,
        hasNextPage:
            discuzInt(vars['count']) > page * discuzInt(vars['perpage']) &&
            discuzInt(vars['perpage']) > 0,
        canReply: uid > 0 && discuzString(vars['formhash']).isNotEmpty,
      );
    }
    final tid = threadID(section, item);
    if (tid <= 0) {
      // Non-thread notifications can still be read fully on the watch.
      final result = await client.request('mynotelist', {'page': 1});
      check(result);
      result.requireData('list');
      final rows = forumRows(result.variables['list'])
          .map(discuzMap)
          .where((row) => discuzInt(row['id']) == item['id']);
      if (rows.isEmpty) throw StateError('content_changed');
      return watchReadingPart(
        [
          {
            'id': item['id']!,
            'author': item['title']!,
            'body': discuzString(rows.first['note']),
          },
        ],
        part: part,
        title: item['title'] as String,
        page: 1,
        hasNextPage: false,
        canReply: false,
      );
    }
    final result = await _thread(tid, page);
    final vars = result.variables;
    final thread = discuzMap(vars['thread']);
    final posts = forumRows(vars['postlist']).map(discuzMap).toList();
    var canReply = false;
    if (uid > 0 && !watchThreadClosed(thread['closed'])) {
      final permission = await client.request('checkpost', {
        'fid': discuzInt(vars['fid'] ?? thread['fid']),
        'tid': tid,
      });
      check(permission);
      canReply =
          permission.code.isEmpty &&
          discuzPermission(
                discuzMap(permission.variables['allowperm'])['allowreply'],
              ) ==
              true;
    }
    final perPage = discuzInt(vars['ppp']);
    return watchReadingPart(
      [
        for (final post in posts)
          {
            'id': discuzInt(post['pid']),
            'author': discuzString(post['author']),
            'body': discuzString(post['message']),
          },
      ],
      part: part,
      title: discuzString(thread['subject']),
      page: page,
      hasNextPage:
          perPage > 0 && discuzInt(thread['replies']) + 1 > page * perPage,
      canReply: canReply,
    );
  }

  Future<void> send(
    String section,
    Map<String, Object> item,
    String text,
  ) async {
    if (uid <= 0 || text.trim().isEmpty || text.runes.length > 1000) {
      throw StateError('invalid_reply');
    }
    final id = item['id'] as int;
    final ForumReply fresh;
    var fid = 0;
    final tid = threadID(section, item);
    if (section == 'messages') {
      fresh = await _messages(id, 1);
    } else {
      if (tid <= 0) throw StateError('reply_unavailable');
      fresh = await _thread(tid, 1);
      final thread = discuzMap(fresh.variables['thread']);
      if (watchThreadClosed(thread['closed'])) {
        throw StateError('reply_unavailable');
      }
      fid = discuzInt(fresh.variables['fid'] ?? thread['fid']);
      final permission = await client.request('checkpost', {
        'fid': fid,
        'tid': tid,
      });
      check(permission);
      if (permission.code.isNotEmpty ||
          discuzPermission(
                discuzMap(permission.variables['allowperm'])['allowreply'],
              ) !=
              true) {
        throw StateError('reply_unavailable');
      }
    }
    final hash = discuzString(fresh.variables['formhash']);
    if (hash.isEmpty || !sameAccount()) throw StateError('account_changed');
    final result = section == 'messages'
        ? await client.request(
            'sendpm',
            {'ac': 'pm', 'op': 'send', 'pmsubmit': 'yes'},
            body: {'formhash': hash, 'touid': id, 'message': text.trim()},
          )
        : await client.request(
            'sendreply',
            {'action': 'reply', 'replysubmit': 'yes', 'usesig': 1},
            body: {
              'fid': fid,
              'tid': tid,
              'formhash': hash,
              'message': text.trim(),
            },
          );
    // Discuz write replies can omit member_uid. Require explicit success and
    // check the local account again without ever repeating a possibly sent POST.
    if (!sameAccount()) throw StateError('account_changed');
    result.requireSuccess({
      section == 'messages' ? 'do_success' : 'post_reply_succeed',
    });
  }
}

Future<T> withWatchReader<T>(
  Discuz site,
  User? user,
  bool Function() sameAccount,
  Future<T> Function(WatchReader) operation,
) async {
  final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
  dio.options.connectTimeout = const Duration(seconds: 8);
  dio.options.receiveTimeout = const Duration(seconds: 10);
  dio.options.sendTimeout = const Duration(seconds: 10);
  try {
    return await operation(
      WatchReader(
        ForumInteractionClient(dio, site.baseURL),
        user?.uid ?? 0,
        sameAccount,
      ),
    );
  } finally {
    dio.close(force: true);
  }
}
