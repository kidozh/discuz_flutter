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
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';
import 'package:slide_countdown/slide_countdown.dart';

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

        return HtmlWidget(
          PostTextUtils.getDecodedString(html, useCompactParagraph),
          onTapUrl: (url) {
            URLUtils.openURL(context, onSelectTid, url, callback, tid);
            return true;
          },
          onTapImage: (imageMetaData){
            for(var source in imageMetaData.sources){
              String src = source.url;
              VibrationUtils.vibrateWithClickIfPossible();
              Navigator.push(
                  context,
                  platformPageRoute(
                      context: context,
                      builder: (context) => FullImagePage(src)));
                        }

          },
          textStyle: TextStyle(
            fontSize: themeFontSize * scalingParameter,
            fontWeight: useThinFont? FontWeight.w300: FontWeight.normal
          ),
          // textStyle: Theme.of(context).useSystemChineseFont(Theme.of(context).brightness).textTheme.bodyLarge?..copyWith(
          //   fontSize: 12 * scalingParameter
          // ),
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

            }
            return null;
          },
        );
      }),
    );
  }
}
