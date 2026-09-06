// ignore_for_file: file_names
import 'dart:developer';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Opt-in diagnostic counters; disabled in normal app startup. Never stores text,
/// account data or URLs. Timings overlap and must not be summed as frame costs.
class ReadingPerformanceProbe {
  static bool enabled = false;
  static final _events = <Map<String, Object?>>[];

  static T measure<T>(String name, T Function() action) {
    if (!enabled) return action();
    final start = Timeline.now;
    try {
      return Timeline.timeSync('Discuz.$name', action);
    } finally {
      if (_events.length < 30000) {
        _events.add({
          'name': name,
          'start_us': start,
          'duration_us': Timeline.now - start
        });
      }
    }
  }

  static List<Map<String, Object?>> drain() {
    final result = List<Map<String, Object?>>.of(_events);
    _events.clear();
    return result;
  }

  /// Opt-in structural metadata only. Callers must not include body text,
  /// account identifiers, authentication data or URLs.
  static void record(String name, Map<String, Object?> metrics) {
    if (!enabled || _events.length >= 30000) return;
    _events.add({
      'name': name,
      'start_us': Timeline.now,
      'duration_us': 0,
      'metrics': metrics,
    });
  }

  static Widget layout(String label, Widget child) =>
      enabled ? _ReadingLayoutProbe(label: label, child: child) : child;
  static Widget sliverLayout(String label, Widget child) =>
      enabled ? _ReadingSliverProbe(label: label, child: child) : child;
}

class _ReadingLayoutProbe extends SingleChildRenderObjectWidget {
  final String label;
  const _ReadingLayoutProbe({required this.label, required super.child});
  @override
  RenderObject createRenderObject(BuildContext context) =>
      _ReadingLayoutBox(label);
  @override
  void updateRenderObject(
      BuildContext context, _ReadingLayoutBox renderObject) {
    renderObject.label = label;
  }
}

class _ReadingLayoutBox extends RenderProxyBox {
  String label;
  _ReadingLayoutBox(this.label);
  @override
  void performLayout() =>
      ReadingPerformanceProbe.measure(label, super.performLayout);
}

class _ReadingSliverProbe extends SingleChildRenderObjectWidget {
  final String label;
  const _ReadingSliverProbe({required this.label, required super.child});
  @override
  RenderObject createRenderObject(BuildContext context) =>
      _ReadingSliverBox(label);
  @override
  void updateRenderObject(
      BuildContext context, _ReadingSliverBox renderObject) {
    renderObject.label = label;
  }
}

class _ReadingSliverBox extends RenderProxySliver {
  String label;
  _ReadingSliverBox(this.label);
  @override
  void performLayout() =>
      ReadingPerformanceProbe.measure(label, super.performLayout);
}
