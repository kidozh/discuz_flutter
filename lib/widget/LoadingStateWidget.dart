
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:html_unescape/html_unescape.dart';

class LoadingStateWidget extends StatelessWidget{
  String? hintText;

  LoadingStateWidget({this.hintText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32.0),
      alignment: Alignment.center,
      child: Column(
        children: [
          SizedBox(
            height: 50,
            width: 50,
            child:PlatformCircularProgressIndicator(),
          ),
          if(hintText!= null)
          SizedBox(
            height: 16,
          ),
          if(hintText!= null)
            Text(HtmlUnescape().convert(hintText!), style: TextStyle(
              color: Theme.of(context).disabledColor,
              fontSize: 24,
              fontWeight: Theme.of(context).brightness == Brightness.dark? FontWeight.normal: FontWeight.w300
            ),
              textAlign: TextAlign.center,
            )


        ],
      )
    );
  }
  
}