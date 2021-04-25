
import 'dart:developer';

import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/page/DisplayForumPage.dart';
import 'package:discuz_flutter/page/ViewThreadPage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';


// ignore: must_be_immutable
class DiscuzHtmlWidget extends StatelessWidget{
  String html;
  Discuz discuz;

  DiscuzHtmlWidget(this.discuz,this.html);


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
      onLinkTap: (urlString, context,attribute, element) async{
        log("Press link ${urlString} ");
        if(urlString != null){
          urlString = urlString.replaceAll("&amp;", "&");
          bool urlLauchable = await canLaunch(urlString);
          User? user = Provider.of<DiscuzAndUserNotifier>(context.buildContext, listen: false).user;

          if(urlLauchable){
            // parse url
            Uri uri = Uri.parse(urlString);
            // check query parameters for full url
            if(uri.queryParameters.containsKey("mod")){
              String modParamter = uri.queryParameters["mod"]!;
              // check forum display
              switch (modParamter){
                case "viewthread":{
                  // check for forum, query fid
                  if(uri.queryParameters.containsKey("tid")){
                    String tidString = uri.queryParameters["tid"]!;
                    // trigger tid
                    if(int.tryParse(tidString) != null){
                      int tid = int.tryParse(tidString)!;
                      await Navigator.push(
                          context.buildContext,
                          MaterialPageRoute(builder: (context) => ViewThreadPage(discuz: discuz, user: user, tid: tid, key: UniqueKey(),))
                      );
                      return;
                    }
                  }
                  break;
                }
                case "forumdisplay":{
                  // check for forum, query fid
                  if(uri.queryParameters.containsKey("fid")){
                    String fidString = uri.queryParameters["fid"]!;
                    // trigger fid
                    if(int.tryParse(fidString) != null){
                      int fid = int.tryParse(fidString)!;
                      await Navigator.push(
                          context.buildContext,
                          MaterialPageRoute(builder: (context) => DisplayForumPage(discuz: discuz, user: user, fid: fid, key: UniqueKey(),))
                      );
                      return;
                    }
                  }
                  break;
                }
              }

            }
            // check short

            
            await launch(urlString);
          }
        }


      },
    );
  }


}