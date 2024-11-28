// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'SteamGameDataResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SteamGameDataResult _$SteamGameDataResultFromJson(Map<String, dynamic> json) =>
    SteamGameDataResult()
      ..success = json['success'] as bool
      ..data = SteamGameData.fromJson(json['data'] as Map<String, dynamic>);

Map<String, dynamic> _$SteamGameDataResultToJson(
        SteamGameDataResult instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data,
    };

SteamGameData _$SteamGameDataFromJson(Map<String, dynamic> json) =>
    SteamGameData()
      ..type = json['type'] as String
      ..name = json['name'] as String
      ..steam_appid = (json['steam_appid'] as num).toInt()
      ..is_free = json['is_free'] as bool? ?? false
      ..dlc_app_list = (json['dlc'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          []
      ..detailed_description = json['detailed_description'] as String
      ..about_the_game = json['about_the_game'] as String
      ..short_description = json['short_description'] as String
      ..supported_languages = json['supported_languages'] as String
      ..header_image = json['header_image'] as String
      ..capsule_image = json['capsule_image'] as String
      ..capsule_imagev5 = json['capsule_imagev5'] as String
      ..legal_notice = json['legal_notice'] as String? ?? ''
      ..developers =
          (json['developers'] as List<dynamic>).map((e) => e as String).toList()
      ..publishers =
          (json['publishers'] as List<dynamic>).map((e) => e as String).toList()
      ..price_overview = json['price_overview'] == null
          ? PriceOverview()
          : PriceOverview.fromJson(
              json['price_overview'] as Map<String, dynamic>)
      ..platforms =
          AvailablePlatform.fromJson(json['platforms'] as Map<String, dynamic>)
      ..categories = (json['categories'] as List<dynamic>)
          .map((e) => GameCategory.fromJson(e as Map<String, dynamic>))
          .toList()
      ..screenshots = (json['screenshots'] as List<dynamic>)
          .map((e) => GameScreenshot.fromJson(e as Map<String, dynamic>))
          .toList()
      ..movies = (json['movies'] as List<dynamic>?)
              ?.map((e) => GameMovie.fromJson(e as Map<String, dynamic>))
              .toList() ??
          []
      ..release_date =
          GameReleaseDate.fromJson(json['release_date'] as Map<String, dynamic>)
      ..support_info = GameSupportInformation.fromJson(
          json['support_info'] as Map<String, dynamic>)
      ..background = json['background'] as String
      ..background_raw = json['background_raw'] as String;

Map<String, dynamic> _$SteamGameDataToJson(SteamGameData instance) =>
    <String, dynamic>{
      'type': instance.type,
      'name': instance.name,
      'steam_appid': instance.steam_appid,
      'is_free': instance.is_free,
      'dlc': instance.dlc_app_list,
      'detailed_description': instance.detailed_description,
      'about_the_game': instance.about_the_game,
      'short_description': instance.short_description,
      'supported_languages': instance.supported_languages,
      'header_image': instance.header_image,
      'capsule_image': instance.capsule_image,
      'capsule_imagev5': instance.capsule_imagev5,
      'legal_notice': instance.legal_notice,
      'developers': instance.developers,
      'publishers': instance.publishers,
      'price_overview': instance.price_overview,
      'platforms': instance.platforms,
      'categories': instance.categories,
      'screenshots': instance.screenshots,
      'movies': instance.movies,
      'release_date': instance.release_date,
      'support_info': instance.support_info,
      'background': instance.background,
      'background_raw': instance.background_raw,
    };

PriceOverview _$PriceOverviewFromJson(Map<String, dynamic> json) =>
    PriceOverview()
      ..currency = json['currency'] as String
      ..initial_price = (json['initial'] as num).toInt()
      ..final_price = (json['final'] as num).toInt()
      ..discount_percent = (json['discount_percent'] as num).toInt()
      ..initial_formatted = json['initial_formatted'] as String
      ..final_formatted = json['final_formatted'] as String;

Map<String, dynamic> _$PriceOverviewToJson(PriceOverview instance) =>
    <String, dynamic>{
      'currency': instance.currency,
      'initial': instance.initial_price,
      'final': instance.final_price,
      'discount_percent': instance.discount_percent,
      'initial_formatted': instance.initial_formatted,
      'final_formatted': instance.final_formatted,
    };

AvailablePlatform _$AvailablePlatformFromJson(Map<String, dynamic> json) =>
    AvailablePlatform()
      ..windows = json['windows'] as bool
      ..mac = json['mac'] as bool
      ..linux = json['linux'] as bool;

Map<String, dynamic> _$AvailablePlatformToJson(AvailablePlatform instance) =>
    <String, dynamic>{
      'windows': instance.windows,
      'mac': instance.mac,
      'linux': instance.linux,
    };

GameCategory _$GameCategoryFromJson(Map<String, dynamic> json) => GameCategory()
  ..id = (json['id'] as num).toInt()
  ..description = json['description'] as String;

Map<String, dynamic> _$GameCategoryToJson(GameCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
    };

GameScreenshot _$GameScreenshotFromJson(Map<String, dynamic> json) =>
    GameScreenshot()
      ..id = (json['id'] as num).toInt()
      ..path_thumbnail = json['path_thumbnail'] as String
      ..path_full = json['path_full'] as String;

Map<String, dynamic> _$GameScreenshotToJson(GameScreenshot instance) =>
    <String, dynamic>{
      'id': instance.id,
      'path_thumbnail': instance.path_thumbnail,
      'path_full': instance.path_full,
    };

GameMovie _$GameMovieFromJson(Map<String, dynamic> json) => GameMovie()
  ..id = (json['id'] as num).toInt()
  ..name = json['name'] as String
  ..thumbnail = json['thumbnail'] as String
  ..webm = GameMoviesFormat.fromJson(json['webm'] as Map<String, dynamic>)
  ..mp4 = GameMoviesFormat.fromJson(json['mp4'] as Map<String, dynamic>)
  ..highlight = json['highlight'] as bool;

Map<String, dynamic> _$GameMovieToJson(GameMovie instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'thumbnail': instance.thumbnail,
      'webm': instance.webm,
      'mp4': instance.mp4,
      'highlight': instance.highlight,
    };

GameMoviesFormat _$GameMoviesFormatFromJson(Map<String, dynamic> json) =>
    GameMoviesFormat()
      ..resolution_480p = json['480'] as String
      ..resolution_max = json['max'] as String;

Map<String, dynamic> _$GameMoviesFormatToJson(GameMoviesFormat instance) =>
    <String, dynamic>{
      '480': instance.resolution_480p,
      'max': instance.resolution_max,
    };

GameReleaseDate _$GameReleaseDateFromJson(Map<String, dynamic> json) =>
    GameReleaseDate()
      ..coming_soon = json['coming_soon'] as bool
      ..date = json['date'] as String;

Map<String, dynamic> _$GameReleaseDateToJson(GameReleaseDate instance) =>
    <String, dynamic>{
      'coming_soon': instance.coming_soon,
      'date': instance.date,
    };

GameSupportInformation _$GameSupportInformationFromJson(
        Map<String, dynamic> json) =>
    GameSupportInformation()
      ..url = json['url'] as String
      ..email = json['email'] as String;

Map<String, dynamic> _$GameSupportInformationToJson(
        GameSupportInformation instance) =>
    <String, dynamic>{
      'url': instance.url,
      'email': instance.email,
    };
