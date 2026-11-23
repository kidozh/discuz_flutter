import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/utility/DiscuzCookieSessionManager.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:html/parser.dart' as html;
import 'package:random_user_agents/random_user_agents.dart';

import '../client/ForumInteractionClient.dart';

class NetworkUtils {
  static final ua = RandomUserAgents.random();
  static final DiscuzCookieSessionManager _cookieSessions =
      DiscuzCookieSessionManager(
        documentsDirectoryProvider: getApplicationDocumentsDirectory,
      );

  static Future<PersistCookieJar> getPersistentCookieJarByUser(
    User user,
  ) async {
    return _cookieSessions.getJar(user);
  }

  static Future<CookieJar> getTemporaryCookieJar() async {
    // Login and forum discovery do not need cookies after the operation ends.
    // An in-memory jar also prevents concurrent flows from clearing the same
    // temporary directory underneath one another.
    return CookieJar();
  }

  static Future<void> replacePersistentCookiesForUser(
    User user,
    Uri origin,
    List<Cookie> cookies,
  ) {
    return _cookieSessions.replaceCookies(user, origin, cookies);
  }

  static Future<void> clearPersistentCookiesForUser(User user) {
    return _cookieSessions.clear(user);
  }

  static void addCookieManager(Dio dio, CookieJar cookieJar) {
    // Some Discuz installations send malformed analytics or legacy cookies.
    // Ignoring only those invalid Set-Cookie entries keeps the valid session
    // cookies and response instead of turning the whole request into an error.
    dio.interceptors.add(CookieManager(cookieJar, ignoreInvalidCookies: true));
  }

  static Dio getDio() {
    return Dio(
      BaseOptions(
        headers: {'Accept-Language': "zh-CN,zh;q=0.9,zh-TW;q=0.8,en;q=0.6"},
      ),
    )..transformer = _ForumResponseTransformer();
  }

  static Dio getDioInUserAgent() {
    return Dio(
      BaseOptions(
        headers: {
          'Accept-Language': "zh-CN,zh;q=0.9,zh-TW;q=0.8,en;q=0.6",
          'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/115.0',
        },
      ),
    );
  }

  static Future<Dio> getDioWithTempCookieJar() async {
    var dio = getDio();

    CookieJar cookieJar = await getTemporaryCookieJar();
    addCookieManager(dio, cookieJar);
    return dio;
  }

  static final _guestForumCookies = <String, CookieJar>{};

  static Future<Dio> getDioWithPersistCookieJar(
    User? user, {
    String? guestForum,
  }) async {
    var dio = getDio();
    if (user == null) {
      if (guestForum != null) {
        addCookieManager(
          dio,
          _guestForumCookies.putIfAbsent(guestForum, CookieJar.new),
        );
      }
      return dio;
    }
    final cookieJar = await getPersistentCookieJarByUser(user);
    addCookieManager(dio, cookieJar);
    return dio;
  }
}

class _ForumResponseTransformer extends FusedTransformer {
  @override
  Future<dynamic> transformResponse(
    RequestOptions options,
    ResponseBody body,
  ) async {
    if (options.responseType != ResponseType.json ||
        !options.uri.path.endsWith('/api/mobile/index.php')) {
      return super.transformResponse(options, body);
    }

    if (!options.validateStatus(body.statusCode)) {
      // Keep the error body and let Dio throw with its original HTTP status.
      return super.transformResponse(
        options.copyWith(responseType: ResponseType.plain),
        body,
      );
    }
    final destination =
        body.redirects?.fold(
          options.uri,
          (uri, redirect) => uri.resolveUri(redirect.location),
        ) ??
        options.uri;
    final redirectedAwayFromApi = !destination.path.endsWith(
      '/api/mobile/index.php',
    );
    final data = await super.transformResponse(
      redirectedAwayFromApi
          ? options.copyWith(responseType: ResponseType.plain)
          : options,
      body,
    );
    if (data is! String) return data;
    if (options.uri.queryParameters['module'] == 'forumdisplay' &&
        data.trimLeft().startsWith('<') &&
        html.parse(data).querySelector('form input[type=password][name=pw]') !=
            null) {
      throw const ForumApiException(
        'forum_passwd_required',
        '',
        fromForum: true,
      );
    }
    try {
      return ForumReply.decodePayload(data);
    } on ForumApiException catch (error) {
      if (redirectedAwayFromApi && error.code == 'unexpected_markup_response') {
        throw const ForumApiException(
          'forum_webpage_redirect',
          '',
          fromForum: true,
        );
      }
      rethrow;
    }
  }
}
