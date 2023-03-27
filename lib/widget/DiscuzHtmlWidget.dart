
import 'dart:developer';

import 'package:discuz_flutter/dao/TrustHostDao.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
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
import 'package:discuz_flutter/utility/RewriteRuleUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_iframe/flutter_html_iframe.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:slide_countdown/slide_countdown.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utility/URLUtils.dart';

typedef void JumpToPidCallback(int pid);

// ignore: must_be_immutable
class DiscuzHtmlWidget extends StatelessWidget{
  String html;
  Discuz discuz;
  JumpToPidCallback? callback;
  int? tid;

  DiscuzHtmlWidget(this.discuz,this.html,{this.callback, this.tid});

  _trustHost(String host) async{
    TrustHostDao trustHostDao = await AppDatabase.getTrustHostDao();
    await trustHostDao.insertTrustHost(TrustHost(host));
  }

  String replaceCollapseTag(String string){
    //log("Recv html $string");
    string = string.replaceAllMapped(RegExp(r"\[collapse(|=(.*?))]"), (match){
      //log("Get match string ${match.groupCount} ${match.group(0)}");
      if(match.groupCount == 2){
        String title = match.group(1)!;
        if(title.startsWith("=")){
          title = title.replaceFirst("=", "");
        }
        //log("Recv matched message ${match.group(1)} $title");
        return '<collapse title="$title"> \n';
      }
      else{
        return '<collapse>\n';
      }
    });
    string = string.replaceAll(RegExp(r"\[/collapse.*?\]"), r"<br/></collapse>");

    return string;
  }

  String replaceSpoilTag(String string){
    string = string
        .replaceAll(RegExp(r"\[spoil.*?\]"), r'<spoil><br/>')
        .replaceAll(RegExp(r"\[/spoil\]"), r"<br/></spoil>");

    return string;
  }

  String replaceCountDownTag(String string){
    string = string.replaceAllMapped(RegExp(r"\[micxp_countdown.*?\](.*?)\[/micxp_countdown\]"), (match) {
      if(match.groupCount == 1){
        return '<countdown time="${match.group(1)}"></countdown>';
      }
      return "";
    });
    return string;
  }

  String getDecodedString(){
    String decodedString = replaceCollapseTag(this.html);
    decodedString = replaceSpoilTag(decodedString);
    decodedString = replaceCountDownTag(decodedString);
    //log("decode string ${decodedString}");
    return decodedString;
  }


