import 'package:flutter/material.dart';

import '../utility/PlatformAdaptiveWidgets.dart';
import '../utility/thread_selection_colors.dart';

/// The row owns its selection fill. Nested adaptive tiles must not add cards.
class ThreadListSurface extends StatelessWidget {
  const ThreadListSurface({
    super.key,
    required this.selected,
    required this.child,
    this.onTap,
    this.onLongPress,
  });
  final bool selected;
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final selection = ThreadSelectionColors(colors);
    final content = Semantics(selected: selected, child: child);
    if (isMaterial(context)) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        color: selected ? selection.background : null,
        clipBehavior: Clip.antiAlias,
        child: onTap == null && onLongPress == null
            ? content
            : InkWell(onTap: onTap, onLongPress: onLongPress, child: content),
      );
    }
    return PlatformLiquidGlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      selected: selected,
      opaque: selected,
      tintColor: selected ? selection.background : null,
      backgroundColor: selected ? selection.background : null,
      glassBackgroundColor: selected ? selection.background : null,
      // The card already supplies PlatformGlassScope, so its inner list tile
      // stays transparent instead of creating a second glass card.
      child: onTap == null && onLongPress == null
          ? content
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              onLongPress: onLongPress,
              child: content,
            ),
    );
  }
}
