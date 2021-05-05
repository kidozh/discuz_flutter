
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/AddDiscuzPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class BlankScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Center(
          child: SizedBox(
            height: 200.0,
            width: 300.0,
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 50.0,
                    height: 50.0,
                    child: SpinKitWanderingCubes(
                      color: Theme.of(context).primaryColor,
                      size: 25.0,
                    ),
                  ),
                  Container(
                    child: Text(S.of(context).preparingPage),
                  )
                ],
              ),
            ),
          )),
    );
  }

}