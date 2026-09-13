import 'package:flutter/material.dart';

/// A restrained selection fill with readable text in both appearance modes.
class ThreadSelectionColors {
  ThreadSelectionColors(ColorScheme scheme)
    : background = Color.alphaBlend(
        scheme.primary.withValues(
          alpha: scheme.brightness == Brightness.dark ? 0.16 : 0.09,
        ),
        scheme.surface,
      ),
      foreground = scheme.onSurface,
      secondary = scheme.onSurfaceVariant;

  final Color background;
  final Color foreground;
  final Color secondary;
}
