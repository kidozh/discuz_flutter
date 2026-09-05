import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:discuz_flutter/entity/User.dart';

typedef CookieDirectoryProvider = Future<Directory> Function();

/// Owns the persistent cookie jar for every Discuz account.
///
/// A [PersistCookieJar] keeps an in-memory snapshot in addition to its files.
/// Creating several jars for the same directory lets those snapshots diverge
/// and can make a later response write an older session back to disk. This
/// manager guarantees that all requests for one forum account share one jar.
class DiscuzCookieSessionManager {
  DiscuzCookieSessionManager({
    required CookieDirectoryProvider documentsDirectoryProvider,
  }) : _documentsDirectoryProvider = documentsDirectoryProvider;

  final CookieDirectoryProvider _documentsDirectoryProvider;
  final Map<String, Future<PersistCookieJar>> _persistentJars = {};

  Future<PersistCookieJar> getJar(User user) async {
    final key = sessionKeyFor(user);
    final future = _persistentJars.putIfAbsent(key, () => _createJar(user));
    try {
      return await future;
    } catch (_) {
      if (identical(_persistentJars[key], future)) {
        _persistentJars.remove(key);
      }
      rethrow;
    }
  }

  Future<void> replaceCookies(
    User user,
    Uri origin,
    List<Cookie> cookies,
  ) async {
    final jar = await getJar(user);
    await jar.deleteAll();
    if (cookies.isNotEmpty) {
      await jar.saveFromResponse(origin, cookies);
    }
    await _deleteLegacyJar(user);
  }

  Future<void> clear(User user) async {
    final key = sessionKeyFor(user);
    final cachedJar = _persistentJars.remove(key);
    final jar = cachedJar == null
        ? await _openJar(user, ignoreExpires: false)
        : await cachedJar;
    await jar.deleteAll();
    await _deleteLegacyJar(user);
  }

  String sessionKeyFor(User user) {
    return '${_normalizeBaseUrl(user.discuz.baseURL)}#${user.uid}';
  }

  Future<PersistCookieJar> _createJar(User user) async {
    final jar = await _openJar(user, ignoreExpires: false);
    final origin = _originFor(user);
    final currentCookies = await _loadOrReset(jar, origin);
    if (currentCookies.isNotEmpty) {
      return jar;
    }

    // Versions before the shared-session implementation used
    // ignoreExpires=true. cookie_jar stores that configuration in a separate
    // subdirectory, so copy its still-valid cookies once instead of logging
    // every existing user out during the upgrade.
    final legacyJar = await _openJar(user, ignoreExpires: true);
    final legacyCookies = await _loadOrReset(legacyJar, origin);
    final cookiesToMigrate = legacyCookies.where(_canMigrate).toList();
    if (cookiesToMigrate.isNotEmpty) {
      await jar.saveFromResponse(origin, cookiesToMigrate);
    }
    await legacyJar.deleteAll();
    return jar;
  }

  Future<List<Cookie>> _loadOrReset(
    PersistCookieJar jar,
    Uri origin,
  ) async {
    try {
      return await jar.loadForRequest(origin);
    } catch (_) {
      // Cookies are recoverable session state. If an old or malformed entry
      // cannot be decoded, reset this account's jar instead of failing every
      // subsequent network request with a cookie format exception.
      await jar.deleteAll();
      return const <Cookie>[];
    }
  }

  Future<PersistCookieJar> _openJar(
    User user, {
    required bool ignoreExpires,
  }) async {
    final documentsDirectory = await _documentsDirectoryProvider();
    final jar = PersistCookieJar(
      storage: FileStorage(_storagePath(documentsDirectory, user)),
      persistSession: true,
      ignoreExpires: ignoreExpires,
    );
    await jar.forceInit();
    return jar;
  }

  Future<void> _deleteLegacyJar(User user) async {
    final legacyJar = await _openJar(user, ignoreExpires: true);
    await legacyJar.deleteAll();
  }

  Uri _originFor(User user) {
    final uri = Uri.parse(user.discuz.baseURL.trim());
    return uri.path.isEmpty ? uri.replace(path: '/') : uri;
  }

  String _storagePath(Directory directory, User user) {
    // Keep the historical base path so existing sessions can be migrated.
    return '${directory.path}/v_cookie_${user.discuz.baseURL}_${user.uid}';
  }

  bool _canMigrate(Cookie cookie) {
    if (cookie.name.isEmpty) return false;
    if (cookie.maxAge != null && cookie.maxAge! <= 0) return false;
    final expires = cookie.expires;
    return expires == null || expires.isAfter(DateTime.now());
  }

  String _normalizeBaseUrl(String value) {
    final trimmed = value.trim();
    final uri = Uri.tryParse(trimmed);
    if (uri == null || uri.host.isEmpty) {
      return trimmed.replaceAll(RegExp(r'/+$'), '').toLowerCase();
    }

    final scheme = uri.scheme.toLowerCase();
    final host = uri.host.toLowerCase();
    final isDefaultPort = (scheme == 'https' && uri.port == 443) ||
        (scheme == 'http' && uri.port == 80);
    final port = uri.hasPort && !isDefaultPort ? ':${uri.port}' : '';
    final path = uri.path.replaceAll(RegExp(r'/+$'), '');
    return '$scheme://$host$port$path';
  }
}
