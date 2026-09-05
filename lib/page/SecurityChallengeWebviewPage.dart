import 'dart:convert';
import 'dart:io';

import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/DiscuzCheckResponseUtils.dart';
import 'package:flutter/material.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Holds the validated API response and any cookies extracted from the WebView
/// after a security challenge completes.
class SecurityChallengeResult {
  final List<Cookie> cookies;
  final String? rawResponse;

  SecurityChallengeResult({required this.cookies, this.rawResponse});
}

/// A page that opens a URL inside a WebView so the user can complete a
/// security challenge (e.g. a TencentEdgeOne / EdgeOne JavaScript challenge).
///
/// Once the page content can be parsed as a Discuz JSON response the page pops
/// and returns a [SecurityChallengeResult]. The caller can consume the validated
/// response directly and only needs to replay the cookies as a fallback.
///
/// Usage:
/// ```dart
/// final result = await Navigator.push<SecurityChallengeResult>(
///   context,
///   platformPageRoute(
///     context: context,
///     builder: (_) => SecurityChallengeWebviewPage(checkUrl: url),
///   ),
/// );
/// if (result != null) { /* use result.cookies */ }
/// ```
class SecurityChallengeWebviewPage extends StatelessWidget {
  final String checkUrl;

  const SecurityChallengeWebviewPage({Key? key, required this.checkUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _SecurityChallengeWebviewStatefulPage(checkUrl: checkUrl);
  }
}

class _SecurityChallengeWebviewStatefulPage extends StatefulWidget {
  final String checkUrl;

  const _SecurityChallengeWebviewStatefulPage(
      {Key? key, required this.checkUrl})
      : super(key: key);

  @override
  _SecurityChallengeWebviewState createState() =>
      _SecurityChallengeWebviewState();
}

class _SecurityChallengeWebviewState
    extends State<_SecurityChallengeWebviewStatefulPage> {
  final _cookieManager = WebviewCookieManager();
  late final WebViewController _controller;

  bool _isLoading = true;
  bool _challengeCompleted = false;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                _isLoading = true;
              });
            }
          },
          onPageFinished: (_) async {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
            // Try to detect automatic challenge completion.
            await _verifyChallengePassed();
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkUrl));
  }

  /// Reads the visible text of the page via JavaScript and tries to parse it
  /// as a Discuz API JSON response.  Returns true and pops the route if the
  /// content is recognised as a valid JSON object with `discuzversion` and
  /// `sitename` keys (i.e. the challenge has been completed and the real API
  /// response is now visible).
  Future<bool> _verifyChallengePassed() async {
    if (_challengeCompleted || _isVerifying || !mounted) return false;
    _isVerifying = true;

    try {
      final decoded = await _readCheckResponseFromPage();
      if (decoded != null) {
        _challengeCompleted = true;

        List<Cookie> cookies = [];
        try {
          cookies = await _cookieManager.getCookies(widget.checkUrl);
        } catch (_) {
          // Cookie extraction failure is non-fatal; proceed with empty list.
        }

        if (mounted) {
          Navigator.pop(
            context,
            SecurityChallengeResult(
              cookies: cookies,
              rawResponse: jsonEncode(decoded),
            ),
          );
        }
        return true;
      }
      return false;
    } catch (_) {
      // Page is still showing the challenge or non-JSON content – do nothing.
      return false;
    } finally {
      _isVerifying = false;
    }
  }

  Future<Map<String, dynamic>?> _readCheckResponseFromPage() async {
    const scripts = <String>[
      "document.querySelector('pre')?.textContent ?? document.body?.innerText ?? ''",
      "document.documentElement?.outerHTML ?? ''",
    ];
    for (final script in scripts) {
      final raw = await _controller.runJavaScriptReturningResult(script);
      final decoded = DiscuzCheckResponseUtils.tryDecode(raw.toString());
      if (decoded != null) return decoded;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      iosContentBottomPadding: true,
      iosContentPadding: true,
      appBar: PlatformAppBar(
        title: Text(S.of(context).securityChallengeTitle),
        trailingActions: [
          if (!_isLoading)
            PlatformIconButton(
              liquidGlassSymbol: 'checkmark',
              icon: Icon(
                PlatformIcons(context).checkMark,
                size: 20,
                semanticLabel: S.of(context).ok,
              ),
              onPressed: _verifyChallengePassed,
            ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const PositionedDirectional(
              top: 12,
              end: 12,
              child: IgnorePointer(
                child: PlatformLiquidGlassSurface(
                  borderRadius: BorderRadius.all(Radius.circular(22)),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: PlatformCircularProgressIndicator(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
