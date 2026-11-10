import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:discuz_flutter/JsonResult/ViewThreadResult.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/provider/TypeSettingNotifierProvider.dart';
import 'package:discuz_flutter/provider/UserPreferenceNotifierProvider.dart';
import 'package:discuz_flutter/screen/NotificationScreen.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/widget/PollWidget.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
// The platform interface lets the test redirect the real cookie store.
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'refresh errors preserve pagination and stale sessions cannot replace rows',
    (tester) async {
      final site = Discuz(
        'https://refresh.example.test',
        'X3.5',
        'utf-8',
        4,
        '',
        '',
        false,
        '',
        '',
        'Example',
        '1',
        '',
        '',
      );
      User user(int uid) =>
          User('same-auth', 'salt', 'User $uid', '', 1, uid, 10, site);
      final firstUser = user(1);
      final secondUser = user(2);
      final account = DiscuzAndUserNotifier()
        ..initDiscuz(site)
        ..setUser(firstUser);
      addTearDown(account.dispose);

      final oldPathProvider = PathProviderPlatform.instance;
      final directory = (await tester.runAsync(
        () => Directory.systemTemp.createTemp('discuz_refresh_session_'),
      ))!;
      PathProviderPlatform.instance = _TestPaths(directory.path);
      addTearDown(() async {
        PathProviderPlatform.instance = oldPathProvider;
        await directory.delete(recursive: true);
      });
      SharedPreferences.setMockInitialValues({});
      for (final user in [firstUser, secondUser]) {
        await tester.runAsync(
          () => NetworkUtils.getPersistentCookieJarByUser(user),
        );
        await UserPreferencesUtils.putLastMobileSignRecord(site, user.uid);
      }

      final pages = <int>[];
      final replies = <FutureOr<Map<String, dynamic>>>[];
      Future<HttpClientResponse> serve(Uri uri) async {
        if (uri.queryParameters['module'] != 'mynotelist') {
          throw StateError('Unexpected request: ${uri.path}');
        }
        pages.add(int.parse(uri.queryParameters['page']!));
        return _JsonResponse(await replies.removeAt(0));
      }

      Future<void> pumpUntil(bool Function() ready) async {
        for (var frame = 0; frame < 40 && !ready(); frame++) {
          await tester.pump(const Duration(milliseconds: 50));
          await tester.runAsync(() => Future<void>.delayed(Duration.zero));
        }
        expect(ready(), isTrue, reason: 'The refresh did not complete');
      }

      Future<Object?> waitFor(FutureOr<dynamic> task) async {
        var done = false;
        Object? result;
        Future<dynamic>.value(task).then((value) {
          result = value;
          done = true;
        });
        await pumpUntil(() => done);
        return result;
      }

      await HttpOverrides.runWithHttpOverrides(() async {
        replies.add(_response(1, 'Original', count: 3));
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: account),
              ChangeNotifierProvider(
                create: (_) => UserPreferenceNotifierProvider(),
              ),
              ChangeNotifierProvider(create: (_) => ThemeNotifierProvider()),
              ChangeNotifierProvider(
                create: (_) => TypeSettingNotifierProvider(),
              ),
            ],
            child: const MaterialApp(
              localizationsDelegates: [
                S.delegate,
                ...GlobalMaterialLocalizations.delegates,
              ],
              home: Scaffold(body: NotificationScreen()),
            ),
          ),
        );
        await pumpUntil(() => find.text('ORIGINAL').evaluate().isNotEmpty);
        expect(pages, [1]);
        expect(find.text('ORIGINAL'), findsOneWidget);
        EasyRefresh refresh() =>
            tester.widget<EasyRefresh>(find.byType(EasyRefresh));

        replies.add(_response(1, 'Page two', count: 3));
        expect(await waitFor(refresh().onLoad!()), IndicatorResult.success);
        await tester.pump();
        expect(find.text('PAGE TWO'), findsOneWidget);

        replies.add({
          ..._response(1, 'Placeholder'),
          'error': 'Forum unavailable',
        });
        expect(await waitFor(refresh().onRefresh!()), IndicatorResult.fail);
        await tester.pump();
        expect(find.text('ORIGINAL'), findsOneWidget);
        expect(find.text('PLACEHOLDER'), findsNothing);

        replies.add(_response(1, 'Page three', count: 3));
        expect(await waitFor(refresh().onLoad!()), IndicatorResult.noMore);
        expect(pages, [1, 2, 1, 3]);

        final pending = Completer<Map<String, dynamic>>();
        replies.add(pending.future);
        final staleRefresh = refresh().onRefresh!();
        await pumpUntil(() => pages.length == 5);
        expect(pages.last, 1);

        // Re-authenticate with the same site, UID and auth value.
        replies.add(_response(1, 'Signed in again'));
        account.setUser(firstUser);
        await pumpUntil(
          () => find.text('SIGNED IN AGAIN').evaluate().isNotEmpty,
        );
        expect(find.text('SIGNED IN AGAIN'), findsOneWidget);
        pending.complete(_response(1, 'Old session'));
        expect(await waitFor(staleRefresh), IndicatorResult.fail);
        await tester.pump();
        expect(find.text('OLD SESSION'), findsNothing);
        expect(find.text('SIGNED IN AGAIN'), findsOneWidget);

        replies.add(_response(2, 'Other account'));
        account.setUser(secondUser);
        await pumpUntil(() => find.text('OTHER ACCOUNT').evaluate().isNotEmpty);
        expect(find.text('OTHER ACCOUNT'), findsOneWidget);
        expect(find.text('SIGNED IN AGAIN'), findsNothing);
        expect(replies, isEmpty);
        expect(pages, [1, 2, 1, 3, 1, 1, 1]);
        await tester.pumpAndSettle();
      }, _TestHttpOverrides(serve));
    },
  );

  testWidgets('the same poll row displays refreshed options and vote totals', (
    tester,
  ) async {
    Poll poll({
      required String option,
      required bool allowVote,
      required int votes,
    }) => Poll()
      ..allowVote = allowVote
      ..expiredAt = DateTime.now().add(const Duration(days: 1))
      ..pollOptionsMap = {
        '1': (PollOption()
          ..id = 1
          ..name = option
          ..voteNumber = votes),
        '2': (PollOption()
          ..id = 2
          ..name = 'Other option'
          ..voteNumber = 1),
      };

    Future<void> show(Poll poll) => tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          S.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        home: Scaffold(body: PollWidget(poll, 'formhash', 10, 1)),
      ),
    );

    await show(poll(option: 'Original option', allowVote: true, votes: 0));
    expect(find.text('Original option'), findsOneWidget);
    await show(poll(option: 'Updated option', allowVote: false, votes: 2));
    await tester.pumpAndSettle();
    expect(find.text('Original option'), findsNothing);
    expect(find.text('Updated option'), findsOneWidget);
    expect(find.text('66.7%'), findsOneWidget);
  });
}

