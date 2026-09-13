import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Theme;

import '../utility/PlatformAdaptiveWidgets.dart';

/// Opt in at a list-item boundary, never on every nested card or list tile.
/// The sliver path keeps long post bodies lazy in their existing viewport.
class CupertinoSeparatedItem extends StatelessWidget {
  final Widget child;
  final bool sliver;

  /// Reading rows use separators in both Apple appearances, only in light mode.
  final bool reading;
  final bool includeLiquidGlass;

  const CupertinoSeparatedItem({
    required this.child,
    this.sliver = false,
    this.reading = false,
    this.includeLiquidGlass = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final showSeparator = reading
        ? isCupertino(context) &&
              (includeLiquidGlass ||
                  visualStyle(context) == AppVisualStyle.cupertino) &&
              Theme.of(context).brightness == Brightness.light
        : visualStyle(context) == AppVisualStyle.cupertino;
    if (!showSeparator) return child;

    const separator = CupertinoListSeparator();
    return sliver
        ? SliverMainAxisGroup(
            slivers: [
              child,
              const SliverToBoxAdapter(child: separator),
            ],
          )
        : Column(mainAxisSize: MainAxisSize.min, children: [child, separator]);
  }
}

class CupertinoListSeparator extends StatelessWidget {
  const CupertinoListSeparator({super.key});

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 1 / MediaQuery.devicePixelRatioOf(context),
        child: ColoredBox(
          color: CupertinoColors.separator.resolveFrom(context),
          child: const SizedBox(width: double.infinity),
        ),
      ),
    ),
  );
}
