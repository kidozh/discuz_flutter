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
    final uri = resolveForumImageUri(baseUrl, url);
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

  Future<File> downloadAttachment(
    Uri uri,
    Directory directory, {
    String? filename,
  }) => downloadForumAttachment(
    uri,
    directory,
    forum: baseUrl,
    filename: filename,
    policy: _policy,
    threadId: _threadId,
    isCurrent: () => _active,
    cookieJar: () => NetworkUtils.getPersistentCookieJarByUser(_user),
  );
}

final _resourceDio = NetworkUtils.getDio();
const _redirectStatuses = {301, 302, 303, 307, 308};

bool _canUseForumSession(ForumImageCookiePolicy policy, Uri forum, Uri image) =>
    switch (policy) {
      ForumImageCookiePolicy.never => false,
      ForumImageCookiePolicy.sameSite => sameForumImageSite(forum, image),
      ForumImageCookiePolicy.always =>
        forum.scheme != 'https' || image.scheme == 'https',
    };

Future<Uint8List> loadForumImage(
  Uri uri, {
  required Uri forum,
  Future<CookieJar?> Function()? cookieJar,
  ForumImageCookiePolicy policy = ForumImageCookiePolicy.sameSite,
  int? threadId,
  bool Function()? isCurrent,
  Dio? dio,
}) async {
  final response = await _getForumResource<Uint8List>(
    uri,
    forum: forum,
    cookieJar: cookieJar,
    policy: policy,
    threadId: threadId,
    isCurrent: isCurrent,
    dio: dio,
    responseType: ResponseType.bytes,
  );
  final data = response.data;
  if (data == null || data.isEmpty || _isHtml(response.headers)) {
    throw HttpException('No image received', uri: response.requestOptions.uri);
  }
  return data;
}

Future<File> downloadForumAttachment(
  Uri uri,
  Directory directory, {
  required Uri forum,
  String? filename,
  ForumImageCookiePolicy policy = ForumImageCookiePolicy.never,
  int? threadId,
  bool Function()? isCurrent,
  Future<CookieJar?> Function()? cookieJar,
  Dio? dio,
}) async {
  final response = await _getForumResource<ResponseBody>(
    uri,
    forum: forum,
    responseType: ResponseType.stream,
    policy: policy,
    threadId: threadId,
    isCurrent: isCurrent,
    cookieJar: cookieJar,
    dio: dio,
  );
  final body = response.data;
  final disposition = response.headers.value('content-disposition');
  // Discuz can return a login or permission page with HTTP 200.
  if (body == null || (_isHtml(response.headers) && disposition == null)) {
    await body?.stream.listen(null).cancel();
    throw HttpException(
      'No attachment received',
      uri: response.requestOptions.uri,
    );
  }
  Directory? downloadDirectory;
  var consuming = false;
  try {
    downloadDirectory = await directory.createTemp('attachment-');
    final name = _attachmentFilename(
      filename,
      disposition,
      response.requestOptions.uri,
    );
    final file = File(
      '${downloadDirectory.path}${Platform.pathSeparator}$name',
    );
    _checkSession(isCurrent);
    final sink = file.openWrite();
    var received = 0;
    try {
      consuming = true;
      await sink.addStream(
        body.stream.map((bytes) {
          _checkSession(isCurrent);
          received += bytes.length;
          return bytes;
        }),
      );
    } finally {
      await sink.close();
    }
    _checkSession(isCurrent);
    if (received == 0) throw HttpException('Empty attachment', uri: uri);
    return file;
  } catch (_) {
    if (!consuming) await body.stream.listen(null).cancel();
    await downloadDirectory?.delete(recursive: true);
    rethrow;
  }
}

bool _isHtml(Headers headers) =>
    headers
        .value(HttpHeaders.contentTypeHeader)
        ?.split(';')
        .first
        .trim()
        .toLowerCase() ==
    'text/html';

String _attachmentFilename(String? preferred, String? disposition, Uri uri) {
  final encoded = RegExp(
    "filename\\*=utf-8'[^']*'([^;]+)",
    caseSensitive: false,
  ).firstMatch(disposition ?? '')?.group(1);
  final plain = RegExp(
    r'filename\s*=\s*(?:"([^"]+)"|([^;]+))',
    caseSensitive: false,
  ).firstMatch(disposition ?? '');
  String? decoded;
  if (encoded != null) {
    try {
      decoded = Uri.decodeComponent(encoded.trim());
    } on FormatException {
      // A malformed optional filename can fall back to the plain header.
    }
  }
  for (final candidate in [
    preferred,
    decoded,
    plain?.group(1) ?? plain?.group(2),
    if (!isForumAttachmentUrl(uri)) uri.pathSegments.lastOrNull,
  ]) {
    final name = candidate
        ?.split(RegExp(r'[/\\]'))
        .last
        .trim()
        .replaceAll(RegExp(r'[\x00-\x1f<>:"|?*]'), '_');
    if (name != null && name.isNotEmpty && name != '.' && name != '..') {
      return name;
    }
  }
  return 'attachment';
}

void _checkSession(bool Function()? isCurrent) {
  if (isCurrent?.call() == false) {
    throw ForumResourceSessionChanged();
  }
}

class ForumResourceSessionChanged extends StateError {
  ForumResourceSessionChanged() : super('Forum resource session changed');
}

/// Re-evaluate the cookie policy and scope at each redirect.
Future<Response<T>> _getForumResource<T>(
  Uri uri, {
  required Uri forum,
  required ResponseType responseType,
  Future<CookieJar?> Function()? cookieJar,
  ForumImageCookiePolicy policy = ForumImageCookiePolicy.never,
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
  var useSession = _canUseForumSession(policy, forum, uri);
  for (var redirects = 0; redirects <= 5; redirects++) {
    _checkSession(isCurrent);
    final sameOrigin = uri.origin == forum.origin;
    final jar = useSession ? await cookieJar?.call() : null;
    final cookies = jar == null
        ? ''
        : await _cookieHeader(
            jar,
            uri,
            forumHost: policy == ForumImageCookiePolicy.sameSite
                ? forum.host
                : null,
          );
    _checkSession(isCurrent);
    final response = await (dio ?? _resourceDio).getUri<T>(
      uri,
      options: Options(
        followRedirects: false,
        responseType: responseType,
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
    final redirected = _redirectStatuses.contains(response.statusCode);
    final body = response.data;
    final sessionChanged = isCurrent?.call() == false;
    if (body is ResponseBody && (redirected || sessionChanged)) {
      await body.stream.listen(null).cancel();
    }
    if (sessionChanged) throw ForumResourceSessionChanged();
    if (!redirected) return response;
    final location = response.headers.value(HttpHeaders.locationHeader);
    final target = location == null
        ? null
        : resolveForumImageUri(uri, location);
    if (target == null) {
      throw HttpException('Invalid resource redirect', uri: uri);
    }
    useSession = useSession && _canUseForumSession(policy, forum, target);
    uri = target;
  }
  throw HttpException('Too many resource redirects', uri: uri);
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
