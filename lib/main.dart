import 'dart:developer';
import 'package:discuz_flutter/app/ExclusiveDiscuzApp.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/provider/ReplyPostNotifierProvider.dart';
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/provider/TypeSettingNotifierProvider.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'app/MainApp.dart';
import 'dao/DiscuzDao.dart';
import 'entity/Discuz.dart';


String initialPlatform = "";

bool isExclusiveDiscuz = false;

Discuz exclusiveDiscuz = Discuz("https://keylol.com", "X3.2", "utf-8", 4, "1.4.8", "register", true, "true", "true", "其乐 Keylol", "0", "https://keylol.com/uc_server", "161");

void main() async{
  // init google ads

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // init for hive
  await Hive.initFlutter();
  await AppDatabase.initBoxes();

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
          ChangeNotifierProvider.value(value: TypeSettingNotifierProvider())
        ],
        child: isExclusiveDiscuz? ExclusiveDiscuzApp(initialPlatform,discuz): MyApp(initialPlatform),
      ));

}


