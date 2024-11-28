
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:language_code/language_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:random_user_agents/random_user_agents.dart';
import 'package:ua_client_hints/ua_client_hints.dart';

class NetworkUtils{

  static final ua = RandomUserAgents.random();

  static Future<PersistCookieJar> getPersistentCookieJarByUser(User user) async{
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath =appDocDir.path+"/v_cookie_${user.discuz.baseURL}_${user.uid}";
    var cookieJar=PersistCookieJar(storage:FileStorage(appDocPath),ignoreExpires: true,);
    return cookieJar;
  }

  // static Future<PersistCookieJar> getPersistentCookieJarByUserId(int uid) async{
  //   Directory appDocDir = await getApplicationDocumentsDirectory();
  //   String appDocPath =appDocDir.path+"/cookie_${uid}";
  //   var cookieJar=PersistCookieJar(storage:FileStorage(appDocPath),ignoreExpires: true,);
  //   return cookieJar;
  // }

  static Future<PersistCookieJar> getTemporaryCookieJar() async{
    Directory tempDir = await getTemporaryDirectory();
    var tempPath = tempDir.path+"/temp_cookie";
    var cookieJar=PersistCookieJar(storage:FileStorage(tempPath));
    // clear before using it
    cookieJar.deleteAll();
    return cookieJar;
  }

  static Dio getDio(){
    return Dio(BaseOptions(
      headers: {
        'Accept-Language': LanguageCode.code.name
      }
    ));
  }

  static Future<Dio> getDioWithTempCookieJar() async{

    var dio = getDio();
    
    PersistCookieJar cookieJar = await getTemporaryCookieJar();
    dio.interceptors.add(CookieManager(cookieJar));
    // dio.interceptors.add(InterceptorsWrapper(
    //     onRequest: (options, handler) async{
    //       options.headers.addAll(await userAgentClientHintsHeader());
    //       //return options;
    //     },
    // ));
    return dio;
  }

  static Future<Dio> getDioWithPersistCookieJar(User? user) async{
    if(user == null){
      var dio = getDio();


      return dio;
    }
    else{
      var dio = getDio();
      PersistCookieJar cookieJar = await getPersistentCookieJarByUser(user);
      dio.interceptors.add(CookieManager(cookieJar));
      return dio;
    }
  }
}