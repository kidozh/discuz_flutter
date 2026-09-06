import 'package:discuz_flutter/utility/ReadingPerformanceProbe.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    ReadingPerformanceProbe.enabled = false;
    ReadingPerformanceProbe.drain();
  });
  tearDown(() {
    ReadingPerformanceProbe.enabled = false;
    ReadingPerformanceProbe.drain();
  });
  test('normal app path records nothing and returns the original result', () {
    expect(ReadingPerformanceProbe.measure('unit', () => 42), 42);
    expect(ReadingPerformanceProbe.drain(), isEmpty);
    ReadingPerformanceProbe.record('post.content', {'html_chars': 42});
    expect(ReadingPerformanceProbe.drain(), isEmpty);
  });
  test('opt-in measurement drains timing metadata only', () {
    ReadingPerformanceProbe.enabled = true;
    expect(ReadingPerformanceProbe.measure('unit', () => 'private body'),
        'private body');
    final events = ReadingPerformanceProbe.drain();
    expect(events, hasLength(1));
    expect(events.single.keys,
        unorderedEquals(['name', 'start_us', 'duration_us']));
    expect(events.single['duration_us'], greaterThanOrEqualTo(0));
    expect(ReadingPerformanceProbe.drain(), isEmpty);
  });
  test('measurement preserves exceptions and records elapsed work', () {
    ReadingPerformanceProbe.enabled = true;
    final error = StateError('unit');
    expect(() => ReadingPerformanceProbe.measure('unit', () => throw error),
        throwsA(same(error)));
    expect(ReadingPerformanceProbe.drain(), hasLength(1));
  });
  test('layout instrumentation is absent when disabled', () {
    const child = SizedBox(width: 120, height: 30);
    expect(ReadingPerformanceProbe.layout('layout', child), same(child));
    const sliver = SliverToBoxAdapter(child: child);
    expect(
        ReadingPerformanceProbe.sliverLayout('sliver', sliver), same(sliver));
  });
  testWidgets('sliver instrumentation preserves scroll geometry',
      (tester) async {
    ReadingPerformanceProbe.enabled = true;
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: CustomScrollView(controller: controller, slivers: [
        ReadingPerformanceProbe.sliverLayout(
            'sliver', const SliverToBoxAdapter(child: SizedBox(height: 2000))),
      ]),
    ));
    expect(controller.position.maxScrollExtent, 1400);
    expect(ReadingPerformanceProbe.drain().any((e) => e['name'] == 'sliver'),
        isTrue);
  });
  testWidgets('layout instrumentation preserves child geometry',
      (tester) async {
    ReadingPerformanceProbe.enabled = true;
    const child = SizedBox(key: ValueKey('child'), width: 120, height: 30);
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: ReadingPerformanceProbe.layout('layout', child)),
    ));
    expect(tester.getSize(find.byKey(const ValueKey('child'))),
        const Size(120, 30));
    expect(ReadingPerformanceProbe.drain().any((e) => e['name'] == 'layout'),
        isTrue);
  });
}
