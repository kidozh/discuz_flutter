import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Cupertino mode exposes the active Material dark theme',
      (tester) async {
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
          cupertinoLightTheme:
              const CupertinoThemeData(brightness: Brightness.light),
          cupertinoDarkTheme:
              const CupertinoThemeData(brightness: Brightness.dark),
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

  testWidgets('Cupertino three-line tiles do not truncate their subtitle',
      (tester) async {
    const subtitleKey = ValueKey('expanded-subtitle');
    await tester.pumpWidget(
      PlatformProvider(
        initialPlatform: TargetPlatform.iOS,
        builder: (context) => PlatformTheme(
          materialLightTheme: ThemeData.light(),
          materialDarkTheme: ThemeData.dark(),
          cupertinoLightTheme: const CupertinoThemeData(),
          cupertinoDarkTheme:
              const CupertinoThemeData(brightness: Brightness.dark),
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
