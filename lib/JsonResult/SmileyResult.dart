import 'dart:convert';

import 'package:discuz_flutter/JsonResult/BaseVariableResult.dart';
import 'package:discuz_flutter/entity/Smiley.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:discuz_flutter/converter/StringToIntConverter.dart';

import 'BaseResult.dart';
import 'ErrorResult.dart';


part 'SmileyResult.g.dart';

@JsonSerializable()
class SmileyResult extends BaseResult{

  @JsonKey(name: "Variables")
  late SmileyVariables variables;

  SmileyResult(){}

  factory SmileyResult.fromJson(Map<String, dynamic> json) => _$SmileyResultFromJson(json);
}

@JsonSerializable()
class SmileyVariables extends BaseVariableResult{
  List<List<Smiley>> smilies = [];

  SmileyVariables(){}
  factory SmileyVariables.fromJson(Map<String, dynamic> json) => _$SmileyVariablesFromJson(json);

}



