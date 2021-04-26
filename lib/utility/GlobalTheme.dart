import 'package:flutter/material.dart';

class GlobalTheme {

  static ThemeData getThemeData(){
    return ThemeData(
      primarySwatch: Colors.blue,
      // accentColor: Colors.deepOrangeAccent,
      visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.light
    );
  }

  static ThemeData getDarkThemeData(){
    return ThemeData(
      primarySwatch: Colors.lime,
      // accentColor: Colors.orange,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      brightness: Brightness.dark
    );
  }
}