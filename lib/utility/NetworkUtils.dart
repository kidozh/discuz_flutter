
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

class NetworkUtils{


  static Future<PersistCookieJar> getPersistentCookieJarByUser(User user) async{
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath =appDocDir.path+"/cookie_${user.id}";
    var cookieJar=PersistCookieJar(storage:FileStorage(appDocPath),ignoreExpires: true,);
    return cookieJar;
  }

  static Future<PersistCookieJar> getPersistentCookieJarByUserId(int uid) async{
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath =appDocDir.path+"/cookie_${uid}";
    var cookieJar=PersistCookieJar(storage:FileStorage(appDocPath),ignoreExpires: true,);
    return cookieJar;
  }

  static Future<PersistCookieJar> getTemporaryCookieJar() async{
    Directory tempDir = await getTemporaryDirectory();
    var tempPath = tempDir.path+"/temp_cookie";
    var cookieJar=PersistCookieJar(storage:FileStorage(tempPath));
    // clear before using it
    cookieJar.deleteAll();
    return cookieJar;
  }

  static Future<Dio> getDioWithTempCookieJar() async{
    var dio =  Dio();
    PersistCookieJar cookieJar = await getTemporaryCookieJar();
    dio.interceptors.add(CookieManager(cookieJar));
    return dio;
  }

  static Future<Dio> getDioWithPersistCookieJar(User? user) async{
    if(user == null){
      return Dio();
    }
    else{
      var dio =  Dio();
      PersistCookieJar cookieJar = await getPersistentCookieJarByUser(user);
      dio.interceptors.add(CookieManager(cookieJar));
      return dio;
    }
  }
}