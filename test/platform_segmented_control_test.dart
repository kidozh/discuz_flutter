import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child,
        {AppVisualStyle style = AppVisualStyle.cupertino,
        Brightness brightness = Brightness.light}) =>
    PlatformProvider(
      style: style,
      builder: (_) => MaterialApp(
        theme: ThemeData(brightness: brightness),
        home: Scaffold(body: Center(child: SizedBox(width: 320, child: child))),
      ),
    );

void main() {
  for (final labels in [
    <String>[],
    ['Only'],
    ['Light', 'System', 'Dark']
  ]) {
    testWidgets('Material segments support ${labels.length} options and taps',
        (tester) async {
      var selected = 0;
      await tester.pumpWidget(_host(
          StatefulBuilder(
              builder: (_, setState) => PlatformSegmentedControl(
                  labels: labels,
                  selectedIndex: selected,
                  onValueChanged: (value) => setState(() => selected = value))),
          style: AppVisualStyle.material));
      expect(find.byType(CupertinoSlidingSegmentedControl<int>), findsNothing);
      expect(find.byType(CupertinoSegmentedControl<int>), findsNothing);
      if (labels.isEmpty) {
        expect(find.byType(SegmentedButton<int>), findsNothing);
      } else {
        await tester.tap(find.text(labels.last));
        await tester.pumpAndSettle();
        expect(selected, labels.length - 1);
        expect(
            tester
                .widget<SegmentedButton<int>>(find.byType(SegmentedButton<int>))
                .selected,
            {selected});
      }
      expect(tester.takeException(), isNull);
    });
  }

  for (final brightness in Brightness.values) {
    testWidgets('classic segments keep the system palette in $brightness',
        (tester) async {
      await tester.pumpWidget(_host(
        PlatformSegmentedControl(
          labels: const ['Latest', 'Hot'],
          selectedIndex: 0,
          onValueChanged: (_) {},
          color: Colors.red,
          textColor: Colors.green,
          selectedTextColor: Colors.yellow,
        ),
        brightness: brightness,
      ));
      final finder = find.byType(CupertinoSlidingSegmentedControl<int>);
      final control =
          tester.widget<CupertinoSlidingSegmentedControl<int>>(finder);
      final defaults = CupertinoSlidingSegmentedControl<int>(
          children: const {0: Text('A'), 1: Text('B')}, onValueChanged: (_) {});
      final context = tester.element(finder);
      expect(CupertinoDynamicColor.resolve(control.thumbColor, context),
          CupertinoDynamicColor.resolve(defaults.thumbColor, context));
      expect(control.backgroundColor, defaults.backgroundColor);
      for (final label in ['Latest', 'Hot']) {
        final text = tester.widget<Text>(find.text(label).first);
        expect(text.style!.color, CupertinoColors.label.resolveFrom(context));
        expect(text.style!.fontFamily,
            CupertinoTheme.of(context).textTheme.textStyle.fontFamily);
        expect(text.style!.fontSize, 13);
      }
      expect(tester.getSize(find.byType(PlatformSegmentedControl)).height,
          greaterThanOrEqualTo(44));
      expect(find.byType(BackdropFilter), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('scrollable segments also use Cupertino colors in $brightness',
        (tester) async {
      await tester.pumpWidget(_host(
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: PlatformSegmentedControl(
            labels: const ['First', 'Second', 'Third', 'Fourth'],
            selectedIndex: 1,
            onValueChanged: (_) {},
            color: Colors.red,
            textColor: Colors.green,
            selectedTextColor: Colors.yellow,
          ),
        ),
        brightness: brightness,
      ));
      final finder = find.byType(CupertinoSegmentedControl<int>);
      final control = tester.widget<CupertinoSegmentedControl<int>>(finder);
      final context = tester.element(finder);
      expect(
          control.selectedColor,
          brightness == Brightness.light
              ? CupertinoColors.white
              : CupertinoColors.systemGrey2.resolveFrom(context));
      expect(control.unselectedColor,
          CupertinoColors.tertiarySystemFill.resolveFrom(context));
      expect(control.borderColor,
          CupertinoColors.systemGrey4.resolveFrom(context));
      expect(tester.widget<Text>(find.text('Second')).style!.color,
          CupertinoColors.label.resolveFrom(context));
      expect(find.byType(CupertinoSlidingSegmentedControl<int>), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('segments support both tapping and dragging the thumb',
      (tester) async {
    var selected = 0;
    await tester.pumpWidget(_host(StatefulBuilder(builder: (_, setState) {
      return PlatformSegmentedControl(
        labels: const ['Latest', 'Hot', 'Featured'],
        selectedIndex: selected,
        onValueChanged: (value) => setState(() => selected = value),
      );
    })));
    Finder label(String text) => find.text(text).hitTestable().first;
    await tester.tap(label('Hot'));
    await tester.pumpAndSettle();
    expect(selected, 1);
    final gesture = await tester.startGesture(tester.getCenter(label('Hot')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await gesture.moveTo(tester.getCenter(label('Featured')));
    await tester.pump(const Duration(milliseconds: 300));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(selected, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('switching appearance preserves the selected segment',
      (tester) async {
    Widget control() => PlatformSegmentedControl(
          labels: const ['Latest', 'Hot'],
          selectedIndex: 1,
          onValueChanged: (_) {},
          color: Colors.red,
          textColor: Colors.green,
          selectedTextColor: Colors.yellow,
        );
    await tester.pumpWidget(_host(control(), style: AppVisualStyle.material));
    final finder = find.byType(CupertinoSlidingSegmentedControl<int>);
    final material =
        tester.widget<SegmentedButton<int>>(find.byType(SegmentedButton<int>));
    expect(material.selected, {1});
    expect(material.style!.backgroundColor!.resolve({WidgetState.selected}),
        Colors.red);
    expect(material.style!.foregroundColor!.resolve({WidgetState.selected}),
        Colors.yellow);
    expect(finder, findsNothing);
    await tester.pumpWidget(_host(control()));
    await tester.pumpAndSettle();
    expect(
        tester.widget<CupertinoSlidingSegmentedControl<int>>(finder).groupValue,
        1);
    expect(tester.widget<Text>(find.text('Hot').first).style!.color,
        CupertinoColors.label.resolveFrom(tester.element(finder)));
    expect(tester.takeException(), isNull);
  });
}
