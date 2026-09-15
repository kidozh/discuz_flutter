import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:discuz_flutter/utility/thread_selection_colors.dart';

void main() {
  double contrast(Color a, Color b) {
    final x = a.computeLuminance(), y = b.computeLuminance();
    return (math.max(x, y) + 0.05) / (math.min(x, y) + 0.05);
  }

  for (final brightness in Brightness.values) {
    for (final seed in [
      Colors.blue,
      Colors.purple,
      Colors.green,
      Colors.orange,
    ]) {
      test('selected thread remains readable: $brightness $seed', () {
        final scheme = ColorScheme.fromSeed(
          seedColor: seed,
          brightness: brightness,
        );
        final selected = ThreadSelectionColors(scheme);
        expect(
          contrast(selected.foreground, selected.background),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          contrast(selected.secondary, selected.background),
          greaterThanOrEqualTo(4.5),
        );
      });
    }
  }
}
