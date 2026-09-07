import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/ChoosePlatformPage.dart';
import 'package:discuz_flutter/widget/UserProfileListItem.dart';
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/utility/PlatformGlass.dart'
    show PlatformGlassBackdrop;
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final isIOS in [false, true]) {
    for (final supportsGlass in [false, true]) {
      for (final style in AppVisualStyle.values) {
        test('${style.name}: iOS=$isIOS glass=$supportsGlass', () {
          final resolved =
              style.resolve(isIOS: isIOS, supportsLiquidGlass: supportsGlass);
          final expected = switch (style) {
            AppVisualStyle.cupertino => AppVisualStyle.cupertino,
            AppVisualStyle.material => AppVisualStyle.material,
            AppVisualStyle.liquidGlass => isIOS && supportsGlass
                ? AppVisualStyle.liquidGlass
                : AppVisualStyle.cupertino,
            AppVisualStyle.system => !isIOS
                ? AppVisualStyle.material
                : supportsGlass
                    ? AppVisualStyle.liquidGlass
                    : AppVisualStyle.cupertino,
          };
          expect(resolved, expected);
          expect(resolved, isNot(AppVisualStyle.system));
        });
      }
    }
  }

  test('legacy iOS selection keeps adaptive glass, not classic-only Cupertino',
      () {
    final theme = ThemeNotifierProvider(platformName: 'ios');
    expect(theme.visualStyle, AppVisualStyle.liquidGlass);
    expect(theme.platformName, 'liquid_glass');
    theme.setPlatformName('cupertino');
    expect(theme.visualStyle, AppVisualStyle.cupertino);
    expect(AppVisualStyle.fromPreference('fuchsia'), AppVisualStyle.system);
    expect(AppVisualStyle.fromPreference('invalid'), AppVisualStyle.system);
  });

  for (final brightness in Brightness.values) {
    testWidgets('Cupertino profile keeps its colored card background ($brightness)',
        (tester) async {
      await tester.pumpWidget(PlatformProvider(
        style: AppVisualStyle.cupertino,
        builder: (_) => MaterialApp(
          theme: ThemeData(brightness: brightness),
          home: const Scaffold(
            body: PlatformCard(
              color: Colors.purple,
              child: UserProfileListItem(
                title: 'Credits',
                titleColor: Colors.white,
                describe: '120',
                describeColor: Colors.white,
                icon: Icon(Icons.star, color: Colors.white),
              ),
            ),
          ),
        ),
      ));
      final surface = tester.widgetList<Container>(find.descendant(
        of: find.byType(PlatformLiquidGlassCard),
        matching: find.byType(Container),
      )).firstWhere((widget) => widget.decoration is BoxDecoration);
      expect((surface.decoration! as BoxDecoration).color, Colors.purple);
      expect(tester.widget<Text>(find.text('Credits')).style!.color, Colors.white);
      expect(tester.widget<Text>(find.text('120')).style!.color, Colors.white);
      expect(find.byType(BackdropFilter), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  for (final brightness in Brightness.values) {
    testWidgets('Cupertino incognito menu keeps foreground and background paired ($brightness)',
        (tester) async {
      final colors = ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: brightness,
      );
      await tester.pumpWidget(PlatformProvider(
        style: AppVisualStyle.cupertino,
        builder: (_) => MaterialApp(
          theme: ThemeData(colorScheme: colors),
          home: Scaffold(
            body: PlatformCard(
              color: colors.primary,
              child: PlatformListTile(
                title: Text('匿名模式', style: TextStyle(color: colors.onPrimary)),
                subtitle: Text('某些功能可能不可用',
                    style: TextStyle(color: colors.onPrimary)),
                trailing: Icon(Icons.expand_more, color: colors.onPrimary),
              ),
            ),
          ),
        ),
      ));
      final surface = tester.widgetList<Container>(find.descendant(
        of: find.byType(PlatformLiquidGlassCard),
        matching: find.byType(Container),
      )).firstWhere((widget) => widget.decoration is BoxDecoration);
      expect((surface.decoration! as BoxDecoration).color, colors.primary);
      expect(tester.widget<Text>(find.text('匿名模式')).style!.color,
          colors.onPrimary);
      expect(tester.widget<Text>(find.text('某些功能可能不可用')).style!.color,
          colors.onPrimary);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('classic Cupertino keeps controls and removes custom glass',
      (tester) async {
    await tester.pumpWidget(PlatformProvider(
      style: AppVisualStyle.cupertino,
      builder: (_) => PlatformApp(
          home: PlatformScaffold(
        appBar: PlatformAppBar(title: const Text('Classic')),
        body: PlatformLiquidGlassCard(
            child: Column(children: [
          PlatformSwitch(value: true, onChanged: (_) {}),
          PlatformTextField(hintText: 'Input'),
        ])),
      )),
    ));
    expect(find.byType(CupertinoNavigationBar), findsOneWidget);
    expect(find.byType(CupertinoSwitch), findsOneWidget);
    expect(find.byType(CupertinoTextField), findsOneWidget);
    expect(find.byType(PlatformGlassBackdrop), findsNothing);
    expect(find.byType(UiKitView), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'style changes notify existing descendants with unchanged identity',
      (tester) async {
    final style = ValueNotifier(AppVisualStyle.cupertino);
    addTearDown(style.dispose);
    final observations = <AppVisualStyle>[];
    final child = Builder(builder: (context) {
      observations.add(visualStyle(context));
      return const SizedBox();
    });
    await tester.pumpWidget(ValueListenableBuilder(
      valueListenable: style,
      builder: (_, value, __) =>
          PlatformProvider(style: value, builder: (_) => child),
    ));
    expect(observations.last, AppVisualStyle.cupertino);
    style.value = AppVisualStyle.material;
    await tester.pump();
    expect(observations.last, AppVisualStyle.material);
    expect(observations.length, 2);
  });

  for (final locale in [const Locale('en'), const Locale('zh', 'CN')]) {
    testWidgets(
        'appearance selection persists and unsupported glass is hidden ($locale)',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('haptic_feedback'), (_) async => false);
      addTearDown(() => tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(
              const MethodChannel('haptic_feedback'), null));
      final theme = ThemeNotifierProvider(platformName: 'android');
      final navigatorKey = GlobalKey<NavigatorState>();
      addTearDown(theme.dispose);
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: theme,
        child: Consumer<ThemeNotifierProvider>(
            builder: (_, value, __) => PlatformProvider(
                  style: value.visualStyle,
                  builder: (_) => PlatformApp(
                    navigatorKey: navigatorKey,
                    locale: locale,
                    localizationsDelegates: const [
                      S.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate
                    ],
                    supportedLocales: S.delegate.supportedLocales,
                    home: Builder(
                        builder: (context) => PlatformScaffold(
                              body: PlatformTextButton(
                                child: const Text('Open appearance'),
                                onPressed: () =>
                                    navigatorKey.currentState!.push(
                                  platformPageRoute(
                                    context: context,
                                    builder: (_) => const ChoosePlatformPage(),
                                  ),
                                ),
                              ),
                            )),
                  ),
                )),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open appearance'));
      await tester.pumpAndSettle();
      expect(
          find.byKey(const ValueKey('appearance-liquidGlass')), findsNothing);
      expect(find.text('Liquid Glass'), findsNothing);
      expect(find.text('Cupertino'), findsOneWidget);
      await tester.tap(find.text('Cupertino'));
      await tester.pumpAndSettle();
      expect(theme.visualStyle, AppVisualStyle.cupertino);
      expect(await UserPreferencesUtils.getPlatformPreference(), 'cupertino');
      final restored = ThemeNotifierProvider(
          platformName: await UserPreferencesUtils.getPlatformPreference());
      expect(restored.visualStyle, AppVisualStyle.cupertino);
      restored.dispose();
      expect(find.byType(CupertinoPageScaffold), findsOneWidget);
      expect(navigatorKey.currentState!.canPop(), isTrue);
      expect(find.byType(UiKitView), findsNothing);
      await tester.tap(
          find.text(locale.languageCode == 'en' ? 'Material Design' : '质感设计'));
      await tester.pumpAndSettle();
      expect(theme.visualStyle, AppVisualStyle.material);
      expect(await UserPreferencesUtils.getPlatformPreference(), 'android');
      expect(find.byType(Scaffold), findsOneWidget);
      expect(navigatorKey.currentState!.canPop(), isTrue);
      navigatorKey.currentState!.pop();
      await tester.pumpAndSettle();
      expect(find.text('Open appearance'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
