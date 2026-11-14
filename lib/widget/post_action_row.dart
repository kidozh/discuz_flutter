import 'package:flutter/material.dart';

import '../utility/PlatformAdaptiveWidgets.dart';

/// Keep the timestamp and actions together, moving extra actions into the menu.
class PostActionRow extends StatelessWidget {
  final Widget metadata;
  final double metadataLeadingWidth;

  /// The last action opens the menu and remains visible at every width.
  final List<Widget> actions;
  final Widget Function(List<Widget>) overflowBuilder;

  const PostActionRow({
    super.key,
    required this.metadata,
    this.metadataLeadingWidth = 0,
    required this.actions,
    required this.overflowBuilder,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final metadataWidth =
          metadataLeadingWidth + MediaQuery.textScalerOf(context).scale(96);
      final slots = ((constraints.maxWidth - metadataWidth - 8) / 52)
          .floor()
          .clamp(1, actions.length);
      final visible = actions.take(slots - 1).toList();
      final hidden = actions
          .skip(slots - 1)
          .take(actions.length - slots)
          .toList();
      visible.add(hidden.isEmpty ? actions.last : overflowBuilder(hidden));
      return Row(
        children: [
          Expanded(child: metadata),
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
