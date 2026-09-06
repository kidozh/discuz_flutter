import 'package:flutter/widgets.dart';
import 'package:discuz_flutter/utility/ReadingPerformanceProbe.dart';

/// Waits for asynchronously built long HTML before restoring its numeric offset.
/// Bounded corrections account for the sliver's estimated extent changing as
/// nearby blocks are laid out. User scrolling/refresh/disposal cancels the job.
class ReadingPositionRestorer {
  double? _target;
  bool _active = false;
  int _generation = 0;

  bool get pending => _target != null || _active;

  void schedule(double offset) {
    cancel();
    if (offset.isFinite && offset > 0) _target = offset;
  }

  void cancel() {
    _generation++;
    _target = null;
    _active = false;
  }

  Future<void> restoreWhenReady(ScrollController controller,
      {Future<void>? contentSettled}) async {
    final target = _target;
    if (target == null || _active || !controller.hasClients) return;
    final generation = _generation;
    _active = true;
    bool valid() => generation == _generation && controller.hasClients;
    void record(String stage) {
      if (!ReadingPerformanceProbe.enabled || !valid()) return;
      ReadingPerformanceProbe.record('readingPosition.restore', {
        'stage': stage,
        'target': target,
        'offset': controller.offset,
        'max_extent': controller.position.maxScrollExtent,
      });
    }

    try {
      record('start');
      await controller.animateTo(target,
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
      if (!valid()) return;
      record('animated');
      // Cached HTML can be ready before the initial refresh finishes. Its
      // temporary extent is not the final reachable end; keep the original
      // target until that response (and the refresh indicator) has settled.
      if (contentSettled != null) await contentSettled;
      for (var attempt = 0; attempt < 3; attempt++) {
        await WidgetsBinding.instance.endOfFrame;
        if (!valid()) return;
        record('correct_$attempt');
        final reachable =
            target.clamp(0.0, controller.position.maxScrollExtent);
        if ((controller.offset - reachable).abs() <= 1) return;
        controller.jumpTo(reachable);
      }
    } finally {
      record('finished');
      if (generation == _generation) cancel();
    }
  }
}
