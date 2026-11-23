import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Uses the chosen theme hue for actions and neutral layers for reading.
ThemeData withForumColors(ThemeData theme, {required bool material}) {
  final dark = theme.brightness == Brightness.dark;
  final nativeInset = CupertinoColors.secondarySystemBackground;
  final card = material
      ? (dark ? const Color(0xFF1A2029) : Colors.white)
      : (dark ? nativeInset.darkColor : nativeInset.color);
  final background = material
      ? (dark ? const Color(0xFF11151C) : const Color(0xFFF3F5F8))
      : theme.scaffoldBackgroundColor;
  final inset = dark ? const Color(0xFF2B3542) : const Color(0xFFE8EDF4);
  final primary = readableForumForeground(theme.colorScheme.primary, inset);
  final secondary = readableForumForeground(theme.colorScheme.secondary, inset);
  final text = dark ? const Color(0xFFEAF0F8) : const Color(0xFF1A2534);
  final muted = dark ? const Color(0xFFB2BECD) : const Color(0xFF536173);
  final colors = theme.colorScheme.copyWith(
    primary: primary,
    onPrimary: readableForumForeground(theme.colorScheme.onPrimary, primary),
    secondary: secondary,
    onSecondary: readableForumForeground(
      theme.colorScheme.onSecondary,
      secondary,
    ),
    surface: card,
    onSurface: text,
    onSurfaceVariant: muted,
    surfaceTint: Colors.transparent,
    surfaceDim: dark ? background : const Color(0xFFD9E0E8),
    surfaceBright: dark ? const Color(0xFF343F4D) : Colors.white,
    surfaceContainerLowest: dark ? const Color(0xFF0E1218) : Colors.white,
    surfaceContainerLow: card,
    surfaceContainer: dark ? const Color(0xFF222A35) : const Color(0xFFF2F5F9),
    surfaceContainerHigh: dark
        ? const Color(0xFF26303C)
        : const Color(0xFFEDF1F6),
    surfaceContainerHighest: inset,
    outline: dark ? const Color(0xFF8694A5) : const Color(0xFF748195),
    outlineVariant: dark ? const Color(0xFF354151) : const Color(0xFFDDE4EC),
  );
  return theme.copyWith(
    colorScheme: colors,
    primaryColor: colors.primary,
    scaffoldBackgroundColor: background,
    canvasColor: material ? background : theme.canvasColor,
    cardColor: card,
    cardTheme: theme.cardTheme.copyWith(
      color: card,
      surfaceTintColor: Colors.transparent,
    ),
    appBarTheme: material
        ? theme.appBarTheme.copyWith(
            backgroundColor: background,
            foregroundColor: text,
            surfaceTintColor: Colors.transparent,
          )
        : theme.appBarTheme,
    bottomNavigationBarTheme: material
        ? theme.bottomNavigationBarTheme.copyWith(
            backgroundColor: card,
            selectedItemColor: primary,
            unselectedItemColor: muted,
          )
        : theme.bottomNavigationBarTheme,
    dividerColor: colors.outlineVariant,
    textTheme: theme.textTheme.apply(bodyColor: text, displayColor: text),
  );
}

Color readableForumForeground(Color foreground, Color background) {
  final base = background.computeLuminance();
  double contrast(Color color) {
    final luminance = color.computeLuminance();
    return luminance >= base
        ? (luminance + 0.05) / (base + 0.05)
        : (base + 0.05) / (luminance + 0.05);
  }

  if (contrast(foreground) >= 4.6) return foreground;
  final target = contrast(Colors.white) > contrast(Colors.black)
      ? Colors.white
      : Colors.black;
  // Move only as far from the chosen hue as readability requires.
  var low = 0.0;
  var high = 1.0;
  for (var step = 0; step < 10; step++) {
    final mix = (low + high) / 2;
    if (contrast(Color.lerp(foreground, target, mix)!) >= 4.6) {
      high = mix;
    } else {
      low = mix;
    }
  }
  return Color.lerp(foreground, target, high)!;
}
