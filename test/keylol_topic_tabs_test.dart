import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/widget/KeylolTopicTabs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(Widget child, {TargetPlatform platform = TargetPlatform.iOS}) =>
    PlatformProvider(
        initialPlatform: platform,
        builder: (_) => MaterialApp(home: Scaffold(body: child)));

void main() {
  for (final direction in TextDirection.values) {
    testWidgets('glass hit regions let horizontal scrolling win ($direction)',
        (tester) async {
      final scroll = ScrollController();
      addTearDown(scroll.dispose);
      var selected = 0;
      var nativeDrags = 0;
      const labels = ['Latest', 'Shopping', 'Games', 'Hot', 'Featured'];
      await tester.pumpWidget(host(Directionality(
        textDirection: direction,
        child: Center(
            child: SizedBox(
          width: 320,
          child: StatefulBuilder(
              builder: (_, setState) => SingleChildScrollView(
                    controller: scroll,
                    scrollDirection: Axis.horizontal,
                    child: KeylolScrollableTabHitRegion(
                      labels: labels,
                      selectedIndex: selected,
                      onSelected: (index) => setState(() => selected = index),
                      // Simulate the native control's competing pan recognizer.
                      child: SizedBox(
                          width: 800,
                          height: 44,
                          child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onPanUpdate: (_) => nativeDrags++)),
                    ),
                  )),
        )),
      )));
      Finder segment(String label) => find.byWidgetPredicate(
          (widget) => widget is Semantics && widget.properties.label == label);
      await tester.drag(segment('Latest'),
          Offset(direction == TextDirection.ltr ? -220 : 220, 0));
      await tester.pumpAndSettle();
      expect(scroll.offset, greaterThan(0));
      expect(selected, 0);
      expect(nativeDrags, 0);
      await Scrollable.ensureVisible(tester.element(segment('Games')),
          alignment: .5);
      await tester.pumpAndSettle();
      await tester.tap(segment('Games'));
      await tester.pumpAndSettle();
      expect(selected, 2);
      expect(tester.widget<Semantics>(segment('Games')).properties.selected,
          isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'topic taps, page swipes and label visibility stay in sync ($direction)',
        (tester) async {
      final built = <int>{};
      Widget topics({double scale = 1, int count = 8}) => host(Directionality(
            textDirection: direction,
            child: Center(
                child: SizedBox(
              width: 320,
              child: MediaQuery(
                data: MediaQueryData(
                    size: const Size(320, 600),
                    textScaler: TextScaler.linear(scale)),
                child: KeylolTopicTabs(
                    titles: List.generate(count, (index) => 'Topic $index'),
                    topicBuilder: (_, index) {
                      built.add(index);
                      return Center(child: Text('page-$index'));
                    }),
              ),
            )),
          ));
      await tester.pumpWidget(topics());
      await tester.pumpAndSettle();
      expect(built, {0});
      await Scrollable.ensureVisible(tester.element(find.text('Topic 6')),
          alignment: .5);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Topic 6'));
      await tester.pumpAndSettle();
      expect(find.text('page-6'), findsOneWidget);
      expect(built, {0, 6});
      final control = find.byType(PlatformSegmentedControl);
      await tester.drag(find.byType(PageView),
          Offset(direction == TextDirection.ltr ? -280 : 280, 0));
      await tester.pumpAndSettle();
      expect(tester.widget<PlatformSegmentedControl>(control).selectedIndex, 7);
      expect(find.text('Topic 7').hitTestable(), findsOneWidget);
      await tester.pumpWidget(topics(scale: 2));
      await tester.pumpAndSettle();
      expect(find.text('Topic 7').hitTestable(), findsOneWidget);
      // A refresh that reduces the category count must not leave an empty page.
      await tester.pumpWidget(topics(count: 2));
      await tester.pumpAndSettle();
      expect(tester.widget<PlatformSegmentedControl>(control).selectedIndex, 1);
      expect(find.text('page-1'), findsOneWidget);
      await tester.pumpWidget(topics(count: 0));
      await tester.pumpAndSettle();
      expect(find.byType(PageView), findsNothing);
      await tester.pumpWidget(topics(count: 1));
      await tester.pumpAndSettle();
      expect(find.text('page-0'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Cupertino topic labels scroll independently from the topic list',
      (tester) async {
    await tester.pumpWidget(host(Center(
        child: SizedBox(
      width: 320,
      child: KeylolTopicTabs(
        titles: const ['最新主题', '热门购物', '游戏专区', '热门主题', '精华主题'],
        topicBuilder: (_, topic) => ListView.builder(
            itemCount: 100,
            itemExtent: 60,
            itemBuilder: (_, row) => Text('$topic:$row')),
      ),
    ))));
    final tabs = find.byType(PlatformSegmentedControl);
    final scroller = tester.state<ScrollableState>(
        find.ancestor(of: tabs, matching: find.byType(Scrollable)).first);
    await tester.drag(find.text('最新主题'), const Offset(-230, 0));
    await tester.pumpAndSettle();
    expect(scroller.position.pixels, greaterThan(0));
    expect(tester.widget<PlatformSegmentedControl>(tabs).selectedIndex, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Cupertino topic content swipes to the next category',
      (tester) async {
    await tester.pumpWidget(host(Center(
        child: SizedBox(
      width: 320,
      child: KeylolTopicTabs(
        titles: const ['最新主题', '热门主题', '精华主题'],
        topicBuilder: (_, topic) => ListView.builder(
            itemCount: 100,
            itemExtent: 60,
            itemBuilder: (_, row) => Text('$topic:$row')),
      ),
    ))));
    double listOffset() => tester
        .state<ScrollableState>(find.descendant(
            of: find.byType(ListView), matching: find.byType(Scrollable)))
        .position
        .pixels;
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    final firstOffset = listOffset();
    expect(firstOffset, greaterThan(0));
    await tester.drag(find.byType(ListView), const Offset(-280, 0));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<PlatformSegmentedControl>(
                find.byType(PlatformSegmentedControl))
            .selectedIndex,
        1);
    expect(find.text('1:0'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(280, 0));
    await tester.pumpAndSettle();
    expect(listOffset(), firstOffset);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'horizontal segmented control has finite bounds at large text scale',
      (tester) async {
    await tester.pumpWidget(host(Center(
        child: SizedBox(
      width: 240,
      child: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: PlatformSegmentedControl(
            labels: const ['最新主题', '很长的热门购物分类', '游戏专区', '热门主题', '精华主题'],
            selectedIndex: 999,
            onValueChanged: (_) {},
          ),
        ),
      ),
    ))));
    final control = find.byType(CupertinoSlidingSegmentedControl<int>);
    final box = tester.renderObject<RenderBox>(control);
    expect(box.constraints.hasBoundedWidth, isTrue);
    expect(box.size.width.isFinite, isTrue);
    expect(box.size.width, greaterThan(240));
    expect(
        tester.widget<CupertinoSlidingSegmentedControl<int>>(control).groupValue, 4);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty and single-label controls do not assert', (tester) async {
    for (final labels in [
      <String>[],
      ['Only']
    ]) {
      await tester.pumpWidget(host(PlatformSegmentedControl(
        labels: labels,
        selectedIndex: -1,
        onValueChanged: (_) {},
      )));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('Cupertino tabs build only selected list and restore its offset',
      (tester) async {
    final builtTopics = <int>[];
    await tester.pumpWidget(host(KeylolTopicTabs(
      titles: const ['First', 'Second', 'Third', 'Fourth', 'Fifth'],
      topicBuilder: (_, topic) {
        builtTopics.add(topic);
        return ListView.builder(
            itemExtent: 60,
            itemCount: 100,
            itemBuilder: (_, row) => Text('$topic:$row'));
      },
    )));
    expect(builtTopics, [0]);
    expect(find.byType(ListView), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    double offset() => tester
        .state<ScrollableState>(find.descendant(
            of: find.byType(ListView), matching: find.byType(Scrollable)))
        .position
        .pixels;
    final firstOffset = offset();
    expect(firstOffset, greaterThan(0));

    tester
        .widget<PlatformSegmentedControl>(find.byType(PlatformSegmentedControl))
        .onValueChanged(1);
    await tester.pumpAndSettle();
    expect(builtTopics, [0, 1]);
    expect(offset(), 0);
    expect(find.byType(ListView), findsOneWidget);

    tester
        .widget<PlatformSegmentedControl>(find.byType(PlatformSegmentedControl))
        .onValueChanged(0);
    await tester.pumpAndSettle();
    expect(offset(), firstOffset);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Material tabs remain swipeable', (tester) async {
    await tester.pumpWidget(host(
        KeylolTopicTabs(
          titles: const ['First', 'Second'],
          topicBuilder: (_, index) => Center(child: Text('page-$index')),
        ),
        platform: TargetPlatform.android));
    expect(find.byType(TabBarView), findsOneWidget);
    expect(find.byType(PlatformSegmentedControl), findsNothing);
    await tester.drag(find.byType(TabBarView), const Offset(-700, 0));
    await tester.pumpAndSettle();
    expect(find.text('page-1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
