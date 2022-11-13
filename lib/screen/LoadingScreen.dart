
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

class LoadingScreen extends StatelessWidget{
  String? loadingText;

  LoadingScreen({this.loadingText});

  @override
  Widget build(BuildContext context) {

    return SkeletonListView();
  }

}