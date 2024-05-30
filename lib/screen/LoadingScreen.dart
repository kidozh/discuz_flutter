
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class LoadingScreen extends StatelessWidget{
  String? loadingText;

  LoadingScreen({this.loadingText});

  @override
  Widget build(BuildContext context) {

    return Container(
      child: PlatformCircularProgressIndicator(),
    );
  }

}