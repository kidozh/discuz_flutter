

import 'package:flutter/widgets.dart';

enum TwoPaneType{
  foldable,
  tablet,
  smallScreen
}

class TwoPaneUtils{
  static TwoPaneType getTwoPaneType(BoxConstraints constraints){
    if(constraints.maxWidth< 600){
      return TwoPaneType.smallScreen;
    }
    else{
      return TwoPaneType.tablet;
    }
  }
}