  @override
  Widget build(BuildContext context) {

    return Container(
      width: double.infinity,

      child: Consumer<TypeSettingNotifierProvider>(builder: (context, typesetting, _) {
        double scalingParameter = typesetting.scalingParameter;
        // print("font scaling parameters ${scalingParameter} and font size ${12*scalingParameter}");
        double? themeFontSize = Theme.of(context).textTheme.bodyMedium?.fontSize == null? 14 : Theme.of(context).textTheme.bodyText2?.fontSize!;
        double paragraphFontSize = themeFontSize == null ? 14 : themeFontSize;
        return Html(

          data: "<p>${this.getDecodedString()}</p>",
          style: {
            "*": Style(
              fontSize: FontSize(paragraphFontSize*scalingParameter),
            ),
            ".reply_wrap" :Style(
              //backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.grey.shade200: Colors.grey.shade600,
              backgroundColor: Theme.of(context).brightness == Brightness.light ? Colors.grey.shade200: Colors.grey.shade600,
              padding: const EdgeInsets.all(8),
              margin: Margins(bottom: Margin(4.0)),
              border: Border(left: BorderSide(color: Theme.of(context).colorScheme.primary, width: 4)),
              width: Width.auto()
            ),
            "p":Style(
              fontStyle: Theme.of(context).textTheme.bodyMedium?.fontStyle,
            ),
            "a":Style(
              color: Theme.of(context).colorScheme.primary,
            )

          },
          onLinkTap: (urlString, context,attribute, element) async{
            VibrationUtils.vibrateWithClickIfPossible();
            log("Press link ${urlString} ");
            if(urlString != null){
              urlString = urlString.replaceAll("&amp;", "&");
              bool urlLauchable = await canLaunchUrl(Uri.parse(urlString));
              User? user = Provider.of<DiscuzAndUserNotifier>(context.buildContext, listen: false).user;
              // judge if it is a path
              Uri? tryUri = Uri.tryParse(urlString);
              log("${Uri.parse(urlString).isAbsolute} can launch $urlLauchable $urlString");
              if(!Uri.parse(urlString).isAbsolute){
                // add a prefix to test if it's a url
                urlString = discuz.baseURL+ "/" + urlString;
                log("Press after link ${urlString} ");
                urlLauchable = await canLaunchUrl(Uri.parse(urlString));
                //return;
              }


              if(urlLauchable){
                // parse url
                Uri uri = Uri.parse(urlString);
                // check host
                if(uri.host != Uri.parse(discuz.baseURL).host){
                  VibrationUtils.vibrateWithClickIfPossible();
                  checkWithDbAndOpenURL(context, urlString);
                  return;
                }

                // check query parameters for full url
                if(uri.queryParameters.containsKey("mod")){
                  String modParamter = uri.queryParameters["mod"]!;
                  log("recv modParamter ${modParamter} and tid ${this.tid}" );
                  // check forum display
                  switch (modParamter){
                    case "redirect":{
                      if(uri.queryParameters.containsKey("ptid")){
                        String tidString = uri.queryParameters["ptid"]!;
                        if(this.tid != null && callback!= null && this.tid.toString() == tidString){
                          // may need to scroll
                          log("Need to rescroll by the parameter");
                          if(uri.queryParameters.containsKey("pid")){
                            String pidString = uri.queryParameters["pid"]!;
                            if(int.tryParse(pidString) != null){
                              int pid = int.parse(pidString);
                              // navigate
                              this.callback!(pid);
                              return;
                            }
                          }
                        }
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
                              platformPageRoute(context:context.buildContext,builder: (context) => DisplayForumTwoPanePage(discuz,user, fid))
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
                      platformPageRoute(context:context.buildContext,builder: (context) => DisplayForumTwoPanePage(discuz, user, int.tryParse(fid)!))
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


                await URLUtils.launchURL(urlString);
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
          customRenders: {
            iframeMatcher(): iframeRender(),
            collapseMatcher(): CustomRender.widget(
                widget: (context, buildChild){
                  String title = S.of(context.buildContext).collapseItem;
                  if(context.tree.element?.attributes["title"] != null){
                    title = context.tree.element!.attributes["title"]!;
                  }

                  return ExpansionTile(
                    title: Text(title),
                    controlAffinity: ListTileControlAffinity.platform,
                    children: [
                      DiscuzHtmlWidget(discuz, context.tree.element!.innerHtml)
                    ],
                    collapsedBackgroundColor: Theme.of(context.buildContext).colorScheme.primary,
                    collapsedTextColor: Theme.of(context.buildContext).colorScheme.onPrimary,
                    collapsedIconColor: Theme.of(context.buildContext).colorScheme.onPrimary,
                  );
                }

            ),
            spoilMatcher(): CustomRender.widget(widget: (context, buildChild){
              String title = S.of(context.buildContext).collapseItem;
              if(context.tree.element?.attributes["title"] != null){
                title = context.tree.element!.attributes["title"]!;
              }

              return ExpansionTile(
                title: Text(title),
                controlAffinity: ListTileControlAffinity.platform,
                children: [
                  DiscuzHtmlWidget(discuz, context.tree.element!.innerHtml)
                ],
                collapsedBackgroundColor: Theme.of(context.buildContext).colorScheme.primary,
                collapsedTextColor: Theme.of(context.buildContext).colorScheme.onPrimary,
                collapsedIconColor: Theme.of(context.buildContext).colorScheme.onPrimary,
              );
            }),

            countDownMatcher(): CustomRender.widget(widget: (renderContext, buildChild){
              String timeString = "";
              if(renderContext.tree.element?.attributes["time"] != null){
                timeString = renderContext.tree.element!.attributes["time"]!;
                DateTime? datetime = DateTime.tryParse(timeString);

                if(datetime!=null){

                  // most of them located in Asia/Shanghai
                  Duration duration = datetime.difference(DateTime.now());

                  log("get time string ${timeString} ${datetime}");
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: ListTile(
                      leading: Icon(Icons.timer),
                      title: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SlideCountdown(
                            duration: duration,
                            textStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            separatorType: SeparatorType.title,
                            durationTitle: DurationTitle(
                              days: S.of(context).day,
                              hours:S.of(context).hour,
                              minutes:S.of(context).minute,
                              seconds:S.of(context).second,
                            ),
                          )
                        ],
                      ),
                      subtitle: DateTime.now().timeZoneOffset != Duration(hours: 8)? Text(S.of(context).countDownTimeZoneNotify): null,
                    ),
                  );
                }
                else{
                  return Text(S.of(renderContext.buildContext).brokenCountDown);
                }
              }
              else{
                return Text(S.of(renderContext.buildContext).brokenCountDown);
              }
            }),


          },
          tagsList: Html.tags..addAll(["collapse", "spoil","countdown"]),
        );
      }),


    );
  }

  CustomRenderMatcher collapseMatcher() => (context) => context.tree.element?.localName == "collapse";
  CustomRenderMatcher spoilMatcher() => (context) => context.tree.element?.localName == "spoil";
  CustomRenderMatcher countDownMatcher() => (context) => context.tree.element?.localName == "countdown";

  void checkWithDbAndOpenURL(RenderContext context, String urlString) async{
    Uri uri = Uri.parse(urlString);
    // check host
    if(uri.host != Uri.parse(discuz.baseURL).host){
      // check if database exists

      TrustHostDao trustHostDao = await AppDatabase.getTrustHostDao();
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
                            child: Text(urlString,softWrap: true,style: TextStyle(color: Colors.red,),)

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

                    URLUtils.launchURL(urlString);
                    Navigator.pop(context);
                  },
                  child: Text(S.of(context).trustHostActionText)
              ),
              TextButton(
                  onPressed: (){
                    URLUtils.launchURL(urlString);
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
        URLUtils.launchURL(urlString);
      }
      return ;
    }
  }

}