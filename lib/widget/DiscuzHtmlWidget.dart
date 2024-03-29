
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
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
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/provider/TypeSettingNotifierProvider.dart';
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:discuz_flutter/utility/PostTextUtils.dart';
import 'package:discuz_flutter/utility/RewriteRuleUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_audio/flutter_html_audio.dart';
import 'package:flutter_html_iframe/flutter_html_iframe.dart';
import 'package:flutter_html_svg/flutter_html_svg.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import 'package:flutter_html_video/flutter_html_video.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:slide_countdown/slide_countdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../utility/URLUtils.dart';

typedef void JumpToPidCallback(int pid);

// ignore: must_be_immutable
class DiscuzHtmlWidget extends StatelessWidget{
  String html;
  Discuz discuz;
  JumpToPidCallback? callback;
  int? tid;
  final ValueChanged<int>? onSelectTid;

  DiscuzHtmlWidget(this.discuz,this.html,{this.callback, this.tid, this.onSelectTid});

  _trustHost(String host) async{
    TrustHostDao trustHostDao = await AppDatabase.getTrustHostDao();
    await trustHostDao.insertTrustHost(TrustHost(host));
  }




  @override
  Widget build(BuildContext context) {

    return Container(
      width: double.infinity,
      //padding: EdgeInsets.zero,

      child: Consumer<TypeSettingNotifierProvider>(builder: (context, typesetting, _) {
        double scalingParameter = typesetting.scalingParameter;
        bool useThinFont = typesetting.useThinFontWeight;
        Typography typography = Typography.material2021();
        String platformName = Provider.of<ThemeNotifierProvider>(context, listen: false).platformName;
        TargetPlatform targetPlatform = TargetPlatform.android;

        switch(platformName){
          case "ios":{
            targetPlatform = TargetPlatform.iOS;
            break;
          }
          case "android":{
            targetPlatform = TargetPlatform.android;
            break;
          }
          case "":{
            targetPlatform = Theme.of(context).platform;
          }
        }

        switch (typesetting.typographyTheme){
          case "material2014":{
            typography = Typography.material2014(platform: targetPlatform);
            break;
          }
          case "material2018":{
            typography = Typography.material2018(platform: targetPlatform);
            break;
          }
          case "material2021":{
            typography = Typography.material2021(platform: targetPlatform);
            break;
          }
          default:{
            typography = Theme.of(context).typography;
          }
        }

        TextTheme textTheme = typography.dense.useSystemChineseFont(Theme.of(context).brightness);
        TextStyle? defaultTextStyle = textTheme.bodyLarge;
        double? themeFontSize = defaultTextStyle?.fontSize == null? 14 : defaultTextStyle?.fontSize!;

        return Html(
          //shrinkWrap: true,
          data: PostTextUtils.getDecodedString(html),

          style: {
            "p": Style(
                color: defaultTextStyle?.color,
                backgroundColor: defaultTextStyle?.backgroundColor,
                fontStyle: defaultTextStyle?.fontStyle,
                fontFamily: defaultTextStyle?.fontFamily,
                fontFamilyFallback: defaultTextStyle?.fontFamilyFallback,
                fontSize: defaultTextStyle?.fontSize == null? FontSize.medium:FontSize(defaultTextStyle!.fontSize!*scalingParameter),
                fontWeight: defaultTextStyle?.fontWeight,
                wordSpacing: defaultTextStyle?.wordSpacing,

                padding: HtmlPaddings.zero,
                margin: Margins.zero
            ),
            "*": Style(
              fontSize: defaultTextStyle?.fontSize == null? FontSize.medium:FontSize(defaultTextStyle!.fontSize!*scalingParameter),
              fontWeight: useThinFont? FontWeight.w300: null,
              lineHeight: LineHeight(1.8),
            ),
            "font": Style(
              backgroundColor: Theme.of(context).brightness == Brightness.dark? Colors.transparent: null,
              color: Theme.of(context).brightness == Brightness.dark? Theme.of(context).textTheme.bodySmall?.color: null,
              fontSize: defaultTextStyle?.fontSize == null? FontSize.medium:FontSize(defaultTextStyle!.fontSize!*scalingParameter),
              //fontWeight: defaultTextStyle?.fontWeight,
            ),
            ".reply_wrap" :Style(
              backgroundColor: Theme.of(context).brightness == Brightness.light ? Colors.grey.shade200: Colors.grey.shade600,
              padding: HtmlPaddings.all(4.0),
              margin: Margins(bottom: Margin(4.0)),
              border: Border(left: BorderSide(color: Theme.of(context).colorScheme.primary, width: 4)),
              width: Width.auto()
            ),
            "a":Style(
              color: Theme.of(context).colorScheme.primary,
              textDecoration: TextDecoration.underline,
              textDecorationColor: Theme.of(context).colorScheme.primary,

            ),
            "h1": Style(
                fontSize: textTheme.titleLarge?.fontSize != null ? FontSize(textTheme.titleLarge!.fontSize!*scalingParameter): null,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontFamily: textTheme.titleLarge?.fontFamily,
                fontWeight: FontWeight.bold,
                fontStyle: textTheme.titleLarge?.fontStyle,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                padding: HtmlPaddings.all(6.0)
            ),
            "h2": Style(
                fontSize: textTheme.titleLarge?.fontSize != null ? FontSize(textTheme.titleLarge!.fontSize!*scalingParameter): null,
                color: Theme.of(context).colorScheme.primary,
                fontFamily: textTheme.titleLarge?.fontFamily,
                fontWeight: FontWeight.bold,
                fontStyle: textTheme.titleLarge?.fontStyle,
                backgroundColor: textTheme.titleLarge?.backgroundColor,
            ),
            "h3": Style(
                fontSize: textTheme.titleLarge?.fontSize != null ? FontSize(textTheme.titleLarge!.fontSize!*scalingParameter): null,
                color: Theme.of(context).colorScheme.primary,
                fontFamily: textTheme.titleLarge?.fontFamily,
                fontWeight: textTheme.titleLarge?.fontWeight,
                fontStyle: textTheme.titleLarge?.fontStyle,
                backgroundColor: textTheme.titleLarge?.backgroundColor
            ),
            "h4": Style(
              fontSize: textTheme.titleLarge?.fontSize != null ? FontSize(textTheme.titleLarge!.fontSize!*scalingParameter): null,
              color: textTheme.titleLarge?.color,
              fontFamily: textTheme.titleLarge?.fontFamily,
              fontWeight: textTheme.titleLarge?.fontWeight,
              fontStyle: textTheme.titleLarge?.fontStyle,
              backgroundColor: textTheme.titleLarge?.backgroundColor
            ),
            "h5": Style(
                fontSize: textTheme.titleMedium?.fontSize != null ? FontSize(textTheme.titleMedium!.fontSize!*scalingParameter): null,
                color: textTheme.titleMedium?.color,
                fontFamily: textTheme.titleMedium?.fontFamily,
                fontWeight: FontWeight.w300,
                fontStyle: textTheme.titleMedium?.fontStyle,
                backgroundColor: textTheme.titleMedium?.backgroundColor
            ),
            "h6": Style(
                fontSize: textTheme.titleSmall?.fontSize != null ? FontSize(textTheme.titleSmall!.fontSize!*scalingParameter): null,
                color: textTheme.titleSmall?.color,
                fontFamily: textTheme.titleSmall?.fontFamily,
                fontWeight: FontWeight.w300,
                fontStyle: textTheme.titleSmall?.fontStyle,
                backgroundColor: textTheme.titleSmall?.backgroundColor
            ),


          },
          onLinkTap: (urlString, context1,attribute) async{
            VibrationUtils.vibrateWithClickIfPossible();
            log("Press link ${urlString} ");
            if(urlString != null){
              urlString = urlString.replaceAll("&amp;", "&");
              bool urlLauchable = await canLaunchUrl(Uri.parse(urlString));
              User? user = Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
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


          },
          extensions: [
            //const IframeHtmlExtension(),
            //MathHtmlExtension(),
            const SvgHtmlExtension(),
            const AudioHtmlExtension(),
            const TableHtmlExtension(),
            const VideoHtmlExtension(),
            TagWrapExtension(
                tagsToWrap: {"table"},
                builder: (child) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: child,
                  );
                }),
            ImageExtension(
                //matchesAssetImages: false,
                //matchesDataImages: false,
                //networkSchemas: {"custom:"},
                builder: (extensionContext) {
                  final element = extensionContext.styledElement;
                  if(element?.node.attributes["src"] != null){
                    return InkWell(
                      child: CachedNetworkImage(
                        imageUrl: element!.node.attributes["src"]!,
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        progressIndicatorBuilder: (context, url, progress) => PlatformCircularProgressIndicator(
                          material: (_, __) => MaterialProgressIndicatorData(
                            value: progress.progress
                          ),
                        ),
                      ),
                      onTap: () {
                        String? src = element.node.attributes["src"];
                        if (src != null) {
                          VibrationUtils.vibrateWithClickIfPossible();
                          Navigator.push(
                              context,
                              platformPageRoute(context: context,
                                  builder: (context) => FullImagePage(src))
                          );
                        }
                      }
                    );
                  }
                  else{
                    return Container();
                  }

                }
            ),
            OnImageTapExtension(onImageTap: (src, imgAttributes, element){
              if (src!= null){
                VibrationUtils.vibrateWithClickIfPossible();
                Navigator.push(
                    context,
                    platformPageRoute(context:context,builder: (context) => FullImagePage(src))
                );
              }

            }),
            TagExtension(
              tagsToExtend: {"collapse", "spoil"},
              builder: (extensionContext){
                String title = S.of(context).collapseItem;
                if(extensionContext.attributes["title"] != null){
                  title = extensionContext.attributes["title"]!;
                }

                return ExpansionTile(
                  title: Text(title),
                  onExpansionChanged: (bool){
                    VibrationUtils.vibrateWithClickIfPossible();
                  },
                  controlAffinity: ListTileControlAffinity.platform,
                  children: [
                    DiscuzHtmlWidget(discuz, extensionContext.innerHtml)
                  ],
                  collapsedBackgroundColor: Theme.of(context).colorScheme.primary,
                  collapsedTextColor: Theme.of(context).colorScheme.onPrimary,
                  collapsedIconColor: Theme.of(context).colorScheme.onPrimary,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  textColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  iconColor: Theme.of(context).colorScheme.onPrimaryContainer,
                );
              }
            ),
            TagExtension(
                tagsToExtend: {"countdown"},
                builder: (extensionContext){
                  String timeString = "";
                  if(extensionContext.attributes["time"] != null){
                    timeString = extensionContext.attributes["time"]!;
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
                      return Text(S.of(context).brokenCountDown);
                    }
                  }
                  else{
                    return Text(S.of(context).brokenCountDown);
                  }
                }
            ),
            TagExtension(
                tagsToExtend: {"iframe"},
                builder: (extensionContext){
                    String? url = extensionContext.attributes["src"];
                    if(url != null ){
                      return InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.all(Radius.circular(16.0))
                          ),
                          padding: EdgeInsets.all(isCupertino(context)? 4.0: 0.0),
                          child: PlatformListTile(
                            leading: Icon(AppPlatformIcons(context).iframeOutline,
                              color: Theme.of(context).colorScheme.onPrimary,),
                            title: Text(S.of(context).inlineFramePage, style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold
                            ),),
                            subtitle: Text(extensionContext.attributes["src"]!,style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.6),
                                fontWeight: FontWeight.w300
                            ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        onTap: (){
                          VibrationUtils.vibrateWithClickIfPossible();
                          checkWithDbAndOpenURL(context, url);
                        },
                      );
                    }
                    else{
                      return Container();
                    }

                }
            ),

          ],
        );
      }),


    );
  }

  void checkWithDbAndOpenURL(BuildContext context, String urlString) async{
    Uri uri = Uri.parse(urlString);
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

}