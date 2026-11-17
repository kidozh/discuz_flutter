import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/JsonResult/UserProfileResult.dart';
import 'package:discuz_flutter/client/ForumInteractionClient.dart';
import 'package:discuz_flutter/client/discuz_web_client.dart';
import 'package:discuz_flutter/client/forum_web_features.dart';
import 'package:discuz_flutter/entity/Post.dart';
import 'package:discuz_flutter/utility/reply_draft_store.dart';
import 'package:flutter_test/flutter_test.dart';

String searchForm({bool fullText = true}) =>
    '''
<form class="searchform"><p>Each search costs 2 coins</p></form>
<form action="search.php?mod=forum"><input name="formhash" value="fresh">
<input name="srchuname">${fullText ? '<input name="srchtype" value="fulltext">' : ''}
<select name="srchfrom"><option value="0">Any time</option><option value="604800">7 days</option></select>
<select name="orderby"><option value="lastpost">Last reply</option><option value="dateline">Posted</option></select>
<select name="orderby" disabled><option value="price">Price</option></select></form>''';

void main() {
  test(
    'advanced search checks the form and sends all selected conditions once',
    () async {
      final requests = <RequestOptions>[];
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (request, handler) {
              requests.add(request);
              handler.resolve(
                Response(
                  requestOptions: request,
                  statusCode: 200,
                  data: request.method == 'GET'
                      ? searchForm()
                      : '<div class="tl"><p class="emp">No results</p></div>',
                ),
              );
            },
          ),
        );
      addTearDown(dio.close);
      final client = ForumSearchClient(
        DiscuzWebClient(ForumInteractionClient(dio, 'https://forum.test/sub')),
      );
      const options = ForumSearchOptions(
        author: 'Alice',
        fullText: true,
        since: '604800',
        order: 'dateline',
        ascending: true,
        older: true,
      );
      expect(
        (await client.search('needle', 7, options: options)).hits,
        isEmpty,
      );
      expect(requests.length, 2);
      expect(requests.first.method, 'GET');
      expect(requests.last.data, {
        'searchsubmit': 'yes',
        'formhash': 'fresh',
        'srchtxt': 'needle',
        'srchfid': '7',
        ...options.fields,
      });
      final uri = ForumSearchClient.website(
        client.web.base,
        'needle',
        7,
        options: options,
      );
      expect(uri.path, '/sub/search.php');
      for (final field in options.fields.entries) {
        expect(uri.queryParameters[field.key], field.value);
      }
      expect(uri.queryParameters['searchsubmit'], isNull);
    },
  );

  test(
    'search results keep title, excerpt, stats and attribution separate',
    () async {
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (request, handler) => handler.resolve(
              Response(
                requestOptions: request,
                statusCode: 200,
                data: request.method == 'GET'
                    ? searchForm()
                    : '''
<div id="threadlist"><ul><li class="pbw">
<h3><a href="forum.php?mod=viewthread&amp;tid=42">A <strong>matching</strong> title</a></h3>
<p>3 replies - 20 views</p><p>Body excerpt about matching words.</p>
<p><span>2026-11-17</span> - <span><a href="home.php?mod=space&amp;uid=3">Alice</a></span>
- <span><a href="forum.php?mod=forumdisplay&amp;fid=2">Help</a></span></p>
</li></ul></div>''',
              ),
            ),
          ),
        );
      addTearDown(dio.close);
      final client = ForumSearchClient(
        DiscuzWebClient(ForumInteractionClient(dio, 'https://forum.test')),
      );
      final hit = (await client.search('matching', null)).hits.single;
      expect(hit.title, 'A matching title');
      expect(hit.excerpt, 'Body excerpt about matching words.');
      expect(hit.attribution, '2026-11-17 · Alice');
      expect(hit.board, 'Help');
      expect(hit.details, '3 replies - 20 views');
      expect(hit.tid, 42);
    },
  );

  test(
    'revoked full-text permission never silently searches titles or submits',
    () async {
      var calls = 0;
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (request, handler) {
              calls++;
              expect(request.method, 'GET');
              handler.resolve(
                Response(
                  requestOptions: request,
                  statusCode: 200,
                  data: searchForm(fullText: false),
                ),
              );
            },
          ),
        );
      addTearDown(dio.close);
      final client = ForumSearchClient(
        DiscuzWebClient(ForumInteractionClient(dio, 'https://forum.test')),
      );
      await expectLater(
        client.search(
          'body',
          null,
          options: const ForumSearchOptions(fullText: true),
        ),
        throwsA(
          isA<ForumApiException>().having(
            (e) => e.fromForum,
            'forum error',
            true,
          ),
        ),
      );
      expect(calls, 1);
    },
  );

  test('pagination uses server search ID without creating another paid search', () async {
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) {
            expect(request.method, 'GET');
            expect(request.uri.queryParameters['searchid'], '12');
            expect(request.data, isNull);
            handler.resolve(
              Response(
                requestOptions: request,
                statusCode: 200,
                data:
                    '<div class="tl"><p class="emp">No more results</p></div>',
              ),
            );
          },
        ),
      );
    addTearDown(dio.close);
    final client = ForumSearchClient(
      DiscuzWebClient(ForumInteractionClient(dio, 'https://forum.test')),
    );
    await client.search(
      'needle',
      null,
      next: Uri.parse(
        'https://forum.test/search.php?mod=forum&searchid=12&page=2',
      ),
    );
  });

  test(
    'draft discovery preserves account, site, quote and durable voice bytes',
    () async {
      final root = await Directory.systemTemp.createTemp('draft-inbox-test');
      addTearDown(() => root.delete(recursive: true));
      final first = ReplyDraftStore(
        'https://forum.test/a',
        3,
        9,
        title: 'Saved topic',
        root: () async => root,
      );
      final voice = await first.add(
        name: 'recording.mp3',
        bytes: Stream.value([73, 68, 51, 4]),
        image: false,
      );
      final quote = Post()
        ..pid = 14
        ..tid = 9
        ..author = 'Alice'
        ..message = 'Quoted text'
        ..publishAt = DateTime.now();
      await first.write(
        ReplyDraft(
          text: 'Body ${voice.token}',
          quote: quote,
          attachments: [voice],
        ),
      );
      await ReplyDraftStore(
        'https://forum.test/a',
        4,
        9,
        root: () async => root,
      ).write(const ReplyDraft(text: 'Other account'));
      await ReplyDraftStore(
        'https://forum.test/b',
        3,
        9,
        root: () async => root,
      ).write(const ReplyDraft(text: 'Other install'));
      expect(await ReplyDraftStore.indexedAccounts(root: () async => root), {
        'https://forum.test/a': {3, 4},
        'https://forum.test/b': {3},
      });
      final rows = await ReplyDraftStore.listFor(
        'https://forum.test/a',
        3,
        root: () async => root,
      );
      expect(rows, hasLength(1));
      expect(rows.single.title, 'Saved topic');
      expect(rows.single.draft.quote?.pid, 14);
      final reopened = ReplyDraftStore(
        rows.single.site,
        rows.single.uid,
        rows.single.tid,
        root: () async => root,
      );
      expect(
        await (await reopened.file(rows.single.draft.attachments.single))
            .readAsBytes(),
        [73, 68, 51, 4],
      );
      await reopened.delete();
      expect(
        await ReplyDraftStore.listFor(
          'https://forum.test/a',
          3,
          root: () async => root,
        ),
        isEmpty,
      );
      expect(
        await ReplyDraftStore.listFor(
          'https://forum.test/a',
          4,
          root: () async => root,
        ),
        hasLength(1),
      );
    },
  );

  test(
    'legacy reply drafts are found by known thread hashes without reassignment',
    () async {
      final root = await Directory.systemTemp.createTemp('draft-legacy-test');
      addTearDown(() => root.delete(recursive: true));
      final store = ReplyDraftStore(
        'https://forum.test',
        3,
        9,
        root: () async => root,
      );
      await store.write(const ReplyDraft(text: 'Legacy'));
      final record =
          await root
                  .list(recursive: true)
                  .where((f) => f.path.endsWith('draft.json'))
                  .first
              as File;
      await record.writeAsString(
        jsonEncode(const ReplyDraft(text: 'Legacy').toJson()),
      );
      final rows = await ReplyDraftStore.listFor(
        'https://forum.test',
        3,
        knownThreads: {9: 'Old topic'},
        root: () async => root,
      );
      expect(rows.single.title, 'Old topic');
      expect(
        await ReplyDraftStore.listFor(
          'https://forum.test',
          4,
          knownThreads: {9: 'Old topic'},
          root: () async => root,
        ),
        isEmpty,
      );
    },
  );

  test(
    'upgrade uses only valid forum values and hides non-upgradable groups',
    () {
      Map<String, dynamic> data({
        String type = 'member',
        Object? percent = '34',
        Object? remaining = '66',
        int ceiling = 100,
      }) => {
        'group': {'type': type, 'creditslower': '$ceiling'},
        'upgradecredit': remaining,
        'upgradeprogress': percent,
      };
      final profile = SpaceVariables.fromJson(data());
      expect(profile.upgrade?.remaining, 66);
      expect(profile.upgrade?.percent, 34);
      for (final invalid in [
        data(type: 'special'),
        data(type: 'system'),
        data(percent: null),
        data(remaining: null),
        data(percent: '101'),
        data(remaining: '-1'),
        data(ceiling: 999999999),
      ]) {
        expect(SpaceVariables.fromJson(invalid).upgrade, isNull);
      }
      expect(
        SpaceVariables.fromJson(data(percent: 100, remaining: 0))
            .upgrade
            ?.remaining,
        0,
      );
    },
  );
}
