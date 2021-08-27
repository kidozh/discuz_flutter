import 'dart:developer';
import 'package:discuz_flutter/app/ExclusiveDiscuzApp.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/provider/ReplyPostNotifierProvider.dart';
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/provider/TypeSettingNotifierProvider.dart';
import 'package:discuz_flutter/utility/DBHelper.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/MainApp.dart';
import 'dao/DiscuzDao.dart';
import 'entity/Discuz.dart';


String initialPlatform = "";

bool isExclusiveDiscuz = true;

void main() async{
  // init google ads

  WidgetsFlutterBinding.ensureInitialized();
  log("languages initialization");
  initialPlatform = await UserPreferencesUtils.getPlatformPreference();

  // save them to database first
  if(isExclusiveDiscuz){
    // save discuz to database first
    final db = await DBHelper.getAppDb();
    DiscuzDao discuzDao = db.discuzDao;
    Discuz exclusiveDiscuz = Discuz(1, "https://keylol.com", "X3.2", "utf-8", 4, "1.4.8", "register", true, "true", "true", "其乐 Keylol", "0", "https://keylol.com/uc_server", "161");
    discuzDao.insertDiscuz(exclusiveDiscuz);
  }

  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: ThemeNotifierProvider()),
          ChangeNotifierProvider.value(value: DiscuzAndUserNotifier()),
          ChangeNotifierProvider.value(value: ReplyPostNotifierProvider()),
          ChangeNotifierProvider.value(value: TypeSettingNotifierProvider())
        ],
        child: isExclusiveDiscuz? ExclusiveDiscuzApp(initialPlatform): MyApp(initialPlatform),
      ));
}


