import 'package:flutter/material.dart';

/// A dark, theme-tinted selection fill with readable light text.
class ThreadSelectionColors {
  ThreadSelectionColors(ColorScheme scheme)
    : background = Color.alphaBlend(
        scheme.primary.withValues(
          alpha: scheme.brightness == Brightness.dark ? 0.32 : 0.72,
        ),
        const Color(0xFF101820),
      ),
      foreground = Colors.white;

  final Color background;
  final Color foreground;
  Color get secondary =>
      Color.alphaBlend(Colors.white.withValues(alpha: 0.82), background);
}
