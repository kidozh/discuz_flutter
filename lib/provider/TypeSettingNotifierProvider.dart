import 'package:discuz_flutter/generated/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';



class TypeSettingNotifierProvider with ChangeNotifier{
  double _scalingParameter = 1.0;

  setScalingParameter(double scalingParameter){
    _scalingParameter = scalingParameter;
    notifyListeners();
  }

  double get scalingParameter => _scalingParameter >= 1.0 && _scalingParameter <= 2.0 ? _scalingParameter : 1.0;


}