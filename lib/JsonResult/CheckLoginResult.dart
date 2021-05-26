import 'package:discuz_flutter/JsonResult/BaseVariableResult.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:discuz_flutter/converter/StringToIntConverter.dart';

import 'BaseResult.dart';
import 'ErrorResult.dart';


part 'CheckLoginResult.g.dart';

@JsonSerializable(disallowUnrecognizedKeys: false, ignoreUnannotated:true)
class CheckLoginResult extends BaseResult{

  @JsonKey(name: "Variables")
  late CheckLoginVariables variables;

  CheckLoginResult();

  factory CheckLoginResult.fromJson(Map<String, dynamic> json) => _$CheckLoginResultFromJson(json);
}

@JsonSerializable(ignoreUnannotated: true)
class CheckLoginVariables extends BaseVariableResult{
  CheckLoginVariables();
  factory CheckLoginVariables.fromJson(Map<String, dynamic> json) => _$CheckLoginVariablesFromJson(json);

}