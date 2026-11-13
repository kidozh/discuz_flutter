import 'dart:io';

import 'package:flutter/services.dart';

/// Shares the system WebView store with the app's HTTP cookie jar.
/// Native access preserves HttpOnly, Secure and expiration on Apple platforms.
/// webview_flutter's public cookie DTO does not carry those attributes yet.
class DiscuzWebviewCookieManager {
  const DiscuzWebviewCookieManager();

  static const _channel = MethodChannel(
    'com.kidozh.discuz_flutter/webview_cookies',
  );
  static Future<void> _loading = Future.value();

  /// The native cookie store is shared across WebViews. Install a complete
  /// account session and start its navigation as one operation.
  Future<void> loadWithCookies(
    List<Cookie> cookies, {
    required String origin,
    required bool Function() isCurrent,
    required Future<void> Function() load,
  }) {
    final operation = _loading.then((_) async {
      if (!isCurrent()) return;
      await clearCookies();
      if (!isCurrent()) return;
      if (cookies.isNotEmpty) await setCookies(cookies, origin: origin);
      if (isCurrent()) await load();
    });
    _loading = operation.then((_) {}, onError: (Object _, StackTrace __) {});
    return operation;
  }

  Uri _url(String value) {
    final uri = Uri.parse(value);
    if (!uri.hasAuthority ||
        uri.host.isEmpty ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      throw ArgumentError('WebView cookies require an HTTP(S) URL');
    }
    return uri;
  }

  Future<List<Cookie>> getCookies(String url) async {
    final uri = _url(url);
    final rows = await _channel.invokeListMethod<Object?>('getCookies', {
      'url': uri.toString(),
    });
    final cookies = <Cookie>[];
    for (final row in rows ?? const []) {
      if (row is! Map || row['name'] is! String || row['value'] is! String) {
        continue;
      }
      try {
        final cookie = Cookie(row['name'] as String, row['value'] as String)
          ..httpOnly = row['httpOnly'] as bool? ?? true
          ..secure = row['secure'] as bool? ?? false;
        if (row['domain'] is String) cookie.domain = row['domain'] as String;
        if (row['path'] is String) cookie.path = row['path'] as String;
        if (row['expiresAt'] is num) {
          cookie.expires = DateTime.fromMillisecondsSinceEpoch(
            (row['expiresAt'] as num).toInt(),
            isUtc: true,
          );
        }
        cookies.add(cookie);
      } on FormatException {
        // Ignore one malformed browser cookie without discarding the session.
      } on ArgumentError {
        // Cookie validates names and values separately on some Dart versions.
      }
    }
    return cookies;
  }

  Future<void> clearCookies() => _channel.invokeMethod<void>('clearCookies');

  Future<void> setCookies(List<Cookie> cookies, {required String origin}) {
    final uri = _url(origin);
    return _channel.invokeMethod<void>('setCookies', {
      'url': uri.toString(),
      'cookies': [for (final cookie in cookies) cookie.toString()],
    });
  }
}
