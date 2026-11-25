import 'package:dio/dio.dart';
import 'package:discuz_flutter/client/ForumInteractionClient.dart';
import 'package:discuz_flutter/client/discuz_web_client.dart';
import 'package:discuz_flutter/client/forum_settings_forms.dart';
import 'package:discuz_flutter/client/forum_web_content.dart';
import 'package:flutter_test/flutter_test.dart';

DiscuzWebClient _web(Object Function(RequestOptions) respond) {
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
  return DiscuzWebClient(
    ForumInteractionClient(dio, 'https://forum.test/bbs/'),
  );
}

void main() {
  test('member replies retain the topic title and each post ID', () async {
    final client = ForumWebContentClient(
      _web((request) {
        expect(request.uri.queryParameters['uid'], '7');
        return '''
<div id="ct"><div class="mn"><div class="tl"><table>
<tr><th><a href="forum.php?mod=redirect&goto=findpost&ptid=12&pid=">Weekend walk</a></th>
<td><a href="forum.php?mod=forumdisplay&fid=3">Outdoors</a></td></tr>
<tr><td colspan="5"><a href="forum.php?mod=redirect&goto=findpost&ptid=12&pid=101">Meet at eight</a></td></tr>
<tr><td colspan="5"><a href="forum.php?mod=redirect&goto=findpost&ptid=12&pid=102">Bring a map</a></td></tr>
</table></div><div class="pg"><a class="nxt" href="home.php?mod=space&amp;do=thread&amp;view=me&amp;uid=8&amp;from=space&amp;type=reply&amp;page=2">Next</a></div></div></div>
''';
      }),
    );
    const kind = ForumContentKind.memberReplies;
    final result = await client.read(kind, client.target(kind, id: 7));
    expect(result.items.map((row) => row.thread?.pid), [101, 102]);
    expect(result.items.map((row) => row.title), everyElement('Weekend walk'));
    expect(result.items.map((row) => row.detail), [
      'Meet at eight',
      'Bring a map',
    ]);
    expect(result.next, isNull);
  });

  test(
    'featured debates and standard rows coexist without duplicate topics',
    () async {
      final client = ForumWebContentClient(
        _web(
          (_) => '''
<div id="ct"><div class="mn">
  <div class="ds"><h3><a href="forum.php?mod=viewthread&tid=4">City park</a></h3>
  <table><tr><td class="si_1"><strong>For (2)</strong></td><td class="si_2"><strong>Against (1)</strong></td></tr></table></div>
  <div class="tl"><table><tr><th><a href="forum.php?mod=viewthread&tid=5">City trees</a></th><td>Open</td></tr>
  <tr><th><a href="forum.php?mod=viewthread&tid=4">City park</a></th></tr></table></div>
</div></div>
''',
        ),
      );
      const kind = ForumContentKind.debates;
      final result = await client.read(
        kind,
        client.target(kind, id: 7, filter: 'orig'),
      );
      expect(result.items.map((row) => row.thread?.tid), [4, 5]);
      expect(result.items.first.detail, 'For (2) · Against (1)');
    },
  );

  test(
    'trade records keep status and amounts while deduplicating order links',
    () async {
      final client = ForumWebContentClient(
        _web(
          (_) => '''
<div id="ct"><div class="mn"><table id="list_trade_selles">
<tr><td>Goods</td><td></td></tr><tbody><tr><td></td>
<td><a href="forum.php?mod=trade&orderid=123">Camera</a></td>
<td>Seller</td><td>120.00</td><td><cite><a href="forum.php?mod=trade&orderid=123">Pending</a></cite></td>
</tr></tbody></table></div></div>
''',
        ),
      );
      const kind = ForumContentKind.trades;
      final result = await client.read(
        kind,
        client.target(kind, id: 7, filter: 'buy'),
      );
      expect(result.items.single.title, 'Camera');
      expect(result.items.single.detail, 'Seller · 120.00 · Pending');
    },
  );

  test(
    'article body drops executable markup and identifies related articles',
    () async {
      final client = ForumWebContentClient(
        _web(
          (_) => '''
<div id="ct"><div class="mn"><div class="vw">
<div class="h"><h1 class="ph">Town news</h1></div>
<table><tr><td id="article_content">
<script>window.alert(1)</script><img src="data/attachment/pic.jpg" onload="alert(1)">
<a href="javascript:alert(1)">No external action</a><p>Body</p>
</td></tr></table>
<div id="related_article"><ul><li><a href="article-26-1.html">Town plans</a></li></ul></div>
</div></div></div>
''',
        ),
      );
      const kind = ForumContentKind.article;
      final result = await client.read(kind, client.target(kind, id: 25));
      expect(
        result.body,
        contains('https://forum.test/bbs/data/attachment/pic.jpg'),
      );
      expect(result.body, isNot(contains('alert(1)')));
      expect(result.relatedArticles.single.article, 26);
    },
  );

  test('settings refuse a form token from a different login', () async {
    final client = ForumSettingsClient(
      _web((request) {
        if (request.uri.path.endsWith('index.php')) {
          return {
            'Variables': {
              'member_uid': '7',
              'formhash': 'test-cookie-formhash',
            },
          };
        }
        return '''
<form name="manage" method="post" action="forum.php?mod=group&action=manage&op=group&fid=3">
<input type="hidden" name="formhash" value="different-token">
</form>
''';
      }),
      7,
    );
    await expectLater(
      client.load(ForumSettingsKind.group, 3, 'base'),
      throwsA(
        isA<ForumApiException>().having(
          (e) => e.code,
          'code',
          'account_changed',
        ),
      ),
    );
  });
}
