import 'dart:ui' show ImageFilter;

import 'package:flutter/widgets.dart';

/// Controls backdrop sampling, not the card's tint, highlight or border.
enum PlatformGlassEffect {
  /// Use blur only outside scrolling content and other glass containers.
  automatic,

  /// Opt a standalone surface into blur, even in scrolling content.
  /// Nested surfaces still never add another blur.
  backdropBlur,

  /// Keep the glass decoration without sampling the background.
  tintOnly,
}

/// Shared by Flutter cards and native blur surfaces to prevent nested blur.
class PlatformGlassScope extends InheritedWidget {
  const PlatformGlassScope({required super.child, super.key});

  static bool contains(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PlatformGlassScope>() != null;

  static bool shouldBlur(BuildContext context, PlatformGlassEffect effect) {
    if (contains(context) || effect == PlatformGlassEffect.tintOnly) {
      return false;
    }
    return effect == PlatformGlassEffect.backdropBlur ||
        Scrollable.maybeOf(context) == null;
  }

  @override
  bool updateShouldNotify(PlatformGlassScope oldWidget) => false;
}

/// Flutter-only rendering shared by glass cards and toolbar capsules.
/// The caller must clip this widget to the surface's bounds.
class PlatformGlassBackdrop extends StatelessWidget {
  final Widget child;
  final PlatformGlassEffect effect;

  const PlatformGlassBackdrop({
    required this.child,
    this.effect = PlatformGlassEffect.automatic,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final blur = PlatformGlassScope.shouldBlur(context, effect);
    return PlatformGlassScope(
      child: blur
          ? BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: child,
            )
          : child,
    );
  }
}
