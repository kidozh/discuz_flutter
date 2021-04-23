import 'package:flutter/material.dart';

class GlobalTheme {

  static ThemeData getThemeData(){
    return ThemeData(
      primarySwatch: Colors.blue,
      accentColor: Colors.deepOrangeAccent,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  static ThemeData getDarkThemeData(){
    return ThemeData(
      primarySwatch: Colors.indigo,
      accentColor: Colors.amber,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}