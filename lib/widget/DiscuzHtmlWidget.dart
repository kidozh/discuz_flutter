
import 'dart:developer';

import 'package:discuz_flutter/dao/TrustHostDao.dart';
import 'package:discuz_flutter/database/TrustHostDatabase.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/TrustHost.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/DisplayForumPage.dart';
import 'package:discuz_flutter/page/FullImagePage.dart';
import 'package:discuz_flutter/page/ViewThreadPage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/utility/DBHelper.dart';
import 'package:discuz_flutter/utility/RewriteRuleUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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

  _trustHost(String host) async{
    TrustHostDatabase trustHostDatabase = await DBHelper.getTrustHostDb();
    TrustHostDao trustHostDao = trustHostDatabase.trustHostDatabaseDao;
    await trustHostDao.insertTrustHost(TrustHost(null, host));
  }


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
          backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.grey.shade200: Colors.grey.shade600,
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.only(bottom: 8.0),
          border: Border(left: BorderSide(color: Theme.of(context).accentColor, width: 4)),
        )
      },
      onLinkTap: (urlString, context,attribute, element) async{
        log("Press link ${urlString} ");
        if(urlString != null){
          urlString = urlString.replaceAll("&amp;", "&");
          bool urlLauchable = await canLaunch(urlString);
          User? user = Provider.of<DiscuzAndUserNotifier>(context.buildContext, listen: false).user;
          // judge if it is a path
          Uri? tryUri = Uri.tryParse(urlString);
          log("${Uri.parse(urlString).isAbsolute}");
          if(!Uri.parse(urlString).isAbsolute){
            // add a prefix to test if it's a url
            urlString = discuz.baseURL+ "/" + urlString;
            log("Press after link ${urlString} ");
            urlLauchable = await canLaunch(urlString);
          }


          if(urlLauchable){
            // parse url
            Uri uri = Uri.parse(urlString);
            // check host
            if(uri.host != Uri.parse(discuz.baseURL).host){
              // check if database exists
              TrustHostDatabase trustHostDatabase = await DBHelper.getTrustHostDb();
              TrustHostDao trustHostDao = trustHostDatabase.trustHostDatabaseDao;
              TrustHost? trustHostInDb = await trustHostDao.findTrustHostByName(uri.host);
              if(trustHostInDb == null){
                showDialog(context: context.buildContext, builder: (context){
                  return AlertDialog(
                    title: Text(S.of(context).outerlinkOpenTitle,),
                    content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children:[
                          Container(
                            color: Colors.red.shade50,
                            padding: EdgeInsets.symmetric(vertical: 4.0,horizontal: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.link,color: Colors.red,),
                                SizedBox(width: 8.0),
                                Expanded(
                                    child: Text(urlString!,softWrap: true,style: TextStyle(color: Colors.red,),)

                                )

                              ],
                            ),
                          ),
                          SizedBox(height: 16.0,),
                          Text(S.of(context).outerlinkOpenMessage,style: Theme.of(context).textTheme.bodyText1,),


                        ]
                    ),
                    actions: [
                      TextButton(
                          onPressed: () async{
                            String host = uri.host;
                            await _trustHost(host);
                            launch(urlString!);
                          },
                          child: Text(S.of(context).trustHostActionText)
                      ),
                      TextButton(
                          onPressed: (){
                            launch(urlString!);
                          },
                          child: Text(S.of(context).openInBrowser)
                      )
                    ],
                  );
                });
              }
              else{
                // direct open it
                launch(urlString);
              }



              return ;
            }

            // check query parameters for full url
            if(uri.queryParameters.containsKey("mod")){
              String modParamter = uri.queryParameters["mod"]!;
              log("recv modParamter ${modParamter}");
              // check forum display
              switch (modParamter){
                case "redirect":{
                  if(uri.queryParameters.containsKey("ptid")){
                    String tidString = uri.queryParameters["ptid"]!;
                    // trigger tid
                    if(int.tryParse(tidString) != null){
                      int tid = int.tryParse(tidString)!;
                      await Navigator.push(
                          context.buildContext,
                          MaterialPageRoute(builder: (context) => ViewThreadPage( discuz,user, tid))
                      );
                      return;
                    }
                  }
                  break;
                }
                case "viewthread":{
                  // check for forum, query fid
                  if(uri.queryParameters.containsKey("tid")){
                    String tidString = uri.queryParameters["tid"]!;
                    // trigger tid
                    if(int.tryParse(tidString) != null){
                      int tid = int.tryParse(tidString)!;
                      await Navigator.push(
                          context.buildContext,
                          MaterialPageRoute(builder: (context) => ViewThreadPage(discuz,user,tid))
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
                          MaterialPageRoute(builder: (context) => DisplayForumPage(discuz,user, fid))
                      );
                      return;
                    }
                  }
                  break;
                }
              }

            }
            // check short
            String? fid = await RewriteRuleUtils.findFidInURL(discuz, urlString);
            if(fid!=null && int.tryParse(fid) != null){
              await Navigator.push(
                  context.buildContext,
                  MaterialPageRoute(builder: (context) => DisplayForumPage(discuz, user, int.tryParse(fid)!))
              );
              return;
            }

            // check short
            String? tid = await RewriteRuleUtils.findTidInURL(discuz, urlString);
            if(tid!=null && int.tryParse(tid) != null){
              await Navigator.push(
                  context.buildContext,
                  MaterialPageRoute(builder: (context) => ViewThreadPage(discuz, user, int.tryParse(tid)!))
              );
              return;
            }

            
            await launch(urlString);
          }
          else{
            // show the link
            EasyLoading.showError(S.of(context.buildContext).linkUnableToOpen(urlString));
          }
        }


      },
      shrinkWrap: true,
      onImageError: (e,s){

      },
      onImageTap: (string, context,attribute, element){
        if(string!= null){
          Navigator.push(
              context.buildContext,
              MaterialPageRoute(builder: (context) => FullImagePage(string))
          );
        }
      },
    );
  }


}