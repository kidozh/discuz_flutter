import 'dart:developer';
import 'dart:io';

import 'package:discuz_flutter/app/ExclusiveDiscuzApp.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/provider/ReplyPostNotifierProvider.dart';
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/provider/TypeSettingNotifierProvider.dart';
import 'package:discuz_flutter/provider/UserPreferenceNotifierProvider.dart';
import 'package:discuz_flutter/utility/PushServiceUtils.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'app/MainApp.dart';
import 'dao/DiscuzDao.dart';
import 'entity/Discuz.dart';
import 'firebase_options.dart';


String initialPlatform = "";

bool isExclusiveDiscuz = false;

Discuz exclusiveDiscuz = Discuz("https://keylol.com", "X3.2", "utf-8", 4, "1.4.8", "register", true, "true", "true", "其乐 Keylol", "0", "https://keylol.com/uc_server", "161");

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async{
  // init google ads

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // init for hive
  await Hive.initFlutter();
  await AppDatabase.initBoxes();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  // check for iOS
  if(Platform.isIOS){

    String? apnsToken = await messaging.getAPNSToken();
    print("Get APNS token ${apnsToken}");
  }
  // await messaging.getToken();
  await PushServiceUtils.initFirebaseLocalNotification();
  await PushServiceUtils.initPushInformation(navigatorKey);


  log("languages initialization");
  initialPlatform = await UserPreferencesUtils.getPlatformPreference();
  Discuz discuz = exclusiveDiscuz;
  // save them to database first
  if(isExclusiveDiscuz){
    // save discuz to database first
    DiscuzDao discuzDao = await AppDatabase.getDiscuzDao();
    Discuz? existDiscuz = await discuzDao.findDiscuzByBaseURL(exclusiveDiscuz.baseURL);
    if(existDiscuz == null){
      // insert it if not exist
      var insertKey = await discuzDao.insertDiscuz(exclusiveDiscuz);
      print(insertKey);
    }
    // final extract
    Discuz? savedDiscuz = await discuzDao.findDiscuzByBaseURL(exclusiveDiscuz.baseURL);
    if(savedDiscuz != null){
      print("find the discuz!");
      discuz = savedDiscuz;
    }
    else{
      print("Can't find the saved discuz in dataset");
    }
  }

  FlutterNativeSplash.remove();

  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: ThemeNotifierProvider()),
          ChangeNotifierProvider.value(value: DiscuzAndUserNotifier()),
          ChangeNotifierProvider.value(value: ReplyPostNotifierProvider()),
          ChangeNotifierProvider.value(value: TypeSettingNotifierProvider()),
          ChangeNotifierProvider.value(value: UserPreferenceNotifierProvider())
        ],
        child: isExclusiveDiscuz? ExclusiveDiscuzApp(initialPlatform,discuz): MyApp(initialPlatform, navigatorKey),
      ));

}


