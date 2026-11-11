import 'package:dio/dio.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/widget/CaptchaWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final knownChallenge in [false, true]) {
    testWidgets('reply captcha only offers retry for a known challenge '
        '(known at preflight: $knownChallenge)', (tester) async {
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
      final controller = CaptchaController(CaptchaFields('', 'post', ''));
      var captchaNeeded = knownChallenge;
      var failCheck = !knownChallenge;
      var checks = 0;
      var images = 0;
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (request, handler) {
              if (request.uri.queryParameters['module'] == 'secure') {
                checks++;
                if (!failCheck) {
                  handler.resolve(
                    Response(
                      requestOptions: request,
                      data: {
                        'Variables': {if (captchaNeeded) 'sechash': 'captcha'},
                      },
                    ),
                  );
                  return;
                }
              } else {
                images++;
              }
              handler.reject(DioException(requestOptions: request));
            },
          ),
        );
      addTearDown(dio.close);
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [S.delegate],
          home: Scaffold(
            body: CaptchaWidget(
              dio,
              discuz,
              null,
              'post',
              captchaController: controller,
              hideUnconfirmedFailure: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final reload = find.text('Reload captcha');
      expect(checks, 1);
      expect(images, knownChallenge ? 1 : 0);
      expect(controller.value?.captchaFormHash, isEmpty);
      if (!knownChallenge) {
        expect(reload, findsNothing);
        controller.reloadCaptcha(requiredByServer: true);
        await tester.pumpAndSettle();
        expect(checks, 2);
      }
      expect(reload, findsOneWidget);
      await tester.tap(reload);
      await tester.pumpAndSettle();
      expect(checks, knownChallenge ? 2 : 3);
      expect(reload, findsOneWidget);

      captchaNeeded = false;
      failCheck = false;
      controller.reloadCaptcha(requiredByServer: false);
      await tester.pumpAndSettle();
      expect(reload, findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
