import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utility/PlatformAdaptiveWidgets.dart';

/// A distinct summary surface with a faint highlight travelling around its edge.
class PostSummaryCard extends StatefulWidget {
  const PostSummaryCard({
    super.key,
    required this.child,
    this.active = true,
    this.loading = false,
  });

  final Widget child;
  final bool active;
  final bool loading;

  @override
  State<PostSummaryCard> createState() => _PostSummaryCardState();
}

class _PostSummaryCardState extends State<PostSummaryCard>
    with SingleTickerProviderStateMixin {
  static const _radius = BorderRadius.all(Radius.circular(16));
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 9),
  );

  void _updateAnimation() {
    final animate =
        widget.active &&
        !MediaQuery.disableAnimationsOf(context) &&
        TickerMode.valuesOf(context).enabled;
    if (animate && !_controller.isAnimating) _controller.repeat();
    if (!animate) _controller.stop();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateAnimation();
  }

  @override
  void didUpdateWidget(covariant PostSummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final light = colors.brightness == Brightness.light;
    final fill = Color.alphaBlend(
      colors.primary.withValues(alpha: light ? 0.035 : 0.06),
      colors.surfaceContainerLow,
    );
    return RepaintBoundary(
      child: CustomPaint(
        foregroundPainter: _SummaryBorder(
          progress: _controller,
          colors: colors,
          loading: widget.loading,
        ),
        // Keep the text and glass out of the border's animation repaints.
        child: RepaintBoundary(
          child: PlatformLiquidGlassCard(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            borderRadius: _radius,
            backgroundColor: fill,
            glassBackgroundColor: fill.withValues(alpha: 0.3),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _SummaryBorder extends CustomPainter {
  _SummaryBorder({
    required this.progress,
    required this.colors,
    required this.loading,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final ColorScheme colors;
  final bool loading;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    const width = 1.0;
    final bounds = Offset.zero & size;
    final edge = RRect.fromRectAndRadius(
      bounds.deflate(width / 2),
      const Radius.circular(15.5),
    );
    canvas.drawRRect(
      edge,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..color = colors.outlineVariant.withValues(alpha: 0.4),
    );
    final strength = loading ? 0.32 : 0.20;
    canvas.drawRRect(
      edge,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..shader = SweepGradient(
          transform: GradientRotation(progress.value * math.pi * 2),
          stops: const [0, 0.65, 0.8, 0.9, 1],
          colors: [
            colors.primary.withValues(alpha: 0.015),
            colors.primary.withValues(alpha: 0.015),
            colors.primary.withValues(alpha: strength),
            colors.tertiary.withValues(alpha: strength),
            colors.primary.withValues(alpha: 0.015),
          ],
        ).createShader(bounds),
    );
  }

  @override
  bool shouldRepaint(covariant _SummaryBorder oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.colors != colors ||
      oldDelegate.loading != loading;
}
