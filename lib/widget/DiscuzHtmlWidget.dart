import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:dio/dio.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/FullImagePage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/provider/TypeSettingNotifierProvider.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/PostTextUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/BilibiliWidget.dart';
import 'package:discuz_flutter/widget/SteamGameWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_cache_manager_dio/flutter_cache_manager_dio.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:fwfh_cached_network_image/fwfh_cached_network_image.dart';
import 'package:html/parser.dart';
import 'package:provider/provider.dart';
import 'package:slide_countdown/slide_countdown.dart';

import '../entity/User.dart';
import '../utility/DiscuzImageDioCacheManager.dart';
import '../utility/URLUtils.dart';

typedef void JumpToPidCallback(int pid);

// ignore: must_be_immutable
class DiscuzHtmlWidget extends StatelessWidget {
  String html;
  Discuz discuz;
  JumpToPidCallback? callback;
  int? tid;
  final ValueChanged<int>? onSelectTid;

  DiscuzHtmlWidget(this.discuz, this.html,
      {this.callback, this.tid, this.onSelectTid});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.0),

      child: Consumer<TypeSettingNotifierProvider>(
          builder: (context, typesetting, _) {
        double scalingParameter = typesetting.scalingParameter;
        bool useThinFont = typesetting.useThinFontWeight;
        Typography typography = Typography.material2021();
        String platformName =
            Provider.of<ThemeNotifierProvider>(context, listen: false)
                .platformName;
        TargetPlatform targetPlatform = TargetPlatform.android;
        bool useCompactParagraph = typesetting.useCompactParagraph;

        switch (platformName) {
          case "ios":
            {
              targetPlatform = TargetPlatform.iOS;
              break;
            }
          case "android":
            {
              targetPlatform = TargetPlatform.android;
              break;
            }
          case "":
            {
              targetPlatform = Theme.of(context).platform;
            }
        }

        switch (typesetting.typographyTheme) {
          case "material2014":
            {
              typography = Typography.material2014(platform: targetPlatform);
              break;
            }
          case "material2018":
            {
              typography = Typography.material2018(platform: targetPlatform);
              break;
            }
          case "material2021":
            {
              typography = Typography.material2021(platform: targetPlatform);
              break;
            }
          default:
            {
              typography = Theme.of(context).typography;
            }
        }

        TextTheme textTheme =
            typography.tall.useSystemChineseFont(Theme.of(context).brightness);
        TextStyle? defaultTextStyle = textTheme.bodyLarge;
        double themeFontSize = defaultTextStyle == null
            ? 14: defaultTextStyle.fontSize == null? 14 : defaultTextStyle.fontSize!;
        User? user = Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
        Future<Dio> futureDio = NetworkUtils.getDioWithPersistCookieJar(user);
        //DiscuzImageDioCacheManager dioCacheManager = DiscuzImageDioCacheManager(futureDio);

        return HtmlWidget(
          PostTextUtils.getDecodedString(html, useCompactParagraph),
          enableCaching: true,
          onTapUrl: (url) {
            URLUtils.openURL(context, onSelectTid, url, callback, tid);
            return true;
          },
          //factoryBuilder: () => DiscuzHtmlWidgetFactory(dioCacheManager),
          onTapImage: (imageMetaData){
            for(var source in imageMetaData.sources){
              String src = source.url;
              VibrationUtils.vibrateWithClickIfPossible();
              Navigator.push(
                  context,
                  platformPageRoute(
                      iosTitle: S.of(context).viewPicture,
                      context: context,
                      builder: (context) => FullImagePage(src, getAllImageSrcList())));
            }

          },
          textStyle: TextStyle(
            fontSize: themeFontSize * scalingParameter,
            fontWeight: useThinFont? FontWeight.w300: FontWeight.normal,
            wordSpacing: defaultTextStyle?.wordSpacing,
            height: defaultTextStyle?.height,
            textBaseline: defaultTextStyle?.textBaseline,
          ).useSystemChineseFont(),
          // textStyle: Theme.of(context).useSystemChineseFont(Theme.of(context).brightness).textTheme.bodyLarge?..copyWith(
          //   fontSize: 12 * scalingParameter
          // ),
          customStylesBuilder: (element){
            if (element.localName == "br"){
              return {
                "margin": '0.1em 0',
                "display" : "block"
              };
            } else if(element.className == "reply_wrap"){
              return {
                "border": "0.05em dashed #${Theme.of(context).colorScheme.primary.value.toRadixString(16).substring(2)}",
                "border-radius": "0.5em",
                "background-color" : "#${Theme.of(context).colorScheme.primaryContainer.value.toRadixString(16).substring(2)}",
                "color" : "#${Theme.of(context).colorScheme.onPrimaryContainer.value.toRadixString(16).substring(2)}",
                "padding" : "0.5em",
                "margin-bottom": "0.1em"
              };
            }
            else if(element.className == "blockcode"){
              return {
                "border": "0.05em dashed #${Theme.of(context).colorScheme.secondary.value.toRadixString(16).substring(2)}",
                "background-color" : "#${Theme.of(context).colorScheme.secondaryContainer.value.toRadixString(16).substring(2)}",
                "color" : "#${Theme.of(context).colorScheme.onSecondaryContainer.value.toRadixString(16).substring(2)}",
                "padding" : "0.5em",
                "margin-bottom": "0.1em",
                "font-family": "monospace",
              };
            }
            return null;
          },
          customWidgetBuilder: (element) {
            // "collapse", "spoil"
            if (element.localName == "collapse" ||
                element.localName == "spoil") {
              String title = S.of(context).collapseItem;
              if (element.attributes["title"] != null) {
                title = element.attributes["title"]!;
              }

              return ExpansionTile(
                title: Text(title),
                onExpansionChanged: (bool) {
                  VibrationUtils.vibrateWithClickIfPossible();
                },
                controlAffinity: ListTileControlAffinity.platform,
                children: [DiscuzHtmlWidget(discuz, element.innerHtml)],
                collapsedBackgroundColor: Theme.of(context).colorScheme.primary,
                collapsedTextColor: Theme.of(context).colorScheme.onPrimary,
                collapsedIconColor: Theme.of(context).colorScheme.onPrimary,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                textColor: Theme.of(context).colorScheme.onPrimaryContainer,
                iconColor: Theme.of(context).colorScheme.onPrimaryContainer,
              );
            } else if (element.localName == "countdown") {
              String timeString = "";
              if (element.attributes["time"] != null) {
                DateTime? datetime = DateTime.tryParse(timeString);

                if (datetime != null) {
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
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold),
                            decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.all(Radius.circular(20)),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            separatorType: SeparatorType.title,
                            durationTitle: DurationTitle(
                              days: S.of(context).day,
                              hours: S.of(context).hour,
                              minutes: S.of(context).minute,
                              seconds: S.of(context).second,
                            ),
                          )
                        ],
                      ),
                      subtitle:
                      DateTime.now().timeZoneOffset != Duration(hours: 8)
                          ? Text(S.of(context).countDownTimeZoneNotify)
                          : null,
                    ),
                  );
                } else {
                  return Text(S.of(context).brokenCountDown);
                }
              } else {
                return Text(S.of(context).brokenCountDown);
              }

            } else if (element.attributes["href"]!= null && element.attributes["href"]!.startsWith("https://www.bilibili.com")){
              return BilibiliWidget(element.attributes["href"]!);
            }
            else if (element.attributes["src"]!= null && element.attributes["src"]!.startsWith("https://store.steampowered.com/widget")){
              return SteamGameWidget(element.attributes["src"]!);
            }
            return null;
          },
        );


      }),
    );
  }

  List<String> getAllImageSrcList(){
    var htmlDocument = parse(html);
    var imageElementList = htmlDocument.getElementsByTagName("img");
    List<String> imageSrcList = [];
    for(var imageElement in imageElementList){
      if(imageElement.attributes["src"] != null){
        imageSrcList.add(imageElement.attributes["src"]!);
      }
    }

    return imageSrcList;
  }
}

class DiscuzHtmlWidgetFactory extends WidgetFactory with CachedNetworkImageFactory{

  DiscuzImageDioCacheManager dioCacheManager;

  DiscuzHtmlWidgetFactory(this.dioCacheManager) {


  }

  BaseCacheManager get cacheManager => dioCacheManager;
}


