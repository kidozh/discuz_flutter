import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/widget/google_translation_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host({
  required bool translated,
  Brightness brightness = Brightness.light,
  double scale = 1,
}) => PlatformProvider(
  style: AppVisualStyle.material,
  builder: (_) => MaterialApp(
    locale: const Locale('en'),
    supportedLocales: S.delegate.supportedLocales,
    localizationsDelegates: const [
      S.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    theme: ThemeData(brightness: brightness),
    home: Scaffold(
      body: Center(
        child: MediaQuery(
          data: MediaQueryData(
            size: const Size(800, 600),
            textScaler: TextScaler.linear(scale),
          ),
          child: SizedBox(
            width: 240,
            child: GoogleTranslationAttribution(translated: translated),
          ),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('original body has no extra controls or attribution space', (
    tester,
  ) async {
    await tester.pumpWidget(host(translated: false));
    await tester.pumpAndSettle();
    expect(find.byType(GoogleTranslationBadge), findsNothing);
    expect(find.byType(TextButton), findsNothing);
    expect(find.byType(IconButton), findsNothing);
    expect(tester.getSize(find.byType(GoogleTranslationAttribution)).height, 0);
    expect(tester.takeException(), isNull);
  });

  for (final brightness in Brightness.values) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
        'badge stays legible and disappears with original: $brightness $scale',
        (tester) async {
          final semantics = tester.ensureSemantics();
          await tester.pumpWidget(
            host(translated: true, brightness: brightness, scale: scale),
          );
          await tester.pumpAndSettle();
          expect(find.byType(GoogleTranslationBadge), findsOneWidget);
          expect(find.byType(TextButton), findsNothing);
          expect(find.byType(IconButton), findsNothing);
          expect(
            find.bySemanticsLabel(
              'Automatic translation powered by Google Translate',
            ),
            findsOneWidget,
          );
          final image = tester.widget<Image>(find.byType(Image));
          expect(
            (image.image as AssetImage).assetName,
            'assets/translation/google_translate.png',
          );
          final panel = tester.widget<Material>(
            find.descendant(
              of: find.byType(GoogleTranslationBadge),
              matching: find.byType(Material),
            ),
          );
          expect(panel.color, Colors.white);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(
            host(translated: false, brightness: brightness, scale: scale),
          );
          await tester.pumpAndSettle();
          expect(find.byType(GoogleTranslationBadge), findsNothing);
          expect(
            tester.getSize(find.byType(GoogleTranslationAttribution)).height,
            0,
          );
          expect(tester.takeException(), isNull);
          semantics.dispose();
        },
      );
    }
  }

  testWidgets('translation notice is bundled and available without a result', (
    tester,
  ) async {
    await tester.pumpWidget(host(translated: false));
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(GoogleTranslationAttribution));
    // Settings continues to use this same offline notice entry point.
    showGoogleTranslationInfo(context);
    await tester.pump();
    await tester.runAsync(
      () => rootBundle.loadString('assets/translation/google_disclaimer.txt'),
    );
    await tester.pumpAndSettle();
    expect(find.text('About Google Translate'), findsOneWidget);
    expect(find.byType(SelectableText), findsOneWidget);
    expect(
      tester.widget<SelectableText>(find.byType(SelectableText)).data,
      startsWith('THIS SERVICE MAY CONTAIN TRANSLATIONS POWERED BY GOOGLE.'),
    );
    expect(find.text('Google Cloud Translation'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(SelectableText), findsNothing);
  });
}
