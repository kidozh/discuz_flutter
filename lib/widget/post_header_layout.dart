import 'package:flutter/material.dart';
import '../utility/PlatformAdaptiveWidgets.dart';

/// Keep the author and complete action group together when both fit.
class PostHeaderLayout extends StatelessWidget {
  final Widget author;
  final PlatformLiquidGlassToolbarGroup actions;

  const PostHeaderLayout({
    super.key,
    required this.author,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      // Allow 48-point targets, spacing and the outer glass padding.
      final actionWidth = actions.children.length * 52.0;
      final authorWidth = 56 + MediaQuery.textScalerOf(context).scale(96);
      if (constraints.maxWidth >= actionWidth + authorWidth + 8) {
        return Row(
          children: [
            Expanded(child: author),
            const SizedBox(width: 8),
            SizedBox(width: actionWidth, child: actions),
          ],
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          author,
          const SizedBox(height: 8),
          Align(alignment: AlignmentDirectional.centerEnd, child: actions),
        ],
      );
    },
  );
}
