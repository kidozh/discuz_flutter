import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';

void main() {
  for (final style in [AppVisualStyle.material, AppVisualStyle.liquidGlass]) {
    testWidgets(
      'post actions remain visible and tappable in narrow $style panel',
      (tester) async {
        final tapped = <int>[];
        await tester.pumpWidget(
          PlatformProvider(
            style: style,
            builder: (_) => MaterialApp(
              home: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 160,
                    child: PlatformLiquidGlassToolbarGroup(
                      wrap: true,
                      children: [
                        for (var i = 0; i < 6; i++)
                          SizedBox(
                            width: i == 3 ? 120 : 44,
                            height: 44,
                            child: TextButton(
                              onPressed: () => tapped.add(i),
                              child: Text(i == 3 ? '查看原文' : '$i'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final bounds = tester.getRect(
          find.byType(PlatformLiquidGlassToolbarGroup),
        );
        for (var i = 0; i < 6; i++) {
          final finder = find.text(i == 3 ? '查看原文' : '$i');
          final rect = tester.getRect(finder);
          expect(bounds.contains(rect.center), isTrue);
          await tester.tap(finder);
        }
        expect(tapped, [0, 1, 2, 3, 4, 5]);
        expect(bounds.height, greaterThan(48));
      },
    );
  }
}
