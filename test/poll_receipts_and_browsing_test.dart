import 'package:dio/dio.dart';
import 'package:discuz_flutter/JsonResult/ViewThreadResult.dart';
import 'package:discuz_flutter/client/ForumInteractionClient.dart';
import 'package:discuz_flutter/client/discuz_web_client.dart';
import 'package:discuz_flutter/client/forum_browse.dart';
import 'package:discuz_flutter/client/poll_voters.dart';
import 'package:discuz_flutter/client/thread_post_options.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/utility/poll_vote_store.dart';
import 'package:discuz_flutter/widget/PollWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('vote receipts are scoped by forum, member, and thread', () async {
    SharedPreferences.setMockInitialValues({});
    const store = PollVoteStore();
    const key = (site: 'https://forum.test/bbs', uid: 3, tid: 8);
    expect(await store.save(key, {1, 4}), isTrue);
    expect(await const PollVoteStore().read(key), {1, 4});
    expect(await store.read((site: key.site, uid: 4, tid: 8)), isEmpty);
    expect(await store.read((site: key.site, uid: 3, tid: 9)), isEmpty);
    expect(
      await store.read((site: 'https://another.test', uid: 3, tid: 8)),
      isEmpty,
    );
    expect(await store.save((site: key.site, uid: 0, tid: 8), {1}), isFalse);
  });

  testWidgets(
    'a restored private vote marks the saved options after reopening',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final forum = Discuz(
        'https://forum.test/path',
        'X3.5',
        'utf-8',
        4,
        '1.4.8',
        '',
        false,
        '',
        '',
        'Test forum',
        '',
        '',
        '',
      );
      final first = User('auth', 'salt', 'first', '', 1, 3, 10, forum);
      final other = User('auth2', 'salt2', 'other', '', 1, 4, 10, forum);
      final account = DiscuzAndUserNotifier()..initDiscuz(forum, user: first);
      addTearDown(account.dispose);
      final store = const PollVoteStore();
      await store.save(
        (site: forum.siteIdentity, uid: first.uid, tid: 8),
        {2, 3},
      );
      final poll = Poll.fromJson({
        'allowvote': '0',
        'visiblepoll': '1',
        'multiple': '1',
        'maxchoices': '2',
        'polloptions': [
          for (var id = 1; id <= 3; id++)
            {'polloptionid': '$id', 'polloption': 'Option $id', 'votes': '5'},
        ],
      });
      Future<void> open() async {
        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: account,
            child: MaterialApp(
              localizationsDelegates: const [S.delegate],
              home: Scaffold(
                body: PollWidget(poll, 'hash', 8, 1, forum: forum),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      final marks = find.byWidgetPredicate(
        (widget) => widget is Icon && widget.semanticLabel == 'My choice',
      );
      await open();
      expect(find.text('My vote'), findsNothing);
      expect(find.text('My choice'), findsNothing);
      expect(marks, findsNWidgets(2));
      expect(find.byType(FractionallySizedBox), findsNothing);
      expect(find.text('33.3%'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      await open();
      expect(marks, findsNWidgets(2));
      account.setUser(other);
      await tester.pumpAndSettle();
      expect(marks, findsNothing);
    },
  );

  test(
    'public recovery follows pagination and never accepts a partial vote list',
    () async {
      final requests = <(int, int)>[];
      Future<PollVoterBatch> load(int option, int page) async {
        requests.add((option, page));
        return (
          voters: [if (page == 2 || option == 3) (uid: 7, name: 'Me')],
          next: option == 1 && page == 1 ? 2 : null,
        );
      }

      Future<Set<int>?> recover(int limit) => findOwnPollVote(
        uid: 7,
        options: [1, 2, 3],
        maximumChoices: 2,
        load: load,
        isCurrent: () => true,
        requestLimit: limit,
      );
      expect(await recover(20), {1, 3});
      expect(requests, [(1, 1), (1, 2), (2, 1), (3, 1)]);
      expect(await recover(2), isNull);
    },
  );

  test('forum topic tags use the permitted form and the posted tag limits', () {
    final form = parse('<form><input name="tags"></form>')
        .querySelector('form')!;
    final options = ExtraThreadOptions.fromForm(form);
    expect(options.submission({'tags': '教程，Flutter， 教程'}, DateTime.now()), {
      'tags': '教程,Flutter',
    });
    expect(
      options.submission({'tags': 'aa,bb,cc,dd,ee,ff'}, DateTime.now()),
      isNull,
    );
    expect(options.submission({'tags': '无效/符号'}, DateTime.now()), isNull);
    form.querySelector('input')!.attributes['readonly'] = '';
    expect(ExtraThreadOptions.fromForm(form).available, isEmpty);
  });

  test('forum browse reads the announcement content and same-forum tag links', () async {
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) {
            final body = request.uri.queryParameters['mod'] == 'announcement'
                ? '<ul id="annonav"></ul><div class="umh" id="announce8_c"><h3>Notice <em>(2026-11-22)</em></h3></div><div id="announce8"><p>Reading hours</p></div>'
                : '<div id="postlist"><div class="ptg"><a href="misc.php?mod=tag&amp;id=7">Release</a><a href="https://other.test/misc.php?mod=tag&amp;id=2">Other</a></div></div>';
            handler.resolve(
              Response(requestOptions: request, data: body, statusCode: 200),
            );
          },
        ),
      );
    addTearDown(dio.close);
    final web = DiscuzWebClient(
      ForumInteractionClient(dio, 'https://forum.test'),
    );
    final client = ForumBrowseClient(web);
    final notice = (await client.announcements()).single;
    expect(notice.title, 'Notice');
    expect(notice.date, '(2026-11-22)');
    expect(notice.body, contains('Reading hours'));
    final tag = (await client.tags(8)).single;
    expect(tag.name, 'Release');
    expect(tag.uri.queryParameters, containsPair('type', 'thread'));
  });
}
