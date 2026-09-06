import 'dart:math' as math;
import 'dart:ui';

Map<String, Object?> summarizeThermalFrames(
    List<FrameTiming> frames, double refreshRate) {
  if (!refreshRate.isFinite || refreshRate <= 0) {
    throw ArgumentError.value(refreshRate, 'refreshRate');
  }
  final budgetUs = 1000000 / refreshRate;
  Map<String, Object?> distribution(Iterable<int> values) {
    final sorted = values.toList()..sort();
    if (sorted.isEmpty) return {'count': 0};
    double percentile(double p) =>
        sorted[math.max(0, (sorted.length * p).ceil() - 1)] / 1000;
    return {
      'count': sorted.length,
      'p50_ms': percentile(.50),
      'p95_ms': percentile(.95),
      'p99_ms': percentile(.99),
      'max_ms': sorted.last / 1000,
    };
  }

  final overBudget = frames
      .where((frame) =>
          frame.buildDuration.inMicroseconds > budgetUs ||
          frame.rasterDuration.inMicroseconds > budgetUs)
      .length;
  return {
    'frame_count': frames.length,
    'budget_ms': budgetUs / 1000,
    'build': distribution(frames.map((f) => f.buildDuration.inMicroseconds)),
    'raster': distribution(frames.map((f) => f.rasterDuration.inMicroseconds)),
    'vsync_to_raster_finish':
        distribution(frames.map((f) => f.totalSpan.inMicroseconds)),
    'build_or_raster_over_budget_count': overBudget,
    'build_or_raster_over_budget_percent':
        frames.isEmpty ? null : 100 * overBudget / frames.length,
    'note':
        'Engine frame timings, not presented FPS or touch-to-photon latency. '
            'UI and raster are pipelined; over-budget frames are not a direct '
            'count of display-dropped frames.',
  };
}
