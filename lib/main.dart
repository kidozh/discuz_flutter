import 'dart:developer';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/provider/ReplyPostNotifierProvider.dart';
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/provider/TypeSettingNotifierProvider.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

import 'app/MainApp.dart';


String initialPlatform = "";

void main() async{
  // init google ads

  WidgetsFlutterBinding.ensureInitialized();
  log("languages initialization");
  initialPlatform = await UserPreferencesUtils.getPlatformPreference();
  await FlutterDisplayMode.setHighRefreshRate();

  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: ThemeNotifierProvider()),
          ChangeNotifierProvider.value(value: DiscuzAndUserNotifier()),
          ChangeNotifierProvider.value(value: ReplyPostNotifierProvider()),
          ChangeNotifierProvider.value(value: TypeSettingNotifierProvider())
        ],
        child: MyApp(initialPlatform),
      ));
}


