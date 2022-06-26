import 'package:discuz_flutter/JsonResult/BaseVariableResult.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:discuz_flutter/converter/StringToIntConverter.dart';

import 'BaseResult.dart';
import 'ErrorResult.dart';


part 'CaptchaResult.g.dart';

@JsonSerializable(disallowUnrecognizedKeys: false, ignoreUnannotated:true)
class CaptchaResult extends BaseResult{

  @JsonKey(name: "Variables")
  CaptchaVariable variables = CaptchaVariable();

  CaptchaResult();

  factory CaptchaResult.fromJson(Map<String, dynamic> json) => _$CaptchaResultFromJson(json);
}

@JsonSerializable(disallowUnrecognizedKeys: false, ignoreUnannotated:true)
class CaptchaVariable extends BaseVariableResult{
  @JsonKey(name:"sechash",defaultValue: "")
  String secHash = "";
  @JsonKey(name:"seccode",defaultValue: "")
  String secCodeURL = "";

  CaptchaVariable();

  factory CaptchaVariable.fromJson(Map<String, dynamic> json) => _$CaptchaVariableFromJson(json);
}