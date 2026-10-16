import 'dart:math' as math;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

/// Uses the feed pane's width so a wide window can show several promotions.
class ThreadCarouselLayout extends StatelessWidget {
  const ThreadCarouselLayout({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.height,
  }) : assert(itemCount > 0);

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double height;

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
      return Align(
        child: SizedBox(
          width: width,
          child: CarouselSlider.builder(
            // Finite and looping carousels use different page index ranges.
            key: ValueKey(hasMore),
            itemCount: itemCount,
            itemBuilder: (context, index, _) => itemBuilder(context, index),
            options: CarouselOptions(
              height: height,
              viewportFraction: tiled ? 1 / visibleCards : (hasMore ? 0.8 : 1),
              enlargeCenterPage: !tiled && hasMore,
              enlargeFactor: 0.3,
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
