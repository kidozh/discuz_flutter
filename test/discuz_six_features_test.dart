import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:discuz_flutter/client/ForumInteractionClient.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/entity/PollDraft.dart';
import 'package:discuz_flutter/entity/ActivityRegistration.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/JsonResult/ViewThreadResult.dart';
import 'package:discuz_flutter/page/ForumListsPage.dart';
import 'package:discuz_flutter/page/ModerateThreadPage.dart';
import 'package:discuz_flutter/page/ActivityRegistrationPage.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';

Dio fake(
  Object Function(RequestOptions) reply,
  List<RequestOptions> requests,
) => Dio()
  ..interceptors.add(
    InterceptorsWrapper(
      onRequest: (o, h) {
        requests.add(o);
        h.resolve(Response(requestOptions: o, statusCode: 200, data: reply(o)));
      },
    ),
  );
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
Widget host(Widget child, {bool login = true}) => ChangeNotifierProvider.value(
  value: DiscuzAndUserNotifier()
    ..discuz = discuz
    ..user = login ? user : null,
  child: MaterialApp(localizationsDelegates: const [S.delegate], home: child),
);
Map<String, dynamic> activity({String cost = '5', String button = 'join'}) => {
  'button': button,
  'closed': '0',
  'cost': '10',
  'creditcost': cost,
  'ufield': {'userfield': [], 'extfield': []},
  'joinfield': {},
};
void main() {
  test('poll validation and persisted draft keep choices and deadline', () {
    const poll = PollDraft(['A', 'B', 'C'], 2, 7);
    expect(poll.valid, true);
    expect(PollDraft.decode(poll.encode())!.fields, poll.fields);
    expect(poll.fields['polloptions'], 'A\nB\nC');
    expect(poll.fields['maxchoices'], '2');
    expect(poll.fields['expiration'], '7');
    for (final invalid in [
      PollDraft(['A'], 1, 7),
      PollDraft(['A', 'A'], 1, 7),
      PollDraft(['A', 'B'], 3, 7),
      PollDraft(['A', 'B'], 1, -1),
    ]) {
      expect(invalid.valid, false);
    }
    expect(PollDraft.decode('broken'), isNull);
  });
  test(
    'existing post client carries poll parameters with normal thread fields',
    () async {
      final requests = <RequestOptions>[];
      final dio = fake(
        (_) => {
          'Message': {
            'messageval': 'post_newthread_succeed',
            'messagestr': 'ok',
          },
          'Variables': <String, dynamic>{},
        },
        requests,
      );
      await MobileApiClient(dio, baseUrl: discuz.baseURL).postNewThread(
        'hash',
        3,
        '',
        'title',
        'body',
        '',
        '',
        '',
        [],
        const PollDraft(['A', 'B'], 1, 0).fields,
      );
      expect(requests.single.uri.queryParameters['special'], '1');
      expect(requests.single.uri.queryParameters['tpolloption'], '2');
      expect(requests.single.uri.queryParameters['polloptions'], 'A\nB');
      expect(requests.single.data['formhash'], 'hash');
      dio.close();
    },
  );
  test('moderation parameter encoding selects only the chosen operation', () {
    expect(moderationFields('stick', 'reason')['sticklevel'], '1');
    expect(moderationFields('unstick', 'reason')['sticklevel'], '0');
    expect(moderationFields('digest', 'reason')['operations[]'], 'digest');
    expect(moderationFields('open', 'reason')['operations[]'], 'open');
    expect(
      moderationFields(
        'move',
        'reason',
        destination: 9,
        type: '2',
      )['threadtypeid'],
      '2',
    );
    expect(() => moderationFields('move', 'reason'), throwsFormatException);
    expect(() => moderationFields('delete', 'reason'), throwsFormatException);
    expect(() => moderationFields('close', ''), throwsFormatException);
    expect(ThreadVariables.fromJson({'ismoderator': true}).isModerator, 1);
  });
  test(
    'activity validates required fields and preserves self-pay semantics',
    () {
      final spec = ActivityRegistration.fromJson({
        ...activity(),
        'ufield': {
          'userfield': ['realname'],
          'extfield': ['Contact'],
        },
        'joinfield': {
          'realname': {
            'fieldid': 'realname',
            'title': 'Name',
            'formtype': 'text',
          },
        },
      });
      expect(spec.supported, true);
      expect(() => spec.form({}, '', null), throwsFormatException);
      final form = spec.form(
        {'realname': 'Tester', 'Contact': '123'},
        'hello',
        null,
      );
      expect(form['payment'], '0');
      expect(form['activitysubmit'], 'yes');
      expect(form['Contact'], '123');
      expect(form.containsKey('formhash'), false);
      expect(
        () => spec.form({'realname': 'Tester', 'Contact': '123'}, '', 'bad'),
        throwsFormatException,
      );
      expect(
        spec.terms,
        isNot(
          ActivityRegistration.fromJson({...spec.raw, 'creditcost': '8'}).terms,
        ),
      );
    },
  );
  test(
    'unsupported file fields and parameter collisions require website, but cancellation is available',
    () {
      for (final field in [
        {'fieldid': 'proof', 'formtype': 'file'},
        {'fieldid': 'formhash', 'formtype': 'text'},
      ]) {
        final spec = ActivityRegistration.fromJson({
          ...activity(),
          'joinfield': {'proof': field},
        });
        expect(spec.supported, false);
        expect(() => spec.form({}, '', null), throwsFormatException);
        final cancel = ActivityRegistration.fromJson({
          ...spec.raw,
          'button': 'cancel',
        });
        expect(cancel.form({}, 'cancel', null)['activitycancel'], 'yes');
      }
    },
  );
  testWidgets('hot forums work for guests and finish without another page', (
    tester,
  ) async {
    final requests = <RequestOptions>[];
    final dio = fake(
      (_) => {
        'Variables': {
          'data': [
            {'fid': '3', 'name': 'Popular', 'todayposts': '7'},
          ],
        },
      },
      requests,
    );
    await tester.pumpWidget(
      host(
        ForumListsPage(
          discuz: discuz,
          user: null,
          directory: ForumDirectory.hotForums,
          createClient: () async => ForumInteractionClient(dio, discuz.baseURL),
        ),
        login: false,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Popular'), findsOneWidget);
    expect(find.text(S.current.forumLoadMore), findsNothing);
    expect(requests.single.uri.queryParameters['module'], 'hotforum');
    dio.close();
  });
  testWidgets('friend directory paginates by count', (tester) async {
    final requests = <RequestOptions>[];
    final dio = fake(
      (o) => {
        'Variables': {
          'list': [
            {
              'uid': o.uri.queryParameters['page'],
              'username': 'Friend ${o.uri.queryParameters['page']}',
            },
          ],
          'count': '2',
        },
      },
      requests,
    );
    await tester.pumpWidget(
      host(
        ForumListsPage(
          discuz: discuz,
          user: user,
          directory: ForumDirectory.friends,
          createClient: () async => ForumInteractionClient(dio, discuz.baseURL),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(S.current.forumLoadMore));
    await tester.pumpAndSettle();
    expect(find.text('Friend 1'), findsOneWidget);
    expect(find.text('Friend 2'), findsOneWidget);
    expect(requests.last.uri.queryParameters['page'], '2');
    expect(find.text(S.current.forumNoMore), findsOneWidget);
    dio.close();
  });
  testWidgets(
    'pinned directory sends current forum and handles numeric-key results',
    (tester) async {
      final requests = <RequestOptions>[];
      final dio = fake(
        (_) => {
          'Variables': {
            'forum_threadlist': {
              '0': {
                'tid': '8',
                'subject': 'Pinned',
                'author': 'A',
                'replies': '2',
              },
            },
          },
        },
        requests,
      );
      await tester.pumpWidget(
        host(
          ForumListsPage(
            discuz: discuz,
            user: user,
            directory: ForumDirectory.pinnedThreads,
            fid: 3,
            createClient: () async =>
                ForumInteractionClient(dio, discuz.baseURL),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Pinned'), findsOneWidget);
      expect(requests.single.uri.queryParameters['fid'], '3');
      expect(requests.single.uri.queryParameters['module'], 'toplist');
      dio.close();
    },
  );
  testWidgets(
    'moderation cancellation does not submit and confirmation rechecks moderator',
    (tester) async {
      final requests = <RequestOptions>[];
      final dio = fake(
        (_) => {
          'Variables': {
            'thread': {'tid': '8'},
            'fid': '3',
            'ismoderator': false,
            'member_uid': '1',
            'formhash': 'hash',
          },
        },
        requests,
      );
      await tester.pumpWidget(
        host(
          ModerateThreadPage(
            discuz: discuz,
            user: user,
            tid: 8,
            createClient: () async =>
                ForumInteractionClient(dio, discuz.baseURL),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'reason');
      await tester.tap(find.text(S.current.forumConfirm));
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.cancel));
      await tester.pumpAndSettle();
      expect(requests, isEmpty);
      await tester.tap(find.text(S.current.forumConfirm));
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.forumConfirm).last);
      await tester.pumpAndSettle();
      expect(requests.where((r) => r.method == 'POST'), isEmpty);
      expect(find.text('no_privilege'), findsOneWidget);
      dio.close();
    },
  );
  testWidgets('activity fee change after confirmation prevents registration', (
    tester,
  ) async {
    final requests = <RequestOptions>[];
    var reads = 0;
    final dio = fake(
      (_) => {
        'Variables': {
          'special_activity': activity(cost: ++reads == 1 ? '5' : '8'),
          'member_uid': '1',
          'formhash': 'hash',
        },
      },
      requests,
    );
    await tester.pumpWidget(
      host(
        ActivityRegistrationPage(
          discuz: discuz,
          user: user,
          tid: 8,
          createClient: () async => ForumInteractionClient(dio, discuz.baseURL),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(S.current.joinActivity));
    await tester.pumpAndSettle();
    await tester.tap(find.text(S.current.forumConfirm));
    await tester.pumpAndSettle();
    expect(requests.where((r) => r.method == 'POST'), isEmpty);
    expect(find.text(S.current.activityChanged), findsOneWidget);
    dio.close();
  });
  testWidgets(
    'moderation confirmation submits exactly one native operation with fresh token',
    (tester) async {
      final requests = <RequestOptions>[];
      final dio = fake(
        (r) => r.method == 'GET'
            ? {
                'Variables': {
                  'thread': {'tid': '8'},
                  'fid': '3',
                  'ismoderator': true,
                  'member_uid': '1',
                  'formhash': 'fresh',
                },
              }
            : {
                'Message': {'messageval': 'admin_succeed'},
              },
        requests,
      );
      await tester.pumpWidget(
        host(
          Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ModerateThreadPage(
                      discuz: discuz,
                      user: user,
                      tid: 8,
                      createClient: () async =>
                          ForumInteractionClient(dio, discuz.baseURL),
                    ),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'reason');
      await tester.tap(find.text(S.current.forumConfirm));
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.forumConfirm).last);
      await tester.pumpAndSettle();
      final request = requests.singleWhere((r) => r.method == 'POST');
      expect(request.uri.queryParameters['action'], 'moderate');
      expect(request.data['operations[]'], 'stick');
      expect(request.data['formhash'], 'fresh');
      expect(find.text('open'), findsOneWidget);
      dio.close();
    },
  );
  testWidgets(
    'activity registration uses activitysubmit and does not send unrelated fields',
    (tester) async {
      final requests = <RequestOptions>[];
      final dio = fake(
        (r) => r.method == 'GET'
            ? {
                'Variables': {
                  'special_activity': activity(),
                  'member_uid': '1',
                  'formhash': 'fresh',
                },
              }
            : {
                'Message': {'messageval': 'activity_completion'},
              },
        requests,
      );
      await tester.pumpWidget(
        host(
          Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ActivityRegistrationPage(
                      discuz: discuz,
                      user: user,
                      tid: 8,
                      createClient: () async =>
                          ForumInteractionClient(dio, discuz.baseURL),
                    ),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.joinActivity));
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.forumConfirm));
      await tester.pumpAndSettle();
      final request = requests.singleWhere((r) => r.method == 'POST');
      expect(request.uri.queryParameters['module'], 'forummisc');
      expect(request.uri.queryParameters['action'], 'activityapplies');
      expect(request.data['activitysubmit'], 'yes');
      expect(request.data['formhash'], 'fresh');
      expect(request.data['payment'], '0');
      expect(find.text('open'), findsOneWidget);
      dio.close();
    },
  );
}
