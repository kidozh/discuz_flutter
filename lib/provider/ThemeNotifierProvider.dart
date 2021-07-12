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

  String get themeColorName => _themeColor;

  setTheme(String themeColorName){
    _themeColor = themeColorName;
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
}