Map<String, dynamic> _response(int uid, String label, {int count = 1}) => {
  'Variables': {
    'member_uid': '$uid',
    'count': '$count',
    'list': [
      {'type': label, 'note': '', 'dateline': '1700000000'},
    ],
  },
};

class _TestPaths extends PathProviderPlatform {
  _TestPaths(this.path);
  final String path;

  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}

class _TestHttpOverrides extends HttpOverrides {
  _TestHttpOverrides(this.serve);
  final Future<HttpClientResponse> Function(Uri) serve;

  @override
  HttpClient createHttpClient(SecurityContext? context) => _TestClient(serve);
}

class _TestClient extends Fake implements HttpClient {
  _TestClient(this.serve);
  final Future<HttpClientResponse> Function(Uri) serve;

  @override
  set idleTimeout(Duration value) {}

  @override
  set connectionTimeout(Duration? value) {}

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _TestRequest(() => serve(url));
}

class _TestRequest extends Fake implements HttpClientRequest {
  _TestRequest(this.respond);
  final Future<HttpClientResponse> Function() respond;

  @override
  final HttpHeaders headers = _JsonHeaders();

  @override
  bool followRedirects = false;

  @override
  int maxRedirects = 0;

  @override
  bool persistentConnection = false;

  @override
  Future<HttpClientResponse> close() => respond();
}

class _JsonResponse extends StreamView<List<int>>
    implements HttpClientResponse {
  _JsonResponse(Map<String, dynamic> value)
    : super(Stream.value(utf8.encode(jsonEncode(value))));

  @override
  final HttpHeaders headers = _JsonHeaders();

  @override
  int get statusCode => 200;

  @override
  String get reasonPhrase => 'OK';

  @override
  bool get isRedirect => false;

  @override
  List<RedirectInfo> get redirects => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _JsonHeaders extends Fake implements HttpHeaders {
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  void forEach(void Function(String, List<String>) action) =>
      action(HttpHeaders.contentTypeHeader, ['application/json']);
}
