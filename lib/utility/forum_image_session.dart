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
import '../entity/forum_display_preferences.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../provider/UserPreferenceNotifierProvider.dart';
import 'forum_image_site.dart';
import 'forum_image_url.dart';
import 'NetworkUtils.dart';

class ForumImageSession {
  ForumImageSession._(
    this.baseUrl,
    this._account,
    this._preferences,
    this._user,
    this._threadId,
    this._policy,
  ) : identity = _account.sessionIdentity;

  final Uri baseUrl;
  final DiscuzAndUserNotifier _account;
  final UserPreferenceNotifierProvider _preferences;
  final User _user;
  final int? _threadId;
  final ForumImageCookiePolicy _policy;
  final Object identity;
  Object get cacheKey => (identity, _policy);

  static ForumImageSession? of(
    BuildContext context,
    Discuz? forum, {
    int? threadId,
  }) {
    if (kIsWeb || forum == null) return null;
    final preferences = context.watch<UserPreferenceNotifierProvider?>();
    final policy = preferences?.forumDisplay.imageCookiePolicy;
    if (preferences == null ||
        policy == null ||
        policy == ForumImageCookiePolicy.never) {
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
    return ForumImageSession._(
      baseUrl,
      account,
      preferences,
      user,
      threadId,
      policy,
    );
  }

  bool get _active =>
      identical(identity, _account.sessionIdentity) &&
      _preferences.forumDisplay.imageCookiePolicy == _policy;

  Uri? _forumImageUri(String url) {
    final uri = resolveForumImageUri(baseUrl, url);
    return uri != null && _canUseForumSession(_policy, baseUrl, uri)
        ? uri
        : null;
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
    policy: _policy,
    threadId: _threadId,
    isCurrent: () => _active,
    cookieJar: () => NetworkUtils.getPersistentCookieJarByUser(_user),
  );
}

final _imageDio = NetworkUtils.getDio();
const _redirectStatuses = {301, 302, 303, 307, 308};

bool _canUseForumSession(ForumImageCookiePolicy policy, Uri forum, Uri image) =>
    switch (policy) {
      ForumImageCookiePolicy.never => false,
      ForumImageCookiePolicy.sameSite => sameForumImageSite(forum, image),
      ForumImageCookiePolicy.always =>
        forum.scheme != 'https' || image.scheme == 'https',
    };

/// Re-evaluate the cookie policy and scope at each redirect.
@visibleForTesting
Future<Uint8List> loadForumImage(
  Uri uri, {
  required Uri forum,
  required Future<CookieJar?> Function() cookieJar,
  ForumImageCookiePolicy policy = ForumImageCookiePolicy.sameSite,
  int? threadId,
  bool Function()? isCurrent,
  Dio? dio,
}) async {
  uri =
      resolveForumImageUri(forum, uri.toString()) ??
      (throw ArgumentError.value(uri, 'uri'));
  final referer = threadId != null && threadId > 0
      ? forum
            .resolve('forum.php')
            .replace(queryParameters: {'mod': 'viewthread', 'tid': '$threadId'})
      : forum;
  void checkSession() {
    if (isCurrent?.call() == false) {
      throw StateError('Forum image session changed');
    }
  }

  var useSession = _canUseForumSession(policy, forum, uri);
  for (var redirects = 0; redirects <= 5; redirects++) {
    checkSession();
    final sameOrigin = uri.origin == forum.origin;
    final jar = useSession ? await cookieJar() : null;
    final cookies = jar == null
        ? ''
        : await _cookieHeader(
            jar,
            uri,
            forumHost: policy == ForumImageCookiePolicy.sameSite
                ? forum.host
                : null,
          );
    checkSession();
    final response = await (dio ?? _imageDio).getUri<Uint8List>(
      uri,
      options: Options(
        followRedirects: false,
        responseType: ResponseType.bytes,
        headers: {
          if (cookies.isNotEmpty) HttpHeaders.cookieHeader: cookies,
          if (useSession && sameForumImageSite(forum, uri))
            HttpHeaders.refererHeader: sameOrigin
                ? referer.toString()
                : '${forum.origin}/',
        },
        validateStatus: (status) =>
            status != null &&
            ((status >= 200 && status < 300) ||
                _redirectStatuses.contains(status)),
      ),
    );
    checkSession();
    if (!_redirectStatuses.contains(response.statusCode)) {
      final data = response.data;
      if (data == null || data.isEmpty) {
        throw HttpException('Empty image', uri: uri);
      }
      return data;
    }
    final location = response.headers.value(HttpHeaders.locationHeader);
    final target = location == null
        ? null
        : resolveForumImageUri(uri, location);
    if (target == null) {
      throw HttpException('Invalid image redirect', uri: uri);
    }
    useSession = useSession && _canUseForumSession(policy, forum, target);
    uri = target;
  }
  throw HttpException('Too many image redirects', uri: uri);
}

Future<String> _cookieHeader(
  CookieJar jar,
  Uri uri, {
  String? forumHost,
}) async {
  final cookies = await jar.loadForRequest(uri);
  if (cookies.isEmpty) return '';

  final allowed = <Cookie>{};
  // The jar's paths preserve the default path, and its entries retain the
  // creation time needed to enforce Max-Age on Secure cookies.
  if (jar is DefaultCookieJar) {
    for (final entry in [
      ...?jar.hostCookies[uri.host]?.entries,
      ...jar.domainCookies.entries
          .where((entry) => _domainMatches(uri.host, entry.key))
          .expand((entry) => entry.value.entries),
    ]) {
      if (!_pathMatches(uri.path, entry.key)) continue;
      for (final stored in entry.value.values) {
        if (!stored.isExpired()) allowed.add(stored.cookie);
      }
    }
  }

  return CookieManager.getCookies(
    cookies.where((cookie) {
      if (cookie.secure && uri.scheme != 'https') return false;
      if (jar is DefaultCookieJar) {
        if (!allowed.contains(cookie)) return false;
      } else if (cookie.expires?.isBefore(DateTime.now()) == true ||
          (cookie.maxAge != null && cookie.maxAge! <= 0) ||
          !_pathMatches(uri.path, cookie.path ?? '/')) {
        return false;
      }
      final domain = cookie.domain?.toLowerCase().replaceFirst(
        RegExp(r'^\.'),
        '',
      );
      if (domain == null) return forumHost == null || uri.host == forumHost;
      return registrableDomain(domain) != null &&
          _domainMatches(uri.host, domain) &&
          (forumHost == null || _domainMatches(forumHost, domain));
    }).toList(),
  );
}

bool _domainMatches(String host, String domain) =>
    host == domain || host.endsWith('.$domain');

bool _pathMatches(String requestPath, String cookiePath) {
  final path = requestPath.isEmpty ? '/' : requestPath;
  return path == cookiePath ||
      path.startsWith(cookiePath.endsWith('/') ? cookiePath : '$cookiePath/');
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
      session._threadId == other.session._threadId &&
      session.cacheKey == other.session.cacheKey;

  @override
  int get hashCode => Object.hash(uri, session.cacheKey, session._threadId);
}
