import 'package:discuz_flutter/generated/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Map<String, MaterialColor> themeColorMap = {
  'grey': Colors.grey,
  'blue': Colors.blue,
  'cyan': Colors.cyan,
  'deepPurple': Colors.purple,
  'deepOrange': Colors.orange,
  'green': Colors.green,
  'indigo': Colors.indigo,
  'orange': Colors.orange,
  'purple': Colors.purple,
  'pink': Colors.pink,
  'red': Colors.red,
  'teal': Colors.teal,
  'brown': Colors.brown,
  "amber": Colors.amber,
  "lightBlue": Colors.lightBlue,
  "blueGrey":Colors.blueGrey,
  "lightGreen": Colors.lightGreen,
  "lime":Colors.lime,
  "yellow":Colors.yellow,
};



class ThemeNotifierProvider with ChangeNotifier{
  String _themeColor = "";

  String _platformName ="";

  String get themeColorName => _themeColor;

  setTheme(String themeColorName){
    _themeColor = themeColorName;
    notifyListeners();
  }

  String get platformName => _platformName;

  setPlatformName(String platformName){
    _platformName = platformName;
    notifyListeners();
  }

  MaterialColor get themeColor => themeColorMap[_themeColor] != null ? themeColorMap[_themeColor]! : Colors.blue;



  Brightness get brightness {
    if (["amber","grey","cyan","deepOrange","yellow","lime","orange","lightBlue","lightGreen"].contains(_themeColor)){
      return Brightness.light;
    }
    else{
      return Brightness.dark;
    }
  }

  Brightness get iconBrightness{
    if(brightness == Brightness.light){
      return Brightness.dark;
    }
    else{
      return Brightness.light;
    }
  }

  String getColorName(BuildContext context){
    Map<String, String> themeColorNameMap = {
      'grey': S.of(context).colorGrey,
      'blue': S.of(context).colorBlue,
      'cyan': S.of(context).colorCyan,
      'deepPurple': S.of(context).colorDeepPurple,
      'deepOrange': S.of(context).colorDeepOrange,
      'green': S.of(context).colorGreen,
      'indigo': S.of(context).colorIndigo,
      'orange': S.of(context).colorOrange,
      'purple': S.of(context).colorPurple,
      'pink': S.of(context).colorPink,
      'red': S.of(context).colorRed,
      'teal': S.of(context).colorTeal,
      'brown': S.of(context).colorBrown,
      "amber": S.of(context).colorAmber,
      "lightBlue": S.of(context).colorLightBlue,
      "blueGrey": S.of(context).colorBlueGrey,
      "lightGreen": S.of(context).colorLightGreen,
      "lime": S.of(context).colorLime,
      "yellow":S.of(context).colorYellow,
    };
    if (themeColorNameMap.containsKey(_themeColor)){
      return themeColorNameMap[_themeColor]!;
    }
    else{
      return S.of(context).colorBlue;
    }
  }

  String getPlatformLocaleName(BuildContext context){
    Map<String, String> platformMap = {
      "":S.of(context).followSystem,
      "ios":S.of(context).ios,
      "android":S.of(context).android,
      "fuchsia":S.of(context).fuchsia
    };
    if (platformMap.containsKey(_platformName)){
      return platformMap[_platformName]!;
    }
    else{
      return S.of(context).followSystem;
    }
  }
}