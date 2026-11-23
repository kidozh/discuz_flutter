import 'package:dio/dio.dart';
import 'package:discuz_flutter/client/ForumInteractionClient.dart';
import 'package:discuz_flutter/client/discuz_web_client.dart';
import 'package:discuz_flutter/client/forum_community.dart';
import 'package:flutter_test/flutter_test.dart';

ForumCommunityClient _client(Object Function(RequestOptions) respond) {
  final dio = Dio()
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) => handler.resolve(
          Response(
            requestOptions: request,
            statusCode: 200,
            data: respond(request),
          ),
        ),
      ),
    );
  addTearDown(dio.close);
  return ForumCommunityClient(
    DiscuzWebClient(ForumInteractionClient(dio, 'https://forum.test/bbs/')),
  );
}

const _groupForm = '''
<div id="ct">
  <div class="mn">
    <div id="gh"><h1>Private group</h1></div>
    <form id="groupjoinform_13" action="forum.php?mod=group&action=join&fid=13" method="post">
      <input type="hidden" name="formhash" value="test-hash">
      <input type="hidden" name="groupjoin" value="1">
    </form>
  </div>
</div>
''';

const _profile = {
  'Variables': {'member_uid': '7', 'formhash': 'test-hash'},
};

const _groupSearchForm = '''
<div id="ct">
  <form class="searchform" method="post" action="search.php?mod=group">
    <input type="hidden" name="formhash" value="test-hash">
  </form>
</div>
''';

