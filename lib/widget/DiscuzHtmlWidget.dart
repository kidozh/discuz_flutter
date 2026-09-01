import 'dart:developer';

import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/FullImagePage.dart';
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/provider/TypeSettingNotifierProvider.dart';
import 'package:discuz_flutter/utility/PostTextUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/BilibiliWidget.dart';
import 'package:discuz_flutter/widget/DiscuzAdaptiveTable.dart';
import 'package:discuz_flutter/widget/DiscuzCodeBlock.dart';
import 'package:discuz_flutter/widget/DiscuzQuoteBlock.dart';
import 'package:discuz_flutter/widget/SteamGameWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:fwfh_cached_network_image/fwfh_cached_network_image.dart';
import 'package:html/parser.dart';
import 'package:provider/provider.dart';
import 'package:slide_countdown/slide_countdown.dart';

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
  final Color? textColor;

  DiscuzHtmlWidget(this.discuz, this.html,
      {this.callback, this.tid, this.onSelectTid, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.0),
      child: Consumer<TypeSettingNotifierProvider>(
          builder: (context, typesetting, _) {
        final colorScheme = Theme.of(context).colorScheme;
        final darkMode = Theme.of(context).brightness == Brightness.dark;
        final effectiveTextColor = textColor ?? colorScheme.onSurface;
        String cssColor(Color color) =>
            color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2);
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
            ? 14
            : defaultTextStyle.fontSize == null
                ? 14
                : defaultTextStyle.fontSize!;
        final paragraphLineHeight = useCompactParagraph ? 1.34 : 1.52;
        final paragraphSpacing = useCompactParagraph ? 0.46 : 0.82;
        final subtleSurface = Color.alphaBlend(
          colorScheme.primary.withValues(alpha: darkMode ? 0.12 : 0.07),
          colorScheme.surface,
        );
        final codeSurface = Color.alphaBlend(
          colorScheme.secondary.withValues(alpha: darkMode ? 0.16 : 0.08),
          colorScheme.surface,
        );
        final subtleBorder = Color.alphaBlend(
          colorScheme.onSurface.withValues(alpha: darkMode ? 0.26 : 0.14),
          colorScheme.surface,
        );
        final mutedText = textColor == null
            ? colorScheme.onSurfaceVariant
            : effectiveTextColor;
        final htmlTextStyle = TextStyle(
          color: effectiveTextColor,
          fontSize: themeFontSize * scalingParameter,
          fontWeight: useThinFont ? FontWeight.w300 : FontWeight.normal,
          wordSpacing: defaultTextStyle?.wordSpacing,
          letterSpacing: defaultTextStyle?.letterSpacing,
          height: paragraphLineHeight,
          textBaseline: defaultTextStyle?.textBaseline,
        ).useSystemChineseFont();
        final repairedSourceHtml = DiscuzTableNormalizer.normalizeHtml(html);
        final normalizedHtml = PostTextUtils.getDecodedString(
          repairedSourceHtml,
          useCompactParagraph,
        );
        //DiscuzImageDioCacheManager dioCacheManager = DiscuzImageDioCacheManager(futureDio);

        return HtmlWidget(
          normalizedHtml,
          //enableCaching: true,
          onTapUrl: (url) {
            URLUtils.openURL(context, onSelectTid, url, callback, tid);
            return true;
          },
          //factoryBuilder: () => DiscuzHtmlWidgetFactory(dioCacheManager),
          onTapImage: (imageMetaData) {
            for (var source in imageMetaData.sources) {
              _openImage(context, source.url);
              break;
            }
          },
          textStyle: htmlTextStyle,
          // textStyle: Theme.of(context).useSystemChineseFont(Theme.of(context).brightness).textTheme.bodyLarge?..copyWith(
          //   fontSize: 12 * scalingParameter
          // ),
          customStylesBuilder: (element) {
            final styles = <String, String>{};
            final tag = element.localName;

            if (darkMode &&
                const {
                  'body',
                  'div',
                  'p',
                  'span',
                  'font',
                  'table',
                  'tbody',
                  'tr',
                  'td',
                  'th',
                  'ul',
                  'ol',
                  'li',
                  'blockquote',
                }.contains(tag)) {
              styles['color'] = '#${cssColor(effectiveTextColor)}';
              styles['background-color'] = 'transparent';
            }

            switch (tag) {
              case 'body':
              case 'div':
                styles['line-height'] = paragraphLineHeight.toString();
              case 'p':
                styles.addAll({
                  'line-height': paragraphLineHeight.toString(),
                  'margin': '0 0 ${paragraphSpacing}em 0',
                });
              case 'h1':
                styles.addAll({
                  'font-size': '1.55em',
                  'line-height': '1.22',
                  'font-weight': '700',
                  'letter-spacing': '-0.015em',
                  'margin': '1.15em 0 0.55em 0',
                  'color': '#${cssColor(effectiveTextColor)}',
                });
              case 'h2':
                styles.addAll({
                  'font-size': '1.34em',
                  'line-height': '1.25',
                  'font-weight': '700',
                  'letter-spacing': '-0.01em',
                  'margin': '1.05em 0 0.5em 0',
                  'color': '#${cssColor(effectiveTextColor)}',
                });
              case 'h3':
                styles.addAll({
                  'font-size': '1.18em',
                  'line-height': '1.3',
                  'font-weight': '600',
                  'margin': '0.95em 0 0.42em 0',
                  'color': '#${cssColor(effectiveTextColor)}',
                });
              case 'h4':
              case 'h5':
              case 'h6':
                styles.addAll({
                  'font-size': '1.05em',
                  'line-height': '1.35',
                  'font-weight': '600',
                  'margin': '0.85em 0 0.38em 0',
                  'color': '#${cssColor(effectiveTextColor)}',
                });
              case 'strong':
              case 'b':
                styles['font-weight'] = '600';
              case 'a':
                styles.addAll({
                  'color': '#${cssColor(colorScheme.primary)}',
                  'font-weight': '500',
                  'text-decoration': 'underline',
                });
              case 'blockquote':
                styles.addAll({
                  'border-left':
                      '0.22em solid #${cssColor(colorScheme.primary)}',
                  'border-radius': '0.45em',
                  'background-color': '#${cssColor(subtleSurface)}',
                  'color': '#${cssColor(mutedText)}',
                  'padding': '0.55em 0.8em',
                  'margin': '0.8em 0',
                  'line-height': '1.48',
                });
              case 'pre':
                styles.addAll({
                  'background-color': 'transparent',
                  'border': 'none',
                  'padding': '0',
                  'margin': '0',
                  'font-family': isCupertino(context) ? 'Menlo' : 'monospace',
                  'font-size': '0.9em',
                  'line-height': '1.45',
                  'white-space': 'pre',
                });
              case 'code':
                if (element.parent?.localName == 'pre') {
                  styles.addAll({
                    'background-color': 'transparent',
                    'border': 'none',
                    'padding': '0',
                    'font-family': isCupertino(context) ? 'Menlo' : 'monospace',
                    'font-size': 'inherit',
                  });
                } else {
                  styles.addAll({
                    'background-color': '#${cssColor(codeSurface)}',
                    'border': '0.04em solid #${cssColor(subtleBorder)}',
                    'border-radius': '0.38em',
                    'padding': '0.11em 0.32em',
                    'color': '#${cssColor(colorScheme.primary)}',
                    'font-family': isCupertino(context) ? 'Menlo' : 'monospace',
                    'font-size': '0.9em',
                    'font-weight': '500',
                  });
                }
              case 'ul':
              case 'ol':
                styles.addAll({
                  'padding-left': '1.45em',
                  'margin': '0.45em 0 ${paragraphSpacing}em 0',
                });
              case 'li':
                styles.addAll({
                  'margin': '0.2em 0',
                  'line-height': paragraphLineHeight.toString(),
                });
              case 'hr':
                styles.addAll({
                  'border': 'none',
                  'border-top': '0.05em solid #${cssColor(subtleBorder)}',
                  'margin': '1.1em 0',
                });
              case 'table':
                styles.addAll({
                  'border': '0.05em solid #${cssColor(subtleBorder)}',
                  'border-radius': '0.55em',
                  'margin': '0.8em 0',
                  'background-color': '#${cssColor(subtleSurface)}',
                });
              case 'th':
                styles.addAll({
                  'font-weight': '600',
                  'background-color': '#${cssColor(codeSurface)}',
                  'padding': '0.5em 0.65em',
                  'border': '0.05em solid #${cssColor(subtleBorder)}',
                });
              case 'td':
                styles.addAll({
                  'padding': '0.5em 0.65em',
                  'border': '0.05em solid #${cssColor(subtleBorder)}',
                });
              case 'img':
                styles.addAll({
                  'max-width': '100%',
                  'height': 'auto',
                  'border-radius': '0.7em',
                  'margin': '0.35em 0',
                });
              case 'figcaption':
                styles.addAll({
                  'color': '#${cssColor(mutedText)}',
                  'font-size': '0.86em',
                  'line-height': '1.35',
                  'margin': '0.35em 0 0.75em 0',
                });
              case 'small':
                styles.addAll({
                  'color': '#${cssColor(mutedText)}',
                  'font-size': '0.86em',
                });
              case 'br':
                styles.addAll({'margin': '0.08em 0', 'display': 'block'});
            }

            if (element.className == "reply_wrap") {
              styles.addAll({
                "border": "0.05em solid #${cssColor(subtleBorder)}",
                "border-left": "0.22em solid #${cssColor(colorScheme.primary)}",
                "border-radius": "0.65em",
                "background-color": "#${cssColor(subtleSurface)}",
                "color": "#${cssColor(effectiveTextColor)}",
                "padding": "0.65em 0.8em",
                "margin": "0.7em 0"
              });
            } else if (element.className == "blockcode") {
              styles.addAll({
                "border": "0.05em solid #${cssColor(subtleBorder)}",
                "border-radius": "0.65em",
                "background-color": "#${cssColor(codeSurface)}",
                "color": "#${cssColor(effectiveTextColor)}",
                "padding": "0.8em",
                "margin": "0.8em 0",
                "font-family": isCupertino(context) ? "Menlo" : "monospace",
                "font-size": "0.9em",
                "line-height": "1.45",
              });
            }
            return styles.isEmpty ? null : styles;
          },
          customWidgetBuilder: (element) {
            // "collapse", "spoil"
            if (element.localName == 'pre' ||
                element.classes.contains('blockcode')) {
              return DiscuzCodeBlock(
                code: DiscuzCodeBlock.extractCode(element),
                language: DiscuzCodeBlock.extractLanguage(element),
                textStyle: htmlTextStyle,
              );
            } else if (element.localName == 'code' &&
                !const {
                  'p',
                  'span',
                  'a',
                  'li',
                  'td',
                  'th',
                  'pre',
                  'h1',
                  'h2',
                  'h3',
                  'h4',
                  'h5',
                  'h6',
                }.contains(element.parent?.localName)) {
              return DiscuzCodeBlock(
                code: DiscuzCodeBlock.extractCode(element),
                language: DiscuzCodeBlock.extractLanguage(element),
                textStyle: htmlTextStyle,
              );
            } else if (element.localName == 'blockquote' ||
                element.classes.contains('quote')) {
              var quoteHtml = element.innerHtml;
              if (element.classes.contains('quote') &&
                  element.children.length == 1 &&
                  element.children.first.localName == 'blockquote') {
                quoteHtml = element.children.first.innerHtml;
              }
              return DiscuzQuoteBlock(
                child: DiscuzHtmlWidget(
                  discuz,
                  quoteHtml,
                  callback: callback,
                  tid: tid,
                  onSelectTid: onSelectTid,
                  textColor: mutedText,
                ),
              );
            } else if (element.localName == 'table') {
              return DiscuzAdaptiveTable(
                element: element,
                textStyle: htmlTextStyle,
                onTapUrl: (url) {
                  URLUtils.openURL(
                    context,
                    onSelectTid,
                    url,
                    callback,
                    tid,
                  );
                  return true;
                },
                onTapImage: (src) => _openImage(context, src),
              );
            } else if (element.localName == "collapse" ||
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
                    child: PlatformListTile(
                      leading: Icon(PlatformIcons(context).timeout),
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
            } else if (element.attributes["href"] != null &&
                element.attributes["href"]!
                    .startsWith("https://www.bilibili.com")) {
              return BilibiliWidget(element.attributes["href"]!);
            } else if (element.attributes["src"] != null &&
                element.attributes["src"]!
                    .startsWith("https://store.steampowered.com/widget")) {
              return SteamGameWidget(element.attributes["src"]!);
            }
            return null;
          },
        );
      }),
    );
  }

  void _openImage(BuildContext context, String src) {
    VibrationUtils.vibrateWithClickIfPossible();
    Navigator.push(
      context,
      platformPageRoute(
        iosTitle: S.of(context).viewPicture,
        context: context,
        builder: (context) => FullImagePage(src, getAllImageSrcList()),
      ),
    );
  }

  List<String> getAllImageSrcList() {
    var htmlDocument = parse(html);
    var imageElementList = htmlDocument.getElementsByTagName("img");
    List<String> imageSrcList = [];
    for (var imageElement in imageElementList) {
      if (imageElement.attributes["src"] != null) {
        imageSrcList.add(imageElement.attributes["src"]!);
      }
    }

    return imageSrcList;
  }
}

class DiscuzHtmlWidgetFactory extends WidgetFactory
    with CachedNetworkImageFactory {
  DiscuzImageDioCacheManager dioCacheManager;

  DiscuzHtmlWidgetFactory(this.dioCacheManager) {}

  BaseCacheManager get cacheManager => dioCacheManager;
}
