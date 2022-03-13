import 'package:discuz_flutter/JsonResult/BaseVariableResult.dart';
import 'package:discuz_flutter/converter/SecondToDateTimeConverter.dart';
import 'package:discuz_flutter/converter/StringToBoolConverter.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/FavoriteForumInDatabase.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:discuz_flutter/converter/StringToIntConverter.dart';

import 'BaseResult.dart';
import 'ErrorResult.dart';


part 'FavoriteForumResult.g.dart';

@JsonSerializable()
class FavoriteForumResult extends BaseResult{

  @JsonKey(name: "Variables")
  late FavoriteForumVariables variables;

  FavoriteForumResult(){}

  factory FavoriteForumResult.fromJson(Map<String, dynamic> json) => _$FavoriteForumResultFromJson(json);
}

@JsonSerializable()
class FavoriteForumVariables extends BaseVariableResult{
  @JsonKey(name: "list")
  List<FavoriteForum> pmList = [];
  @StringToIntConverter()
  int count = 0;
  @JsonKey(name: "perpage")
  @StringToIntConverter()
  int perPage = 0;

  FavoriteForumVariables(){}
  factory FavoriteForumVariables.fromJson(Map<String, dynamic> json) => _$FavoriteForumVariablesFromJson(json);

}

@JsonSerializable()
class FavoriteForum{
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

  FavoriteForum();

  factory FavoriteForum.fromJson(Map<String, dynamic> json) => _$FavoriteForumFromJson(json);

  FavoriteForumInDatabase toDb(Discuz discuz){
    return FavoriteForumInDatabase(null,favId,uid, id,idType, title, description, DateTime.now(), discuz.id!);
  }
}

