import 'dart:io';
import 'dart:ui' as ui;

import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/ChoosePlatformPage.dart';
import 'package:discuz_flutter/page/SettingPage.dart';
import 'package:discuz_flutter/page/forum_display_settings_page.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/provider/TypeSettingNotifierProvider.dart';
import 'package:discuz_flutter/provider/UserPreferenceNotifierProvider.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

Color? _textColor(WidgetTester tester, String text) => tester
    .renderObject<RenderParagraph>(
      find
          .descendant(of: find.text(text), matching: find.byType(RichText))
          .first,
    )
    .text
    .style
    ?.color;

void main() {
  for (final style in [
    AppVisualStyle.material,
    AppVisualStyle.cupertino,
    AppVisualStyle.liquidGlass,
  ]) {
    testWidgets('display settings persist and follow theme: $style', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.reset);
      PackageInfo.setMockInitialValues(
        appName: 'DisFly',
        packageName: 'com.kidozh.discuz_flutter',
        version: '2.0.10',
        buildNumber: '167',
        buildSignature: '',
      );
      tester.binding.platformDispatcher.platformBrightnessTestValue =
          Brightness.light;
      addTearDown(
        tester.binding.platformDispatcher.clearPlatformBrightnessTestValue,
      );
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('haptic_feedback'),
        (_) async => false,
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('haptic_feedback'),
          null,
        ),
      );
      final preference = ThemeNotifierProvider(platformName: style.preference)
        ..setBrightness(Brightness.light);
      final userPreferences = UserPreferenceNotifierProvider();
      final navigator = GlobalKey<NavigatorState>();
      final capture = GlobalKey();
      final light = ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      );
      final dark = ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
      );
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: preference),
            ChangeNotifierProvider.value(value: userPreferences),
            ChangeNotifierProvider(
              create: (_) => TypeSettingNotifierProvider(),
            ),
            ChangeNotifierProvider(create: (_) => DiscuzAndUserNotifier()),
          ],
          child: Consumer<ThemeNotifierProvider>(
            builder: (_, theme, _) => PlatformProvider(
              style: theme.visualStyle,
              builder: (_) => PlatformTheme(
                themeMode: theme.brightness == Brightness.dark
                    ? ThemeMode.dark
                    : ThemeMode.light,
                materialLightTheme: light,
                materialDarkTheme: dark,
                cupertinoLightTheme: const CupertinoThemeData(
                  brightness: Brightness.light,
                ),
                cupertinoDarkTheme: const CupertinoThemeData(
                  brightness: Brightness.dark,
                ),
                builder: (_) => PlatformApp(
                  navigatorKey: navigator,
                  locale: const Locale('en'),
                  supportedLocales: S.delegate.supportedLocales,
                  localizationsDelegates: const [
                    S.delegate,
                    ...GlobalMaterialLocalizations.delegates,
                  ],
                  home: const SettingPage(),
                  builder: (_, child) =>
                      RepaintBoundary(key: capture, child: child),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final strings = S.of(tester.element(find.byType(SettingPage)));
      expect(find.text(strings.mergeHomeNavigation), findsNothing);
      expect(find.text(strings.showForumName), findsNothing);
      expect(find.text(strings.showAccountInfo), findsNothing);
      expect(find.text(strings.showThreadStats), findsNothing);
      expect(find.text(strings.useForumCookiesForImages), findsNothing);
      expect(find.text(strings.showForumCarousel), findsNothing);
      expect(find.text(strings.compactForumCarousel), findsNothing);
      await tester.scrollUntilVisible(
        find.text(strings.forumDisplaySettingsTitle),
        250,
      );
      await tester.tap(find.text(strings.forumDisplaySettingsTitle));
      await tester.pumpAndSettle();
      expect(find.byType(ForumDisplaySettingsPage), findsOneWidget);
      expect(userPreferences.forumDisplay.mergeHomeNavigation, isFalse);
      expect(userPreferences.forumDisplay.useForumCookiesForImages, isTrue);
      expect(find.byType(PlatformSwitch), findsNWidgets(7));
      await tester.tap(find.text(strings.mergeHomeNavigation));
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.showForumName));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(strings.useForumCookiesForImages));
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.useForumCookiesForImages));
      await tester.pumpAndSettle();
      expect(userPreferences.forumDisplay.mergeHomeNavigation, isTrue);
      expect(userPreferences.forumDisplay.showForumName, isFalse);
      final saved = await UserPreferencesUtils.getForumDisplayPreference();
      expect(saved.mergeHomeNavigation, isTrue);
      expect(saved.showForumName, isFalse);
      expect(saved.showAccountInfo, isFalse);
      expect(saved.showThreadStats, isTrue);
      expect(saved.useForumCookiesForImages, isFalse);
      preference.setBrightness(Brightness.dark);
      await tester.pumpAndSettle();
      expect(
        _textColor(tester, strings.mergeHomeNavigation),
        dark.colorScheme.onSurface,
      );
      tester.binding.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(
        tester.binding.platformDispatcher.clearTextScaleFactorTestValue,
      );
      await tester.pumpAndSettle();
      for (final label in [
        strings.mergeHomeNavigation,
        strings.showForumName,
        strings.showAccountInfo,
        strings.showThreadStats,
        strings.useForumCookiesForImages,
        strings.showForumCarousel,
        strings.compactForumCarousel,
      ]) {
        await tester.scrollUntilVisible(find.text(label), 200);
        final text = tester.renderObject<RenderParagraph>(
          find
              .descendant(of: find.text(label), matching: find.byType(RichText))
              .first,
        );
        expect(text.didExceedMaxLines, isFalse, reason: label);
      }
      tester.binding.platformDispatcher.clearTextScaleFactorTestValue();
      await tester.scrollUntilVisible(
        find.text(strings.mergeHomeNavigation),
        -200,
      );
      await tester.pumpAndSettle();
      preference.setBrightness(Brightness.light);
      navigator.currentState!.pop();
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text(strings.appearanceOptimizedPlatform),
        250,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.appearanceOptimizedPlatform));
      await tester.pumpAndSettle();
      expect(find.byType(ChoosePlatformPage), findsOneWidget);
      expect(_textColor(tester, 'Cupertino'), light.colorScheme.onSurface);

      preference.setBrightness(Brightness.dark);
      await tester.pumpAndSettle();
      expect(find.byType(ChoosePlatformPage), findsOneWidget);
      expect(navigator.currentState!.canPop(), isTrue);
      expect(_textColor(tester, 'Cupertino'), dark.colorScheme.onSurface);
      expect(find.byType(SettingsList), findsNothing);
      final list = tester.element(find.byType(PlatformSettingsList));
      expect(Theme.of(list).brightness, Brightness.dark);
      if (const bool.fromEnvironment('SETTINGS_QA')) {
        await tester.runAsync(() async {
          final boundary =
              capture.currentContext!.findRenderObject()
                  as RenderRepaintBoundary;
          final image = await boundary.toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            '${Directory.systemTemp.path}/settings-${style.name}-dark.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }

      preference.setBrightness(Brightness.light);
      await tester.pumpAndSettle();
      expect(_textColor(tester, 'Cupertino'), light.colorScheme.onSurface);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'legacy settings preserve switches, custom content and disabled rows',
    (tester) async {
      var enabled = false;
      var disabledPressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) => Scaffold(
              body: PlatformAdaptiveSettingsList(
                sections: [
                  SettingsSection(
                    tiles: [
                      SettingsTile.switchTile(
                        title: const Text('Toggle'),
                        initialValue: enabled,
                        onToggle: (value) => setState(() => enabled = value),
                      ),
                      SettingsTile(
                        title: const Text('Disabled'),
                        enabled: false,
                        onPressed: (_) => disabledPressed = true,
                      ),
                      CustomSettingsTile(child: const Text('Custom preview')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Toggle'));
      await tester.pumpAndSettle();
      expect(enabled, isTrue);
      await tester.tap(find.text('Disabled'));
      await tester.pumpAndSettle();
      expect(disabledPressed, isFalse);
      expect(find.text('Custom preview'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
