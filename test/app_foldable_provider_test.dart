import 'dart:async';
import 'dart:ui';

import 'package:discuz_flutter/utility/app_foldable_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foldable/foldable.dart';

class NativeSnapshots extends FoldablePlatform {
  FoldableData snapshot;
  final changes = StreamController<FoldableData>.broadcast();
  NativeSnapshots(this.snapshot);
  @override
  Future<FoldableData> getSnapshot() async => snapshot;
  @override
  Stream<FoldableData> get events => changes.stream;
}

const pending = FoldableCapabilities(
  supportLevel: FoldableSupportLevel.unknown,
  isFoldable: false,
  hingeApiPresent: true,
  regionApiPresent: true,
  angleUnitVerified: true,
  strategy: 'native',
);
const available = FoldableCapabilities(
  supportLevel: FoldableSupportLevel.available,
  isFoldable: true,
  hingeApiPresent: true,
  regionApiPresent: true,
  angleUnitVerified: true,
  strategy: 'native',
);

void main() {
  testWidgets('unknown startup waits for the first native hinge update', (
    tester,
  ) async {
    final source = NativeSnapshots(
      FoldableData.unsupported.copyWith(capabilities: pending),
    );
    addTearDown(source.changes.close);
    FoldableData? data;
    List<DisplayFeature>? features;
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) =>
            AppFoldableProvider(platform: source, child: child!),
        home: Builder(
          builder: (context) {
            data = DuoMediaQuery.of(context);
            features = MediaQuery.of(context).displayFeatures;
            return const Scaffold(body: Text('Content'));
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(source.changes.hasListener, isTrue);
    final partial = FoldableData.unsupported.copyWith(
      capabilities: available,
      status: HingeStatus.partiallyOpen,
      horizontalSizeClass: SizeClass.regular,
      regions: const [
        ReservedRegion(
          kind: ReservedRegionKind.division,
          bounds: Rect.fromLTWH(390, 0, 20, 600),
          isActive: true,
        ),
      ],
    );
    source.changes.add(partial);
    await tester.pumpAndSettle();
    expect(data!.isFoldable, isTrue);
    expect(features!.single.type, DisplayFeatureType.fold);
    source.changes.add(partial.copyWith(status: HingeStatus.fullyOpen));
    await tester.pumpAndSettle();
    expect(features, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'non-folding windows still refresh native size classes on resize',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.reset);
      final source = NativeSnapshots(
        FoldableData.unsupported.copyWith(
          horizontalSizeClass: SizeClass.compact,
        ),
      );
      addTearDown(source.changes.close);
      SizeClass? sizeClass;
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) =>
              AppFoldableProvider(platform: source, child: child!),
          home: Builder(
            builder: (context) {
              sizeClass = DuoMediaQuery.horizontalSizeClassOf(context);
              return const Scaffold();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(sizeClass, SizeClass.compact);
      expect(source.changes.hasListener, isFalse);
      source.snapshot = source.snapshot.copyWith(
        horizontalSizeClass: SizeClass.regular,
      );
      tester.view.physicalSize = const Size(900, 700);
      await tester.pumpAndSettle();
      expect(sizeClass, SizeClass.regular);
      expect(source.changes.hasListener, isFalse);
    },
  );
}
