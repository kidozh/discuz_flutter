import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:discuz_flutter/client/ForumInteractionClient.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/entity/Post.dart';
import 'package:discuz_flutter/JsonResult/ViewThreadResult.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/widget/ForumInteractionWidgets.dart';
import 'package:discuz_flutter/page/ForumListsPage.dart';
import 'package:discuz_flutter/widget/PostCommentWidget.dart';
import 'package:discuz_flutter/converter/ViewThreadCommentConverter.dart';

Map<String, dynamic> quote({int price = 5, int balance = 15}) => {
  'price': '$price',
  'balance': '$balance',
  'credit': {'title': 'Credits', 'unit': 'points'},
  'formhash': 'csrf',
  'filename': 'file.zip',
};
Dio fakeDio(
  Object Function(RequestOptions) response,
  List<RequestOptions> requests,
) => Dio()
  ..interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        requests.add(options);
        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: response(options),
          ),
        );
      },
    ),
  );
void main() {
  test('quote preserves after-purchase balance and rejects invalid prices', () {
    final value = PurchaseQuote.fromJson(quote());
    expect(value.price, 5);
    expect(value.balance, 15);
    expect(value.sameTerms(PurchaseQuote.fromJson(quote(price: 6))), false);
    expect(
      () => PurchaseQuote.fromJson(quote(price: 0)),
      throwsA(isA<ForumApiException>()),
    );
    expect(
      () => PurchaseQuote.fromJson({...quote(), 'balance': 'unknown'}),
      throwsA(isA<ForumApiException>()),
    );
  });
  test(
    'purchase and recommendation use proper modules, CSRF and explicit success codes',
    () async {
      final requests = <RequestOptions>[];
      final dio = fakeDio(
        (o) => o.method == 'GET'
            ? {'Variables': quote()}
            : {
                'Message': {
                  'messageval':
                      o.uri.queryParameters['module'] == 'threadrecommend'
                      ? 'recommend_succeed'
                      : 'attachment_mobile_buy',
                },
              },
        requests,
      );
      final client = ForumInteractionClient(dio, 'https://forum.test/bbs/');
      final value = await client.quote(10, aid: 20);
      expect(requests.single.method, 'GET');
      await client.purchase(10, value, aid: 20);
      expect(requests.last.uri.path, '/bbs/api/mobile/index.php');
      expect(requests.last.uri.queryParameters['aid'], '20');
      expect(requests.last.data, {'paysubmit': 'yes', 'formhash': 'csrf'});
      expect(requests.last.data.containsKey('buyall'), false);
      await client.recommend(10, 'hash');
      expect(requests.last.method, 'POST');
      expect(requests.last.uri.queryParameters['hash'], 'hash');
      expect(requests.last.uri.queryParameters['do'], 'add');
      dio.close();
    },
  );
  test(
    'error and malformed responses never report mutation success or retry',
    () async {
      for (final code in [
        '',
        'recommend_duplicate',
        'credits_balance_insufficient',
        'undefined_action',
      ]) {
        final requests = <RequestOptions>[];
        final dio = fakeDio(
          (_) => {
            'Message': {'messageval': code},
          },
          requests,
        );
        final client = ForumInteractionClient(dio, 'https://forum.test');
        await expectLater(
          client.recommend(1, 'hash'),
          throwsA(isA<ForumApiException>()),
        );
        expect(requests.length, 1);
        dio.close();
      }
    },
  );
  test(
    'numeric-key thread lists and nested comments preserve server contract',
    () async {
      final requests = <RequestOptions>[];
      final dio = fakeDio(
        (o) => {
          'Variables': o.uri.queryParameters['module'] == 'mythread'
              ? {
                  'data': {
                    '0': {'tid': 12, 'subject': 'thread'},
                  },
                }
              : {
                  'comments': {
                    '3': {
                      '8': {'id': '8', 'comment': 'hello'},
                    },
                  },
                  'count': '19',
                  'totalcomment': '<b>rating</b>',
                },
        },
        requests,
      );
      final client = ForumInteractionClient(dio, 'https://forum.test');
      expect((await client.myThreads('reply', 2)).single['tid'], 12);
      expect(requests.single.uri.queryParameters['type'], 'reply');
      expect(requests.single.uri.queryParameters['page'], '2');
      final result = await client.comments(12, 3, 2);
      expect(result.variables['count'], '19');
      expect(forumRows(result.variables['comments']['3']).single['id'], '8');
      dio.close();
    },
  );
  test('new fields decode and survive cached JSON', () {
    final variables = ThreadVariables.fromJson({
      'forum_threadpay': true,
      'thread': {'tid': '9', 'recommend': '1', 'recommend_add': 7},
      'commentcount': {'3': '19'},
    });
    final cached = ThreadVariables.fromJson(variables.toJson());
    expect(cached.threadPayRequired, true);
    expect(cached.threadInfo.recommended, true);
    expect(cached.threadInfo.recommendCount, 7);
    expect(cached.commentCounts['3'], '19');
    final attachment = Attachment.fromJson({'price': '5', 'payed': '0'});
    expect(Attachment.fromJson(attachment.toJson()).price, 5);
    expect(attachment.payed, false);
  });
  test('purchase links must match the exact forum installation', () {
    expect(
      ForumPurchaseTarget.parse(
        'https://forum.test/bbs',
        'forum.php?mod=misc&action=attachpay&aid=20',
        10,
      )?.aid,
      20,
    );
    for (final href in [
      'https://foreign.test/bbs/forum.php?mod=misc&action=pay&tid=10',
      '/other/forum.php?mod=misc&action=pay&tid=10',
      'javascript:alert(1)',
      'forum.php?mod=misc&action=attachpay&aid=bad',
    ]) {
      expect(
        ForumPurchaseTarget.parse('https://forum.test/bbs', href, 10),
        isNull,
      );
    }
  });

  final discuz = Discuz(
    'https://forum.test',
    'X3.5',
    'utf-8',
    4,
    '',
    '',
    false,
    '',
    '',
    'Forum',
    '',
    '',
    '',
  );
  final user = User('auth', 'salt', 'test', '', 1, 1, 10, discuz);
  Future<void> mount(
    WidgetTester tester,
    ForumInteractionClient client,
    VoidCallback changed, {
    DiscuzAndUserNotifier? notifier,
  }) async {
    final account =
        notifier ??
        (DiscuzAndUserNotifier()
          ..discuz = discuz
          ..user = user);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: account,
        child: MaterialApp(
          localizationsDelegates: const [S.delegate],
          home: Scaffold(
            body: ForumActionButton(
              discuz: discuz,
              tid: 10,
              aid: 20,
              purchase: true,
              label: 'Buy',
              createClient: (_) async => client,
              onChanged: changed,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('purchase shows after balance and cancellation never submits', (
    tester,
  ) async {
    final requests = <RequestOptions>[];
    final dio = fakeDio((_) => {'Variables': quote()}, requests);
    await mount(tester, ForumInteractionClient(dio, discuz.baseURL), () {});
    await tester.tap(find.text('Buy'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('${S.current.forumBalanceAfterPurchase}: 15'),
      findsOneWidget,
    );
    await tester.tap(find.text(S.current.cancel));
    await tester.pumpAndSettle();
    expect(requests.where((r) => r.method == 'POST'), isEmpty);
    dio.close();
  });
  testWidgets(
    'changed quote requires a second confirmation before one purchase',
    (tester) async {
      final requests = <RequestOptions>[];
      var reads = 0, changed = 0;
      final dio = fakeDio(
        (o) => o.method == 'POST'
            ? {
                'Message': {'messageval': 'attachment_mobile_buy'},
              }
            : {'Variables': quote(price: ++reads == 1 ? 5 : 6)},
        requests,
      );
      await mount(tester, ForumInteractionClient(dio, discuz.baseURL), () {
        changed++;
      });
      await tester.tap(find.text('Buy'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.forumConfirm));
      await tester.pumpAndSettle();
      expect(requests.where((r) => r.method == 'POST'), isEmpty);
      expect(
        find.textContaining('${S.current.forumPurchasePrice}: 6'),
        findsOneWidget,
      );
      await tester.tap(find.text(S.current.forumConfirm));
      await tester.pumpAndSettle();
      expect(requests.where((r) => r.method == 'POST').length, 1);
      expect(changed, 1);
      dio.close();
    },
  );
  testWidgets('account switch during confirmation prevents purchase', (
    tester,
  ) async {
    final requests = <RequestOptions>[];
    final dio = fakeDio((_) => {'Variables': quote()}, requests);
    final account = DiscuzAndUserNotifier()
      ..discuz = discuz
      ..user = user;
    await mount(
      tester,
      ForumInteractionClient(dio, discuz.baseURL),
      () {},
      notifier: account,
    );
    await tester.tap(find.text('Buy'));
    await tester.pumpAndSettle();
    account.setUser(null);
    await tester.tap(find.text(S.current.forumConfirm));
    await tester.pumpAndSettle();
    expect(requests.where((r) => r.method == 'POST'), isEmpty);
    dio.close();
  });
  testWidgets(
    'comment pagination retains rows after failure and deduplicates retry',
    (tester) async {
      final requests = <RequestOptions>[];
      var fail = true;
      final dio = fakeDio((o) {
        final page = o.uri.queryParameters['page'];
        if (page == '2' && fail)
          return {
            'Message': {'messageval': 'temporary', 'messagestr': 'try again'},
          };
        return {
          'Variables': {
            'comments': {
              '3': page == '1'
                  ? [
                      {'id': '1', 'author': 'A', 'comment': '<b>first</b>'},
                    ]
                  : [
                      {'id': '1', 'author': 'A', 'comment': '<b>first</b>'},
                      {'id': '2', 'author': 'B', 'comment': 'second'},
                    ],
            },
            'count': '2',
            'totalcomment': '<i>4.5</i>',
          },
        };
      }, requests);
      final account = DiscuzAndUserNotifier()
        ..discuz = discuz
        ..user = user;
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: account,
          child: MaterialApp(
            localizationsDelegates: const [S.delegate],
            home: ForumListsPage(
              discuz: discuz,
              user: user,
              tid: 10,
              pid: 3,
              createClient: () async =>
                  ForumInteractionClient(dio, discuz.baseURL),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('first', findRichText: true), findsOneWidget);
      await tester.tap(find.text(S.current.forumLoadMore));
      await tester.pumpAndSettle();
      expect(find.textContaining('first', findRichText: true), findsOneWidget);
      expect(find.text('try again'), findsOneWidget);
      fail = false;
      await tester.tap(find.text(S.current.retry));
      await tester.pumpAndSettle();
      expect(find.textContaining('first', findRichText: true), findsOneWidget);
      expect(find.textContaining('second', findRichText: true), findsOneWidget);
      expect(find.byType(PostCommentWidget), findsNWidgets(2));
      expect(find.textContaining('<b>', findRichText: true), findsNothing);
      expect(find.text(S.current.forumNoMore), findsOneWidget);
      expect(requests.map((r) => r.uri.queryParameters['page']), [
        '1',
        '2',
        '2',
      ]);
      dio.close();
    },
  );
  testWidgets(
    'already purchased quote refreshes without submitting or reporting failure',
    (tester) async {
      final requests = <RequestOptions>[];
      var refreshed = 0;
      final dio = fakeDio(
        (_) => {
          'Message': {'messageval': 'attachment_yetpay'},
        },
        requests,
      );
      await mount(tester, ForumInteractionClient(dio, discuz.baseURL), () {
        refreshed++;
      });
      await tester.tap(find.text('Buy'));
      await tester.pumpAndSettle();
      expect(refreshed, 1);
      expect(requests.where((r) => r.method == 'POST'), isEmpty);
      expect(find.text(S.current.forumPurchased), findsOneWidget);
      expect(find.text(S.current.forumActionFailed), findsNothing);
      dio.close();
    },
  );
  test('negative feedback uses sub rather than add', () async {
    final requests = <RequestOptions>[];
    final dio = fakeDio(
      (_) => {
        'Message': {'messageval': 'recommend_succeed'},
      },
      requests,
    );
    await ForumInteractionClient(
      dio,
      discuz.baseURL,
    ).recommend(10, 'hash', positive: false);
    expect(requests.single.uri.queryParameters['do'], 'sub');
    dio.close();
  });
  testWidgets(
    'feedback requires matching server login and hides again on expiry',
    (tester) async {
      final account = DiscuzAndUserNotifier()..discuz = discuz;
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: account,
          child: MaterialApp(
            localizationsDelegates: const [S.delegate],
            home: Scaffold(
              body: ThreadFeedbackBar(
                discuz: discuz,
                tid: 10,
                formhash: 'hash',
                voted: true,
                sessionUid: user.uid,
                positiveCount: 3,
                negativeCount: 2,
                onChanged: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ForumActionButton), findsNothing);
      account.setUser(user);
      await tester.pumpAndSettle();
      expect(find.byType(ForumActionButton), findsNWidgets(2));
      expect(find.text('${S.current.forumDisrecommend} (2)'), findsOneWidget);
      expect(find.text(S.current.forumFeedbackSent), findsNothing);
      for (final button in tester.widgetList<ForumActionButton>(
        find.byType(ForumActionButton),
      )) {
        expect(button.enabled, false);
      }
      for (final serverUid in [0, user.uid + 1]) {
        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: account,
            child: MaterialApp(
              localizationsDelegates: const [S.delegate],
              home: Scaffold(
                body: ThreadFeedbackBar(
                  discuz: discuz,
                  tid: 10,
                  formhash: 'hash',
                  voted: false,
                  sessionUid: serverUid,
                  positiveCount: 3,
                  negativeCount: 2,
                  onChanged: () {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(ForumActionButton), findsNothing);
      }
    },
  );
  for (final positive in [true, false]) {
    testWidgets('accepted feedback shows only its direction: $positive', (
      tester,
    ) async {
      final account = DiscuzAndUserNotifier()
        ..discuz = discuz
        ..user = user;
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: account,
          child: MaterialApp(
            localizationsDelegates: const [S.delegate],
            home: Scaffold(
              body: ThreadFeedbackBar(
                discuz: discuz,
                tid: 10,
                formhash: 'hash',
                voted: false,
                sessionUid: user.uid,
                positiveCount: 3,
                negativeCount: 2,
                onChanged: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final action = tester
          .widgetList<ForumActionButton>(find.byType(ForumActionButton))
          .firstWhere((button) => button.positive == positive);
      action.onFeedbackAccepted!(positive);
      action.onChanged();
      await tester.pumpAndSettle();
      expect(find.byType(ForumActionButton), findsOneWidget);
      expect(
        find.text(
          positive ? S.current.forumRecommended : S.current.forumNotRecommended,
        ),
        findsOneWidget,
      );
      expect(find.text(S.current.forumFeedbackSent), findsNothing);
      expect(
        tester
            .widget<ForumActionButton>(find.byType(ForumActionButton))
            .enabled,
        isFalse,
      );
    });
  }
  test(
    'preview and full comments share tolerant models and cache round trips',
    () {
      const converter = ViewThreadCommentConverter();
      final comments = converter.fromJson({
        '3': {
          '8': {
            'id': 8,
            'pid': '3',
            'author': null,
            'dateline': 123,
            'comment': 'hello',
          },
        },
      });
      expect(comments['3']!.single.author, '');
      expect(comments['3']!.single.avatar, '');
      expect(comments['3']!.single.dateline, '123');
      expect(
        converter.fromJson(converter.toJson(comments))['3']!.single.comment,
        'hello',
      );
    },
  );
}
