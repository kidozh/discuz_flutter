import 'package:discuz_flutter/widget/thread_carousel_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(
  double paneWidth,
  int count, {
  ValueChanged<int>? onTap,
  bool loading = false,
  bool autoPlay = true,
  bool reducedMotion = false,
  bool tickers = true,
}) => MaterialApp(
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: reducedMotion),
    child: TickerMode(enabled: tickers, child: child!),
  ),
  home: Scaffold(
    body: Center(
      child: SizedBox(
        width: paneWidth,
        child: ThreadCarouselLayout(
          itemCount: count,
          isLoading: loading,
          autoPlay: autoPlay,
          itemBuilder: (context, index) => GestureDetector(
            onTap: () => onTap?.call(index),
            child: ColoredBox(
              key: ValueKey('promotion-$index'),
              color: Colors.blue,
              child: Center(child: Text('Promotion $index')),
            ),
          ),
        ),
      ),
    ),
  ),
);

List<int> fullyVisible(WidgetTester tester, int count) {
  final viewport = tester.getRect(find.byType(PageView));
  return [
    for (var i = 0; i < count; i++)
      if (find.byKey(ValueKey('promotion-$i')).evaluate().any((element) {
        final rect = tester.getRect(find.byWidget(element.widget));
        return viewport.inflate(0.1).contains(rect.topLeft) &&
            viewport.inflate(0.1).contains(rect.bottomRight);
      }))
        i,
  ];
}

