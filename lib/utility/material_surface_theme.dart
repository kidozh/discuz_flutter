import 'package:flutter/material.dart';

/// Neutral reading surfaces; the selected theme still supplies action colors.
ThemeData withNeutralMaterialSurfaces(ThemeData theme) {
  final dark = theme.brightness == Brightness.dark;
  final card = dark ? const Color(0xFF1A1A1B) : Colors.white;
  final background = dark ? const Color(0xFF121212) : const Color(0xFFF6F7F8);
  final colors = theme.colorScheme.copyWith(
    surface: card,
    surfaceTint: Colors.transparent,
    surfaceDim: dark ? background : const Color(0xFFDADCE0),
    surfaceBright: dark ? const Color(0xFF333335) : Colors.white,
    surfaceContainerLowest: dark ? const Color(0xFF0E0E0F) : Colors.white,
    surfaceContainerLow: card,
    surfaceContainer: dark ? const Color(0xFF222223) : const Color(0xFFF6F7F8),
    surfaceContainerHigh: dark
        ? const Color(0xFF2A2A2B)
        : const Color(0xFFF0F1F2),
    surfaceContainerHighest: dark
        ? const Color(0xFF333335)
        : const Color(0xFFEDEFF1),
    outline: dark ? const Color(0xFF818384) : const Color(0xFF878A8C),
    outlineVariant: dark ? const Color(0xFF343536) : const Color(0xFFE2E4E6),
  );
  return theme.copyWith(
    colorScheme: colors,
    scaffoldBackgroundColor: background,
    canvasColor: background,
    cardColor: card,
    cardTheme: theme.cardTheme.copyWith(
      color: card,
      surfaceTintColor: Colors.transparent,
    ),
    dividerColor: colors.outlineVariant,
  );
}
