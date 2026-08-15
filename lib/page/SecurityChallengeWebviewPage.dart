import 'dart:convert';
import 'dart:io';

import 'package:discuz_flutter/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Holds cookies extracted from the WebView after a security challenge completes.
class SecurityChallengeResult {
  final List<Cookie> cookies;

  SecurityChallengeResult({required this.cookies});
}

/// A page that opens a URL inside a WebView so the user can complete a
/// security challenge (e.g. a TencentEdgeOne / EdgeOne JavaScript challenge).
///
/// Once the page content can be parsed as a Discuz JSON response the page pops
/// and returns a [SecurityChallengeResult] containing the cookies from the
/// WebView's cookie store so that they can be replayed with Dio.
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

  const _SecurityChallengeWebviewStatefulPage({Key? key, required this.checkUrl})
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
  /// content is recognised as a valid JSON object with a `discuzversion` or
  /// `sitename` key (i.e. the challenge has been completed and the real API
  /// response is now visible).
  Future<bool> _verifyChallengePassed() async {
    if (_challengeCompleted || !mounted) return false;

    try {
      final raw = await _controller
          .runJavaScriptReturningResult('document.body.innerText');

      // The JS result is a JSON-encoded string literal; unwrap it.
      String content = raw.toString();
      if (content.length >= 2 &&
          content.startsWith('"') &&
          content.endsWith('"')) {
        content = content.substring(1, content.length - 1);
        content = content
            .replaceAll(r'\"', '"')
            .replaceAll(r'\\', '\\')
            .replaceAll(r'\n', '\n')
            .replaceAll(r'\r', '\r')
            .replaceAll(r'\t', '\t');
      }

      final decoded = jsonDecode(content);
      if (decoded is Map<String, dynamic> &&
          (decoded.containsKey('discuzversion') ||
              decoded.containsKey('sitename'))) {
        _challengeCompleted = true;

        List<Cookie> cookies = [];
        try {
          cookies = await _cookieManager.getCookies(widget.checkUrl);
        } catch (_) {
          // Cookie extraction failure is non-fatal; proceed with empty list.
        }

        if (mounted) {
          Navigator.pop(context, SecurityChallengeResult(cookies: cookies));
        }
        return true;
      }
    } catch (_) {
      // Page is still showing the challenge or non-JSON content – do nothing.
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      iosContentBottomPadding: true,
      iosContentPadding: true,
      appBar: PlatformAppBar(
        title: Text(S.of(context).securityChallengeTitle),
        trailingActions: [
          if (_isLoading)
            Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              child: PlatformCircularProgressIndicator(),
            )
          else
            IconButton(
              icon: Icon(PlatformIcons(context).checkMark, size: 24),
              onPressed: _verifyChallengePassed,
            ),
        ],
      ),
      body: Builder(
        builder: (_) => WebViewWidget(controller: _controller),
      ),
    );
  }
}
