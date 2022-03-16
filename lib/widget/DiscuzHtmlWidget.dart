
import 'dart:developer';

import 'package:discuz_flutter/dao/TrustHostDao.dart';
import 'package:discuz_flutter/database/TrustHostDatabase.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/TrustHost.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/DisplayForumSliverPage.dart';
import 'package:discuz_flutter/page/FullImagePage.dart';
import 'package:discuz_flutter/page/UserProfilePage.dart';
import 'package:discuz_flutter/page/ViewThreadSliverPage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/provider/TypeSettingNotifierProvider.dart';
import 'package:discuz_flutter/utility/DBHelper.dart';
import 'package:discuz_flutter/utility/RewriteRuleUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart' hide NavigationRequest,NavigationDecision;

typedef void JumpToPidCallback(int pid);

// ignore: must_be_immutable
class DiscuzHtmlWidget extends StatelessWidget{
  String html;
  Discuz discuz;
  JumpToPidCallback? callback;

  DiscuzHtmlWidget(this.discuz,this.html,{this.callback});

  _trustHost(String host) async{
    TrustHostDatabase trustHostDatabase = await DBHelper.getTrustHostDb();
    TrustHostDao trustHostDao = trustHostDatabase.trustHostDatabaseDao;
    await trustHostDao.insertTrustHost(TrustHost(null, host));
  }

  String replaceCollapseTag(String string){
    //log("Recv html $string");
    string = string.replaceAllMapped(RegExp(r"\[collapse(|=(.*?))]"), (match){
      log("Get match string ${match.groupCount} ${match.group(0)}");
      if(match.groupCount == 2){
        String title = match.group(1)!;
        if(title.startsWith("=")){
          title = title.replaceFirst("=", "");
        }
        log("Recv matched message ${match.group(1)} $title");
        return '<collapse title="$title">';
      }
      else{
        return "<collapse title="">";
      }
    });
    string = string.replaceAll(RegExp(r"\[/collapse.*?\]"), r"</collapse>");

    return string;
  }

  String getDecodedString(){
    String decodedString = replaceCollapseTag(this.html);
    return decodedString;
  }


  @override
  Widget build(BuildContext context) {

    return Container(
      width: double.infinity,
      child: Consumer<TypeSettingNotifierProvider>(builder: (context, typesetting, _) {
        double scalingParameter = typesetting.scalingParameter;
        // print("font scaling parameters ${scalingParameter} and font size ${12*scalingParameter}");
        double? themeFontSize = Theme.of(context).textTheme.bodyText2?.fontSize == null? 14 : Theme.of(context).textTheme.bodyText2?.fontSize!;
        double paragraphFontSize = themeFontSize == null ? 14 : themeFontSize;
        return Html(

          data: "<p>${this.getDecodedString()}</p>",
          navigationDelegateForIframe: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
          style: {
            ".reply_wrap" :Style(
              //backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.grey.shade200: Colors.grey.shade600,
              backgroundColor: Theme.of(context).brightness == Brightness.light ? Colors.grey.shade200: Colors.grey.shade600,
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 8.0),
              border: Border(left: BorderSide(color: Theme.of(context).primaryColor, width: 4)),
              width: double.infinity
            ),
            "p":Style(
              fontStyle: Theme.of(context).textTheme.bodyText2?.fontStyle,
              fontSize: FontSize(paragraphFontSize*scalingParameter),
              //fontSize: scalingParameter <= 1.0? FontSize(Theme.of(context).textTheme.bodyText2?.fontSize): FontSize(14*scalingParameter),

            ),
            "a":Style(
              color: Theme.of(context).primaryColor,
              fontSize: FontSize(paragraphFontSize*scalingParameter),
            )

          },
          onLinkTap: (urlString, context,attribute, element) async{
            VibrationUtils.vibrateWithClickIfPossible();
            log("Press link ${urlString} ");
            if(urlString != null){
              urlString = urlString.replaceAll("&amp;", "&");
              bool urlLauchable = await canLaunch(urlString);
              User? user = Provider.of<DiscuzAndUserNotifier>(context.buildContext, listen: false).user;
              // judge if it is a path
              Uri? tryUri = Uri.tryParse(urlString);
              log("${Uri.parse(urlString).isAbsolute} can launch ${urlLauchable} ${urlString}");
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
                    showPlatformDialog(context: context.buildContext, builder: (context){
                      return PlatformAlertDialog(
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
                                Navigator.pop(context);
                              },
                              child: Text(S.of(context).trustHostActionText)
                          ),
                          TextButton(
                              onPressed: (){
                                launch(urlString!);
                                Navigator.pop(context);
                              },
                              child: Text(S.of(context).openInBrowser)
                          ),
                          TextButton(onPressed: (){
                            Navigator.pop(context);
                          }, child: Text(S.of(context).cancel))
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
                              platformPageRoute(context:context.buildContext,builder: (context) => ViewThreadSliverPage( discuz,user, tid))
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
                              platformPageRoute(context:context.buildContext,builder: (context) => ViewThreadSliverPage(discuz,user,tid))
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
                              platformPageRoute(context:context.buildContext,builder: (context) => DisplayForumSliverPage(discuz,user, fid))
                          );
                          return;
                        }
                      }
                      break;
                    }
                    case "space":{
                      // check for forum, query fid
                      if(uri.queryParameters.containsKey("uid")){
                        String uidString = uri.queryParameters["uid"]!;
                        // trigger tid
                        if(int.tryParse(uidString) != null){
                          int uid = int.tryParse(uidString)!;
                          await Navigator.push(
                              context.buildContext,
                              platformPageRoute(context:context.buildContext,builder: (context) => UserProfilePage(discuz,user,uid))
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
                      platformPageRoute(context:context.buildContext,builder: (context) => DisplayForumSliverPage(discuz, user, int.tryParse(fid)!))
                  );
                  return;
                }

                // check short
                String? tid = await RewriteRuleUtils.findTidInURL(discuz, urlString);
                if(tid!=null && int.tryParse(tid) != null){
                  await Navigator.push(
                      context.buildContext,
                      platformPageRoute(context:context.buildContext,builder: (context) => ViewThreadSliverPage(discuz, user, int.tryParse(tid)!))
                  );
                  return;
                }

                String? uid = await RewriteRuleUtils.findUidInURL(discuz, urlString);
                if(uid!=null && int.tryParse(uid) != null){
                  await Navigator.push(
                      context.buildContext,
                      platformPageRoute(context:context.buildContext,builder: (context) => UserProfilePage(discuz, user, int.tryParse(uid)!))
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
          onImageError: (e,s){

          },
          onImageTap: (string, context,attribute, element){
            if(string!= null){
              VibrationUtils.vibrateWithClickIfPossible();
              Navigator.push(
                  context.buildContext,
                  platformPageRoute(context:context.buildContext,builder: (context) => FullImagePage(string))
              );
            }
          },
          customRender: {
            "collapse":(RenderContext context, Widget child){
              String title = S.of(context.buildContext).collapseItem;
              if(context.tree.element?.attributes["title"] != null){
                title = context.tree.element!.attributes["title"]!;
              }

              return ExpansionTile(
                  title: Text(title),
                  controlAffinity: ListTileControlAffinity.platform,
                  children: [
                    child
                  ],
                  collapsedBackgroundColor: Theme.of(context.buildContext).colorScheme.primary,
                  collapsedTextColor: Theme.of(context.buildContext).colorScheme.onPrimary,
                  collapsedIconColor: Theme.of(context.buildContext).colorScheme.onPrimary,
              );
            }
          },
          tagsList: Html.tags..addAll(["collapse"]),
        );
      }),

    );
  }


}