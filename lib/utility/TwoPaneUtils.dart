

import 'package:flutter/widgets.dart';

enum TwoPaneType{
  foldable,
  tablet,
  smallScreen
}



class TwoPaneUtils{
  static double mobileScreenSize = 650;

  static TwoPaneType getTwoPaneType(BoxConstraints constraints){
    if(constraints.maxWidth < mobileScreenSize){
      return TwoPaneType.smallScreen;
    }
    else{
      return TwoPaneType.tablet;
    }
  }
}

