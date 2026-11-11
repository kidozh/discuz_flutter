import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:discuz_flutter/utility/ToastUtils.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  testWidgets('Android content and tabs clear the system bars and keyboard', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 800);
    const insets = FakeViewPadding(left: 24, top: 32, bottom: 48);
    tester.view.padding = insets;
    tester.view.viewPadding = insets;
    addTearDown(tester.view.reset);

    const contentKey = ValueKey('page-content');
    final body = find.byKey(contentKey);
    Future<void> showPage({PlatformBottomNavigationBar? tabs}) =>
        tester.pumpWidget(
          PlatformProvider(
            style: AppVisualStyle.material,
            builder: (_) => PlatformTheme(
              themeMode: ThemeMode.dark,
              materialLightTheme: ThemeData.light(),
              materialDarkTheme: ThemeData.dark(),
              builder: (_) => PlatformApp(
                home: PlatformScaffold(
                  appBar: PlatformAppBar(title: const Text('Forum')),
                  body: const SizedBox.expand(key: contentKey),
                  bottomNavigationBar: tabs,
                ),
              ),
            ),
          ),
        );

    await showPage();
    expect(tester.getRect(body).left, 24);
    expect(tester.getRect(body).top, 32 + 64);
    expect(tester.getRect(body).bottom, 800 - 48);
    expect(
      tester
          .widgetList<AnnotatedRegion<SystemUiOverlayStyle>>(
            find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
          )
          .map((region) => region.value.systemNavigationBarIconBrightness),
      contains(Brightness.light),
    );

    var selected = -1;
    await showPage(
      tabs: PlatformBottomNavigationBar(
        selectedIndex: 0,
        onTap: (index) => selected = index,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Boards'),
        ],
      ),
    );
    final tabs = find.byType(BottomNavigationBar);
    expect(tester.getBottomRight(tabs).dy, 800);
    expect(tester.getRect(body).bottom, tester.getRect(tabs).top);
    expect(tester.getBottomRight(find.text('Boards')).dy, lessThan(800 - 48));
    await tester.tap(find.text('Boards'));
    expect(selected, 1);

    await showPage();
    tester.view.padding = const FakeViewPadding(left: 24, top: 32);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pump();
    expect(tester.getRect(body).bottom, 800 - 300);
  }, variant: const TargetPlatformVariant({TargetPlatform.android}));

  testWidgets('switching Material to Cupertino preserves the active route', (
    tester,
  ) async {
    final platformKey = GlobalKey<PlatformProviderState>();
    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      PlatformProvider(
        key: platformKey,
        style: AppVisualStyle.material,
        builder: (context) => PlatformTheme(
          materialLightTheme: ThemeData.light(),
          materialDarkTheme: ThemeData.dark(),
          cupertinoLightTheme: const CupertinoThemeData(),
          cupertinoDarkTheme: const CupertinoThemeData(
            brightness: Brightness.dark,
          ),
          builder: (context) => PlatformApp(
            navigatorKey: navigatorKey,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            builder: ToastUtils.easyLoadingBuilder(),
            home: PlatformScaffold(body: Text('Home')),
          ),
        ),
      ),
    );
    navigatorKey.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => PlatformScaffold(body: Text('Appearance settings')),
      ),
    );
    await tester.pumpAndSettle();
    final navigator = navigatorKey.currentState;
    platformKey.currentState!.changeStyle(AppVisualStyle.cupertino);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Appearance settings'), findsOneWidget);
    expect(navigatorKey.currentState, same(navigator));
    platformKey.currentState!.changeStyle(AppVisualStyle.material);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Appearance settings'), findsOneWidget);
    navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('Cupertino mode exposes the active Material dark theme', (
    tester,
  ) async {
    Brightness? observedBrightness;
    Color? observedSurface;
    final darkTheme = ThemeData.dark().copyWith(
      colorScheme: const ColorScheme.dark(surface: Color(0xFF121820)),
    );

    await tester.pumpWidget(
      PlatformProvider(
        initialPlatform: TargetPlatform.iOS,
        builder: (context) => PlatformTheme(
          themeMode: ThemeMode.dark,
          materialLightTheme: ThemeData.light(),
          materialDarkTheme: darkTheme,
          cupertinoLightTheme: const CupertinoThemeData(
            brightness: Brightness.light,
          ),
          cupertinoDarkTheme: const CupertinoThemeData(
            brightness: Brightness.dark,
          ),
          builder: (context) => PlatformApp(
            home: Builder(
              builder: (context) {
                observedBrightness = Theme.of(context).brightness;
                observedSurface = Theme.of(context).colorScheme.surface;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );

    expect(observedBrightness, Brightness.dark);
    expect(observedSurface, const Color(0xFF121820));
  });

  testWidgets('Cupertino three-line tiles do not truncate their subtitle', (
    tester,
  ) async {
    const subtitleKey = ValueKey('expanded-subtitle');
    await tester.pumpWidget(
      PlatformProvider(
        initialPlatform: TargetPlatform.iOS,
        builder: (context) => PlatformTheme(
          materialLightTheme: ThemeData.light(),
          materialDarkTheme: ThemeData.dark(),
          cupertinoLightTheme: const CupertinoThemeData(),
          cupertinoDarkTheme: const CupertinoThemeData(
            brightness: Brightness.dark,
          ),
          builder: (context) => PlatformApp(
            home: PlatformScaffold(
              body: PlatformListTile(
                title: const Text('Title'),
                subtitle: const Text(
                  'A long subtitle that should wrap onto every line needed '
                  'instead of being squeezed into a single truncated line.',
                  key: subtitleKey,
                ),
                isThreeLine: true,
              ),
            ),
          ),
        ),
      ),
    );

    final richText = tester.widget<RichText>(
      find.descendant(
        of: find.byKey(subtitleKey),
        matching: find.byType(RichText),
      ),
    );
    expect(richText.maxLines, isNull);
    expect(richText.overflow, TextOverflow.visible);
  });
}
