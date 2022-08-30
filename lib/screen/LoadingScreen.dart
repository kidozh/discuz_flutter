
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class LoadingScreen extends StatelessWidget{
  String? loadingText;

  LoadingScreen({this.loadingText});

  @override
  Widget build(BuildContext context) {

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
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 25, horizontal: 15),
                    child: Column(
                      children: [
                        Container(
                          width: 50.0,
                          height: 50.0,
                          child: PlatformCircularProgressIndicator(

                          ),
                        ),
                        Container(
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(loadingText != null ? loadingText!: S.of(context).preparingPage,
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

                ],
              ),
            ),
          )),
    );
  }

}