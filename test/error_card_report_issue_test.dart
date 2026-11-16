import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/client/ForumInteractionClient.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/entity/DiscuzError.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/BugReportUtils.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/utility/forum_error.dart';
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
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: Scaffold(
          body: ErrorCard(
            error,
            null,
            largeSize: large,
            webpageUrl: 'https://example.test/forum-44-1.html',
          ),
        ),
      ),
    );

DioException badResponse(int status, [Object? data]) {
  final options = RequestOptions(
    path: '/api/mobile/index.php?formhash=private',
  );
  return DioException.badResponse(
    statusCode: status,
    requestOptions: options,
    response: Response(requestOptions: options, statusCode: status, data: data),
  );
}

void main() {
  setUpAll(() async => S.load(const Locale('en')));

  test('the report page receives no forum data', () {
    expect(BugReportUtils.issueUri.host, 'github.com');
    expect(
      BugReportUtils.issueUri.path,
      '/kidozh/discuz_flutter/issues/new/choose',
    );
    expect(BugReportUtils.issueUri.hasQuery, isFalse);
  });

  for (final style in [AppVisualStyle.material, AppVisualStyle.cupertino]) {
    for (final large in [false, true]) {
      testWidgets(
        'only app failures offer GitHub feedback: $style large=$large',
        (tester) async {
          final report = find.byKey(const ValueKey('error-report-issue'));
          final errors = [
            const FormatException('private response'),
            DioException(
              requestOptions: RequestOptions(),
              error: const FormatException('JSON'),
            ),
            badResponse(404, {
              'Message': {
                'messageval': 'thread_nonexistence',
                'messagestr': 'This topic was removed.',
              },
            }),
            badResponse(429),
            const ForumApiException(
              'forum_webpage_redirect',
              '',
              fromForum: true,
            ),
            const ForumApiException(
              'login_before_enter_home//1',
              '',
              fromForum: true,
            ),
            const ForumApiException(
              'site_plugin_limit',
              'Site limit reached.',
              fromForum: true,
            ),
            const DiscuzError(
              'login',
              'Sign in again',
              errorType: ErrorType.userExpired,
            ),
          ];
          for (final (index, error) in errors.indexed) {
            final failure = forumRequestError(S.current, error);
            await tester.pumpWidget(host(failure, large, style));
            await tester.pumpAndSettle();
            expect(find.text(failure.content), findsOneWidget);
            expect(report, index < 2 ? findsOneWidget : findsNothing);
            expect(
              find.text(S.current.navigateToWebPage),
              failure.key == 'forum_webpage_redirect'
                  ? findsOneWidget
                  : findsNothing,
            );
          }
        },
      );
    }
  }

  test('Dio failures explain their cause without exposing request details', () {
    final s = S.current;
    final options = RequestOptions(path: '/secret');
    final failures = <(Object, String, bool)>[
      (
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionTimeout,
        ),
        s.dioErrorConnectionTimeout,
        false,
      ),
      (
        DioException(
          requestOptions: options,
          type: DioExceptionType.sendTimeout,
        ),
        s.dioErrorSendTimeout,
        false,
      ),
      (
        DioException(
          requestOptions: options,
          type: DioExceptionType.receiveTimeout,
        ),
        s.dioErrorReceiveTimeout,
        false,
      ),
      (
        DioException(
          requestOptions: options,
          type: DioExceptionType.badCertificate,
        ),
        s.dioErrorBadCertificate,
        false,
      ),
      (
        DioException(requestOptions: options, type: DioExceptionType.cancel),
        s.dioErrorCancel,
        false,
      ),
      (
        DioException(
          requestOptions: options,
          type: DioExceptionType.transformTimeout,
        ),
        s.forumResponseProcessingTimeout,
        true,
      ),
      (
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: const SocketException('Failed host lookup: private'),
        ),
        s.forumDnsFailure,
        false,
      ),
      (
        DioException(
          requestOptions: options,
          error: const FormatException('secret body'),
        ),
        s.forumUnexpectedResponse,
        true,
      ),
      (badResponse(401), s.forumHttpUnauthorized, false),
      (badResponse(403), s.forumHttpForbidden, false),
      (badResponse(404), s.forumHttpMissing, false),
      (badResponse(413), s.forumHttpTooLarge, false),
      (badResponse(429), s.forumHttpRateLimited, false),
      (badResponse(502), s.forumHttpServerError('502'), false),
      (badResponse(504), s.forumHttpTimeout('504'), false),
      (badResponse(567), s.forumSecurityChallenge, false),
    ];
    for (final (error, message, reportable) in failures) {
      final failure = forumRequestError(s, error);
      expect(failure.content, message);
      expect(failure.reportable, reportable);
    }
  });

  test(
    'forum error envelopes outrank HTTP status and preserve site messages',
    () {
      final error = badResponse(404, '''<?xml version="1.0"?><root><![CDATA[
      {"Message":{"messageval":"thread_nonexistence//1","messagestr":"主题已删除<br />请返回版块"}}
      ]]></root>''');
      final failure = forumRequestError(S.current, error);
      expect(failure.key, 'thread_nonexistence');
      expect(failure.content, '主题已删除 请返回版块');
      expect(failure.reportable, isFalse);
    },
  );

  test(
    'typed clients retain forum messages when Variables cannot be decoded',
    () async {
      final dio = Dio();
      addTearDown(dio.close);
      Object? body;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) {
            handler.resolve(Response(requestOptions: request, data: body));
          },
        ),
      );
      final client = MobileApiClient(dio, baseUrl: 'https://example.test');
      for (final (data, code, reportable) in <(Object, String, bool)>[
        ({'error': 'module_not_exists'}, 'module_not_exists', false),
        (
          {
            'Message': {'messageval': 'login_before_enter_home//1'},
          },
          'login_before_enter_home',
          false,
        ),
        (
          {
            'Message': {
              'messageval': 'custom_site_code',
              'messagestr': 'Daily quota reached',
            },
            'Variables': [],
          },
          'custom_site_code',
          false,
        ),
        ({'Variables': []}, 'invalid_response_format', true),
        (
          {
            'Message': {'messageval': 'login_succeed'},
          },
          'invalid_response_format',
          true,
        ),
      ]) {
        body = data;
        try {
          await client.hotThreadResult(1);
          fail('Expected an error');
        } catch (error) {
          final failure = forumRequestError(S.current, error);
          expect(failure.key, code);
          expect(failure.reportable, reportable);
        }
      }
    },
  );
  test(
    'network client preserves status when the HTTP error body has broken JSON',
    () async {
      final dio = NetworkUtils.getDio();
      addTearDown(dio.close);
      dio.httpClientAdapter = _ForumResponseAdapter(
        502,
        '<html>gateway</html>',
        'application/json',
      );
      final api = MobileApiClient(dio, baseUrl: 'https://example.test');
      try {
        await api.hotThreadResult(1);
        fail('Expected a gateway error');
      } catch (error) {
        final failure = forumRequestError(S.current, error);
        expect(failure.content, S.current.forumHttpServerError('502'));
        expect(failure.reportable, isFalse);
      }
    },
  );

  test(
    'HTTP failures retain Discuz messages even inside an XML envelope',
    () async {
      final dio = NetworkUtils.getDio();
      addTearDown(dio.close);
      dio.httpClientAdapter = _ForumResponseAdapter(
        404,
        '<root><![CDATA[{"Message":{"messageval":"thread_nonexistence"}}]]></root>',
        'application/json',
      );
      final api = MobileApiClient(dio, baseUrl: 'https://example.test');
      try {
        await api.hotThreadResult(1);
        fail('Expected a forum error');
      } catch (error) {
        final failure = forumRequestError(S.current, error);
        expect(failure.key, 'thread_nonexistence');
        expect(failure.content, S.current.forumContentUnavailable);
        expect(failure.reportable, isFalse);
      }
    },
  );

  test('Discuz language keys use the local message when untranslated', () {
    final failure = forumRequestError(
      S.current,
      badResponse(404, {
        'Message': {
          'messageval': 'thread_nonexistence',
          'messagestr': 'mobile:thread_nonexistence',
        },
      }),
    );
    expect(failure.content, S.current.forumContentUnavailable);
    expect(failure.reportable, isFalse);

    final login = forumRequestError(
      S.current,
      const ForumApiException(
        'to_login//1',
        'mobile:to_login',
        fromForum: true,
      ),
    );
    expect(login.content, S.current.forumSignInRequired);
    expect(login.reportable, isFalse);
  });

  test(
    'forum API redirects to HTML are distinguished from malformed API replies',
    () async {
      final dio = NetworkUtils.getDio();
      addTearDown(dio.close);
      final api = MobileApiClient(dio, baseUrl: 'https://example.test');

      for (final (destination, code, reportable) in [
        ('/forum-44-1.html', 'forum_webpage_redirect', false),
        ('/api/mobile/index.php', 'unexpected_markup_response', true),
      ]) {
        dio.httpClientAdapter = _ForumResponseAdapter(
          200,
          '<!doctype html><title>Forum</title>',
          'text/html',
          redirects: [RedirectRecord(301, 'GET', Uri.parse(destination))],
        );
        try {
          await api.displayForumResult('44', 1, {});
          fail('Expected the HTML response to be rejected');
        } catch (error) {
          final failure = forumRequestError(S.current, error);
          expect(failure.key, code);
          expect(failure.reportable, reportable);
        }
      }
    },
  );

  test(
    'network client reads Discuz JSON sent with a text content type',
    () async {
      final dio = NetworkUtils.getDio();
      addTearDown(dio.close);
      dio.httpClientAdapter = _ForumResponseAdapter(
        200,
        '{"error":"mobile_is_closed"}',
        'text/plain',
      );
      final api = MobileApiClient(dio, baseUrl: 'https://example.test');
      try {
        await api.hotThreadResult(1);
        fail('Expected a forum error');
      } catch (error) {
        final failure = forumRequestError(S.current, error);
        expect(failure.key, 'mobile_is_closed');
        expect(failure.content, S.current.forumFeatureDisabled);
        expect(failure.reportable, isFalse);
      }
    },
  );
}

class _ForumResponseAdapter implements HttpClientAdapter {
  _ForumResponseAdapter(
    this.status,
    this.body,
    this.contentType, {
    this.redirects,
  });
  final int status;
  final String body, contentType;
  final List<RedirectRecord>? redirects;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    body,
    status,
    headers: {
      Headers.contentTypeHeader: [contentType],
    },
  )..redirects = redirects;

  @override
  void close({bool force = false}) {}
}
