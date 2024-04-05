import 'package:discuz_flutter/JsonResult/BaseVariableResult.dart';
import 'package:discuz_flutter/converter/SecondToDateTimeConverter.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/FavoriteThreadInDatabase.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:discuz_flutter/converter/StringToIntConverter.dart';

import 'BaseResult.dart';
import 'ErrorResult.dart';


part 'FavoriteThreadResult.g.dart';

@JsonSerializable()
class FavoriteThreadResult extends BaseResult{

  @JsonKey(name: "Variables")
  late FavoriteThreadVariables variables;

  FavoriteThreadResult(){}

  factory FavoriteThreadResult.fromJson(Map<String, dynamic> json) => _$FavoriteThreadResultFromJson(json);
}

@JsonSerializable()
class FavoriteThreadVariables extends BaseVariableResult{
  @JsonKey(name: "list")
  List<FavoriteThread> pmList = [];
  @StringToIntConverter()
  int count = 0;
  @JsonKey(name: "perpage")
  @StringToIntConverter()
  int perPage = 0;

  FavoriteThreadVariables(){}
  factory FavoriteThreadVariables.fromJson(Map<String, dynamic> json) => _$FavoriteThreadVariablesFromJson(json);

}

@JsonSerializable()
class FavoriteThread{
  @StringToIntConverter()
  @JsonKey(name: "favid")
  int favId = 0;
  @StringToIntConverter()
  @JsonKey(name: "uid")
  int uid = 0;
  @StringToIntConverter()
  @JsonKey(name: "id")
  int id = 0;
  @JsonKey(name: "idtype")
  String idType = "";
  String title = "";
  String description = "";
  @JsonKey(name: "replies")
  @StringToIntConverter()
  int replies = 0;
  String author = "";
  @JsonKey(name: "dateline")
  @SecondToDateTimeConverter()
  DateTime publishAt = DateTime.now();

  FavoriteThread();

  factory FavoriteThread.fromJson(Map<String, dynamic> json) => _$FavoriteThreadFromJson(json);

  FavoriteThreadInDatabase toDb(Discuz discuz){
    return FavoriteThreadInDatabase(favId, uid, id, idType, uid, title, description, author, replies, publishAt, discuz);
  }
}

