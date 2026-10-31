import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/widget/cupertino_separated_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(
  Widget child, {
  Brightness brightness = Brightness.light,
  AppVisualStyle style = AppVisualStyle.cupertino,
}) => PlatformProvider(
  style: style,
  builder: (_) => MaterialApp(
    theme: ThemeData(brightness: brightness),
    home: CupertinoTheme(
      data: CupertinoThemeData(brightness: brightness),
      child: Scaffold(
        backgroundColor: brightness == Brightness.light
            ? Colors.white
            : Colors.black,
        body: child,
      ),
    ),
  ),
);

void main() {
  for (final brightness in Brightness.values) {
    for (final sliver in [false, true]) {
      testWidgets(
        'every Cupertino reading row has one separator: $brightness sliver=$sliver',
        (tester) async {
          final rows = [
            for (var i = 0; i < 4; i++)
              CupertinoSeparatedItem(
                reading: true,
                includeLiquidGlass: false,
                sliver: sliver,
                child: sliver
                    ? SliverToBoxAdapter(child: SizedBox(height: 40 + i * 5))
                    : SizedBox(height: 40 + i * 5),
              ),
          ];
          await tester.pumpWidget(
            _host(
              sliver
                  ? CustomScrollView(slivers: rows)
                  : ListView(children: rows),
              brightness: brightness,
            ),
          );
          expect(find.byType(CupertinoListSeparator), findsNWidgets(4));
          expect(tester.takeException(), isNull);
        },
      );
    }

    for (final ratio in [2.0, 3.0]) {
      testWidgets(
        'Cupertino hairlines remain visible between fractional rows while scrolling: $brightness DPR=$ratio',
        (tester) async {
          tester.view.devicePixelRatio = ratio;
          tester.view.physicalSize = Size(240 * ratio, 240 * ratio);
          addTearDown(tester.view.reset);
          final controller = ScrollController();
          addTearDown(controller.dispose);
          final key = GlobalKey();
          await tester.pumpWidget(
            RepaintBoundary(
              key: key,
              child: _host(
                ListView(
                  controller: controller,
                  padding: EdgeInsets.zero,
                  children: [
                    for (final height in [63.25, 71.5, 68.75, 84.1, 77.3, 65.8])
                      CupertinoSeparatedItem(child: SizedBox(height: height)),
                  ],
                ),
                brightness: brightness,
              ),
            ),
          );
          for (final offset in [0.0, 5.2, 70.3]) {
            controller.jumpTo(offset);
            await tester.pump();
            final boundary =
                key.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            final lines = find.byType(CupertinoListSeparator);
            var checked = 0;
            await tester.runAsync(() async {
              final rendered = await boundary.toImage(pixelRatio: ratio);
              final bytes = (await rendered.toByteData(
                format: ui.ImageByteFormat.rawRgba,
              ))!;
              final background = brightness == Brightness.light ? 255 : 0;
              for (final element in lines.evaluate()) {
                final box = element.renderObject! as RenderBox;
                final top =
                    boundary.globalToLocal(box.localToGlobal(Offset.zero)).dy *
                    ratio;
                if (top < 2 || top > rendered.height - 3) continue;
                final color = Color.alphaBlend(
                  CupertinoColors.separator.resolveFrom(element),
                  brightness == Brightness.light ? Colors.white : Colors.black,
                );
                final expectedDelta =
                    (((color.toARGB32() >> 16) & 255) - background).abs();
                var strongest = 0;
                for (var y = top.floor() - 1; y <= top.ceil() + 1; y++) {
                  final red = bytes.getUint8(
                    (y * rendered.width + rendered.width ~/ 2) * 4,
                  );
                  strongest = math.max(strongest, (red - background).abs());
                }
                expect(
                  strongest,
                  greaterThanOrEqualTo(expectedDelta - 2),
                  reason: 'separator at physical y=$top, scroll offset=$offset',
                );
                checked++;
              }
              rendered.dispose();
            });
            expect(tester.takeException(), isNull);
            expect(checked, greaterThanOrEqualTo(2));
          }
        },
      );
    }
  }

  for (final style in [AppVisualStyle.cupertino, AppVisualStyle.material]) {
    testWidgets('separator opt-out remains explicit: $style', (tester) async {
      await tester.pumpWidget(
        _host(
          const CupertinoSeparatedItem(
            enabled: false,
            reading: true,
            child: SizedBox(height: 40),
          ),
          style: style,
        ),
      );
      expect(find.byType(CupertinoListSeparator), findsNothing);
    });
  }

  testWidgets('Material reading rows do not gain Cupertino separators', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const CupertinoSeparatedItem(
          reading: true,
          child: SizedBox(height: 40),
        ),
        style: AppVisualStyle.material,
      ),
    );
    expect(find.byType(CupertinoListSeparator), findsNothing);
  });

  testWidgets('Liquid Glass thread rows retain their separator opt-out', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const CupertinoSeparatedItem(
          reading: true,
          includeLiquidGlass: false,
          child: SizedBox(height: 40),
        ),
        style: AppVisualStyle.liquidGlass,
      ),
    );
    expect(
      find.byType(CupertinoListSeparator),
      AppVisualStyle.supportsLiquidGlass ? findsNothing : findsOneWidget,
    );
  });
}
