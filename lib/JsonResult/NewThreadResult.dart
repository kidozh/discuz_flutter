import 'package:discuz_flutter/entity/NewThread.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:discuz_flutter/JsonResult/BaseVariableResult.dart';
import 'package:discuz_flutter/converter/StringToIntConverter.dart';
import 'package:discuz_flutter/entity/Post.dart';


import 'BaseResult.dart';
import 'ErrorResult.dart';


part "NewThreadResult.g.dart";

@JsonSerializable()
class NewThreadResult extends BaseResult{

  @JsonKey(name: "Variables")
  NewThreadVariables variables = NewThreadVariables();

  NewThreadResult();

  factory NewThreadResult.fromJson(Map<String, dynamic> json) => _$NewThreadResultFromJson(json);
  Map<String, dynamic> toJson() => _$NewThreadResultToJson(this);

}

@JsonSerializable()
class NewThreadVariables extends BaseVariableResult{
  @JsonKey(name: "data",defaultValue: [])
  List<NewThread> newThreadList = [];


  NewThreadVariables();

  factory NewThreadVariables.fromJson(Map<String, dynamic> json) => _$NewThreadVariablesFromJson(json);
  Map<String, dynamic> toJson() => _$NewThreadVariablesToJson(this);

}

