import 'package:flutter/material.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../utility/thread_selection_colors.dart';

/// The row owns its selection fill. Nested adaptive tiles must not add cards.
class ThreadListSurface extends StatelessWidget {
  const ThreadListSurface({
    super.key,
    required this.selected,
    required this.child,
  });
  final bool selected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final selection = ThreadSelectionColors(Theme.of(context).colorScheme);
    return PlatformLiquidGlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      selected: selected,
      tintColor: selected ? selection.background : null,
      backgroundColor: selected ? selection.background : null,
      glassBackgroundColor: selected ? selection.background : null,
      // The card already supplies PlatformGlassScope, so its inner list tile
      // stays transparent instead of creating a second glass card.
      child: Semantics(selected: selected, child: child),
    );
  }
}
