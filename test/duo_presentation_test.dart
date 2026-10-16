import 'dart:async';
import 'dart:ui';

import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/utility/TwoPaneScaffold.dart';
import 'package:discuz_flutter/utility/TwoPaneUtils.dart';
import 'package:dual_screen/dual_screen.dart';
import 'package:foldable/foldable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final style in [
    AppVisualStyle.material,
    AppVisualStyle.cupertino,
    AppVisualStyle.liquidGlass,
  ]) {
    testWidgets(
      'open presentations follow the detail pane through rotation: $style',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(900, 700);
        addTearDown(tester.view.reset);
        BuildContext? source;
        await tester.pumpWidget(
          PlatformProvider(
            style: style,
            builder: (_) => MaterialApp(
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              builder: (context, child) {
                final media = MediaQuery.of(context);
                final vertical = media.size.width > media.size.height;
                return MediaQuery(
                  data: media.copyWith(
                    displayFeatures: [
                      DisplayFeature(
                        bounds: vertical
                            ? const Rect.fromLTWH(400, 0, 20, 700)
                            : const Rect.fromLTWH(0, 400, 700, 20),
                        type: DisplayFeatureType.fold,
                        state: DisplayFeatureState.postureHalfOpened,
                      ),
                    ],
                  ),
                  child: child!,
                );
              },
              home: TwoPaneScaffold(
                type: TwoPaneType.foldable,
                child: TwoPane(
                  startPane: const Text('list'),
                  endPane: Builder(
                    builder: (context) {
                      source = context;
                      return const SizedBox.expand(child: Text('detail'));
                    },
                  ),
                ),
              ),
            ),
          ),
        );
        final dialog = showPlatformDialog<void>(
          context: source!,
          builder: (_) => const PlatformAlertDialog(
            title: Text('Rotating dialog'),
            content: Text('Content'),
          ),
        );
        await tester.pumpAndSettle();
        tester.view.physicalSize = const Size(700, 900);
        await tester.pumpAndSettle();
        expect(
          tester.getTopLeft(find.text('Rotating dialog')).dy,
          greaterThanOrEqualTo(420),
        );
        Navigator.of(source!, rootNavigator: true).pop();
        await tester.pumpAndSettle();
        await dialog;
        final sheet = showPlatformModalSheet<void>(
          context: source!,
          builder: (_) => const SizedBox(
            key: Key('rotating-sheet'),
            height: 180,
            child: Material(child: TextField()),
          ),
        );
        await tester.pumpAndSettle();
        final fieldState = tester.state(find.byType(TextField));
        await tester.enterText(find.byType(TextField), 'unsent draft');
        tester.view.physicalSize = const Size(900, 700);
        await tester.pumpAndSettle();
        expect(
          tester.getTopLeft(find.byKey(const Key('rotating-sheet'))).dx,
          greaterThanOrEqualTo(420),
        );
        expect(tester.state(find.byType(TextField)), same(fieldState));
        expect(find.text('unsent draft'), findsOneWidget);
        tester.view.physicalSize = const Size(700, 900);
        await tester.pumpAndSettle();
        expect(
          tester.getTopLeft(find.byKey(const Key('rotating-sheet'))).dy,
          greaterThanOrEqualTo(420),
        );
        expect(tester.state(find.byType(TextField)), same(fieldState));
        expect(tester.takeException(), isNull);
        Navigator.of(source!, rootNavigator: true).pop();
        await tester.pumpAndSettle();
        await sheet;
      },
    );

    testWidgets(
      'dialog and sheet stay beside their source on an active fold: $style',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(900, 700);
        addTearDown(tester.view.reset);
        BuildContext? source;
        await tester.pumpWidget(
          PlatformProvider(
            style: style,
            builder: (_) => MaterialApp(
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  displayFeatures: const [
                    DisplayFeature(
                      bounds: Rect.fromLTWH(400, 0, 20, 700),
                      type: DisplayFeatureType.fold,
                      state: DisplayFeatureState.postureHalfOpened,
                    ),
                  ],
                ),
                child: child!,
              ),
              home: Scaffold(
                body: Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 300,
                    height: 500,
                    child: Builder(
                      builder: (context) {
                        source = context;
                        return const Text('source');
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        double? dialogWidth;
        final dialog = showPlatformDialog<void>(
          context: source!,
          builder: (context) {
            dialogWidth = MediaQuery.sizeOf(context).width;
            return const PlatformAlertDialog(
              title: Text('Dialog beside source'),
              content: Text('Content'),
            );
          },
        );
        await tester.pumpAndSettle();
        expect(dialogWidth, 480);
        expect(
          tester.getTopLeft(find.text('Dialog beside source')).dx,
          greaterThanOrEqualTo(420),
        );
        Navigator.of(source!, rootNavigator: true).pop();
        await tester.pumpAndSettle();
        await dialog;
        double? sheetWidth;
        final sheet = showPlatformModalSheet<void>(
          context: source!,
          builder: (context) {
            sheetWidth = MediaQuery.sizeOf(context).width;
            return const SizedBox(
              key: Key('sheet'),
              height: 250,
              child: Text('Sheet beside source'),
            );
          },
        );
        await tester.pumpAndSettle();
        expect(sheetWidth, 480);
        final rect = tester.getRect(find.byKey(const Key('sheet')));
        expect(rect.left, greaterThanOrEqualTo(420));
        expect(rect.right, lessThanOrEqualTo(900));
        expect(tester.takeException(), isNull);
        Navigator.of(source!, rootNavigator: true).pop();
        await tester.pumpAndSettle();
        await sheet;
      },
    );
  }

  testWidgets(
    'wide Cupertino sheet has bounded width and avoids keyboard once',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1200, 900);
      addTearDown(tester.view.reset);
      BuildContext? source;
      double? inset;
      double? width;
      await tester.pumpWidget(
        PlatformProvider(
          style: AppVisualStyle.cupertino,
          builder: (_) => MaterialApp(
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            home: Builder(
              builder: (context) {
                source = context;
                return const Scaffold();
              },
            ),
          ),
        ),
      );
      final sheet = showPlatformModalSheet<void>(
        context: source!,
        builder: (context) {
          inset = MediaQuery.viewInsetsOf(context).bottom;
          width = MediaQuery.sizeOf(context).width;
          return const SizedBox(
            key: Key('sheet'),
            height: 300,
            child: Text('Sheet'),
          );
        },
      );
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byKey(const Key('sheet'))).width, 640);
      expect(width, 640);
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpAndSettle();
      expect(
        tester.getBottomRight(find.byKey(const Key('sheet'))).dy,
        lessThanOrEqualTo(600),
      );
      expect(
        inset,
        0,
      ); // Consumed by the sheet viewport, not its nested scaffold.
      expect(tester.takeException(), isNull);
      Navigator.of(source!, rootNavigator: true).pop();
      await tester.pumpAndSettle();
      await sheet;
    },
  );

  testWidgets(
    'native fold snapshots publish active regions without remounting content',
    (tester) async {
      final updates = StreamController<FoldableData>();
      addTearDown(updates.close);
      final text = TextEditingController(text: 'draft');
      addTearDown(text.dispose);
      List<DisplayFeature>? features;
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => FoldableProvider(
            debugData: updates.stream,
            bridgeMode: DisplayFeatureBridgeMode.full,
            child: child!,
          ),
          home: Builder(
            builder: (context) {
              features = MediaQuery.of(context).displayFeatures;
              return Scaffold(body: TextField(controller: text));
            },
          ),
        ),
      );
      final fieldState = tester.state(find.byType(TextField));
      final partial = FoldableData.unsupported.copyWith(
        status: HingeStatus.partiallyOpen,
        regions: const [
          ReservedRegion(
            kind: ReservedRegionKind.division,
            bounds: Rect.fromLTWH(390, 0, 20, 600),
            isActive: true,
          ),
          ReservedRegion(
            kind: ReservedRegionKind.occlusion,
            bounds: Rect.fromLTWH(650, 0, 20, 24),
            isActive: true,
          ),
        ],
      );
      updates.add(partial);
      await tester.pumpAndSettle();
      expect(
        features!.map((f) => f.type),
        containsAll([DisplayFeatureType.fold, DisplayFeatureType.cutout]),
      );
      updates.add(partial.copyWith(status: HingeStatus.fullyOpen));
      await tester.pumpAndSettle();
      expect(
        features!.where((f) => f.type == DisplayFeatureType.fold),
        isEmpty,
      );
      updates.add(partial.copyWith(status: HingeStatus.closed));
      await tester.pumpAndSettle();
      expect(features, isEmpty);
      expect(tester.state(find.byType(TextField)), same(fieldState));
      expect(text.text, 'draft');
    },
  );
}
