import 'package:flutter/material.dart';

import 'material_surface_theme.dart';

class ThreadSelectionColors {
  ThreadSelectionColors(ColorScheme scheme)
    : _scheme = scheme,
      background = Color.alphaBlend(
        scheme.primary.withValues(
          alpha: scheme.brightness == Brightness.dark ? 0.22 : 0.14,
        ),
        scheme.surface,
      );

  final ColorScheme _scheme;
  final Color background;
  Color get foreground =>
      readableForumForeground(_scheme.onSurface, background);
  Color get secondary =>
      readableForumForeground(_scheme.onSurfaceVariant, background);
}
