import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/utility/DiscuzCookieSessionManager.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:random_user_agents/random_user_agents.dart';

class NetworkUtils {
  static final ua = RandomUserAgents.random();
  static final DiscuzCookieSessionManager _cookieSessions =
      DiscuzCookieSessionManager(
    documentsDirectoryProvider: getApplicationDocumentsDirectory,
  );

  static Future<PersistCookieJar> getPersistentCookieJarByUser(
      User user) async {
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
    dio.interceptors.add(
      CookieManager(cookieJar, ignoreInvalidCookies: true),
    );
  }

  static Dio getDio() {
    return Dio(BaseOptions(
        headers: {'Accept-Language': "zh-CN,zh;q=0.9,zh-TW;q=0.8,en;q=0.6"}));
  }

  static Dio getDioInUserAgent() {
    return Dio(BaseOptions(headers: {
      'Accept-Language': "zh-CN,zh;q=0.9,zh-TW;q=0.8,en;q=0.6",
      'User-Agent':
          'Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/115.0',
    }));
  }

  static Future<Dio> getDioWithTempCookieJar() async {
    var dio = getDio();

    CookieJar cookieJar = await getTemporaryCookieJar();
    addCookieManager(dio, cookieJar);
    return dio;
  }

  static Future<Dio> getDioWithPersistCookieJar(User? user) async {
    var dio = getDio();
    if (user == null) {
      return dio;
    }
    final cookieJar = await getPersistentCookieJarByUser(user);
    addCookieManager(dio, cookieJar);
    return dio;
  }
}
