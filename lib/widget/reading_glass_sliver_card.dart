import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utility/PlatformAdaptiveWidgets.dart';
import '../utility/PlatformGlass.dart';

/// Sliver equivalent of the default, unselected scrolling glass card. Keeping
/// the decoration on a sliver lets the HTML body share the outer viewport.
/// Like automatic glass cards in lists, it has tint/highlight but no backdrop.
class ReadingGlassSliverCard extends StatelessWidget {
  final Widget sliver;
  const ReadingGlassSliverCard({required this.sliver, super.key});

  @override
  Widget build(BuildContext context) {
    final light = Theme.of(context).brightness == Brightness.light;
    final primary = Theme.of(context).colorScheme.primary;
    final translucent = usesAppleTranslucentSurface(context);
    final border = light
        ? Color.alphaBlend(
            primary.withValues(alpha: .10), Colors.black.withValues(alpha: .08))
        : Colors.white.withValues(alpha: .20);
    final decoration = BoxDecoration(
      color: translucent
          ? null
          : CupertinoColors.secondarySystemGroupedBackground
              .resolveFrom(context),
      borderRadius: const BorderRadius.all(Radius.circular(18)),
      gradient: translucent
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: light ? .70 : .18),
                Colors.white.withValues(alpha: light ? .44 : .10)
              ],
            )
          : null,
      border: translucent ? Border.all(color: border, width: .8) : null,
      boxShadow: translucent
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: light ? .13 : .28),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
            ]
          : null,
    );
    return PlatformGlassScope(
        child: SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      sliver: DecoratedSliver(
        decoration: decoration,
        sliver: SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          sliver: sliver,
        ),
      ),
    ));
  }
}
