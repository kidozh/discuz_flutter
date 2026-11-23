import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/client/ForumInteractionClient.dart';
import 'package:discuz_flutter/client/discuz_web_client.dart';
import 'package:discuz_flutter/client/forum_site_features.dart';
import 'package:discuz_flutter/client/paid_post.dart';
import 'package:discuz_flutter/client/poll_voters.dart';
import 'package:discuz_flutter/entity/PollDraft.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart';

void main() {
  test(
    'pricing uses server permission, currency, limits and seller rounding',
    () {
      final form = parse('''
      <form id="postform">
        <input name="formhash" value="place-holder">
        <div id="extra_price_c">
          <input id="price" name="price"> coins
          <span class="xg1">(Maximum 30 coins)</span>
        </div>
        <table><tr><td class="attp">Gold</td></tr></table>
      </form>
      <script>var creditstax = 0.2;</script>
    ''').querySelector('form')!;
      final rules = PaidPostRules.parse(form)!;
      expect(rules.maximum, 30);
      expect(rules.unit, 'coins');
      expect(rules.threadNet(2), 1);
      expect(rules.fileNet(2), 2);
      expect(rules.accepts(const PaidPostDraft(thread: 1)), isFalse);
      expect(rules.accepts(const PaidPostDraft(thread: 31)), isFalse);
      expect(
        rules.accepts(const PaidPostDraft(thread: 7, files: {'token': 3})),
        isTrue,
      );
      form.querySelector('input[name=price]')!.attributes['disabled'] = '';
      expect(PaidPostRules.parse(form), isNull);
    },
  );

  test('draft file prices restore by local token and submit only for matching uploads', () {
    const draft = PaidPostDraft(thread: 7, files: {'kept': 3, 'removed': 4});
    final restored = PaidPostDraft.restore(
      jsonEncode({'paid': draft.toJson()}),
    );
    final effective = restored.retainFiles({'kept'});
    expect(effective.submission({'kept': 32, 'free': 43}), {
      'price': '7',
      'attachnew[32][price]': '3',
    });
    expect(() => effective.submission({'removed': 32}), throwsFormatException);
  });

  test(
    'poll participation is private by default and the author can opt in',
    () {
      final legacy = PollDraft.decode(
        '{"options":["A","B"],"maxChoices":1,"days":7}',
      )!;
      expect(legacy.fields['overt'], '0');
      const public = PollDraft(
        ['A', 'B'],
        1,
        7,
        hideResults: true,
        publicVoters: true,
      );
      final restored = PollDraft.decode(public.encode())!;
      expect(restored.fields['overt'], '1');
      expect(restored.fields['visibilitypoll'], '1');
    },
  );

  test(
    'poll voter rows and pagination come from the requested option',
    () async {
      var renderedOption = '99';
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (request, handler) {
              expect(request.uri.path, '/bbs/forum.php');
              expect(request.uri.queryParameters['polloptionid'], '99');
              handler.resolve(
                Response(
                  requestOptions: request,
                  statusCode: 200,
                  data:
                      '''
          <div>
            <div class="voterlist">
              <select><option value="$renderedOption" selected>A</option></select>
              <ul class="voterl">
                <li><a href="home.php?mod=space&amp;uid=4">A user</a></li>
                <li><a href="https://outside.test/home.php?mod=space&amp;uid=18">Outside</a></li>
              </ul>
            </div>
            <div class="pg"><a class="nxt" href="forum.php?mod=misc&amp;action=viewvote&amp;tid=20&amp;polloptionid=99&amp;page=2">Next</a></div>
          </div>
        ''',
                ),
              );
            },
          ),
        );
      addTearDown(dio.close);
      final client = PollVotersClient(
        DiscuzWebClient(ForumInteractionClient(dio, 'https://forum.test/bbs')),
      );
      final result = await client.load(20, 99, 1);
      expect(result.voters, [(uid: 4, name: 'A user')]);
      expect(result.next, 2);
      renderedOption = '14';
      await expectLater(
        client.load(20, 99, 1),
        throwsA(isA<ForumApiException>()),
      );
    },
  );

  test('optional forum menu links require same-forum navigation and an enabled page', () {
    final api = ForumInteractionClient(Dio(), 'https://forum.test/bbs');
    addTearDown(api.dio.close);
    final web = DiscuzWebClient(api);
    const collections = ForumSiteFeature.collections;
    final uri = web.page(collections.file, collections.query);
    bool allowed(String content) =>
        collections.available(web, uri, parse(content));
    expect(
      allowed(
        '<div id="ct"><a href="forum.php?mod=collection&amp;op=all">All</a></div>',
      ),
      isTrue,
    );
    expect(
      allowed(
        '<div id="ct"><a href="https://other.test/bbs/forum.php?mod=collection&amp;op=all">Outside</a></div>',
      ),
      isFalse,
    );
    expect(allowed('<div id="messagetext">Feature is disabled</div>'), isFalse);
  });
}
