import 'package:discuz_flutter/entity/HotThread.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:discuz_flutter/JsonResult/BaseVariableResult.dart';
import 'package:discuz_flutter/converter/StringToIntConverter.dart';
import 'package:discuz_flutter/entity/Post.dart';


import 'BaseResult.dart';
import 'ErrorResult.dart';


part "HotThreadResult.g.dart";

@JsonSerializable()
class HotThreadResult extends BaseResult{

  @JsonKey(name: "Variables")
  HotThreadVariables variables = HotThreadVariables();

  HotThreadResult();

  factory HotThreadResult.fromJson(Map<String, dynamic> json) => _$HotThreadResultFromJson(json);
  Map<String, dynamic> toJson() => _$HotThreadResultToJson(this);

}

@JsonSerializable()
class HotThreadVariables extends BaseVariableResult{
  @JsonKey(name: "perpage")
  @StringToIntConverter()
  int perPage = 0;
  @JsonKey(name: "data",defaultValue: [])
  List<HotThread> hotThreadList = [];


  HotThreadVariables();

  factory HotThreadVariables.fromJson(Map<String, dynamic> json) => _$HotThreadVariablesFromJson(json);
  Map<String, dynamic> toJson() => _$HotThreadVariablesToJson(this);

}

