

import 'dart:ui';

import 'package:dual_screen/dual_screen.dart';
import 'package:flutter/cupertino.dart';

import 'TwoPaneUtils.dart';

class TwoPaneScaffold extends StatelessWidget{

  final TwoPane child;
  final TwoPaneType type;


  TwoPaneScaffold({
    super.key,
    required this.type,
    required this.child
  });

  // An approximation of a real foldable
  static const double foldableAspectRatio = 20 / 18;
  // 16x9 candy bar phone
  static const double singleScreenAspectRatio = 9 / 16;
  // Taller desktop / tablet
  static const double tabletAspectRatio = 4 / 3;
  // How wide should the hinge be, as a proportion of total width
  static const double hingeProportion = 1 / 35;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: LayoutBuilder(builder: (context, constraints){
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          final hingeSize = Size(size.width * hingeProportion, size.height);
          // Position the hinge in the middle of the display
          final hingeBounds = Rect.fromLTWH(
            (size.width - hingeSize.width) / 2,
            0,
            hingeSize.width,
            hingeSize.height,
          );
          var smallestDimension = MediaQuery.of(context).size.shortestSide;
          final type = smallestDimension < 600? TwoPaneType.smallScreen: TwoPaneType.tablet;

          return MediaQuery(
              data: MediaQueryData(
                  size: size,
                  displayFeatures: [
                    if (type == TwoPaneType.foldable)
                      DisplayFeature(
                        bounds: hingeBounds,
                        type: DisplayFeatureType.hinge,
                        state: DisplayFeatureState.postureFlat,
                      ),
                  ]
              ),
              child: child
          );
        })
    );

  }


}