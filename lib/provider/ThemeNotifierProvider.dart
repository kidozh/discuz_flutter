import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Map<String, Color> themeColorMap = {
  'grey': Colors.grey,
  'blue': Colors.blue,
  'blueAccent': Colors.blueAccent,
  'cyan': Colors.cyan,
  'deepPurple': Colors.purple,
  'deepPurpleAccent': Colors.deepPurpleAccent,
  'deepOrange': Colors.orange,
  'green': Colors.green,
  'indigo': Colors.indigo,
  'indigoAccent': Colors.indigoAccent,
  'orange': Colors.orange,
  'purple': Colors.purple,
  'pink': Colors.pink,
  'red': Colors.red,
  'teal': Colors.teal,
  'black': Colors.black,
};

class ThemeNotifierProvider with ChangeNotifier{
  String _themeColor = "";

  String get themeColorName => _themeColor;

  setTheme(String themeColorName){
    _themeColor = themeColorName;
    notifyListeners();
  }

  Color get themeColor => themeColorMap[_themeColor] != null ? themeColorMap[_themeColor]! : Colors.blue;
}