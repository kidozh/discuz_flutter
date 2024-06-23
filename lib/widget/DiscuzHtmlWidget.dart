
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/FullImagePage.dart';
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/provider/TypeSettingNotifierProvider.dart';
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:discuz_flutter/utility/PostTextUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_audio/flutter_html_audio.dart';
import 'package:flutter_html_svg/flutter_html_svg.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import 'package:flutter_html_video/flutter_html_video.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:slide_countdown/slide_countdown.dart';

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
        bool useCompactParagraph = typesetting.useCompactParagraph;

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
          data: PostTextUtils.getDecodedString(html, useCompactParagraph),

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
            "br": Style(
              lineHeight: useCompactParagraph? LineHeight(1): null,
            )


          },
          onLinkTap: (urlString, context1,attribute) async{
            URLUtils.openURL(context, onSelectTid, urlString, callback, tid);


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
                                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold),
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
                          URLUtils.checkWithDbAndOpenURL(context, url);
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



}