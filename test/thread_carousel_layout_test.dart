import 'package:discuz_flutter/widget/thread_carousel_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(double paneWidth, int count, {ValueChanged<int>? onTap}) =>
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: paneWidth,
            child: ThreadCarouselLayout(
              itemCount: count,
              height: 200,
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
  testWidgets('uses the feed pane width and keeps wide promotions clickable', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1800, 700);
    addTearDown(tester.view.reset);
    int? tapped;
    for (final size in [(390.0, 1), (900.0, 2), (1600.0, 3)]) {
      await tester.pumpWidget(host(size.$1, 6, onTap: (i) => tapped = i));
      await tester.pumpAndSettle();
      expect(fullyVisible(tester, 6).length, size.$2);
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
