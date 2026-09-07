import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract final class AppMotion {
  static Duration duration(BuildContext context, int milliseconds) =>
      MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : Duration(milliseconds: milliseconds);
}

/// Keep Material's transitions and back gesture handling; only tune the timing.
class AppMaterialPageRoute<T> extends MaterialPageRoute<T> {
  final bool reduceMotion;

  AppMaterialPageRoute({
    required super.builder,
    required this.reduceMotion,
    super.settings,
    super.maintainState,
    super.fullscreenDialog,
  });

  @override
  Duration get transitionDuration =>
      reduceMotion ? Duration.zero : const Duration(milliseconds: 280);
  @override
  Duration get reverseTransitionDuration =>
      reduceMotion ? Duration.zero : const Duration(milliseconds: 220);
}

class AppCupertinoPageRoute<T> extends CupertinoPageRoute<T> {
  final bool reduceMotion;

  AppCupertinoPageRoute({
    required super.builder,
    required this.reduceMotion,
    super.title,
    super.settings,
    super.maintainState,
    super.fullscreenDialog,
  });

  @override
  Duration get transitionDuration =>
      reduceMotion ? Duration.zero : super.transitionDuration;
  @override
  Duration get reverseTransitionDuration =>
      reduceMotion ? Duration.zero : super.reverseTransitionDuration;
}

/// Reveal only the incoming content, without retaining two media subtrees.
class AppContentTransition extends StatelessWidget {
  final Widget child;
  const AppContentTransition({required this.child, super.key});

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
        duration: AppMotion.duration(context, 180),
        reverseDuration: Duration.zero,
        switchInCurve: Curves.easeOutCubic,
        layoutBuilder: (current, previous) =>
            current ?? const SizedBox.shrink(),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position:
                Tween<Offset>(begin: const Offset(0, 0.02), end: Offset.zero)
                    .animate(animation),
            child: child,
          ),
        ),
        child: child,
      );
}
