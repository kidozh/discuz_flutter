import '../utility/discuz_json.dart';
import 'ForumInteractionClient.dart';
import 'discuz_web_client.dart';

class PrivateMessageManagement {
  PrivateMessageManagement(this.api, this.uid, this.isCurrent)
    : web = DiscuzWebClient(api);

  final ForumInteractionClient api;
  final DiscuzWebClient web;
  final int uid;
  final bool Function() isCurrent;

  void _checkAccount() {
    if (!isCurrent()) throw const ForumApiException('account_changed', '');
  }

  Future<Set<int>> _unreadConversations() async {
    final conversations = <int>{};
    for (var page = 1; ; page++) {
      _checkAccount();
      final reply = await api.request('mypm', {
        'filter': 'newpm',
        'page': page,
      });
      reply.requireData('list');
      if (discuzInt(reply.variables['member_uid']) != uid) {
        throw const ForumApiException('account_changed', '');
      }
      final list = reply.variables['list'];
      final count = int.tryParse(discuzString(reply.variables['count']));
      final perPage = discuzInt(reply.variables['perpage']);
      if (count == null ||
          count < 0 ||
          perPage <= 0 ||
          (list is! List && list is! Map)) {
        throw const ForumApiException('invalid_response', '');
      }
      for (final item in forumRows(list)) {
        final row = discuzMap(item);
        final id = discuzInt(row['plid']);
        if (id > 0 && discuzPermission(row['isnew']) == true) {
          conversations.add(id);
        }
      }
      if (page * perPage >= count) return conversations;
      if (forumRows(list).isEmpty) {
        throw const ForumApiException('invalid_response', '');
      }
    }
  }

  Uri _action(String op, {Map<String, String> params = const {}}) =>
      web.page('home.php', {
        'mod': 'spacecp',
        'ac': 'pm',
        'op': op,
        'inajax': '1',
        'handlekey': 'disfly_pm',
        ...params,
      });

  Future<Set<int>> markAllRead() async {
    final unread = (await _unreadConversations()).toList();
    if (unread.isEmpty) return {};
    final hash = await web.accountHash(uid);
    for (var start = 0; start < unread.length; start += 50) {
      _checkAccount();
      final response = await web.read(
        _action('setpmstatus'),
        body: {
          'formhash': hash,
          'plids': unread.skip(start).take(50).join(','),
        },
      );
      // Discuz returns a localized message without a stable success key here.
      if (!response.source.contains('errorhandle_disfly_pm(')) {
        throw const ForumApiException('private_message_action_failed', '');
      }
    }
    final remaining = await _unreadConversations();
    if (unread.any(remaining.contains)) {
      throw const ForumApiException('private_message_action_failed', '');
    }
    return unread.toSet();
  }

  Future<void> deleteConversation(int peerUid) async {
    if (peerUid <= 0 || peerUid == uid) {
      throw const ForumApiException('private_message_action_failed', '');
    }
    final hash = await web.accountHash(uid);
    _checkAccount();
    final result = await web.read(
      _action('delete', params: {'deletepm_deluid[]': '$peerUid'}),
      body: {'formhash': hash, 'deletesubmit': '1'},
    );
    if (!result.source.contains(
      "succeedhandle_disfly_pm('home.php?mod=space&do=pm&filter=privatepm'",
    )) {
      web.rejected(result.document, 'private_message_action_failed');
    }
  }
}
