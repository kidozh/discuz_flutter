import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';

void main() {
  for (final style in [AppVisualStyle.liquidGlass, AppVisualStyle.cupertino]) {
    testWidgets('dialog and actions follow $style on desktop', (tester) async {
      await tester.pumpWidget(
        PlatformProvider(
          style: style,
          builder: (_) => MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: TextButton(
                    onPressed: () => showPlatformAlert(
                      context: context,
                      title: '打开外链',
                      message: 'https://example.com',
                      actions: [
                        const PlatformAlertAction(label: '信任网站'),
                        const PlatformAlertAction(label: '打开浏览器'),
                        const PlatformAlertAction(
                          label: '取消',
                          isCancelAction: true,
                        ),
                      ],
                    ),
                    child: const Text('打开'),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.tap(find.text('打开'));
      await tester.pumpAndSettle();
      final glass =
          style == AppVisualStyle.liquidGlass &&
          AppVisualStyle.supportsLiquidGlass;
      expect(
        find.byType(PlatformLiquidGlassCard),
        glass ? findsOneWidget : findsNothing,
      );
      expect(
        find.byType(CupertinoAlertDialog),
        glass ? findsNothing : findsOneWidget,
      );
      expect(
        find.byType(CupertinoDialogAction),
        glass ? findsNothing : findsNWidgets(3),
      );
      expect(find.text('打开浏览器'), findsOneWidget);
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();
      expect(find.text('打开外链'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
