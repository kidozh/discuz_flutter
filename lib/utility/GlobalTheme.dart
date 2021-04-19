import 'package:flutter/material.dart';

class GlobalTheme {

  static ThemeData getThemeData(){
    return ThemeData(
      primarySwatch: Colors.blue,
      accentColor: Colors.deepOrangeAccent,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}