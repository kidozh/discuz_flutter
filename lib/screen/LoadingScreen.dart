
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class LoadingScreen extends StatelessWidget{
  String? loadingText;

  LoadingScreen({this.loadingText});

  @override
  Widget build(BuildContext context) {

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: PlatformCircularProgressIndicator(),
          ),

        ],
      ),
    );
  }

}