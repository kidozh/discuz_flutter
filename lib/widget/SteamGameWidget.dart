import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:discuz_flutter/JsonResult/SteamGameDataResult.dart';
import 'package:discuz_flutter/client/SteamApiClient.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/widget/DiscuzHtmlWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:language_code/language_code.dart';
import 'package:provider/provider.dart';

import '../generated/l10n.dart';
import '../utility/AppPlatformIcons.dart';
import '../utility/NetworkUtils.dart';
import '../utility/URLUtils.dart';
import '../utility/VibrationUtils.dart';

class SteamGameWidget extends StatefulWidget {
  String url;

  SteamGameWidget(this.url);

  @override
  State<StatefulWidget> createState() {
    return SteamGameState(url);
  }
}

class SteamGameState extends State<SteamGameWidget> {
  String url;
  Uri steamUri = Uri();
  bool isLoading = false;
  String appId = "";
  SteamApiClient client = SteamApiClient(NetworkUtils.getDio(),
      baseUrl: "https://store.steampowered.com/");

  SteamGameDataResult steamGameDataResult = SteamGameDataResult();

  SteamGameState(this.url) {
    steamUri = Uri.tryParse(url) == null ? Uri() : Uri.tryParse(url)!;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    loadGameState();
  }

  Future<void> loadGameState() async {
    RegExp widgetAppIdRegExp = RegExp(r'(\d+)');
    var matchedList = widgetAppIdRegExp.allMatches(url).toList();
    log("Get matched list ${matchedList}");
    if (matchedList.isNotEmpty && matchedList.first.group(0) != null) {
      appId = matchedList.first.group(0)!;
      log("Get appId ${appId}");
    }

    if (appId.isNotEmpty) {
      setState(() {
        isLoading = true;
      });

      String languageCode = LanguageCode.code.englishName
          .replaceAll(RegExp(r"\(.*?\)"), "")
          .replaceAll(RegExp(r"\s"), "")
          .toLowerCase();
      // check the chinese version there

      client.getSteamGameResultByAppId(appId, languageCode).then((text) {
        Map<String, dynamic> appIdResultJson = jsonDecode(text);
        if (appIdResultJson.containsKey(appId)) {
          Map<String, dynamic> gameDataJson =
              jsonDecode(jsonEncode(appIdResultJson[appId]));
          log("Get Steam API JSON STRING : ${gameDataJson}");
          SteamGameDataResult gameDataResult =
              SteamGameDataResult.fromJson(gameDataJson);
          setState(() {
            steamGameDataResult = gameDataResult;
          });
          log("Steam data set successful ${gameDataResult} ${gameDataResult.data.name} ${gameDataResult.toJson().toString()}");
        }
      })
          //     .catchError((onError){
          //   log("ERROR occured when parsing");
          //   log(onError);
          // })
          .whenComplete(() {
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (steamGameDataResult.data.name.isNotEmpty) {
      return steamGamePreviewWidget;
    }
    return steamDefaultWidget;
  }

  Widget get steamDefaultWidget => InkWell(
        onTap: () {
          VibrationUtils.vibrateWithClickIfPossible();
          URLUtils.openURL(context, null, url, null, null);
        },
        child: Card(
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Container(
            padding: EdgeInsets.all(4.0),
            child: PlatformListTile(
                leading: Icon(
                  FontAwesomeIcons.steam,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
                title: Text(
                  url,
                  maxLines: 1,
                  style: TextStyle(
                      color:
                          Theme.of(context).colorScheme.onSecondaryContainer),
                )),
          ),
        ),
      );

  Widget get steamGamePreviewWidget => InkWell(
        onTap: () {
          // trigger something
          triggerDialog();
        },
        child: Card(
          elevation: isCupertino(context) ? 2 : 4,
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: EdgeInsets.all(0),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    FontAwesomeIcons.steam,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  title: Text(
                    steamGameDataResult.data.name,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  subtitle: Text(
                    steamGameDataResult.data.developers.join(", "),
                    style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimaryContainer
                            .withOpacity(0.5),
                        fontWeight: FontWeight.w300),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: steamGameDataResult.data.header_image,
                    //width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: Text(
                    HtmlUnescape()
                        .convert(steamGameDataResult.data.short_description),
                    maxLines: 3,
                    style: TextStyle(
                        height: 1.2,
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimaryContainer
                            .withOpacity(0.7),
                        fontSize: 12),
                  ),
                ),
                //SizedBox(height: 4,)
              ],
            ),
          ),
        ),
      );