void main() {
  test(
    'my activities keeps organized and registered lists and paging separate',
    () async {
      final client = _client((request) {
        expect(request.uri.path, '/bbs/home.php');
        expect(request.uri.queryParameters['uid'], '7');
        expect(request.uri.queryParameters['type'], 'apply');
        return """
<div id="ct"><div class="mn">
  <ul class="tb"><li><a href="home.php?mod=space&do=activity&view=me">Activities</a></li></ul>
  <table class="acl">
    <caption><h3><span>3</span>2030-03-05<br /><cite>Tuesday</cite></h3></caption>
    <tr><td><h4><a href="forum.php?mod=viewthread&tid=51">Trail walk</a></h4></td>
      <td class="addr"><strong>Outdoors</strong><br>Hilltop<br><strong>Three signed up</strong></td>
    </tr>
  </table>
  <div class="pg"><a class="nxt" href="home.php?mod=space&uid=7&do=activity&view=me&type=apply&page=2">Next</a></div>
</div></div>
""";
      });
      final list = await client.load(CommunitySection.myActivities, {
        'uid': '7',
        'type': 'apply',
      });
      expect(list.items.single.id, 51);
      expect(list.items.single.title, 'Trail walk');
      expect(
        list.items.single.detail,
        '2030-03-05 · Outdoors · Hilltop · Three signed up',
      );
      expect(list.next?.queryParameters['page'], '2');
      await expectLater(
        client.load(CommunitySection.myActivities, {
          'uid': '7',
          'type': 'orig',
        }, next: list.next),
        throwsA(isA<ForumApiException>()),
      );
    },
  );

  test('my activities rejects a generic or signed-out space page', () async {
    final client = _client(
      (_) => '<div id="ct"><div class="mn">Guest</div></div>',
    );
    await expectLater(
      client.load(CommunitySection.myActivities, {'uid': '7', 'type': 'orig'}),
      throwsA(isA<ForumApiException>()),
    );
  });

  test('group search loads the form before submitting the keyword once', () async {
    final methods = <String>[];
    final client = _client((request) {
      methods.add(request.method);
      expect(request.uri.path, '/bbs/search.php');
      expect(request.uri.queryParameters, {'mod': 'group', 'mobile': 'no'});
      if (request.method == 'GET') {
        expect(request.data, isNull);
        return _groupSearchForm;
      }
      expect(request.data, {
        'formhash': 'test-hash',
        'srchtxt': 'Photography',
        'searchsubmit': 'yes',
      });
      return '<div id="ct"><a href="forum.php?mod=group&fid=13">Photography</a></div>';
    });

    final result = await client.load(
      CommunitySection.groupSearch,
      const {},
      keyword: 'Photography',
    );
    expect(result.items.single.id, 13);
    expect(methods, ['GET', 'POST']);
  });

  test('group search leaves verification to the forum form', () async {
    final client = _client((request) {
      expect(request.method, 'GET');
      expect(request.uri.queryParameters['searchsubmit'], isNull);
      return _groupSearchForm.replaceFirst(
        '</form>',
        '<input name="seccodeverify"></form>',
      );
    });
    await expectLater(
      client.load(CommunitySection.groupSearch, const {}, keyword: 'camera'),
      throwsA(
        isA<ForumApiException>().having(
          (error) => error.code,
          'code',
          'forum_search_captcha',
        ),
      ),
    );
  });

  test('moderators can approve a request listed on a later page', () async {
    final requests = <String>[];
    var approved = false;
    final client = _client((request) {
      final args = request.uri.queryParameters;
      if (args['module'] == 'profile') return _profile;
      if (request.method == 'POST') {
        expect(args['uid'], '8');
        expect(args['checktype'], '1');
        expect(request.data, {'formhash': 'test-hash'});
        requests.add('POST');
        approved = true;
        return "succeedhandle_disfly_community('forum.php?mod=group&fid=13')";
      }
      expect(args['uid'], isNull);
      expect(args['mobile'], 'no');
      final page = args['page'] ?? '1';
      requests.add(page);
      if (page == '1') {
        return '''
<div id="ct"><div class="pg">
  <a class="nxt" href="forum.php?mod=group&action=manage&op=checkuser&fid=13&page=2">Next</a>
</div></div>''';
      }
      return '''
<div id="ct"><div class="mn"><dl>
  ${approved ? '' : '<dt><a href="home.php?mod=space&uid=8">Guest</a></dt>'}
</dl></div></div>''';
    });
    await client.reviewGroup(7, 13, 8, true, () => true);
    expect(requests, ['1', '2', 'POST', '1', '2']);
  });

  test('membership pagination accepts only list links', () async {
    final client = _client((request) {
      expect(request.method, 'GET');
      expect(request.uri.queryParameters['uid'], isNull);
      return '''
<div id="ct"><div class="pg">
  <a class="nxt" href="forum.php?mod=group&action=manage&op=checkuser&fid=13&page=2&uid=8">Next</a>
</div></div>''';
    });
    final page = await client.load(CommunitySection.groupRequests, {
      'fid': '13',
    });
    expect(page.next, isNull);
  });

  test(
    'directory deduplicates IDs and rejects out-of-installation links',
    () async {
      final client = _client(
        (_) => '''
      <div id="ct">
        <a href="forum.php?mod=group&fid=13">Photography</a>
        <a href="forum.php?mod=group&fid=13&extra=popular">Duplicate</a>
        <a href="/forum.php?mod=group&fid=14">Different installation</a>
        <a href="https://other.test/bbs/forum.php?mod=group&fid=15">Another host</a>
        <div class="pg"><a class="nxt" href="group.php?mod=index&page=2">Next</a></div>
      </div>
      ''',
      );
      final page = await client.load(CommunitySection.groups, const {});
      expect(page.items.map((item) => item.id), [13]);
      expect(
        page.next.toString(),
        'https://forum.test/bbs/group.php?mod=index&page=2',
      );
    },
  );

  test(
    'a successful join response is checked against current membership',
    () async {
      var posted = false;
      final client = _client((request) {
        final args = request.uri.queryParameters;
        if (args['module'] == 'profile') return _profile;
        if (request.method == 'POST') {
          expect(args['fid'], '13');
          expect(request.data, {'formhash': 'test-hash', 'groupjoin': '1'});
          posted = true;
          return "succeedhandle_disfly_community('forum.php?mod=group&fid=13')";
        }
        return _groupForm;
      });
      await expectLater(
        client.changeGroup(7, 13, true, () => true),
        throwsA(isA<ForumApiException>()),
      );
      expect(posted, true);
    },
  );

  test(
    'account changes prevent submitting even after the form was loaded',
    () async {
      final client = _client((request) {
        expect(request.method, 'GET');
        if (request.uri.queryParameters['module'] == 'profile') return _profile;
        return _groupForm;
      });
      await expectLater(
        client.changeGroup(7, 13, true, () => false),
        throwsA(
          isA<ForumApiException>().having(
            (error) => error.code,
            'code',
            'account_changed',
          ),
        ),
      );
    },
  );

  test(
    'friend acceptance uses the server form and cannot turn into sending',
    () async {
      var posted = false;
      final client = _client((request) {
        if (request.uri.queryParameters['module'] == 'profile') return _profile;
        if (request.method == 'POST') posted = true;
        return '''
        <form action="home.php?mod=spacecp&ac=friend&op=add&uid=8" method="post">
          <input name="formhash" value="test-hash">
          <input name="addsubmit" value="true">
        </form>
        ''';
      });
      await expectLater(
        client.friend(7, 8, accept: true, current: () => true),
        throwsA(isA<ForumApiException>()),
      );
      expect(posted, false);
    },
  );
}
