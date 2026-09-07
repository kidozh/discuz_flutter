import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/widget/message_composer_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('send stays legible and respects enabled state in $brightness',
        (tester) async {
      final colors = ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: brightness,
      );
      var sends = 0;
      Future<void> pump(bool enabled) => tester.pumpWidget(PlatformProvider(
            style: AppVisualStyle.material,
            builder: (_) => MaterialApp(
              theme: ThemeData(colorScheme: colors),
              localizationsDelegates: const [S.delegate],
              home: Scaffold(
                body: MessageComposerSurface(
                  borderRadius: BorderRadius.circular(24),
                  child: Row(children: [
                    const Expanded(child: TextField()),
                    MaterialMessageSendButton(
                      onPressed: enabled ? () => sends++ : null,
                    ),
                  ]),
                ),
              ),
            ),
          ));
      await pump(false);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(IconButton));
      expect(sends, 0);
      await pump(true);
      await tester.pumpAndSettle();
      final button = tester.widget<IconButton>(find.byType(IconButton));
      expect(button.style!.foregroundColor!.resolve({}), colors.onPrimary);
      expect(button.style!.backgroundColor!.resolve({}), colors.primary);
      await tester.tap(find.byType(IconButton));
      expect(sends, 1);
      final context = tester.element(find.byType(TextField));
      expect(Theme.of(context).inputDecorationTheme.border, InputBorder.none);
      expect(tester.takeException(), isNull);
    });
  }
}
