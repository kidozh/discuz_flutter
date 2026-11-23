import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/LoginPage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _site = Discuz(
  'https://forum.test',
  'X3.5',
  'utf-8',
  4,
  '',
  '',
  false,
  '0',
  '0',
  'Forum',
  '1',
  '',
  '0',
);

class _LoginClient extends DioForNative {
  _LoginClient(this.reply);

  final FutureOr<Map<String, Object?>> Function(RequestOptions) reply;

  @override
  Future<Response<T>> fetch<T>(RequestOptions requestOptions) async =>
      Response<T>(
        requestOptions: requestOptions,
        statusCode: 200,
        data: await reply(requestOptions) as T,
      );
}

Map<String, Object?> _loginFailure(String code) => {
  'Variables': <String, Object?>{},
  'Message': {'messageval': '$code//1', 'messagestr': 'mobile:$code'},
};

const _noCaptcha = {'Variables': <String, Object?>{}};

Future<void> _openLogin(WidgetTester tester, Dio dio) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = const Size(480, 850);
  addTearDown(tester.view.reset);
  addTearDown(dio.close);
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => DiscuzAndUserNotifier(),
      child: MaterialApp(
        localizationsDelegates: const [S.delegate],
        builder: EasyLoading.init(),
        home: Scaffold(
          body: LoginForumFieldStatefulWidget(_site, 'member', dio: dio),
        ),
      ),
    ),
  );
  tester
          .widget<PlatformTextFormField>(
            find.byType(PlatformTextFormField).last,
          )
          .controller!
          .text =
      'fixture-password';
  await tester.pump();
}

Future<void> _pressLogin(WidgetTester tester) async {
  final button = find.text(S.current.loginTitle);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pump();
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    const haptic = MethodChannel('haptic_feedback');
    const paths = MethodChannel('plugins.flutter.io/path_provider');
    messenger.setMockMethodCallHandler(haptic, (_) async => false);
    final folder = Directory.systemTemp.createTempSync('login-verification-');
    messenger.setMockMethodCallHandler(paths, (_) async => folder.path);
    addTearDown(() {
      messenger.setMockMethodCallHandler(haptic, null);
      messenger.setMockMethodCallHandler(paths, null);
      folder.deleteSync(recursive: true);
    });
  });

  testWidgets(
    'login waits for the ongoing verification check and then submits once',
    (tester) async {
      final preflight = Completer<void>();
      var checks = 0;
      var logins = 0;
      final dio = _LoginClient((request) async {
        if (request.uri.queryParameters['module'] == 'secure') {
          checks++;
          await preflight.future;
          return _noCaptcha;
        }
        logins++;
        expect(request.method, 'POST');
        return _loginFailure('login_seccheck2');
      });
      await _openLogin(tester, dio);
      await _pressLogin(tester);
      expect(checks, 1);
      expect(logins, 0);
      preflight.complete();
      await tester.pump();
      await tester.pump();

      expect(logins, 1);
      expect(
        find.text(S.current.loginBrowserVerificationRequired),
        findsOneWidget,
      );
      expect(find.text(S.current.loginTitle), findsNothing);
      expect(find.text(S.current.signInViaBrowser), findsOneWidget);
      expect(find.text(S.current.reportIssue), findsNothing);
    },
  );

  testWidgets(
    'an empty captcha probe cannot clear verification required by login',
    (tester) async {
      var logins = 0;
      var checks = 0;
      final dio = _LoginClient((request) {
        if (request.uri.queryParameters['module'] == 'secure') {
          checks++;
          return _noCaptcha;
        }
        logins++;
        return _loginFailure('submit_seccode_invalid');
      });
      await _openLogin(tester, dio);
      await _pressLogin(tester);
      expect(logins, 1);
      expect(checks, 2);
      expect(find.text(S.current.reloadCaptcha), findsOneWidget);

      await _pressLogin(tester);
      expect(logins, 1);
      expect(
        find.text(S.current.loginBrowserVerificationRequired),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'a forum verification question offers browser login without sending credentials',
    (tester) async {
      final modules = <String>[];
      final dio = _LoginClient((request) {
        modules.add(request.uri.queryParameters['module']!);
        return {
          'Variables': {'sechash': 'fixture', 'secqaa': 'A forum question'},
        };
      });
      await _openLogin(tester, dio);
      await _pressLogin(tester);

      expect(modules, ['secure']);
      expect(
        find.text(S.current.loginBrowserVerificationRequired),
        findsOneWidget,
      );
      expect(find.text(S.current.signInViaBrowser), findsOneWidget);
    },
  );
}
