import 'package:discuz_flutter/utility/steam_store_link.dart';
import 'package:discuz_flutter/utility/app_motion.dart';
import 'dart:convert';

import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:discuz_flutter/JsonResult/SteamGameDataResult.dart';
import 'package:discuz_flutter/client/SteamApiClient.dart';
import 'package:flutter/material.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:language_code/language_code.dart';

import '../generated/l10n.dart';
import '../utility/AppPlatformIcons.dart';
import '../utility/NetworkUtils.dart';
import '../utility/URLUtils.dart';
import '../utility/VibrationUtils.dart';

import 'cupertino_media_outline.dart';

class SteamGameWidget extends StatefulWidget {
  final String url;
  final SteamApiClient? client;

  const SteamGameWidget(this.url, {this.client, super.key});

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
    super.initState();

    loadGameState();
  }

  int _requestVersion = 0;

  @override
  void didUpdateWidget(covariant SteamGameWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      url = widget.url;
      steamUri = Uri.tryParse(url) ?? Uri();
      steamGameDataResult = SteamGameDataResult();
      loadGameState();
    }
  }

  Future<void> loadGameState() async {
    final version = ++_requestVersion;
    if (!mounted) return;
    appId = steamAppId(url) ?? '';
    setState(() => isLoading = appId.isNotEmpty);
    if (appId.isEmpty) return;
    final requestedAppId = appId;
    try {
      final languageCode = LanguageCode.code.englishName
          .replaceAll(RegExp(r"\(.*?\)"), "")
          .replaceAll(RegExp(r"\s"), "")
          .toLowerCase();
      final text = await (widget.client ?? client)
          .getSteamGameResultByAppId(requestedAppId, languageCode);
      if (!mounted || version != _requestVersion) return;
      final response = jsonDecode(text);
      final data = response is Map ? response[requestedAppId] : null;
      if (data is Map<String, dynamic>) {
        final result = SteamGameDataResult.fromJson(data);
        setState(() => steamGameDataResult = result);
      }
    } catch (error) {
      // Keep a usable link for unavailable games and malformed API responses.
      log('Unable to load Steam preview: $error');
    } finally {
      if (mounted && version == _requestVersion) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoMediaOutline(
      borderRadius: BorderRadius.circular(18),
      child: AppContentTransition(
        child: KeyedSubtree(
          key: ValueKey(
              '$url:${steamGameDataResult.success && steamGameDataResult.data.name.isNotEmpty}'),
          child: steamGameDataResult.success &&
                  steamGameDataResult.data.name.isNotEmpty
              ? steamGamePreviewWidget
              : steamDefaultWidget,
        ),
      ),
    );
  }

  Widget get steamDefaultWidget => InkWell(
        onTap: () {
          VibrationUtils.vibrateWithClickIfPossible();
          URLUtils.openURL(context, null, url, null, null);
        },
        child: PlatformCard(
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Container(
            padding: EdgeInsets.only(
                top: 4.0, left: 4.0, right: 4.0, bottom: isLoading ? 0 : 4.0),
            child: Column(
              children: [
                PlatformListTile(
                    leading: FaIcon(
                      FontAwesomeIcons.steam,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                    title: Text(
                      url,
                      maxLines: 1,
                      style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer),
                    )),
                isLoading
                    ? LinearProgressIndicator(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      );

  Widget get steamGamePreviewWidget => InkWell(
        onTap: () {
          // trigger something
          triggerDialog();
        },
        child: PlatformCard(
          elevation: isCupertino(context) ? 2 : 4,
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: EdgeInsets.all(0),
            child: Column(
              children: [
                PlatformListTile(
                  leading: FaIcon(
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
                    [
                      _contentTypeLabel(context),
                      ...steamGameDataResult.data.developers
                    ].join(' · '),
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w300),
                  ),
                ),
                if (steamGameDataResult.data.header_image.isNotEmpty)
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
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 12),
                  ),
                ),
                //SizedBox(height: 4,)
              ],
            ),
          ),
        ),
      );

  double _steamSheetHorizontalPadding(BuildContext context) {
    final viewportWidth = MediaQuery.sizeOf(context).width;
    if (viewportWidth < 650) return 0;
    final preferredWidth = viewportWidth * 0.72;
    final dialogWidth = preferredWidth > 760 ? 760.0 : preferredWidth;
    return (viewportWidth - dialogWidth) / 2;
  }

  void triggerDialog() {
    VibrationUtils.vibrateWithClickIfPossible();
    showPlatformModalSheet(
        context: context,
        builder: (context) => SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: _steamSheetHorizontalPadding(context),
              ),
              child: Container(
                //alignment: Alignment.centerRight,
                color: usesLiquidGlass(context)
                    ? Colors.transparent
                    : Theme.of(context).colorScheme.surface,
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
                    if (steamGameDataResult.data.screenshots.isNotEmpty)
                      LayoutBuilder(builder: (context, constraint) {
                        log("Get constraint maxWidth ${constraint.maxWidth}");
                        return CarouselSlider(
                          options: CarouselOptions(
                              height: constraint.maxWidth > 960
                                  ? constraint.maxWidth * 0.4
                                  : 160,
                              aspectRatio:
                                  constraint.maxWidth > 960 ? 1 : 16 / 9,
                              viewportFraction: 0.8,
                              autoPlay: true),
                          items: steamGameDataResult.data.screenshots
                              .map((screenshot) => Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 4.0),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
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
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          Chip(label: Text(_contentTypeLabel(context))),
                          for (final category
                              in steamGameDataResult.data.categories)
                            Chip(label: Text(category.description)),
                        ],
                      ),
                    ),
                    if (steamGameDataResult.data.parentAppId != null &&
                        steamGameDataResult.data.parentAppId! > 0)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: PlatformTextButton(
                          onPressed: () => URLUtils.openURL(
                              context,
                              null,
                              'https://store.steampowered.com/app/${steamGameDataResult.data.parentAppId}/',
                              null,
                              null),
                          child: Text(S.of(context).steamParentApp(
                              steamGameDataResult.data.parentName.isNotEmpty
                                  ? steamGameDataResult.data.parentName
                                  : '${steamGameDataResult.data.parentAppId}')),
                        ),
                      ),
                    _priceAndAvailability(context),
                    const SizedBox(height: 8),
                    if (!steamGameDataResult.data.isSoundtrack &&
                        steamGameDataResult.data.supported_languages.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            PlatformIcons(context).translate,
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
                                  child: FaIcon(
                                FontAwesomeIcons.steam,
                                size: 18,
                                color: Theme.of(context).colorScheme.surface,
                              )),
                              WidgetSpan(
                                  child: SizedBox(
                                width: 12,
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

  String _contentTypeLabel(BuildContext context) {
    final labels = S.of(context);
    return switch (steamGameDataResult.data.type.toLowerCase()) {
      'game' => labels.steamTypeGame,
      'dlc' => labels.steamTypeDlc,
      'music' || 'soundtrack' => labels.steamTypeMusic,
      'demo' => labels.steamTypeDemo,
      'advertising' ||
      'mod' ||
      'tool' ||
      'application' ||
      'software' =>
        labels.steamTypeSoftware,
      'video' || 'movie' || 'episode' || 'series' => labels.steamTypeVideo,
      _ => labels.steamTypeOther,
    };
  }

  Widget _priceAndAvailability(BuildContext context) {
    final data = steamGameDataResult.data;
    final price = data.price_overview;
    final colors = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (data.release_date.coming_soon)
            Text(S.of(context).steamComingSoon),
          if (data.release_date.date.isNotEmpty) Text(data.release_date.date),
          if (!data.is_free && data.hasPrice && price.discount_percent > 0)
            Text('-${price.discount_percent}%',
                style: TextStyle(color: colors.primary)),
          Text(
            data.is_free
                ? S.of(context).gameFreeOfCharge
                : data.hasPrice
                    ? price.final_formatted
                    : S.of(context).steamPriceUnavailable,
            textAlign: TextAlign.end,
            style: data.is_free || data.hasPrice
                ? Theme.of(context).textTheme.headlineSmall
                : Theme.of(context).textTheme.bodyMedium,
          ),
          if (!data.is_free &&
              data.hasPrice &&
              price.discount_percent > 0 &&
              price.initial_formatted.isNotEmpty)
            Text(price.initial_formatted,
                style: const TextStyle(decoration: TextDecoration.lineThrough)),
          if (!data.isSoundtrack && data.hasPlatforms) supportedPlatformRow,
        ],
      ),
    );
  }

  Widget get supportedPlatformRow => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (steamGameDataResult.data.platforms.windows)
            Container(
              margin: EdgeInsets.only(top: 8.0, left: 6.0),
              child: FaIcon(FontAwesomeIcons.windows, size: 14),
            ),
          if (steamGameDataResult.data.platforms.mac)
            Container(
              margin: EdgeInsets.only(top: 8.0, left: 6.0),
              child: FaIcon(FontAwesomeIcons.apple, size: 14),
            ),
          if (steamGameDataResult.data.platforms.linux)
            Container(
              margin: EdgeInsets.only(top: 8.0, left: 6.0),
              child: FaIcon(
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
