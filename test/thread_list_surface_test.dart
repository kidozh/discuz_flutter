import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/widget/thread_list_surface.dart';
import 'package:discuz_flutter/utility/thread_selection_colors.dart';
import 'package:discuz_flutter/utility/PlatformGlass.dart'
    show PlatformGlassBackdrop;

void main() {
  for (final selected in [true, false]) {
    for (final brightness in Brightness.values) {
      testWidgets(
        'thread row retains exactly one outer glass card: $selected $brightness',
        (tester) async {
          final scheme = ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: brightness,
          );
          await tester.pumpWidget(
            PlatformProvider(
              style: AppVisualStyle.liquidGlass,
              builder: (_) => MaterialApp(
                theme: ThemeData(colorScheme: scheme),
                home: ThreadListSurface(
                  selected: selected,
                  child: const PlatformListTile(
                    title: Text('帖子标题'),
                    subtitle: Text('作者 · 时间'),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.byType(PlatformLiquidGlassCard), findsOneWidget);
          final card = tester.widget<PlatformLiquidGlassCard>(
            find.byType(PlatformLiquidGlassCard),
          );
          expect(card.selected, selected);
          expect(
            card.glassBackgroundColor,
            selected ? ThreadSelectionColors(scheme).background : null,
          );
          expect(
            find.byType(PlatformGlassBackdrop),
            AppVisualStyle.supportsLiquidGlass ? findsOneWidget : findsNothing,
          );
          expect(
            find.byType(BackdropFilter).evaluate().length,
            lessThanOrEqualTo(1),
          );
          // No selected side stripe or nested rounded card is introduced.
          final decorations = tester.widgetList<DecoratedBox>(
            find.byType(DecoratedBox),
          );
          expect(
            decorations.any(
              (widget) =>
                  widget.decoration is BoxDecoration &&
                  (widget.decoration as BoxDecoration).border
                      is BorderDirectional,
            ),
            isFalse,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
