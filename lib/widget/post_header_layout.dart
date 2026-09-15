import 'package:flutter/material.dart';
import '../utility/PlatformAdaptiveWidgets.dart';

/// Keep the author and complete action group together when both fit.
class PostHeaderLayout extends StatelessWidget {
  final Widget author;
  final PlatformLiquidGlassToolbarGroup actions;
  final Widget Function(List<Widget>) overflowBuilder;

  const PostHeaderLayout({
    super.key,
    required this.author,
    required this.actions,
    required this.overflowBuilder,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final authorWidth = 56 + MediaQuery.textScalerOf(context).scale(96);
      final slots = ((constraints.maxWidth - authorWidth - 8) / 52)
          .floor()
          .clamp(1, actions.children.length);
      final visible = actions.children.take(slots - 1).toList();
      final hidden = actions.children
          .skip(slots - 1)
          .take(actions.children.length - slots)
          .toList();
      visible.add(
        hidden.isEmpty ? actions.children.last : overflowBuilder(hidden),
      );
      return Row(
        children: [
          Expanded(child: author),
          const SizedBox(width: 8),
          SizedBox(
            width: slots * 52.0,
            child: PlatformLiquidGlassToolbarGroup(children: visible),
          ),
        ],
      );
    },
  );
}
