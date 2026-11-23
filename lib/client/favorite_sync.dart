import '../utility/discuz_json.dart';
import 'ForumInteractionClient.dart';

/// A partial or changing list cannot establish that a favorite was removed.
Future<Map<int, Map<String, dynamic>>> loadFavoriteSnapshot(
  ForumInteractionClient client, {
  required int uid,
  required bool threads,
  required bool Function() isCurrent,
}) async {
  final rows = <int, Map<String, dynamic>>{};
  int? total;
  for (var page = 1; ; page++) {
    if (!isCurrent()) throw const ForumApiException('account_changed', '');
    final reply = await client.request(threads ? 'myfavthread' : 'myfavforum', {
      'page': page,
    });
    if (!isCurrent() || discuzInt(reply.variables['member_uid']) != uid) {
      if (reply.serverError case final error?) throw error;
      throw const ForumApiException('account_changed', '');
    }
    reply.requireData('list');
    final payload = reply.variables['list'];
    final count = int.tryParse(discuzString(reply.variables['count']));
    if (count == null ||
        count < 0 ||
        (total != null && count != total) ||
        (payload is! List && payload is! Map)) {
      throw const ForumApiException('favorite_sync_incomplete', '');
    }
    total = count;
    final previousLength = rows.length;
    for (final item in forumRows(payload)) {
      final row = discuzMap(item);
      final id = discuzInt(row['id']);
      final owner = discuzInt(row['uid']);
      if (id <= 0 ||
          discuzInt(row['favid']) <= 0 ||
          (owner != 0 && owner != uid) ||
          rows.containsKey(id)) {
        throw const ForumApiException('favorite_sync_incomplete', '');
      }
      rows[id] = row;
    }
    if (rows.length == total) return rows;
    if (rows.length > total || rows.length == previousLength) {
      throw const ForumApiException('favorite_sync_incomplete', '');
    }
  }
}

Future<int> changeServerFavorite(
  ForumInteractionClient client, {
  required int uid,
  required bool threads,
  required int target,
  required bool add,
  required String formhash,
  required bool Function() isCurrent,
}) async {
  if (!isCurrent()) throw const ForumApiException('account_changed', '');
  if (formhash.isEmpty) throw const ForumApiException('missing_formhash', '');
  final module = threads ? 'favthread' : 'favforum';
  final type = threads ? 'thread' : 'forum';
  if (add) {
    final reply = await client.request(
      module,
      {'type': type, 'ac': 'favorite', 'favoritesubmit': 'true'},
      body: {'id': target, 'formhash': formhash},
    );
    if (const {
      'favorite_status_off',
      'module_not_exists',
    }.contains(reply.code)) {
      return -1;
    }
    reply.requireSuccess({
      'favorite_do_success',
      'favorite_repeat',
      'do_success',
    });
    return discuzInt(reply.variables['favid']);
  }

  final rows = await loadFavoriteSnapshot(
    client,
    uid: uid,
    threads: threads,
    isCurrent: isCurrent,
  );
  final favorite = rows[target];
  if (favorite == null) return 0;
  if (!isCurrent()) throw const ForumApiException('account_changed', '');
  final reply = await client.request(
    module,
    {'type': type, 'ac': 'favorite', 'op': 'delete', 'deletesubmit': 'true'},
    body: {'favid': discuzInt(favorite['favid']), 'formhash': formhash},
  );
  reply.requireSuccess({'do_success'});
  return 0;
}
