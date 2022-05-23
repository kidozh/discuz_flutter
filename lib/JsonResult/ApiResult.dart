import 'package:discuz_flutter/JsonResult/BaseVariableResult.dart';
import 'package:json_annotation/json_annotation.dart';

import 'BaseResult.dart';
import 'ErrorResult.dart';


part 'ApiResult.g.dart';

@JsonSerializable(disallowUnrecognizedKeys: false, ignoreUnannotated:true)
class ApiResult extends BaseResult{

  @JsonKey(name: "Variables")
  late BaseVariableResult variables;

  ApiResult();

  factory ApiResult.fromJson(Map<String, dynamic> json) => _$ApiResultFromJson(json);
}

