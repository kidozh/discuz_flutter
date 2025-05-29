import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/ExclusiveDiscuzPortalPage.dart';
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/provider/TypeSettingNotifierProvider.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

class ExclusiveDiscuzApp extends StatelessWidget {
  String platformName = "";
  Discuz _discuz;

  ThemeMode? themeMode = null;

  ExclusiveDiscuzApp(this.platformName, this._discuz);

  _loadPreference(context) async {
    FlexScheme colorScheme = await UserPreferencesUtils.getThemeColor();
    platformName = await UserPreferencesUtils.getPlatformPreference();
    double scale = await UserPreferencesUtils.getTypesettingScalePreference();
    Brightness? brightness =
        await UserPreferencesUtils.getInterfaceBrightnessPreference();

    Provider.of<ThemeNotifierProvider>(context, listen: false)
        .setTheme(colorScheme);
    Provider.of<ThemeNotifierProvider>(context, listen: false)
        .setPlatformName(platformName);
    Provider.of<TypeSettingNotifierProvider>(context, listen: false)
        .setScalingParameter(scale);
    Provider.of<ThemeNotifierProvider>(context, listen: false)
        .setBrightness(brightness);
  }

  TargetPlatform? getTargetPlatformByName(String name) {
    switch (name) {
      case "android":
        return TargetPlatform.android;
      case "ios":
        return TargetPlatform.iOS;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    _loadPreference(context);

    return Consumer<ThemeNotifierProvider>(
      builder: (context, themeColorEntity, _) {
        // deal with theme data
        final materialThemeDataLight = ThemeData(
            brightness: Brightness.light,
            //primarySwatch: themeColorEntity.themeColor,
            primaryColor: Colors.blue,
            useMaterial3: themeColorEntity.useMaterial3);
        final materialThemeDataDark = ThemeData(
            brightness: Brightness.dark,
            //primarySwatch: themeColorEntity.themeColor,
            primaryColor: Colors.amber,
            useMaterial3: themeColorEntity.useMaterial3);
        const darkDefaultCupertinoTheme =
            CupertinoThemeData(brightness: Brightness.dark);
        final cupertinoDarkTheme = MaterialBasedCupertinoThemeData(
          materialTheme: materialThemeDataDark.copyWith(
            cupertinoOverrideTheme: CupertinoThemeData(
              brightness: Brightness.dark,
              barBackgroundColor: darkDefaultCupertinoTheme.barBackgroundColor,
              textTheme: CupertinoTextThemeData(
                primaryColor: Colors.white,
                navActionTextStyle:
                darkDefaultCupertinoTheme.textTheme.navActionTextStyle.copyWith(
                  color: const Color(0xF0F9F9F9),
                ),
                navLargeTitleTextStyle: darkDefaultCupertinoTheme
                    .textTheme.navLargeTitleTextStyle
                    .copyWith(color: const Color(0xF0F9F9F9)),
              ),
            ),
          ),
        );
        final cupertinoLightTheme = MaterialBasedCupertinoThemeData(materialTheme: materialThemeDataLight);
        // check the system setting
        if(themeColorEntity.brightness == null){
          this.themeMode = ThemeMode.system;
        }
        else if(themeColorEntity.brightness == Brightness.light){
          this.themeMode = ThemeMode.light;
        }
        else if(themeColorEntity.brightness == Brightness.dark){
          this.themeMode = ThemeMode.dark;
        }
        else{
          this.themeMode = null;
        }

        return PlatformProvider(
          initialPlatform: getTargetPlatformByName(platformName),
          settings: PlatformSettingsData(),
          builder: (context) {
            // here insert the app
            return PlatformTheme(
                themeMode: this.themeMode,
                materialLightTheme: materialThemeDataLight,
                materialDarkTheme: materialThemeDataDark,
                cupertinoLightTheme: cupertinoLightTheme,
                cupertinoDarkTheme: cupertinoDarkTheme,
                onThemeModeChanged: (themeMode){
                  this.themeMode = themeMode;
                },
                builder: (context) => PlatformApp(
                      debugShowCheckedModeBanner: false,
                      //title: S.of(context).appName,
                      // localization
                      localizationsDelegates: [
                        S.delegate,
                        GlobalCupertinoLocalizations.delegate,
                        GlobalMaterialLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate
                      ],
                      supportedLocales: S.delegate.supportedLocales,
                      localeResolutionCallback: (locale, _) {
                        if (locale != null) {
                          print(
                              "Locale ${locale.languageCode},${locale.scriptCode}, ${locale.countryCode}");
                        }
                        return null;
                      },
                      builder: EasyLoading.init(),
                      home: ExclusiveDiscuzPortalPage(_discuz),
                    ));
          },
        );
      },
    );
  }
}
