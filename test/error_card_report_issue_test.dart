import 'dart:io';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/entity/DiscuzError.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/BugReportUtils.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(DiscuzError error, bool large, AppVisualStyle style) =>
    PlatformProvider(
      style: style,
      builder: (_) => MaterialApp(
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: Scaffold(body: ErrorCard(error, null, largeSize: large)),
      ),
    );

void main() {
  test('report link opens the app repository without sending error data', () {
    expect(BugReportUtils.issueUri.host, 'github.com');
    expect(BugReportUtils.issueUri.path,
        '/kidozh/discuz_flutter/issues/new/choose');
    expect(BugReportUtils.issueUri.hasQuery, isFalse);
  });

  for (final style in [AppVisualStyle.material, AppVisualStyle.cupertino]) {
    for (final large in [false, true]) {
      testWidgets(
          'report action is shown for parsing errors: $style large=$large',
          (tester) async {
        await tester.pumpWidget(host(
            DiscuzError('FormatException', 'Invalid response'), large, style));
        await tester.pumpAndSettle();
        expect(
            find.byKey(const ValueKey('error-report-issue')), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
      testWidgets(
          'network and expired session errors hide report: $style large=$large',
          (tester) async {
        for (final error in [
          DiscuzError('network_fail', 'Offline'),
          DiscuzError('login', 'Sign in again',
              errorType: ErrorType.userExpired),
          DiscuzError('connectionError', 'Offline',
              dioError: DioException(
                requestOptions: RequestOptions(),
                type: DioExceptionType.connectionError,
              )),
        ]) {
          await tester.pumpWidget(host(error, large, style));
          await tester.pumpAndSettle();
          expect(
              find.byKey(const ValueKey('error-report-issue')), findsNothing);
        }
      });
    }
  }

  test('Dio transport errors differ from wrapped parsing errors', () {
    DiscuzError wrapped(DioExceptionType type, [Object? cause]) => DiscuzError(
          'error',
          'Failed',
          dioError: DioException(
            requestOptions: RequestOptions(),
            type: type,
            error: cause,
          ),
        );
    for (final type in [
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.badCertificate,
      DioExceptionType.badResponse,
      DioExceptionType.cancel,
    ]) {
      expect(wrapped(type).isNetworkError, isTrue);
    }
    expect(
        wrapped(DioExceptionType.unknown, const SocketException('Offline'))
            .isNetworkError,
        isTrue);
    expect(
        wrapped(DioExceptionType.unknown, const FormatException('Invalid JSON'))
            .isNetworkError,
        isFalse);
    expect(wrapped(DioExceptionType.transformTimeout).isNetworkError, isFalse);
  });
}
