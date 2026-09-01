import 'dart:async';

import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/ExclusiveDiscuzPortalPage.dart';
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/provider/TypeSettingNotifierProvider.dart';
import 'package:discuz_flutter/provider/UserPreferenceNotifierProvider.dart';
import 'package:discuz_flutter/utility/OnDeviceAiService.dart';
import 'package:discuz_flutter/utility/ToastUtils.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:provider/provider.dart';

class ExclusiveDiscuzApp extends StatefulWidget {
  final String initialPlatformName;
  final Discuz discuz;

  const ExclusiveDiscuzApp(this.initialPlatformName, this.discuz, {super.key});

  @override
  State<ExclusiveDiscuzApp> createState() => _ExclusiveDiscuzAppState();
}

class _ExclusiveDiscuzAppState extends State<ExclusiveDiscuzApp> {
  late String platformName = widget.initialPlatformName;

  ThemeMode? themeMode;
  bool _didLoadPreferences = false;

  Future<void> _loadPreference(BuildContext context) async {
    FlexScheme colorScheme = await UserPreferencesUtils.getThemeColor();
    Color? customThemeColor = await UserPreferencesUtils.getCustomThemeColor();
    platformName = await UserPreferencesUtils.getPlatformPreference();
    double scale = await UserPreferencesUtils.getTypesettingScalePreference();
    Brightness? brightness =
        await UserPreferencesUtils.getInterfaceBrightnessPreference();
    final intelligenceEnabled =
        await UserPreferencesUtils.getAppleIntelligenceEnabled();
    final intelligenceGuardrail =
        await UserPreferencesUtils.getAppleIntelligenceGuardrail();
    OnDeviceAiAvailability intelligenceAvailability =
        const OnDeviceAiAvailability(
      status: OnDeviceAiAvailabilityStatus.unsupportedPlatform,
      reasonCode: 'unsupported_platform',
    );
    if (OnDeviceAiService.isSupportedPlatform) {
      intelligenceAvailability = await OnDeviceAiService.checkAvailability();
    }
    if (!context.mounted) return;

    Provider.of<ThemeNotifierProvider>(context, listen: false)
        .setTheme(colorScheme);
    if (customThemeColor != null) {
      Provider.of<ThemeNotifierProvider>(context, listen: false)
          .setCustomThemeColor(customThemeColor);
    }
    Provider.of<ThemeNotifierProvider>(context, listen: false)
        .setPlatformName(platformName);
    Provider.of<TypeSettingNotifierProvider>(context, listen: false)
        .setScalingParameter(scale);
    Provider.of<ThemeNotifierProvider>(context, listen: false)
        .setBrightness(brightness);
    final preferences =
        Provider.of<UserPreferenceNotifierProvider>(context, listen: false);
    preferences.setAppleIntelligenceGuardrail(intelligenceGuardrail);
    preferences.setOnDeviceAiAvailability(intelligenceAvailability);
    preferences.setAppleIntelligenceEnabled(
      intelligenceEnabled && intelligenceAvailability.isAvailable,
    );
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
    if (!_didLoadPreferences) {
      _didLoadPreferences = true;
      unawaited(_loadPreference(context));
    }

    return Consumer<ThemeNotifierProvider>(
      builder: (context, themeColorEntity, _) {
        // deal with theme data
        final customThemeColor = themeColorEntity.customThemeColor;
        final materialThemeDataLight = FlexThemeData.light(
          scheme: customThemeColor == null ? themeColorEntity.themeColor : null,
          colorScheme: customThemeColor == null
              ? null
              : ColorScheme.fromSeed(
                  seedColor: customThemeColor,
                  brightness: Brightness.light,
                  dynamicSchemeVariant: themeColorEntity.dynamicSchemeVariant,
                ),
          useMaterial3: themeColorEntity.useMaterial3,
        );
        final materialThemeDataDark = FlexThemeData.dark(
          scheme: customThemeColor == null ? themeColorEntity.themeColor : null,
          colorScheme: customThemeColor == null
              ? null
              : ColorScheme.fromSeed(
                  seedColor: customThemeColor,
                  brightness: Brightness.dark,
                  dynamicSchemeVariant: themeColorEntity.dynamicSchemeVariant,
                ),
          useMaterial3: themeColorEntity.useMaterial3,
        );
        const darkDefaultCupertinoTheme =
            CupertinoThemeData(brightness: Brightness.dark);
        final cupertinoDarkTheme = MaterialBasedCupertinoThemeData(
          materialTheme: materialThemeDataDark.copyWith(
            cupertinoOverrideTheme: CupertinoThemeData(
              brightness: Brightness.dark,
              barBackgroundColor: darkDefaultCupertinoTheme.barBackgroundColor,
              textTheme: CupertinoTextThemeData(
                primaryColor: Colors.white,
                navActionTextStyle: darkDefaultCupertinoTheme
                    .textTheme.navActionTextStyle
                    .copyWith(
                  color: const Color(0xF0F9F9F9),
                ),
                navLargeTitleTextStyle: darkDefaultCupertinoTheme
                    .textTheme.navLargeTitleTextStyle
                    .copyWith(color: const Color(0xF0F9F9F9)),
              ),
            ),
          ),
        );
        final cupertinoLightTheme = MaterialBasedCupertinoThemeData(
            materialTheme: materialThemeDataLight);
        // check the system setting
        if (themeColorEntity.brightness == null) {
          this.themeMode = ThemeMode.system;
        } else if (themeColorEntity.brightness == Brightness.light) {
          this.themeMode = ThemeMode.light;
        } else if (themeColorEntity.brightness == Brightness.dark) {
          this.themeMode = ThemeMode.dark;
        } else {
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
                onThemeModeChanged: (themeMode) {
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
                      builder: ToastUtils.easyLoadingBuilder(),
                      home: ExclusiveDiscuzPortalPage(widget.discuz),
                    ));
          },
        );
      },
    );
  }
}
