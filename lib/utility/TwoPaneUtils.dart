import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/widgets.dart';

enum TwoPaneType { foldable, tablet, smallScreen }

class TwoPaneUtils {
  static const double mobileScreenSize = 720;

  static TwoPaneType getTwoPaneType(BoxConstraints constraints) =>
      constraints.maxWidth >= mobileScreenSize && constraints.maxHeight >= 320
      ? TwoPaneType.tablet
      : TwoPaneType.smallScreen;
}

/// Geometry in the available viewport, independent of device names/orientation.
class PaneLayout {
  final Rect start;
  final Rect end;
  final bool showsBoth;

  const PaneLayout(this.start, this.end, this.showsBoth);

  static PaneLayout resolve(
    Size size,
    List<DisplayFeature> features, {
    double proportion = 0.35,
    TextDirection textDirection = TextDirection.ltr,
    bool compactSizeClass = false,
    bool regularSizeClass = false,
  }) {
    final viewport = Offset.zero & size;
    for (final feature in features) {
      final active =
          feature.type == DisplayFeatureType.hinge ||
          (feature.type == DisplayFeatureType.fold &&
              feature.state == DisplayFeatureState.postureHalfOpened);
      if (!active) continue;
      final bounds = feature.bounds;
      if (bounds.top <= 0 &&
          bounds.bottom >= size.height &&
          bounds.left > 0 &&
          bounds.right < size.width) {
        final left = Rect.fromLTRB(0, 0, bounds.left, size.height);
        final right = Rect.fromLTRB(bounds.right, 0, size.width, size.height);
        final rtl = textDirection == TextDirection.rtl;
        final start = rtl ? right : left;
        final end = rtl ? left : right;
        return PaneLayout(
          start,
          end,
          start.width >= 300 && end.width >= 340 && size.height >= 320,
        );
      }
      if (bounds.left <= 0 &&
          bounds.right >= size.width &&
          bounds.top > 0 &&
          bounds.bottom < size.height) {
        final top = Rect.fromLTRB(0, 0, size.width, bounds.top);
        final bottom = Rect.fromLTRB(0, bounds.bottom, size.width, size.height);
        return PaneLayout(
          top,
          bottom,
          size.width >= 340 && top.height >= 240 && bottom.height >= 300,
        );
      }
    }
    final breakpoint = regularSizeClass ? 640.0 : TwoPaneUtils.mobileScreenSize;
    if (compactSizeClass || size.width < breakpoint || size.height < 320) {
      return PaneLayout(viewport, viewport, false);
    }
    final masterWidth = (size.width * proportion)
        .clamp(300.0, math.min(420.0, size.width - 340))
        .toDouble();
    final rtl = textDirection == TextDirection.rtl;
    return PaneLayout(
      Rect.fromLTWH(
        rtl ? size.width - masterWidth : 0,
        0,
        masterWidth,
        size.height,
      ),
      Rect.fromLTWH(
        rtl ? 0 : masterWidth,
        0,
        size.width - masterWidth,
        size.height,
      ),
      true,
    );
  }
}

/// Rebase the screen's insets and real display features for a local pane.
MediaQueryData mediaQueryForPane(MediaQueryData media, Rect pane) {
  EdgeInsets crop(EdgeInsets insets) => EdgeInsets.fromLTRB(
    math.max(0, insets.left - pane.left),
    math.max(0, insets.top - pane.top),
    math.max(0, insets.right - (media.size.width - pane.right)),
    math.max(0, insets.bottom - (media.size.height - pane.bottom)),
  );
  final features = <DisplayFeature>[];
  for (final feature in media.displayFeatures) {
    final bounds = feature.bounds;
    final intersects =
        bounds.overlaps(pane) ||
        (bounds.width == 0 &&
            bounds.left > pane.left &&
            bounds.left < pane.right &&
            bounds.bottom > pane.top &&
            bounds.top < pane.bottom) ||
        (bounds.height == 0 &&
            bounds.top > pane.top &&
            bounds.top < pane.bottom &&
            bounds.right > pane.left &&
            bounds.left < pane.right);
    if (!intersects) continue;
    features.add(
      DisplayFeature(
        bounds: bounds.intersect(pane).shift(-pane.topLeft),
        type: feature.type,
        state: feature.state,
      ),
    );
  }
  var padding = crop(media.padding);
  var viewPadding = crop(media.viewPadding);
  for (final feature in features) {
    if (feature.type != DisplayFeatureType.cutout) continue;
    final bounds = feature.bounds;
    // Edge-connected camera occlusions become local safe insets. Retain the
    // feature as well so region-aware content still has its exact geometry.
    final cutout = EdgeInsets.fromLTRB(
      bounds.left <= 0 ? bounds.right : 0,
      bounds.top <= 0 ? bounds.bottom : 0,
      bounds.right >= pane.width ? pane.width - bounds.left : 0,
      bounds.bottom >= pane.height ? pane.height - bounds.top : 0,
    );
    EdgeInsets protect(EdgeInsets value) => EdgeInsets.fromLTRB(
      math.max(value.left, cutout.left),
      math.max(value.top, cutout.top),
      math.max(value.right, cutout.right),
      math.max(value.bottom, cutout.bottom),
    );
    padding = protect(padding);
    viewPadding = protect(viewPadding);
  }
  return media.copyWith(
    size: pane.size,
    padding: padding,
    viewPadding: viewPadding,
    viewInsets: crop(media.viewInsets),
    systemGestureInsets: crop(media.systemGestureInsets),
    displayFeatures: features,
  );
}
