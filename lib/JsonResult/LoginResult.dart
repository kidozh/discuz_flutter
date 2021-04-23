import 'package:discuz_flutter/JsonResult/BaseVariableResult.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:discuz_flutter/converter/StringToIntConverter.dart';

import 'BaseResult.dart';
import 'ErrorResult.dart';


part 'LoginResult.g.dart';

@JsonSerializable(disallowUnrecognizedKeys: false, ignoreUnannotated:true)
class LoginResult extends BaseResult{

  @JsonKey(name: "Variables")
  late LoginVariables loginVariables;

  LoginResult(){}

  factory LoginResult.fromJson(Map<String, dynamic> json) => _$LoginResultFromJson(json);
}

@JsonSerializable(ignoreUnannotated: true)
class LoginVariables extends BaseVariableResult{
  String loginUrl = "";
  LoginVariables(){}
  factory LoginVariables.fromJson(Map<String, dynamic> json) => _$LoginVariablesFromJson(json);

}