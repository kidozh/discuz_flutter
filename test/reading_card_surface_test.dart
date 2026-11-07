import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/utility/material_surface_theme.dart';
import 'package:discuz_flutter/widget/reading_glass_sliver_card.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

double _contrast(Color foreground, Color background) {
  final a = foreground.computeLuminance();
  final b = background.computeLuminance();
  return (math.max(a, b) + 0.05) / (math.min(a, b) + 0.05);
}

void main() {
  for (final style in [
    AppVisualStyle.material,
    AppVisualStyle.cupertino,
    AppVisualStyle.liquidGlass,
  ]) {
    for (final brightness in Brightness.values) {
      for (final useMaterial3 in [false, true]) {
        testWidgets(
          'reading cards stay distinct and legible: $style $brightness M3=$useMaterial3',
          (tester) async {
            var theme = brightness == Brightness.light
                ? FlexThemeData.light(
                    scheme: FlexScheme.blueWhale,
                    useMaterial3: useMaterial3,
                  )
                : FlexThemeData.dark(
                    scheme: FlexScheme.blueWhale,
                    useMaterial3: useMaterial3,
                  );
            if (style == AppVisualStyle.material) {
              theme = withNeutralMaterialSurfaces(theme);
            }
            await tester.pumpWidget(
              PlatformProvider(
                style: style,
                builder: (_) => MaterialApp(
                  theme: theme,
                  home: CupertinoTheme(
                    data: CupertinoThemeData(brightness: brightness),
                    child: Scaffold(
                      body: CustomScrollView(
                        slivers: const [
                          SliverToBoxAdapter(
                            child: ReadingPostCard(
                              child: SizedBox(
                                height: 80,
                                child: Text('First post'),
                              ),
                            ),
                          ),
                          ReadingGlassSliverCard(
                            sliver: SliverToBoxAdapter(
                              child: SizedBox(height: 80, child: Text('Reply')),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
            final sliverDecoration =
                tester
                        .widget<DecoratedSliver>(find.byType(DecoratedSliver))
                        .decoration
                    as ShapeDecoration;
            final fill = sliverDecoration.color!;
            expect(fill.a, 1);
            Finder firstFill;
            if (style == AppVisualStyle.material) {
              firstFill = find.descendant(
                of: find.byType(ReadingPostCard),
                matching: find.byType(Material),
              );
              final card = tester.widget<Material>(firstFill);
              expect(fill, card.color);
              expect(sliverDecoration.shape, card.shape);
              expect(card.elevation, 1);
              expect(
                (card.shape as RoundedRectangleBorder).side.style,
                BorderStyle.none,
              );
              expect(sliverDecoration.shadows, isNotEmpty);
            } else {
              firstFill = find.descendant(
                of: find.byType(ReadingPostCard),
                matching: find.byType(DecoratedBox),
              );
              final boxDecoration = tester
                  .widget<DecoratedBox>(firstFill)
                  .decoration;
              expect(sliverDecoration, boxDecoration);
              expect(
                fill,
                CupertinoColors.secondarySystemBackground.resolveFrom(
                  tester.element(find.byType(ReadingPostCard)),
                ),
              );
            }
            expect(
              _contrast(theme.colorScheme.onSurface, fill),
              greaterThanOrEqualTo(4.5),
            );
            expect(
              _contrast(theme.colorScheme.onSurfaceVariant, fill),
              greaterThanOrEqualTo(4.5),
            );
            final sliverTop = MatrixUtils.transformPoint(
              tester
                  .renderObject(find.byType(DecoratedSliver))
                  .getTransformTo(null),
              Offset.zero,
            ).dy;
            expect(sliverTop - tester.getBottomLeft(firstFill).dy, 12);
            expect(find.byType(BackdropFilter), findsNothing);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }

  for (final style in [
    AppVisualStyle.material,
    AppVisualStyle.cupertino,
    AppVisualStyle.liquidGlass,
  ]) {
    for (final sliver in [false, true]) {
      testWidgets(
        'post content stays inside rounded corners: $style sliver=$sliver',
        (tester) async {
          tester.view.physicalSize = const Size(200, 200);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          final key = GlobalKey();
          final content = SizedBox(
            height: 80,
            child: Transform.scale(
              scale: 3,
              child: const ColoredBox(color: Colors.red),
            ),
          );
          await tester.pumpWidget(
            PlatformProvider(
              style: style,
              builder: (_) => MaterialApp(
                home: RepaintBoundary(
                  key: key,
                  child: Scaffold(
                    backgroundColor: Colors.black,
                    body: CustomScrollView(
                      slivers: [
                        if (sliver)
                          ReadingGlassSliverCard(
                            sliver: SliverToBoxAdapter(child: content),
                          )
                        else
                          SliverToBoxAdapter(
                            child: ReadingPostCard(
                              padding: EdgeInsets.zero,
                              child: content,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          await tester.runAsync(() async {
            final boundary =
                key.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            final rendered = await boundary.toImage();
            final bytes = (await rendered.toByteData(
              format: ui.ImageByteFormat.rawRgba,
            ))!;
            Color pixel(int x, int y) {
              final index = (y * rendered.width + x) * 4;
              return Color.fromARGB(
                bytes.getUint8(index + 3),
                bytes.getUint8(index),
                bytes.getUint8(index + 1),
                bytes.getUint8(index + 2),
              );
            }

            expect(pixel(9, 7).toARGB32(), Colors.black.toARGB32());
            expect(pixel(0, 40).toARGB32(), Colors.black.toARGB32());
            expect(pixel(100, 40).toARGB32(), Colors.red.toARGB32());
            rendered.dispose();
          });
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
