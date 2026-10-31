import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/widget/thread_list_surface.dart';
import 'package:discuz_flutter/utility/thread_selection_colors.dart';
import 'package:discuz_flutter/utility/PlatformGlass.dart'
    show PlatformGlassBackdrop;

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
      'Material thread cards have distinct fills and gaps: $brightness',
      (tester) async {
        final scheme = ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: brightness,
        );
        await tester.pumpWidget(
          PlatformProvider(
            style: AppVisualStyle.material,
            builder: (_) => MaterialApp(
              theme: ThemeData(colorScheme: scheme),
              home: Scaffold(
                body: ListView(
                  children: [
                    for (final selected in [false, true])
                      ThreadListSurface(
                        selected: selected,
                        child: const SizedBox(height: 80),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
        final cards = tester.widgetList<Card>(find.byType(Card)).toList();
        expect(cards.first.color, isNull);
        expect(cards.first.shape, isNull);
        expect(cards.first.elevation, isNull);
        expect(cards.last.color, ThreadSelectionColors(scheme).background);
        final fills = find.descendant(
          of: find.byType(Card),
          matching: find.byType(Material),
        );
        final material = tester.widget<Material>(fills.first);
        expect(material.color, scheme.surfaceContainerLow);
        expect(material.elevation, 1);
        final shape = material.shape! as RoundedRectangleBorder;
        expect(shape.borderRadius, BorderRadius.circular(12));
        expect(shape.side.style, BorderStyle.none);
        expect(
          tester.getTopLeft(fills.at(1)).dy -
              tester.getBottomLeft(fills.first).dy,
          8,
        );
        expect(find.byType(BackdropFilter), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('thread ripple belongs to the native card surface', (
    tester,
  ) async {
    var opened = false;
    await tester.pumpWidget(
      PlatformProvider(
        style: AppVisualStyle.material,
        builder: (_) => MaterialApp(
          home: Scaffold(
            body: ThreadListSurface(
              selected: false,
              onTap: () => opened = true,
              child: const SizedBox(height: 80, child: Text('Open thread')),
            ),
          ),
        ),
      ),
    );
    final ripple = find.descendant(
      of: find.byType(Card),
      matching: find.byType(InkWell),
    );
    expect(ripple, findsOneWidget);
    expect(tester.widget<Card>(find.byType(Card)).clipBehavior, Clip.antiAlias);
    await tester.tap(find.text('Open thread'));
    expect(opened, isTrue);
  });

  testWidgets('glass fill, border, shadow and clipping share their corners', (
    tester,
  ) async {
    const radius = BorderRadius.only(
      topLeft: Radius.circular(24),
      topRight: Radius.circular(16),
      bottomLeft: Radius.circular(12),
      bottomRight: Radius.circular(20),
    );
    await tester.pumpWidget(
      PlatformProvider(
        style: AppVisualStyle.liquidGlass,
        builder: (_) => const MaterialApp(
          home: Center(
            child: PlatformLiquidGlassCard(
              borderRadius: radius,
              child: SizedBox(width: 240, height: 80),
            ),
          ),
        ),
      ),
    );
    final decorations = tester.widgetList<DecoratedBox>(
      find.byType(DecoratedBox),
    );
    final surfaces = decorations
        .map((box) => box.decoration)
        .whereType<ShapeDecoration>();
    expect(surfaces, isNotEmpty);
    for (final surface in surfaces) {
      expect((surface.shape as RoundedRectangleBorder).borderRadius, radius);
      expect(surface.gradient, isNull);
      for (final shadow in surface.shadows ?? <BoxShadow>[]) {
        expect(shadow.blurRadius, lessThanOrEqualTo(8));
        expect(shadow.offset, const Offset(0, 2));
      }
    }
    if (AppVisualStyle.supportsLiquidGlass) {
      final clip = tester.widget<ClipPath>(find.byType(ClipPath));
      final shape =
          (clip.clipper! as ShapeBorderClipper).shape as RoundedRectangleBorder;
      expect(shape.borderRadius, radius);
    }
    expect(tester.takeException(), isNull);
  });
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
          expect(card.opaque, selected);
          expect(
            card.glassBackgroundColor,
            selected ? ThreadSelectionColors(scheme).background : null,
          );
          expect(
            find.byType(PlatformGlassBackdrop),
            !selected && AppVisualStyle.supportsLiquidGlass
                ? findsOneWidget
                : findsNothing,
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
