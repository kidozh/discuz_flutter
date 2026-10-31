import 'dart:math' as math;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

/// Uses the feed pane's width so a wide window can show several promotions.
class ThreadCarouselLayout extends StatelessWidget {
  const ThreadCarouselLayout({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.compact = true,
  }) : assert(itemCount > 0);

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final bool compact;

  static const maxCardWidth = 480.0;
  static const _minTileWidth = 360.0;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final availableWidth = constraints.hasBoundedWidth
          ? constraints.maxWidth
          : MediaQuery.sizeOf(context).width;
      final visibleCards = (availableWidth / _minTileWidth).floor().clamp(
        1,
        math.min(itemCount, 3),
      );
      final width = math.min(availableWidth, visibleCards * maxCardWidth);
      final tiled = visibleCards > 1;
      final hasMore = itemCount > visibleCards;
      // Size from one tile so phone banners have enough room for their artwork.
      final tileWidth = width / visibleCards;
      final baseHeight = compact
          ? (tileWidth / 2).clamp(180.0, 224.0)
          : (tileWidth / 1.6).clamp(220.0, 280.0);
      final textScale = (MediaQuery.textScalerOf(context).scale(14) / 14).clamp(
        1.0,
        double.infinity,
      );
      return Align(
        child: SizedBox(
          width: width,
          child: CarouselSlider.builder(
            // Finite and looping carousels use different page index ranges.
            key: ValueKey(hasMore),
            itemCount: itemCount,
            itemBuilder: (context, index, _) => itemBuilder(context, index),
            options: CarouselOptions(
              height: baseHeight * textScale,
              viewportFraction: tiled ? 1 / visibleCards : (hasMore ? 0.86 : 1),
              enlargeCenterPage: !tiled && hasMore,
              enlargeFactor: 0.16,
              padEnds: !tiled,
              enableInfiniteScroll: hasMore,
              autoPlay: hasMore,
              autoPlayInterval: const Duration(seconds: 3),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
            ),
          ),
        ),
      );
    },
  );
}
