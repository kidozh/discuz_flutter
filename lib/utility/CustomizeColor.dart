
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomizeColor{
  static final error = Color.fromRGBO(244,67,54,1);
  static final errorBackground = Color.fromRGBO(255,235,238 ,1.0);
  static final colorBackgroundList = [
    Colors.blue.shade600,
    Colors.teal.shade600,
    Colors.red.shade600,
    Colors.cyan.shade600,
    Colors.deepOrange.shade600,
    Colors.lightBlue.shade600,
    Colors.lightBlueAccent.shade700,
    Colors.amber.shade600,
    Colors.indigo.shade600,
    Colors.brown.shade600,
    Colors.deepPurple.shade600,
    Colors.green.shade600,
    Colors.lime.shade600,
    Colors.orange.shade600,
    Colors.pink.shade600
  ];
  static Color getColorBackgroundById(int id){
    return colorBackgroundList[id%colorBackgroundList.length];
  }

  static void updateAndroidNavigationbar(BuildContext context){
    if(Platform.isAndroid){
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          systemNavigationBarColor: Theme.of(context).colorScheme.surface,
          systemNavigationBarIconBrightness: Theme.of(context).brightness,
          systemNavigationBarDividerColor: Colors.transparent
      ));
    }
  }


  static void updateAndroidNavigationbarColorWithDashboard(BuildContext context){
    if(Platform.isAndroid){
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          systemNavigationBarColor: Theme.of(context).colorScheme.primary,
          systemNavigationBarIconBrightness: Theme.of(context).brightness,
          systemNavigationBarDividerColor: Colors.transparent
      ));
    }
  }
}

