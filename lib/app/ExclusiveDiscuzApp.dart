import 'dart:io';
import 'package:discuz_flutter/page/ExclusiveDiscuzPortalPage.dart';
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/provider/TypeSettingNotifierProvider.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/generated/l10n.dart';



class ExclusiveDiscuzApp extends StatelessWidget{

  String platformName = "";

  ExclusiveDiscuzApp(this.platformName);

  _loadPreference(context) async{

    String colorName = await UserPreferencesUtils.getThemeColor();
    platformName = await UserPreferencesUtils.getPlatformPreference();
    double scale = await UserPreferencesUtils.getTypesettingScalePreference();
    Brightness? brightness = await UserPreferencesUtils.getInterfaceBrightnessPreference();

    print("Get brightness ${brightness}");

    Provider.of<ThemeNotifierProvider>(context,listen: false).setTheme(colorName);
    Provider.of<ThemeNotifierProvider>(context,listen: false).setPlatformName(platformName);
    Provider.of<TypeSettingNotifierProvider>(context,listen: false).setScalingParameter(scale);
    Provider.of<ThemeNotifierProvider>(context,listen: false).setBrightness(brightness);

  }

  TargetPlatform? getTargetPlatformByName(String name){
    switch (name){
      case "android": return TargetPlatform.android;
      case "ios": return TargetPlatform.iOS;
    }
    return null;
  }
  // our testflight discuz is keylol
  Discuz exclusiveDiscuz = Discuz(1, "https://keylol.com", "X3.2", "utf-8", 4, "1.4.8", "register", true, "true", "true", "其乐 Keylol", "0", "https://keylol.com/uc_server", "161");

  @override
  Widget build(BuildContext context) {
    _loadPreference(context);

    return Consumer<ThemeNotifierProvider>(
      builder: (context, themeColorEntity, _){
        print("Change brightness ${themeColorEntity.brightness}");
        final materialTheme = ThemeData(
          brightness: themeColorEntity.brightness,
          cupertinoOverrideTheme: CupertinoThemeData(
              primaryColor: themeColorEntity.themeColor,
              brightness: themeColorEntity.brightness
          ),

          primarySwatch: themeColorEntity.themeColor,
          primaryColor: themeColorEntity.themeColor,
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: ButtonStyle(
              padding: MaterialStateProperty.all(EdgeInsets.all(16.0)),
              foregroundColor: MaterialStateProperty.all(themeColorEntity.themeColor),
            ),
          ),
        );

        if (Platform.isAndroid) {
          print("Selected color ${themeColorEntity.themeColorName} ${themeColorEntity.themeColor}");

          SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: themeColorEntity.iconBrightness,
            statusBarBrightness: themeColorEntity.brightness,
            // systemNavigationBarColor: Color(themeColorEntity.themeColor.value),
            // systemNavigationBarIconBrightness: themeColorEntity.brightness
          );
          SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
        }

        return Theme(
            data: materialTheme,
            child: PlatformProvider(
              initialPlatform: getTargetPlatformByName(platformName),
              settings: PlatformSettingsData(
                iosUsesMaterialWidgets: true,


              ),
              builder: (context){
                return  PlatformApp(
                  //title: S.of(context).appName,

                  material: (_,__)=> MaterialAppData(

                      theme: materialTheme,
                      darkTheme: ThemeData(
                        primaryColor: themeColorEntity.themeColor,
                        floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: themeColorEntity.themeColor),
                        brightness: Brightness.dark,
                      )
                  ),
                  cupertino: (_,__) => CupertinoAppData(
                    theme: CupertinoThemeData(
                      primaryColor: themeColorEntity.themeColor,
                    ),

                  ),
                  // localization
                  localizationsDelegates: [
                    S.delegate,
                    GlobalCupertinoLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate
                  ],
                  supportedLocales: S.delegate.supportedLocales,
                  localeResolutionCallback: (locale, _){
                    if(locale!=null){
                      print("Locale ${locale.languageCode},${locale.scriptCode}, ${locale.countryCode}");
                    }
                  },
                  builder: EasyLoading.init(),
                  home: ExclusiveDiscuzPortalPage(exclusiveDiscuz),
                );
              },
            )

        );
      },
    );

  }



}