import 'package:discuz_flutter/generated/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';



class TypeSettingNotifierProvider with ChangeNotifier{
  double _scalingParameter = 1.0;



  setScalingParameter(double scalingParameter){
    _scalingParameter = scalingParameter;
    notifyListeners();
  }

  double get scalingParameter => _scalingParameter >= 1.0 && _scalingParameter <= 3.0 ? _scalingParameter : 1.0;

  String _typographyTheme ="";

  set typographyTheme(String typographyTheme){
    this._typographyTheme = typographyTheme;
    notifyListeners();
  }

  static List<String> typographyList = [
    "","material2014", "material2018", "material2021"
  ];

  String get typographyTheme => _typographyTheme;

  String getTypographyThemeName(BuildContext context){
    switch (_typographyTheme){
      case "material2014": return S.of(context).typographyMaterial2014;
      case "material2018": return S.of(context).typographyMaterial2018;
      case "material2021": return S.of(context).typographyMaterial2021;
    }
    return S.of(context).typographySystem;

  }

  static String getTypographyThemeByName(BuildContext context, String typographyTheme){
    switch (typographyTheme){
      case "material2014": return S.of(context).typographyMaterial2014;
      case "material2018": return S.of(context).typographyMaterial2018;
      case "material2021": return S.of(context).typographyMaterial2021;
    }
    return S.of(context).typographySystem;

  }

  static List<String> getTypographyThemeNameList(BuildContext context){
    return typographyList.map((e) => getTypographyThemeByName(context,e)).toList();
  }

  bool _useThinFontWeight = false;

  set useThinFontWeight(bool value){
    this._useThinFontWeight = value;
    notifyListeners();
  }

  bool get useThinFontWeight => _useThinFontWeight;

  bool _useCompactParagraph = false;

  set useCompactParagraph(bool value){
    this._useCompactParagraph = value;
    notifyListeners();
  }

  bool get useCompactParagraph => _useCompactParagraph;

  bool _ignoreCustomFontStyle = true;

  bool get ignoreCustomFontStyle => _ignoreCustomFontStyle;

  set ignoreCustomFontStyle(bool value){
    this._ignoreCustomFontStyle = value;
    notifyListeners();
  }

  void setIgnoreCustomFontStyle(bool value){
    this._ignoreCustomFontStyle = value;
    notifyListeners();
  }


}