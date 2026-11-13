import 'package:flutter/cupertino.dart';

import '../utility/PlatformAdaptiveWidgets.dart';

/// Opt in at a list-item boundary, never on every nested card or list tile.
/// The sliver path keeps long post bodies lazy in their existing viewport.
class CupertinoSeparatedItem extends StatelessWidget {
  final Widget child;
  final bool sliver;
  final bool enabled;

  const CupertinoSeparatedItem({
    required this.child,
    this.sliver = false,
    this.enabled = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled || visualStyle(context) != AppVisualStyle.cupertino) {
      return child;
    }

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
        child: CustomPaint(
          painter: _CupertinoSeparatorPainter(
            CupertinoColors.separator.resolveFrom(context),
          ),
          child: const SizedBox(width: double.infinity),
        ),
      ),
    ),
  );
}

class _CupertinoSeparatorPainter extends CustomPainter {
  const _CupertinoSeparatorPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // A non-antialiased hairline stays one physical pixel even when text
    // heights or scrolling place this row between device pixels.
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      Paint()
        ..color = color
        ..strokeWidth = 0
        ..isAntiAlias = false,
    );
  }

  @override
  bool shouldRepaint(_CupertinoSeparatorPainter oldDelegate) =>
      color != oldDelegate.color;
}
