import 'package:flutter/material.dart';

/// Subtle on-device intelligence highlight, respecting Reduce Motion and TickerMode.
class SummarySweep extends StatefulWidget {
  const SummarySweep({super.key, required this.active, required this.child});
  final bool active;
  final Widget child;

  @override
  State<SummarySweep> createState() => _SummarySweepState();
}

class _SummarySweepState extends State<SummarySweep>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );

  void _updateAnimation() {
    final animate =
        widget.active &&
        !MediaQuery.disableAnimationsOf(context) &&
        TickerMode.of(context);
    if (animate && !_controller.isAnimating) _controller.repeat();
    if (!animate) _controller.stop();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateAnimation();
  }

  @override
  void didUpdateWidget(covariant SummarySweep oldWidget) {
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
    if (!widget.active || MediaQuery.disableAnimationsOf(context))
      return widget.child;
    final colors = Theme.of(context).colorScheme;
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        child: widget.child,
        builder: (context, child) => ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            final offset = _controller.value * 4 - 2;
            return LinearGradient(
              begin: Alignment(offset - 1, 0),
              end: Alignment(offset + 1, 0),
              colors: [
                colors.onSurfaceVariant,
                colors.primary,
                colors.tertiary,
                colors.onSurfaceVariant,
              ],
              stops: const [0, 0.4, 0.6, 1],
            ).createShader(bounds);
          },
          child: child,
        ),
      ),
    );
  }
}
