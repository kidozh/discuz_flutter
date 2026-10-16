import 'dart:ui';

import 'package:discuz_flutter/utility/TwoPaneScaffold.dart';
import 'package:discuz_flutter/utility/TwoPaneUtils.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:dual_screen/dual_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

DisplayFeature fold(Rect bounds, {bool flat = false}) => DisplayFeature(
  bounds: bounds,
  type: DisplayFeatureType.fold,
  state: flat
      ? DisplayFeatureState.postureFlat
      : DisplayFeatureState.postureHalfOpened,
);

class DraftPane extends StatefulWidget {
  final String label;
  const DraftPane(this.label, {super.key});
  @override
  State<DraftPane> createState() => DraftPaneState();
}

class DraftPaneState extends State<DraftPane> {
  final controller = TextEditingController();
  final scroll = ScrollController();
  final focus = FocusNode();
  @override
  void dispose() {
    controller.dispose();
    scroll.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      children: [
        Text(widget.label),
        TextField(controller: controller, focusNode: focus),
        Expanded(
          child: ListView(
            controller: scroll,
            children: [
              for (var i = 0; i < 50; i++)
                SizedBox(height: 50, child: Text('row $i')),
            ],
          ),
        ),
      ],
    ),
  );
}

void main() {
  test('width and height determine layout, with no simulated hinge', () {
    expect(PaneLayout.resolve(const Size(390, 844), []).showsBoth, isFalse);
    expect(PaneLayout.resolve(const Size(680, 900), []).showsBoth, isFalse);
    expect(PaneLayout.resolve(const Size(900, 700), []).showsBoth, isTrue);
    expect(PaneLayout.resolve(const Size(1200, 260), []).showsBoth, isFalse);
    expect(
      PaneLayout.resolve(
        const Size(844, 390),
        [],
        compactSizeClass: true,
      ).showsBoth,
      isFalse,
    );
    expect(
      PaneLayout.resolve(
        const Size(640, 700),
        [],
        regularSizeClass: true,
      ).showsBoth,
      isTrue,
    );
    final wide = PaneLayout.resolve(const Size(1600, 900), []);
    expect(wide.start.width, 420);
    expect(wide.end.left, wide.start.right);
    final rtl = PaneLayout.resolve(
      const Size(900, 700),
      [],
      textDirection: TextDirection.rtl,
    );
    expect(rtl.start.right, 900);
    expect(rtl.end.left, 0);
  });

  test('real off-centre vertical and horizontal folds constrain panes', () {
    final vertical = PaneLayout.resolve(const Size(900, 700), [
      fold(const Rect.fromLTWH(330, 0, 20, 700)),
    ]);
    expect(vertical.start.right, 330);
    expect(vertical.end.left, 350);
    expect(vertical.showsBoth, isTrue);
    final horizontal = PaneLayout.resolve(const Size(700, 900), [
      fold(const Rect.fromLTWH(0, 350, 700, 20)),
    ]);
    expect(horizontal.start.bottom, 350);
    expect(horizontal.end.top, 370);
    expect(horizontal.showsBoth, isTrue);
    final narrow = PaneLayout.resolve(const Size(500, 700), [
      fold(const Rect.fromLTWH(180, 0, 10, 700)),
    ]);
    expect(narrow.showsBoth, isFalse);
    expect(narrow.end.left, 190); // Single pane also avoids the active fold.
    final flat = PaneLayout.resolve(const Size(900, 700), [
      fold(const Rect.fromLTWH(500, 0, 0, 700), flat: true),
    ]);
    expect(flat.start.width, 315); // Flat crease does not force a split.
  });

  test('pane media rebases asymmetric safe areas, keyboard and camera', () {
    const camera = DisplayFeature(
      bounds: Rect.fromLTWH(740, 0, 24, 30),
      type: DisplayFeatureType.cutout,
      state: DisplayFeatureState.unknown,
    );
    final media = MediaQueryData(
      size: const Size(900, 700),
      padding: const EdgeInsets.fromLTRB(50, 24, 12, 0),
      viewPadding: const EdgeInsets.fromLTRB(50, 24, 12, 20),
      viewInsets: const EdgeInsets.only(bottom: 250),
      displayFeatures: [camera],
    );
    final local = mediaQueryForPane(
      media,
      const Rect.fromLTRB(400, 0, 888, 700),
    );
    expect(local.size, const Size(488, 700));
    expect(local.padding, const EdgeInsets.only(top: 30));
    expect(local.viewInsets.bottom, 250);
    expect(local.displayFeatures.single.bounds.left, 340);
    final top = mediaQueryForPane(media, const Rect.fromLTRB(0, 0, 900, 350));
    final bottom = mediaQueryForPane(
      media,
      const Rect.fromLTRB(0, 370, 900, 700),
    );
    expect(top.viewInsets.bottom, 0);
    expect(bottom.viewInsets.bottom, 250);
    expect(bottom.padding.top, 0);
  });

  testWidgets(
    'folding retains both drafts, focus isolation and scroll positions',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(900, 700);
      addTearDown(tester.view.reset);
      final master = GlobalKey<DraftPaneState>();
      final detail = GlobalKey<DraftPaneState>();
      var selected = true;
      late StateSetter rebuild;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return TwoPaneScaffold(
                type: TwoPaneType.tablet,
                onCloseDetail: () => setState(() => selected = false),
                child: TwoPane(
                  panePriority: selected
                      ? TwoPanePriority.end
                      : TwoPanePriority.start,
                  startPane: DraftPane('master', key: master),
                  endPane: DraftPane('detail', key: detail),
                ),
              );
            },
          ),
        ),
      );
      master.currentState!.controller.text = 'master draft';
      detail.currentState!.controller.text = 'reply draft';
      master.currentState!.scroll.jumpTo(250);
      detail.currentState!.scroll.jumpTo(350);
      final masterState = master.currentState;
      final detailState = detail.currentState;
      tester.view.physicalSize = const Size(390, 844);
      await tester.pumpAndSettle();
      expect(find.text('master'), findsNothing);
      expect(find.text('detail'), findsOneWidget);
      expect(detail.currentState, same(detailState));
      expect(master.currentState, same(masterState));
      expect(detail.currentState!.controller.text, 'reply draft');
      detail.currentState!.focus.requestFocus();
      await tester.pump();
      rebuild(() => selected = false);
      await tester.pumpAndSettle();
      expect(detail.currentState!.focus.hasFocus, isFalse);
      tester.view.physicalSize = const Size(900, 700);
      await tester.pumpAndSettle();
      expect(master.currentState!.scroll.offset, 250);
      expect(detail.currentState!.scroll.offset, 350);
      expect(master.currentState!.controller.text, 'master draft');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('compact back clears selected detail and retains master', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    var selected = true;
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigator,
        home: StatefulBuilder(
          builder: (context, setState) => TwoPaneScaffold(
            type: TwoPaneType.smallScreen,
            onCloseDetail: () => setState(() => selected = false),
            child: TwoPane(
              panePriority: selected
                  ? TwoPanePriority.end
                  : TwoPanePriority.start,
              startPane: const Text('master'),
              endPane: const Text('detail'),
            ),
          ),
        ),
      ),
    );
    await navigator.currentState!.maybePop();
    await tester.pumpAndSettle();
    expect(selected, isFalse);
    expect(find.text('master'), findsOneWidget);
  });

  testWidgets('local constraints and left/right safe areas are respected', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1000, 700);
    addTearDown(tester.view.reset);
    MediaQueryData? master, detail;
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(padding: const EdgeInsets.only(left: 50, right: 12)),
          child: child!,
        ),
        home: TwoPaneScaffold(
          type: TwoPaneType.tablet,
          child: TwoPane(
            startPane: Builder(
              builder: (context) {
                master = MediaQuery.of(context);
                return const Text('master');
              },
            ),
            endPane: Builder(
              builder: (context) {
                detail = MediaQuery.of(context);
                return const Text('detail');
              },
            ),
          ),
        ),
      ),
    );
    expect(tester.getTopLeft(find.text('master')).dx, 50);
    expect(master!.size.width + detail!.size.width, 938);
    expect(master!.displayFeatures, isEmpty);
    expect(detail!.padding.right, 0);
  });
  for (final direction in TextDirection.values) {
    testWidgets('compact iOS edge swipe returns to master ($direction)', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.reset);
      var selected = true;
      await tester.pumpWidget(
        PlatformProvider(
          style: AppVisualStyle.cupertino,
          builder: (_) => MaterialApp(
            home: Directionality(
              textDirection: direction,
              child: StatefulBuilder(
                builder: (context, setState) => TwoPaneScaffold(
                  type: TwoPaneType.smallScreen,
                  onCloseDetail: () => setState(() => selected = false),
                  child: TwoPane(
                    panePriority: selected
                        ? TwoPanePriority.end
                        : TwoPanePriority.start,
                    startPane: const Text('master'),
                    endPane: const Text('detail'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      final rtl = direction == TextDirection.rtl;
      await tester.dragFrom(
        Offset(rtl ? 380 : 10, 300),
        Offset(rtl ? -160 : 160, 0),
      );
      await tester.pumpAndSettle();
      expect(selected, isFalse);
      expect(find.text('master'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
