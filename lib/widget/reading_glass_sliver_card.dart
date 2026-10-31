import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../utility/PlatformAdaptiveWidgets.dart' show isMaterial;

const _postMargin = EdgeInsets.symmetric(horizontal: 8, vertical: 6);
const _postPadding = EdgeInsets.symmetric(horizontal: 8, vertical: 12);

ShapeDecoration _postDecoration(BuildContext context) {
  if (isMaterial(context)) {
    final theme = Theme.of(context);
    final card = CardTheme.of(context);
    final elevation = card.elevation ?? 1;
    final shadowColor = card.shadowColor ?? theme.colorScheme.shadow;
    return ShapeDecoration(
      color:
          card.color ??
          (theme.useMaterial3
              ? theme.colorScheme.surfaceContainerLow
              : theme.cardColor),
      shape:
          card.shape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(theme.useMaterial3 ? 12 : 4),
          ),
      shadows: [
        for (final shadow
            in kElevationToShadow[elevation.round()] ?? const <BoxShadow>[])
          shadow.copyWith(
            color: shadowColor.withValues(
              alpha: shadowColor.a * shadow.color.a,
            ),
          ),
      ],
    );
  }
  return ShapeDecoration(
    color: CupertinoColors.secondarySystemBackground.resolveFrom(
      context,
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(18)),
    ),
  );
}

/// Opaque post background. Embedded controls retain their own glass styling.
class ReadingPostCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const ReadingPostCard({
    required this.child,
    this.padding = _postPadding,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (isMaterial(context)) {
      return Card(
        margin: _postMargin,
        clipBehavior: Clip.antiAlias,
        child: Padding(padding: padding, child: child),
      );
    }
    return Container(
      margin: _postMargin,
      padding: padding,
      decoration: _postDecoration(context),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

/// Keeps the HTML body in the outer viewport, with an opaque post background.
/// No glass scope: embedded cards and folding controls manage their own effects.
class ReadingGlassSliverCard extends StatelessWidget {
  final Widget sliver;
  const ReadingGlassSliverCard({required this.sliver, super.key});

  @override
  Widget build(BuildContext context) {
    final decoration = _postDecoration(context);
    return SliverPadding(
      padding: _postMargin,
      sliver: DecoratedSliver(
        decoration: decoration,
        sliver: _SliverShapeClip(
          shape: decoration.shape,
          textDirection: Directionality.of(context),
          sliver: SliverPadding(padding: _postPadding, sliver: sliver),
        ),
      ),
    );
  }
}

/// Clip the full post outline rather than rounding the visible viewport edge.
/// The child remains a sliver, so long HTML bodies still build lazily.
class _SliverShapeClip extends SingleChildRenderObjectWidget {
  const _SliverShapeClip({
    required this.shape,
    required this.textDirection,
    required Widget sliver,
  }) : super(child: sliver);

  final ShapeBorder shape;
  final TextDirection textDirection;

  @override
  _RenderSliverShapeClip createRenderObject(BuildContext context) =>
      _RenderSliverShapeClip(shape, textDirection);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSliverShapeClip renderObject,
  ) {
    renderObject.updateShape(shape, textDirection);
  }
}

class _RenderSliverShapeClip extends RenderProxySliver {
  _RenderSliverShapeClip(this._shape, this._textDirection);

  ShapeBorder _shape;
  TextDirection _textDirection;

  void updateShape(ShapeBorder shape, TextDirection textDirection) {
    if (_shape == shape && _textDirection == textDirection) return;
    _shape = shape;
    _textDirection = textDirection;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null || !geometry!.visible) {
      layer = null;
      return;
    }
    final bounds = getMaxPaintRect();
    layer = context.pushClipPath(
      needsCompositing,
      offset,
      bounds,
      _shape.getOuterPath(bounds, textDirection: _textDirection),
      super.paint,
      clipBehavior: Clip.antiAlias,
      oldLayer: layer as ClipPathLayer?,
    );
  }
}
