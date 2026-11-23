import 'package:dio/dio.dart';
import 'package:discuz_flutter/JsonResult/DisplayForumResult.dart';
import 'package:discuz_flutter/client/ForumInteractionClient.dart';
import 'package:discuz_flutter/client/favorite_sync.dart';
import 'package:discuz_flutter/client/private_message_management.dart';
import 'package:discuz_flutter/page/DisplayForumSliverPage.dart';
import 'package:discuz_flutter/page/ModerateThreadPage.dart';
import 'package:flutter_test/flutter_test.dart';

ForumInteractionClient _api(Object Function(RequestOptions) respond) {
  final dio = Dio()
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) {
          handler.resolve(
            Response(
              requestOptions: request,
              statusCode: 200,
              data: respond(request),
            ),
          );
        },
      ),
    );
  addTearDown(dio.close);
  return ForumInteractionClient(dio, 'https://forum.test/bbs/');
}

Map<String, dynamic> _vars(Map<String, dynamic> data, {int uid = 7}) => {
  'Variables': {'member_uid': '$uid', ...data},
};

void main() {
  test('favorites only accept a complete, stable account snapshot', () async {
    var valid = true;
    final api = _api((request) {
      final page = int.parse(request.uri.queryParameters['page']!);
      return _vars({
        'count': '2',
        'list': [
          if (valid || page == 1) {'id': '$page', 'favid': '${page + 20}'},
        ],
      });
    });
    Future<Map<int, Map<String, dynamic>>> load() =>
        loadFavoriteSnapshot(api, uid: 7, threads: true, isCurrent: () => true);
    expect((await load()).keys, [1, 2]);
    valid = false;
    await expectLater(
      load(),
      throwsA(
        isA<ForumApiException>().having(
          (e) => e.code,
          'code',
          'favorite_sync_incomplete',
        ),
      ),
    );
  });

  test('removing a favorite sends the server favorite ID', () async {
    final api = _api((request) {
      final params = request.uri.queryParameters;
      if (params['module'] == 'myfavthread') {
        return _vars({
          'count': '1',
          'list': [
            {'id': '42', 'favid': '931'},
          ],
        });
      }
      expect(params['op'], 'delete');
      expect(request.data, {'favid': 931, 'formhash': 'hash'});
      return {
        'Message': {'messageval': 'do_success'},
      };
    });
    await changeServerFavorite(
      api,
      uid: 7,
      threads: true,
      target: 42,
      add: false,
      formhash: 'hash',
      isCurrent: () => true,
    );
  });

  test('board classification accepts the empty PHP arrays used by Discuz', () {
    final category = ThreadType.fromJson({
      'required': '',
      'listable': '1',
      'prefix': '1',
      'types': {'405': 'QA Support'},
      'icons': [],
      'moderators': [],
    });
    expect(category.idNameMap, {'405': 'QA Support'});
    expect(category.idIconMap, isEmpty);
    expect(category.idModeratorMap, isEmpty);
    expect(category.typeRequired(), isFalse);
    expect(
      ThreadType.fromJson(category.toJson()).idNameMap,
      category.idNameMap,
    );
  });

  test('board queries combine category, active window, and reward status', () {
    final query = DisplayForumQuery()
      ..setTypeId(3, true)
      ..setDateline(86400, true)
      ..setSpecialType('reward', true)
      ..rewardStatus = 2;
    expect(query.generateForumQueriesMap(), containsPair('typeid', '3'));
    expect(query.generateForumQueriesMap(), containsPair('dateline', '86400'));
    expect(
      query.generateForumQueriesMap(),
      containsPair('specialtype', 'reward'),
    );
    expect(query.generateForumQueriesMap(), containsPair('rewardtype', '2'));
    query.setSpecialType('poll', true);
    expect(query.generateForumQueriesMap().containsKey('rewardtype'), false);
    query.setHot(true);
    expect(query.generateForumQueriesMap(), {'filter': 'hot'});
  });

  test(
    'personal comments keep their post ID and profile lookups stay scoped',
    () async {
      final requests = <RequestOptions>[];
      final api = _api((request) {
        requests.add(request);
        final query = request.uri.queryParameters;
        if (query['module'] == 'mythread') {
          return _vars({
            'data': [
              {'tid': '53', 'pid': '96', 'comment': 'Thanks'},
            ],
          });
        }
        return _vars({
          'profiles': [
            {'uid': '1', 'username': 'Forum user'},
            {'uid': '99', 'username': 'Unrequested user'},
          ],
        });
      });
      final comments = await api.myThreads('postcomment', 1, uid: 7);
      expect(comments.single['pid'], '96');
      expect(requests.single.uri.queryParameters['type'], 'postcomment');
      await api.myThreads('thread', 1, filter: 'aduit', uid: 7);
      expect(requests.last.uri.queryParameters['filter'], 'aduit');
      expect(
        await api.profileNames({
          for (var uid = 1; uid <= 31; uid++) uid,
        }, uid: 7),
        {1: 'Forum user'},
      );
      final lookups = requests.where(
        (r) => r.uri.queryParameters['module'] == 'profiles',
      );
      expect(
        lookups.map((r) => r.uri.queryParameters['uids']!.split(',').length),
        [30, 1],
      );
    },
  );

  test('batch moderation rejects a topic from another board', () async {
    final api = _api(
      (_) => _vars({
        'ismoderator': '1',
        'fid': '8',
        'formhash': 'hash',
        'thread': {'tid': '53'},
      }),
    );
    final allowed = await loadModerationScope(
      api,
      tid: 53,
      uid: 7,
      expectedForum: 8,
    );
    expect(allowed.fid, 8);
    await expectLater(
      loadModerationScope(api, tid: 53, uid: 7, expectedForum: 9),
      throwsA(isA<ForumApiException>()),
    );
    expect(
      moderationFields('type', 'reason', type: '5'),
      containsPair('typeid', '5'),
    );
  });

  test('mark all read checks the unread list after sending the forum action', () async {
    var acted = false;
    final api = _api((request) {
      final query = request.uri.queryParameters;
      if (query['module'] == 'mypm') {
        return _vars({
          'count': acted ? '0' : '1',
          'perpage': '15',
          'list': [
            if (!acted) {'plid': '18', 'isnew': '1'},
          ],
        });
      }
      if (query['module'] == 'profile') return _vars({'formhash': 'hash'});
      expect(query['op'], 'setpmstatus');
      expect(request.uri.path, '/bbs/home.php');
      expect(request.data, {'formhash': 'hash', 'plids': '18'});
      acted = true;
      return '<root><![CDATA[<script>errorhandle_disfly_pm("ok", {});</script>]]></root>';
    });
    final marked = await PrivateMessageManagement(
      api,
      7,
      () => true,
    ).markAllRead();
    expect(marked, {18});
  });

  test(
    'conversation removal requires a positively acknowledged callback',
    () async {
      var allowed = false;
      final api = _api((request) {
        final query = request.uri.queryParameters;
        if (query['module'] == 'profile') return _vars({'formhash': 'hash'});
        expect(query['deletepm_deluid[]'], '18');
        expect(request.data, {'deletesubmit': '1', 'formhash': 'hash'});
        return allowed
            ? "<root><![CDATA[<script>succeedhandle_disfly_pm('home.php?mod=space&do=pm&filter=privatepm', 'done', {});</script>]]></root>"
            : '<p>Permission denied</p>';
      });
      final management = PrivateMessageManagement(api, 7, () => true);
      await expectLater(
        management.deleteConversation(18),
        throwsA(isA<ForumApiException>()),
      );
      allowed = true;
      await management.deleteConversation(18);
    },
  );
}