  void triggerDialog() {
    VibrationUtils.vibrateWithClickIfPossible();
    showPlatformModalSheet(
        context: context,
        builder: (context) => SingleChildScrollView(
              child: Container(
                color: Theme.of(context).dialogBackgroundColor,
                width: double.infinity,
                padding: EdgeInsets.only(bottom: 16.0, left: 16, right: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SafeArea(child: Container()),
                    Row(
                      children: [
                        Expanded(
                            child: Text(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          steamGameDataResult.data.name.toUpperCase(),
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            //color: Theme.of(context).colorScheme.primary,
                            fontSize: 24,
                          ),
                        )),
                        PlatformIconButton(
                          icon: Icon(
                            AppPlatformIcons(context).clearCircleSolid,
                            size: 30,
                          ),
                          onPressed: () {
                            VibrationUtils.vibrateWithClickIfPossible();
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                    LayoutBuilder(builder: (context, constraint) {
                      log("Get constraint maxWidth ${constraint.maxWidth}");
                      return CarouselSlider(
                        options: CarouselOptions(
                            height: constraint.maxWidth > 960
                                ? constraint.maxWidth * 0.4
                                : 160,
                            aspectRatio: constraint.maxWidth > 960 ? 1 : 16 / 9,
                            viewportFraction: 0.8,
                            autoPlay: true),
                        items: steamGameDataResult.data.screenshots
                            .map((screenshot) => Container(
                                  margin: EdgeInsets.symmetric(horizontal: 4.0),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16.0),
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: CachedNetworkImageProvider(
                                            screenshot.path_full),
                                      )),
                                ))
                            .toList(),
                      );
                    }),

                    SizedBox(
                      height: 8,
                    ),
                    // SizedBox(
                    //   width: double.infinity,
                    //   child: Text(
                    //     steamGameDataResult.data.name.toUpperCase(),
                    //     textAlign: TextAlign.start,
                    //     style: TextStyle(
                    //       fontWeight: FontWeight.bold,
                    //       color: Theme.of(context).colorScheme.primary,
                    //       fontSize: 24,
                    //
                    //     ),
                    //   ),
                    // ),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: RichText(
                            text: TextSpan(
                                children: steamGameDataResult.data.categories
                                    .map((element) => WidgetSpan(
                                            child: Container(
                                          padding: EdgeInsets.all(4),
                                          margin: EdgeInsets.only(
                                              right: 8, bottom: 8),
                                          decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primaryContainer,
                                              borderRadius:
                                                  BorderRadius.circular(4.0)),
                                          child: Text(
                                            element.description,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer,
                                                fontSize: 12),
                                          ),
                                        )))
                                    .toList()),
                          ),
                        ),
                        // price
                        if (steamGameDataResult.data.is_free)
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                // padding: EdgeInsets.all(4.0),
                                // margin: EdgeInsets.only(bottom: 8.0),
                                //color: Theme.of(context).colorScheme.primary,
                                child: Text(
                                  S.of(context).gameFreeOfCharge.toUpperCase(),
                                  style: TextStyle(
                                      //color: Theme.of(context).colorScheme.onPrimary,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 26),
                                ),
                              ),
                            ],
                          )),
                        if (!steamGameDataResult.data.is_free &&
                            steamGameDataResult
                                .data.price_overview.currency.isNotEmpty)
                          Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (steamGameDataResult
                                      .data.release_date.coming_soon)
                                    comingSoonContainer,
                                  if (steamGameDataResult.data.price_overview
                                          .discount_percent !=
                                      0)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 2.0, horizontal: 8),
                                      margin: EdgeInsets.only(bottom: 8.0),
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      child: Text(
                                        "-${steamGameDataResult.data.price_overview.discount_percent}%",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary),
                                      ),
                                    ),
                                  Text(
                                    steamGameDataResult
                                        .data.price_overview.final_formatted,
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                      fontSize: 26,
                                    ),
                                  ),
                                  if (steamGameDataResult.data.price_overview
                                          .discount_percent !=
                                      0)
                                    Text(
                                      steamGameDataResult.data.price_overview
                                          .initial_formatted,
                                      style: TextStyle(
                                          fontSize: 14,
                                          decoration:
                                              TextDecoration.lineThrough),
                                    ),
                                  supportedPlatformRow,
                                ],
                              )),
                      ],
                    ),

                    SizedBox(
                      height: 8,
                    ),

                    Row(
                      children: [
                        Icon(
                          Icons.translate,
                          size: 16,
                        ),
                        SizedBox(
                          width: 16.0,
                        ),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            HtmlWidget(
                              steamGameDataResult.data.supported_languages,
                              textStyle: TextStyle(
                                  color: Theme.of(context).disabledColor,
                                  fontSize: 12),
                            ),
                            if (!steamGameDataResult.data.supported_languages
                                .contains(LanguageCode.code.nativeName
                                    .replaceAll(RegExp(r"\(.*?\)"), "")
                                    .replaceAll(RegExp(r"\s"), "")))
                              Container(
                                padding: EdgeInsets.all(4.0),
                                //margin: EdgeInsets.only(bottom: 8),
                                //width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .errorContainer,
                                    border: Border.all(
                                      style: BorderStyle.none,
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    )),
                                child: Text(
                                  S.of(context).gameLanguageNotSupported(
                                      LanguageCode.code.nativeName),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onErrorContainer,
                                      fontSize: 12),
                                ),
                              ),
                          ],
                        ))
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),

                    SizedBox(
                      width: double.infinity,
                      child: PlatformElevatedButton(
                        onPressed: () {
                          // https://store.steampowered.com/app/990080
                          String steamUrl =
                              "https://store.steampowered.com/app/${appId}";
                          VibrationUtils.vibrateWithClickIfPossible();
                          URLUtils.openURL(context, null, steamUrl, null, null);
                          Navigator.of(context).pop();
                        },
                        color: Theme.of(context).colorScheme.inverseSurface,
                        child: RichText(
                            text: TextSpan(
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.surface,
                                ),
                                children: [
                              WidgetSpan(
                                  child: Icon(
                                FontAwesomeIcons.steam,
                                size: 18,
                                color: Theme.of(context).colorScheme.surface,
                              )),
                              WidgetSpan(
                                  child: SizedBox(
                                width: 8.0,
                              )),
                              TextSpan(
                                text: S.of(context).openGameInSteam,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    fontSize: 18),
                              )
                            ])),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    // HtmlWidget(steamGameDataResult.data.about_the_game),
                    // Divider(),
                    HtmlWidget(steamGameDataResult.data.detailed_description),
                    SizedBox(
                      height: 16,
                    ),
                    Divider(),
                    PlatformIconButton(
                      icon: Icon(
                        AppPlatformIcons(context).clearAtEndSolid,
                        size: 30,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      onPressed: () {
                        VibrationUtils.vibrateWithClickIfPossible();
                        Navigator.of(context).pop();
                      },
                    ),
                    SizedBox(
                      height: 16,
                    )
                  ],
                ),
              ),
            ));
  }

  Widget get supportedPlatformRow => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (steamGameDataResult.data.platforms.windows)
            Container(
              margin: EdgeInsets.only(top: 8.0, left: 6.0),
              child: Icon(FontAwesomeIcons.windows, size: 14),
            ),
          if (steamGameDataResult.data.platforms.mac)
            Container(
              margin: EdgeInsets.only(top: 8.0, left: 6.0),
              child: Icon(FontAwesomeIcons.apple, size: 14),
            ),
          if (steamGameDataResult.data.platforms.linux)
            Container(
              margin: EdgeInsets.only(top: 8.0, left: 6.0),
              child: Icon(
                FontAwesomeIcons.linux,
                size: 14,
              ),
            )
        ],
      );

  Widget get comingSoonContainer => Container(
        padding: EdgeInsets.all(0),
        margin: EdgeInsets.only(bottom: 4.0),
        //color: Theme.of(context).colorScheme.primaryContainer,
        child: RichText(
          text: TextSpan(children: [
            //WidgetSpan(child: Icon(PlatformIcons(context).clockSolid, size: 14, color: Theme.of(context).colorScheme.onPrimaryContainer,)),
            //WidgetSpan(child: SizedBox(width: 4,)),
            TextSpan(
                text: steamGameDataResult.data.release_date.date,
                style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.normal,
                    fontStyle: FontStyle.normal,
                    decoration: TextDecoration.underline))
          ]),
        ),
      );
}
