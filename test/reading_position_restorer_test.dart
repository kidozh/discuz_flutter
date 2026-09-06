import 'dart:async';

import 'package:discuz_flutter/utility/reading_position_restorer.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(ScrollController controller) => Directionality(
      textDirection: TextDirection.ltr,
      child: CustomScrollView(controller: controller, slivers: [
        SliverList.builder(
            itemCount: 100,
            itemBuilder: (_, i) =>
                SizedBox(height: 60.0 + i % 3, child: Text('$i'))),
      ]),
    );

void main() {
  testWidgets('waits for content readiness then restores the target',
      (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    final restorer = ReadingPositionRestorer()..schedule(1800);
    await tester.pumpWidget(_host(controller));
    await tester.pump(const Duration(seconds: 1));
    expect(controller.offset, 0);
    expect(restorer.pending, isTrue);
    final done = restorer.restoreWhenReady(controller);
    await tester.pumpAndSettle();
    await done;
    expect(controller.offset, closeTo(1800, 1));
    expect(restorer.pending, isFalse);
  });

  testWidgets('user cancellation never jumps back to the old target',
      (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    final restorer = ReadingPositionRestorer()..schedule(1800);
    await tester.pumpWidget(_host(controller));
    final done = restorer.restoreWhenReady(controller);
    await tester.pump(const Duration(milliseconds: 100));
    restorer.cancel();
    controller.jumpTo(250);
    await tester.pumpAndSettle();
    await done;
    expect(controller.offset, 250);
    expect(restorer.pending, isFalse);
  });

  testWidgets('initial refresh cannot finalize a temporary shorter extent',
      (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    final restorer = ReadingPositionRestorer()..schedule(1800);
    final loaded = Completer<void>();
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: CustomScrollView(controller: controller, slivers: const [
        SliverToBoxAdapter(child: SizedBox(height: 1000)),
      ]),
    ));
    final done =
        restorer.restoreWhenReady(controller, contentSettled: loaded.future);
    await tester.pumpAndSettle();
    expect(restorer.pending, isTrue);
    expect(controller.offset, lessThan(1800));
    await tester.pumpWidget(_host(controller));
    loaded.complete();
    await tester.pumpAndSettle();
    await done;
    expect(controller.offset, closeTo(1800, 1));
    expect(restorer.pending, isFalse);
  });

  testWidgets('drag while waiting for refresh cancels the final correction',
      (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    final restorer = ReadingPositionRestorer()..schedule(1800);
    final loaded = Completer<void>();
    await tester.pumpWidget(_host(controller));
    final done =
        restorer.restoreWhenReady(controller, contentSettled: loaded.future);
    await tester.pumpAndSettle();
    expect(restorer.pending, isTrue);
    restorer.cancel();
    controller.jumpTo(250);
    loaded.complete();
    await tester.pumpAndSettle();
    await done;
    expect(controller.offset, 250);
    expect(restorer.pending, isFalse);
  });

  testWidgets('shorter content clamps restoration to the reachable end',
      (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    final restorer = ReadingPositionRestorer()..schedule(100000);
    await tester.pumpWidget(_host(controller));
    final done = restorer.restoreWhenReady(controller);
    await tester.pumpAndSettle();
    await done;
    expect(controller.offset, controller.position.maxScrollExtent);
    expect(restorer.pending, isFalse);
  });

  testWidgets('disposal cancels pending corrections safely', (tester) async {
    final controller = ScrollController();
    final restorer = ReadingPositionRestorer()..schedule(1800);
    await tester.pumpWidget(_host(controller));
    final done = restorer.restoreWhenReady(controller);
    await tester.pump(const Duration(milliseconds: 100));
    restorer.cancel();
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    await tester.pumpAndSettle();
    await done;
    expect(restorer.pending, isFalse);
    expect(tester.takeException(), isNull);
  });

  test('invalid and zero offsets do not schedule work', () {
    final restorer = ReadingPositionRestorer();
    for (final offset in [double.nan, double.infinity, -1.0, 0.0]) {
      restorer.schedule(offset);
      expect(restorer.pending, isFalse);
    }
  });
}
