import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import '../integration_test/support/thermal_metrics.dart';

FrameTiming frame(int build, int raster) => FrameTiming(
      vsyncStart: 0,
      buildStart: 100,
      buildFinish: 100 + build,
      rasterStart: 100 + build,
      rasterFinish: 100 + build + raster,
      rasterFinishWallTime: 100 + build + raster,
    );

void main() {
  test('empty sample is unavailable, not a zero-cost frame', () {
    final result = summarizeThermalFrames([], 60);
    expect(result['frame_count'], 0);
    expect(result['build_or_raster_over_budget_percent'], isNull);
    expect(result['raster'], {'count': 0});
  });

  test('uses per-thread budget without summing pipeline work', () {
    final result = summarizeThermalFrames(
        [frame(10000, 10000), frame(17000, 2000), frame(1000, 18000)], 60);
    expect(result['build_or_raster_over_budget_count'], 2);
    expect(
        result['build_or_raster_over_budget_percent'], closeTo(200 / 3, .001));
    expect((result['raster'] as Map)['p50_ms'], 10);
    expect((result['raster'] as Map)['p95_ms'], 18);
  });

  test('counts a frame over both thread budgets only once', () {
    final result = summarizeThermalFrames([frame(20000, 30000)], 60);
    expect(result['build_or_raster_over_budget_count'], 1);
    expect(result.containsKey('fps'), isFalse);
    expect(() => summarizeThermalFrames([], 0), throwsArgumentError);
  });
}
