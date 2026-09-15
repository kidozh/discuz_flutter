import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/widget/post_translation_button.dart';

void main() {
  for (final style in [AppVisualStyle.material, AppVisualStyle.cupertino]) {
    testWidgets('compact translation tap and long press are separate: $style', (
      tester,
    ) async {
      var taps = 0, selections = 0;
      await tester.pumpWidget(
        PlatformProvider(
          style: style,
          builder: (_) => MaterialApp(
            home: Scaffold(
              body: PlatformLiquidGlassToolbarGroup(
                children: [
                  PostTranslationButton(
                    label: '翻译',
                    hint: '长按选择语言',
                    busy: false,
                    translated: false,
                    onPressed: () => taps++,
                    onChooseLanguage: () => selections++,
                  ),
                  PlatformIconButton(
                    icon: const Icon(Icons.more_horiz),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      final button = find.byType(PostTranslationButton);
      expect(tester.getSize(button), const Size(44, 44));
      expect(find.text('翻译'), findsNothing);
      await tester.tap(button);
      expect(taps, 1);
      expect(selections, 0);
      await tester.longPress(button);
      expect(taps, 1);
      expect(selections, 1);
      expect(tester.takeException(), isNull);
    });
  }
}
