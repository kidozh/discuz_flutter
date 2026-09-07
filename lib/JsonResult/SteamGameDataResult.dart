import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'SteamGameDataResult.g.dart';

@JsonSerializable()
class SteamGameDataResult {
  bool success = false;
  SteamGameData data = SteamGameData();

  SteamGameDataResult();

  factory SteamGameDataResult.fromJson(Map<String, dynamic> json) {
    if (json['success'] != true || json['data'] is! Map<String, dynamic>) {
      return SteamGameDataResult();
    }
    return _$SteamGameDataResultFromJson(json);
  }
  Map<String, dynamic> toJson() => _$SteamGameDataResultToJson(this);
}

@JsonSerializable()
class SteamGameData {
  String type = "", name = "";
  int steam_appid = 0;
  @JsonKey(defaultValue: false)
  bool is_free = false;
  @JsonKey(name: "dlc", defaultValue: [])
  List<int> dlc_app_list = [];
  String detailed_description = "", about_the_game = "", short_description = "";
  @JsonKey(defaultValue: "")
  String supported_languages = "";
  String header_image = "", capsule_image = "", capsule_imagev5 = "";
  @JsonKey(defaultValue: "")
  String legal_notice = "";
  List<String> developers = [], publishers = [];
  @JsonKey(required: false, defaultValue: PriceOverview.new)
  PriceOverview price_overview = PriceOverview();
  AvailablePlatform platforms = AvailablePlatform();
  @JsonKey(defaultValue: [])
  List<GameCategory> categories = [];
  @JsonKey(required: false, defaultValue: [])
  List<GameScreenshot> screenshots = [];
  @JsonKey(required: false, defaultValue: [])
  List<GameMovie> movies = [];

  GameReleaseDate release_date = GameReleaseDate();
  GameSupportInformation support_info = GameSupportInformation();

  String background = "", background_raw = "";

  SteamGameData();

  Map<String, dynamic> _fullgame = {};
  int? get parentAppId => int.tryParse('${_fullgame['appid'] ?? ''}');
  String get parentName => _fullgame['name'] is String ? _fullgame['name'] : '';
  bool get isSoundtrack =>
      const ['music', 'soundtrack'].contains(type.toLowerCase());
  bool get hasPrice => price_overview.final_formatted.trim().isNotEmpty;
  bool get hasPlatforms =>
      platforms.windows || platforms.mac || platforms.linux;

  factory SteamGameData.fromJson(Map<String, dynamic> json) {
    final data = _$SteamGameDataFromJson(_steamDefaults(
      jsonDecode(jsonEncode(SteamGameData().toJson())) as Map<String, dynamic>,
      json,
    ));
    if (json['fullgame'] is Map<String, dynamic>) {
      data._fullgame = json['fullgame'] as Map<String, dynamic>;
    }
    return data;
  }
  Map<String, dynamic> toJson() => {
        ..._$SteamGameDataToJson(this),
        if (_fullgame.isNotEmpty) 'fullgame': _fullgame,
      };
}

@JsonSerializable()
class PriceOverview {
  String currency = "";
  // should divide by 100
  @JsonKey(name: "initial")
  int initial_price = 0;
  @JsonKey(name: "final")
  int final_price = 0;
  int discount_percent = 0;
  String initial_formatted = "", final_formatted = "";

  PriceOverview();

  factory PriceOverview.fromJson(Map<String, dynamic> json) =>
      _$PriceOverviewFromJson(json);
  Map<String, dynamic> toJson() => _$PriceOverviewToJson(this);
}

@JsonSerializable()
class AvailablePlatform {
  bool windows = false, mac = false, linux = false;

  AvailablePlatform();

  factory AvailablePlatform.fromJson(Map<String, dynamic> json) =>
      _$AvailablePlatformFromJson(json);
  Map<String, dynamic> toJson() => _$AvailablePlatformToJson(this);
}

@JsonSerializable()
class GameCategory {
  int id = 0;
  String description = "";

  GameCategory();

  factory GameCategory.fromJson(Map<String, dynamic> json) =>
      _$GameCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$GameCategoryToJson(this);
}

@JsonSerializable()
class GameScreenshot {
  int id = 0;
  String path_thumbnail = "", path_full = "";

  GameScreenshot();

  factory GameScreenshot.fromJson(Map<String, dynamic> json) =>
      _$GameScreenshotFromJson(json);
  Map<String, dynamic> toJson() => _$GameScreenshotToJson(this);
}

@JsonSerializable()
class GameMovie {
  int id = 0;
  String name = "";
  String thumbnail = "";

  GameMoviesFormat? webm = GameMoviesFormat();
  GameMoviesFormat? mp4 = GameMoviesFormat();
  bool highlight = true;

  GameMovie();

  factory GameMovie.fromJson(Map<String, dynamic> json) =>
      _$GameMovieFromJson(json);
  Map<String, dynamic> toJson() => _$GameMovieToJson(this);
}

@JsonSerializable()
class GameMoviesFormat {
  @JsonKey(name: "480")
  String resolution_480p = "";
  @JsonKey(name: "max")
  String resolution_max = "";

  GameMoviesFormat();

  factory GameMoviesFormat.fromJson(Map<String, dynamic> json) =>
      _$GameMoviesFormatFromJson(json);
  Map<String, dynamic> toJson() => _$GameMoviesFormatToJson(this);
}

@JsonSerializable()
class GameReleaseDate {
  bool coming_soon = false;
  String date = "";

  GameReleaseDate();

  factory GameReleaseDate.fromJson(Map<String, dynamic> json) =>
      _$GameReleaseDateFromJson(json);
  Map<String, dynamic> toJson() => _$GameReleaseDateToJson(this);
}

@JsonSerializable()
class GameSupportInformation {
  String url = "", email = "";

  GameSupportInformation();

  factory GameSupportInformation.fromJson(Map<String, dynamic> json) =>
      _$GameSupportInformationFromJson(json);
  Map<String, dynamic> toJson() => _$GameSupportInformationToJson(this);
}

// Optional fields vary between games, DLC, demos and unavailable store regions.
Map<String, dynamic> _steamDefaults(
  Map<String, dynamic> defaults,
  Map<String, dynamic> values,
) {
  final result = Map<String, dynamic>.from(defaults);
  for (final entry in values.entries) {
    if (entry.value == null) continue;
    final fallback = defaults[entry.key];
    result[entry.key] =
        fallback is Map<String, dynamic> && entry.value is Map<String, dynamic>
            ? _steamDefaults(fallback, entry.value as Map<String, dynamic>)
            : entry.value;
  }
  return result;
}
