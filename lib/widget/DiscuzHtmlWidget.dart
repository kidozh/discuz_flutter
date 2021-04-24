

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:webview_flutter/webview_flutter.dart';


// ignore: must_be_immutable
class DiscuzHtmlWidget extends StatelessWidget{
  String html;

  DiscuzHtmlWidget(this.html);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Html(
      data: html,
      navigationDelegateForIframe: (NavigationRequest request) {
        return NavigationDecision.navigate;
      },
      style: {
        ".reply_wrap" :Style(
          backgroundColor: Colors.grey.shade100,
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.only(bottom: 8.0),
          border: Border(left: BorderSide(color: Theme.of(context).primaryColor, width: 4)),
        )
      },
    );
  }


}