import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../entity/Discuz.dart';
import '../entity/User.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../provider/UserPreferenceNotifierProvider.dart';
import 'NetworkUtils.dart';

class ForumImageSession {
  ForumImageSession._(
    this.baseUrl,
    this._account,
    this._preferences,
    this._user,
  ) : identity = _account.sessionIdentity;

  final Uri baseUrl;
  final DiscuzAndUserNotifier _account;
  final UserPreferenceNotifierProvider _preferences;
  final User _user;
  final Object identity;

  static ForumImageSession? of(BuildContext context, Discuz? forum) {
    if (kIsWeb || forum == null) return null;
    final preferences = context.watch<UserPreferenceNotifierProvider?>();
    if (preferences == null ||
        !preferences.forumDisplay.useForumCookiesForImages) {
      return null;
    }
    final account = context.watch<DiscuzAndUserNotifier?>();
    final user = account?.user;
    final baseUrl = forumBaseUri(forum);
    if (account == null ||
        user == null ||
        baseUrl == null ||
        account.discuz == null ||
        forumBaseUri(account.discuz!) != baseUrl ||
        forumBaseUri(user.discuz) != baseUrl) {
      return null;
    }
    return ForumImageSession._(baseUrl, account, preferences, user);
  }

  bool get _active =>
      identical(identity, _account.sessionIdentity) &&
      _preferences.forumDisplay.useForumCookiesForImages;

  Uri? _forumImageUri(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !_isHttp(uri) || uri.origin != baseUrl.origin) {
      return null;
    }
    return uri;
  }

  ImageProvider? providerFor(String url) {
    final uri = _forumImageUri(url);
    return uri == null ? null : _ForumSessionImage(this, uri);
  }

  Future<Uint8List>? download(String url) {
    final uri = _forumImageUri(url);
    return uri == null ? null : _load(uri);
  }

  Future<Uint8List> _load(Uri uri) => loadForumImage(
    uri,
    forum: baseUrl,
    cookieJar: () async {
      if (!_active) return null;
      final jar = await NetworkUtils.getPersistentCookieJarByUser(_user);
      return _active ? jar : null;
    },
  );
}

Uri? forumBaseUri(Discuz forum) {
  final uri = Uri.tryParse(forum.baseURL.trim());
  if (uri == null || !_isHttp(uri)) return null;
  final path = uri.path.replaceFirst(RegExp(r'/+$'), '');
  return Uri.parse('${uri.origin}$path/');
}

bool _isHttp(Uri uri) =>
    (uri.scheme == 'http' || uri.scheme == 'https') &&
    uri.host.isNotEmpty &&
    uri.userInfo.isEmpty;

final _imageDio = NetworkUtils.getDio();
const _redirectStatuses = {301, 302, 303, 307, 308};

/// Read the account's cookies for each same-origin request. Follow redirects
/// explicitly so a response can redirect to a CDN without forwarding cookies.
@visibleForTesting
Future<Uint8List> loadForumImage(
  Uri uri, {
  required Uri forum,
  required Future<CookieJar?> Function() cookieJar,
}) async {
  if (!_isHttp(uri)) throw ArgumentError.value(uri, 'uri');
  var allowCookies = uri.origin == forum.origin;
  for (var redirects = 0; redirects <= 5; redirects++) {
    final jar = allowCookies ? await cookieJar() : null;
    final cookies = jar == null ? '' : await _cookieHeader(jar, uri);
    final response = await _imageDio.getUri<Uint8List>(
      uri,
      options: Options(
        followRedirects: false,
        responseType: ResponseType.bytes,
        headers: {if (cookies.isNotEmpty) HttpHeaders.cookieHeader: cookies},
        validateStatus: (status) =>
            status != null &&
            ((status >= 200 && status < 300) ||
                _redirectStatuses.contains(status)),
      ),
    );
    if (!_redirectStatuses.contains(response.statusCode)) {
      return response.data ?? (throw HttpException('Empty image', uri: uri));
    }
    final location = response.headers.value(HttpHeaders.locationHeader);
    final target = location == null ? null : uri.resolve(location);
    if (target == null || !_isHttp(target)) {
      throw HttpException('Invalid image redirect', uri: uri);
    }
    allowCookies = allowCookies && target.origin == forum.origin;
    uri = target;
  }
  throw HttpException('Too many image redirects', uri: uri);
}

Future<String> _cookieHeader(CookieJar jar, Uri uri) async {
  final cookies = (await jar.loadForRequest(uri))
      .where((cookie) => !cookie.secure || uri.scheme == 'https')
      .toList();
  // The current jar can return expired Secure cookies on HTTPS. Its stored
  // entries retain the creation time needed to enforce Max-Age.
  if (jar is DefaultCookieJar) {
    for (final path in [
      ...?jar.hostCookies[uri.host]?.values,
      ...jar.domainCookies.values.expand((paths) => paths.values),
    ]) {
      for (final stored in path.values) {
        if (stored.isExpired()) cookies.remove(stored.cookie);
      }
    }
  }
  return CookieManager.getCookies(cookies);
}

/// Keep authenticated images in the normal Flutter memory cache and scope
/// their keys to the current login, separate from public disk-cached images.
class _ForumSessionImage extends ImageProvider<_ForumSessionImage> {
  const _ForumSessionImage(this.session, this.uri);

  final ForumImageSession session;
  final Uri uri;

  @override
  Future<_ForumSessionImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(
    _ForumSessionImage key,
    ImageDecoderCallback decode,
  ) => MultiFrameImageStreamCompleter(codec: key._decode(decode), scale: 1);

  Future<ui.Codec> _decode(ImageDecoderCallback decode) async {
    try {
      final bytes = await session._load(uri);
      return await decode(await ui.ImmutableBuffer.fromUint8List(bytes));
    } catch (_) {
      scheduleMicrotask(() => PaintingBinding.instance.imageCache.evict(this));
      rethrow;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is _ForumSessionImage &&
      uri == other.uri &&
      identical(session.identity, other.session.identity);

  @override
  int get hashCode => Object.hash(uri, session.identity);
}
