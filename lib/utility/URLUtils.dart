
import 'dart:developer';
import 'dart:io';

import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../dao/TrustHostDao.dart';
import '../database/AppDatabase.dart';
import '../entity/TrustHost.dart';
import '../entity/User.dart';
import '../generated/l10n.dart';
import '../page/DisplayForumSliverPage.dart';
import '../page/UserProfilePage.dart';
import '../page/ViewThreadSliverPage.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../widget/DiscuzHtmlWidget.dart';
import 'AppPlatformIcons.dart';
import 'RewriteRuleUtils.dart';
import 'VibrationUtils.dart';

class URLUtils{
  static String getAvatarURL(Discuz discuz, String uid){
    return "${discuz.uCenterURL}/avatar.php?uid=${uid}&size=big";
  }

  static String getLargeAvatarURL(Discuz discuz, String uid){
    return "${discuz.uCenterURL}/avatar.php?uid=${uid}&size=middle";
  }

  static String getSmallAvatarURL(Discuz discuz, String uid){
    return "${discuz.uCenterURL}/avatar.php?uid=${uid}&size=small";
  }

  static String getAttachmentURLWithAidEncode(Discuz discuz, String aid){
    return "${discuz.baseURL}/forum.php?mod=attachment&aid=${aid}";
  }

  static String getViewThreadURL(Discuz discuz, int tid){
    return "${discuz.baseURL}/forum.php?mod=viewthread&tid=${tid}";
  }

  static String getForumDisplayURL(Discuz discuz, int fid){
    return "${discuz.baseURL}/forum.php?mod=forumdisplay&fid=${fid}";
  }

  static Future<void> launchURL(String url) async => await canLaunchUrl(Uri.parse(url))
      ? await launchUrl(Uri.parse(url), mode: Platform.isIOS? LaunchMode.inAppWebView: LaunchMode.externalApplication)
      : throw 'Could not launch $url';

  static String getPublicMessageURL(Discuz discuz, int pmid){
    return "${discuz.baseURL}/home.php?mod=space&do=pm&subop=viewg&pmid=${pmid}";
  }

  static Future<void> openURL(BuildContext context, ValueChanged<int>? onSelectTid, String? urlString, JumpToPidCallback? callback, int? originalTid) async {
    VibrationUtils.vibrateWithClickIfPossible();
    Discuz? discuz = Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz;
    if(discuz == null){
      return;
    }
    User? user = Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    if(urlString != null){
      urlString = urlString.replaceAll("&amp;", "&");
      bool urlLauchable = await canLaunchUrl(Uri.parse(urlString));

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
          log("recv modParamter ${modParamter} and tid ${originalTid}" );
          // check forum display
          switch (modParamter){
            case "redirect":{
              if(uri.queryParameters.containsKey("ptid")){
                String tidString = uri.queryParameters["ptid"]!;
                if(originalTid!= null && callback!= null && originalTid.toString() == tidString){
                  // may need to scroll
                  log("Need to rescroll by the parameter");
                  if(uri.queryParameters.containsKey("pid")){
                    String pidString = uri.queryParameters["pid"]!;
                    if(int.tryParse(pidString) != null){
                      int pid = int.parse(pidString);
                      // navigate
                      callback(pid);
                      return;
                    }
                  }
                }
                // trigger tid
                if(int.tryParse(tidString) != null){
                  int tid = int.tryParse(tidString)!;
                  if(onSelectTid == null){
                    await Navigator.push(
                        context,
                        platformPageRoute(context:context,builder: (context) => ViewThreadSliverPage( discuz,user, tid))
                    );
                  }
                  else{
                    onSelectTid(tid);
                  }

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
                  if(onSelectTid == null){
                    await Navigator.push(
                        context,
                        platformPageRoute(context:context,builder: (context) => ViewThreadSliverPage( discuz,user, tid))
                    );
                  }
                  else{
                    onSelectTid!(tid);
                  }
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
                      context,
                      platformPageRoute(context:context,builder: (context) => DisplayForumTwoPanePage(discuz,user, fid))
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
                      context,
                      platformPageRoute(context:context,builder: (context) => UserProfilePage(discuz,user,uid))
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
              context,
              platformPageRoute(context:context,builder: (context) => DisplayForumTwoPanePage(discuz, user, int.tryParse(fid)!))
          );
          return;
        }

        // check short
        String? tid = await RewriteRuleUtils.findTidInURL(discuz, urlString);
        if(tid!=null && int.tryParse(tid) != null){
          if(onSelectTid == null){
            await Navigator.push(
                context,
                platformPageRoute(context:context,builder: (context) => ViewThreadSliverPage(discuz, user, int.tryParse(tid)!))
            );
          }
          else{
            onSelectTid!(int.tryParse(tid)!);
          }

          return;
        }

        String? uid = await RewriteRuleUtils.findUidInURL(discuz, urlString);
        if(uid!=null && int.tryParse(uid) != null){
          await Navigator.push(
              context,
              platformPageRoute(context:context,builder: (context) => UserProfilePage(discuz, user, int.tryParse(uid)!))
          );
          return;
        }


        await URLUtils.launchURL(urlString);
      }
      else{
        // show the link
        EasyLoading.showError(S.of(context).linkUnableToOpen(urlString));
      }
    }
  }

  static void checkWithDbAndOpenURL(BuildContext context, String urlString) async{
    Uri uri = Uri.parse(urlString);
    Discuz? discuz = Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz;
    if(discuz == null){
      return;
    }
    // check host
    if(uri.host != Uri.parse(discuz.baseURL).host){
      // check if database exists

      TrustHostDao trustHostDao = await AppDatabase.getTrustHostDao();
      TrustHost? trustHostInDb = await trustHostDao.findTrustHostByName(uri.host);
      if(trustHostInDb == null){
        showPlatformDialog(context: context, builder: (context){
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
                        Icon(AppPlatformIcons(context).linkSolid,color: Colors.red, size: 12,),
                        SizedBox(width: 8.0),
                        Expanded(
                            child: Text(urlString,softWrap: true,style: TextStyle(color: Colors.red,),)

                        )

                      ],
                    ),
                  ),
                  SizedBox(height: 16.0,),
                  Text(S.of(context).outerlinkOpenMessage,style: Theme.of(context).textTheme.bodyLarge,),


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

  static Future<void> _trustHost(String host) async{
    TrustHostDao trustHostDao = await AppDatabase.getTrustHostDao();
    await trustHostDao.insertTrustHost(TrustHost(host));
  }
}