void main() {
  for (final reducedMotion in [false, true]) {
    testWidgets(
      'loading fades in place and respects reduced motion: $reducedMotion',
      (tester) async {
        Widget carousel({required bool loading}) => host(
          390,
          loading ? 0 : 6,
          loading: loading,
          autoPlay: false,
          reducedMotion: reducedMotion,
        );

        await tester.pumpWidget(carousel(loading: true));
        final promotion = find.byKey(const ValueKey('promotion-0'));
        final placeholderRect = tester.getRect(promotion);

        await tester.pumpWidget(carousel(loading: false));
        await tester.pump(const Duration(milliseconds: 100));
        final pageView = find.byType(PageView);
        expect(
          tester.getRect(find.descendant(of: pageView, matching: promotion)),
          rectMoreOrLessEquals(placeholderRect, epsilon: 1e-6),
        );
        expect(promotion, findsNWidgets(reducedMotion ? 1 : 2));
        final fades = tester.widgetList<FadeTransition>(
          find.descendant(
            of: find.byType(ThreadCarouselLayout),
            matching: find.byType(FadeTransition),
          ),
        );
        expect(fades, hasLength(reducedMotion ? 1 : 2));
        for (final fade in fades) {
          if (reducedMotion) {
            expect(fade.opacity.value, 1);
          } else {
            expect(fade.opacity.value, inExclusiveRange(0, 1));
          }
        }

        // Reloading before the fade finishes must not retain an attached pager.
        await tester.pumpWidget(carousel(loading: true));
        expect(pageView, findsNothing);
        await tester.pumpWidget(carousel(loading: false));
        expect(
          tester.widget<PageView>(pageView).controller!.positions,
          hasLength(1),
        );
        await tester.pumpAndSettle();
        expect(promotion, findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('static loading reserves the final height at every pane width', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1800, 700);
    addTearDown(tester.view.reset);
    for (final width in [320.0, 390.0, 720.0, 900.0, 1600.0]) {
      for (final count in [1, 2, 6]) {
        await tester.pumpWidget(host(width, 0, loading: true));
        await tester.pumpAndSettle();
        final height = tester
            .getSize(find.byKey(const ValueKey('promotion-0')))
            .height;
        expect(find.byType(PageView), findsNothing);
        expect(tester.binding.hasScheduledFrame, isFalse);
        await tester.pumpWidget(host(width, count));
        await tester.pumpAndSettle();
        expect(tester.getSize(find.byType(PageView)).height, height);
        expect(tester.takeException(), isNull);
      }
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'image readiness and rebuilds preserve the page already swiped to',
    (tester) async {
      await tester.pumpWidget(host(390, 6, autoPlay: false));
      await tester.pumpAndSettle();
      final controller = tester
          .widget<PageView>(find.byType(PageView))
          .controller!;
      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();
      final page = controller.page!;
      await tester.pump(const Duration(seconds: 6));
      expect(controller.page, page);
      await tester.pumpWidget(host(390, 6));
      await tester.pumpAndSettle();
      expect(
        tester.widget<PageView>(find.byType(PageView)).controller,
        same(controller),
      );
      expect(controller.page, page);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(controller.page, page + 1);
      await tester.pumpWidget(host(390, 6));
      await tester.pumpAndSettle();
      expect(controller.page, page + 1);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  for (final reducedMotion in [false, true]) {
    testWidgets(
      'autoplay pauses with reduced motion or hidden feeds: $reducedMotion',
      (tester) async {
        await tester.pumpWidget(
          host(390, 6, reducedMotion: reducedMotion, tickers: reducedMotion),
        );
        await tester.pumpAndSettle();
        final controller = tester
            .widget<PageView>(find.byType(PageView))
            .controller!;
        final page = controller.page;
        await tester.pump(const Duration(seconds: 10));
        await tester.pumpAndSettle();
        expect(controller.page, page);
        if (!reducedMotion) {
          await tester.pumpWidget(host(390, 6));
          await tester.pumpAndSettle();
        }
        await tester.drag(find.byType(PageView), const Offset(-300, 0));
        await tester.pumpAndSettle();
        expect(controller.page, page! + 1);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  testWidgets('uses the feed pane width and keeps wide promotions clickable', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1800, 700);
    addTearDown(tester.view.reset);
    int? tapped;
    for (final size in [
      (320.0, 1),
      (390.0, 1),
      (430.0, 1),
      (900.0, 2),
      (1600.0, 3),
    ]) {
      await tester.pumpWidget(host(size.$1, 6, onTap: (i) => tapped = i));
      await tester.pumpAndSettle();
      expect(fullyVisible(tester, 6).length, size.$2);
      if (size.$2 == 1) {
        final cardSize = tester.getSize(
          find.byKey(const ValueKey('promotion-0')),
        );
        expect(cardSize.height, greaterThanOrEqualTo(180));
        expect(cardSize.width / cardSize.height, lessThanOrEqualTo(2));
      }
      for (final card in find.byType(ColoredBox).evaluate()) {
        if (card.widget.key is ValueKey<String> &&
            (card.widget.key! as ValueKey<String>).value.startsWith(
              'promotion',
            )) {
          expect(
            tester.getSize(find.byWidget(card.widget)).width,
            lessThanOrEqualTo(480),
          );
        }
      }
      if (size.$2 > 1) {
        await tester.tap(find.text('Promotion 1'));
        expect(tapped, 1);
      }
      expect(tester.takeException(), isNull);
    }
    await tester.drag(find.byType(PageView), const Offset(-480, 0));
    await tester.pumpAndSettle();
    expect(fullyVisible(tester, 6), [1, 2, 3]);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'resizing between a loop and all cards fitting keeps real pages',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1800, 700);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(host(900, 2));
      await tester.pumpAndSettle();
      expect(fullyVisible(tester, 2), [0, 1]);
      await tester.pump(const Duration(seconds: 4));
      expect(fullyVisible(tester, 2), [0, 1]);
      await tester.pumpWidget(host(390, 2));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(PageView), const Offset(-320, 0));
      await tester.pumpAndSettle();
      expect(fullyVisible(tester, 2), [1]);
      await tester.pumpWidget(host(1600, 2));
      await tester.pumpAndSettle();
      expect(fullyVisible(tester, 2), [0, 1]);
      expect(tester.getSize(find.byType(PageView)).width, 960);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
