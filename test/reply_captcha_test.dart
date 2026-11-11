import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/widget/CaptchaWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final (checkOnMount, preflightFails) in [
    (false, false),
    (true, false),
    (true, true),
  ]) {
    testWidgets('captcha stays hidden until its requirement is confirmed '
        '(background login check: $checkOnMount, fails: $preflightFails)', (
      tester,
    ) async {
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
      var captchaNeeded = false;
      var imageAvailable = false;
      var checks = 0;
      var images = 0;
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (request, handler) {
              if (request.uri.queryParameters['module'] == 'secure') {
                checks++;
                if (!captchaNeeded && preflightFails) {
                  handler.reject(DioException(requestOptions: request));
                  return;
                }
                handler.resolve(
                  Response(
                    requestOptions: request,
                    data: {
                      'Variables': {if (captchaNeeded) 'sechash': 'captcha'},
                    },
                  ),
                );
                return;
              } else {
                images++;
                if (imageAvailable) {
                  handler.resolve(
                    Response<Uint8List>(
                      requestOptions: request,
                      data: base64Decode(
                        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jB1kAAAAASUVORK5CYII=',
                      ),
                    ),
                  );
                  return;
                }
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
              checkOnMount ? 'login' : 'post',
              captchaController: controller,
              checkOnMount: checkOnMount,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final reload = find.text('Reload captcha');
      expect(checks, checkOnMount ? 1 : 0);
      expect(images, 0);
      expect(reload, findsNothing);
      expect(find.text('Loading captcha information.'), findsNothing);
      expect(find.text('No captcha needed.'), findsNothing);
      expect(find.byType(EditableText), findsNothing);

      captchaNeeded = true;
      controller.reloadCaptcha(requiredByServer: true);
      await tester.pumpAndSettle();
      expect(reload, findsOneWidget);
      expect(images, 1);
      await tester.tap(reload);
      await tester.pumpAndSettle();
      expect(checks, checkOnMount ? 3 : 2);
      expect(images, 2);
      expect(reload, findsOneWidget);

      imageAvailable = true;
      await tester.tap(reload);
      await tester.pumpAndSettle();
      expect(find.byType(Image), findsOneWidget);
      expect(controller.value?.captchaFormHash, 'captcha');
      await tester.enterText(find.byType(EditableText), '1234');
      expect(controller.value?.verification, '1234');

      controller.reloadCaptcha(requiredByServer: false);
      await tester.pumpAndSettle();
      expect(checks, checkOnMount ? 4 : 3);
      expect(images, 3);
      expect(reload, findsNothing);
      expect(find.byType(EditableText), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
