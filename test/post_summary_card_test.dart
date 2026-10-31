import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/widget/post_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final style in [AppVisualStyle.cupertino, AppVisualStyle.liquidGlass]) {
    for (final brightness in Brightness.values) {
      testWidgets(
        'summary remains distinct and interactive: $style $brightness',
        (tester) async {
          var retried = false;
          final colors = ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: brightness,
          );
          await tester.pumpWidget(
            PlatformProvider(
              style: style,
              builder: (_) => MaterialApp(
                theme: ThemeData(colorScheme: colors),
                home: Scaffold(
                  body: MediaQuery(
                    data: const MediaQueryData(
                      textScaler: TextScaler.linear(2),
                      disableAnimations: true,
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 280,
                        child: PostSummaryCard(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('AI summary'),
                              const Text(
                                'A long summary remains readable with large '
                                'type in a narrow reading pane.',
                              ),
                              TextButton(
                                onPressed: () => retried = true,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final surface = tester.widget<PlatformLiquidGlassCard>(
            find.byType(PlatformLiquidGlassCard),
          );
          expect(surface.backgroundColor, isNotNull);
          expect(surface.backgroundColor, isNot(colors.surface));
          expect(surface.borderRadius, BorderRadius.circular(16));
          await tester.tap(find.text('Retry'));
          expect(retried, isTrue);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'border motion pauses and resumes without rebuilding the content',
    (tester) async {
      var builds = 0;
      final content = Builder(
        builder: (_) {
          builds++;
          return const Text('Completed summary');
        },
      );
      Widget host({
        bool enabled = true,
        bool reduced = false,
        bool active = true,
      }) => MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduced),
          child: TickerMode(
            enabled: enabled,
            child: PostSummaryCard(active: active, child: content),
          ),
        ),
      );
      await tester.pumpWidget(host());
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.binding.hasScheduledFrame, isTrue);
      expect(builds, 1);
      await tester.pumpWidget(host(enabled: false));
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
      await tester.pumpWidget(host());
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.binding.hasScheduledFrame, isTrue);
      await tester.pumpWidget(host(reduced: true));
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(find.text('Completed summary'), findsOneWidget);
      await tester.pumpWidget(host(active: false));
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    },
  );
}
