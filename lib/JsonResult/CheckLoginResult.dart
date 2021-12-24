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
  Map<String, dynamic> toJson() => _$CheckLoginResultToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

@JsonSerializable(ignoreUnannotated: true)
class CheckLoginVariables extends BaseVariableResult{
  CheckLoginVariables();
  factory CheckLoginVariables.fromJson(Map<String, dynamic> json) => _$CheckLoginVariablesFromJson(json);
  Map<String, dynamic> toJson() => _$CheckLoginVariablesToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}