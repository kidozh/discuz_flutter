import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/ExploreWebsitePage.dart';
import 'package:discuz_flutter/page/InternalWebviewBrowserPage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/utility/forum_web_location.dart';
import 'package:discuz_flutter/widget/forum_web_location_banner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Exercise the browser's actual navigation delegate without a native WebView.
// ignore: depend_on_referenced_packages
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

const forumUrl = 'https://forum.test/bbs';
final site = Discuz(
  forumUrl,
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

Widget host(Widget child, {AppVisualStyle style = AppVisualStyle.cupertino}) =>
    PlatformProvider(
      style: style,
      builder: (_) => MaterialApp(
        theme: ThemeData.dark(),
        locale: const Locale('zh', 'CN'),
        supportedLocales: S.delegate.supportedLocales,
        localizationsDelegates: const [
          S.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        home: child,
      ),
    );

void main() {
  test('forum boundary respects host, port and installation path', () {
    for (final url in [
      '$forumUrl/',
      '$forumUrl/forum.php?mod=guide#posts',
      'https://FORUM.test:443/bbs',
      'http://forum.test/bbs/forum.php',
      '$forumUrl/folder/../forum.php',
    ]) {
      expect(isForumWebLocation(forumUrl, url), isTrue, reason: url);
    }
    for (final url in [
      'https://other.test/bbs',
      'https://forum.test.evil.test/bbs',
      'https://login.forum.test/bbs',
      'https://forum.test:8443/bbs',
      'https://forum.test/bbs-other',
      'https://forum.test/another-forum',
      '$forumUrl/%2e%2e/outside',
      'https://forum.test@other.test/bbs',
      'https://user:password@forum.test/bbs',
      'data:text/html,Forum',
      'about:blank',
      'invalid',
    ]) {
      expect(isForumWebLocation(forumUrl, url), isFalse, reason: url);
    }
    expect(
      isForumWebLocation('http://forum.test:8080', 'http://forum.test:8080/a'),
      isTrue,
    );
    expect(
      isForumWebLocation('http://forum.test:8080', 'http://forum.test/a'),
      isFalse,
    );
  });

  test('visible address excludes login credentials and URL tokens', () {
    expect(
      forumWebLocationLabel(
        'https://user:secret@other.test/path?token=private#secret',
      ),
      'https://other.test/path',
    );
    expect(forumWebLocationLabel('data:text/html,private'), 'data:');
    expect(forumWebLocationLabel('not a URL'), '—');
  });

  for (final style in AppVisualStyle.values) {
    testWidgets('notice fits narrow screens with large text in $style', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2)),
              child: const SizedBox(
                width: 280,
                child: Column(
                  children: [
                    ForumWebLocationBanner(
                      forumUrl: forumUrl,
                      pageUrl: 'https://external.example.test/a/long/page/path?secret=hidden',
                    ),
                  ],
                ),
              ),
            ),
          ),
          style: style,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('已离开当前论坛'), findsOneWidget);
      expect(
        find.text('https://external.example.test/a/long/page/path'),
        findsOneWidget,
      );
      expect(
        find.byIcon(
          style.effective == AppVisualStyle.material
              ? Icons.info_outline
              : CupertinoIcons.info_circle,
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('both browsers track redirects and history, ignoring subframes', (
    tester,
  ) async {
    // Both pages share the serialized cookie loader; keep its asynchronous
    // queue within one test clock, just as the app uses one event loop.
    for (final embedded in [false, true]) {
      final platform = _WebPlatform();
      final previous = WebViewPlatform.instance;
      WebViewPlatform.instance = platform;
      addTearDown(() => WebViewPlatform.instance = previous ?? _WebPlatform());
      final messenger = tester.binding.defaultBinaryMessenger;
      const cookies = MethodChannel(
        'com.kidozh.discuz_flutter/webview_cookies',
      );
      const haptics = MethodChannel('haptic_feedback');
      messenger.setMockMethodCallHandler(cookies, (_) async => null);
      messenger.setMockMethodCallHandler(haptics, (_) async => false);
      addTearDown(() {
        messenger.setMockMethodCallHandler(cookies, null);
        messenger.setMockMethodCallHandler(haptics, null);
      });
      SharedPreferences.setMockInitialValues({});
      final account = DiscuzAndUserNotifier()..initDiscuz(site);
      addTearDown(account.dispose);
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: account,
          child: host(
            embedded
                ? InnerWebviewScreen(const ValueKey('embedded'), site, null)
                : InternalWebviewBrowserPage(site, null, '$forumUrl/forum.php'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final delegate = platform.delegate;
      expect(find.text('已离开当前论坛'), findsNothing);
      expect(
        await delegate.navigation!(
          const NavigationRequest(
            url: 'https://captcha.test',
            isMainFrame: false,
          ),
        ),
        NavigationDecision.navigate,
      );
      await tester.pump();
      expect(find.text('已离开当前论坛'), findsNothing);

      // Main-frame load begins, then an HTTP redirect changes the real URL.
      delegate.started!('$forumUrl/redirect.php');
      delegate.changed!(
        const UrlChange(url: 'https://outside.test/page?token=private'),
      );
      await tester.pumpAndSettle();
      expect(find.text('已离开当前论坛'), findsOneWidget);
      expect(find.text('https://outside.test/page'), findsOneWidget);

      // History and script navigation can change the URL without a full load.
      delegate.changed!(const UrlChange(url: '$forumUrl/forum.php'));
      await tester.pump();
      expect(find.text('已离开当前论坛'), findsNothing);
      delegate.changed!(const UrlChange(url: 'https://outside.test/page'));
      await tester.pump();
      expect(find.text('已离开当前论坛'), findsOneWidget);
      delegate.changed!(const UrlChange(url: null));
      await tester.pump();
      expect(find.text('已离开当前论坛'), findsOneWidget);

      // Late callbacks from a closed browser must not update disposed state.
      await tester.pumpWidget(const SizedBox.shrink());
      delegate.changed!(const UrlChange(url: '$forumUrl/forum.php'));
      await tester.pump();
      expect(tester.takeException(), isNull);
    }
  });
}

class _WebPlatform extends WebViewPlatform {
  late _Delegate delegate;
  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) => _Controller(params);
  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) => delegate = _Delegate(params);
  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) => _WebWidget(params);
}

class _Controller extends PlatformWebViewController {
  _Controller(super.params) : super.implementation();
  @override
  Future<void> setJavaScriptMode(JavaScriptMode mode) async {}
  @override
  Future<void> setPlatformNavigationDelegate(
    PlatformNavigationDelegate handler,
  ) async {}
  @override
  Future<void> loadRequest(LoadRequestParams params) async {}
  @override
  Future<String?> getTitle() async => 'Forum page title';
}

class _Delegate extends PlatformNavigationDelegate {
  _Delegate(super.params) : super.implementation();
  NavigationRequestCallback? navigation;
  PageEventCallback? started;
  UrlChangeCallback? changed;
  @override
  Future<void> setOnNavigationRequest(
    NavigationRequestCallback callback,
  ) async => navigation = callback;
  @override
  Future<void> setOnPageStarted(PageEventCallback callback) async =>
      started = callback;
  @override
  Future<void> setOnPageFinished(PageEventCallback callback) async {}
  @override
  Future<void> setOnProgress(ProgressCallback callback) async {}
  @override
  Future<void> setOnUrlChange(UrlChangeCallback callback) async =>
      changed = callback;
}

class _WebWidget extends PlatformWebViewWidget {
  _WebWidget(super.params) : super.implementation();
  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}
