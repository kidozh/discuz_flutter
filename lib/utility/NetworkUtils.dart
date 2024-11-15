
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:discuz_flutter/entity/User.dart';
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

  static Future<Dio> getDioWithTempCookieJar() async{
    String userAgent = ua;
    final header =  await userAgentClientHintsHeader();
    var dio =  Dio(
      BaseOptions(
        headers: {
          'User-Agent': userAgent,
          //'Accept-Language': 'en-US,en;q=0.9'
        }
      )
    );
    print("Running on UA ${ua} ${header}");
    
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
      String userAgent = ua;
      var dio =  Dio(
          BaseOptions(
              headers: {
                'User-Agent': userAgent
              }
          )
      );
      // dio.interceptors.add(InterceptorsWrapper(
      //   onRequest: (options, handler) async{
      //     options.headers.addAll(await userAgentClientHintsHeader());
      //     //return options;
      //   },
      // ));
      return dio;
    }
    else{
      String userAgent = ua;
      var dio =  Dio(
          BaseOptions(
              headers: {
                'User-Agent': userAgent
              }
          )
      );
      // dio.interceptors.add(InterceptorsWrapper(
      //   onRequest: (options, handler) async{
      //     options.headers.addAll(await userAgentClientHintsHeader());
      //     //return options;
      //   },
      // ));
      PersistCookieJar cookieJar = await getPersistentCookieJarByUser(user);
      dio.interceptors.add(CookieManager(cookieJar));
      return dio;
    }
  }
}