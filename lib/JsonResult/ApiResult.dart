import 'package:discuz_flutter/JsonResult/BaseVariableResult.dart';
import 'package:json_annotation/json_annotation.dart';

import '../utility/discuz_json.dart';
import 'BaseResult.dart';
import 'ErrorResult.dart';

part 'ApiResult.g.dart';

@JsonSerializable(disallowUnrecognizedKeys: false, ignoreUnannotated: true)
class ApiResult extends BaseResult {
  @JsonKey(name: "Variables")
  late BaseVariableResult variables;

  int postedPid = 0;
  int postedTid = 0;

  ApiResult();

  factory ApiResult.fromJson(Map<String, dynamic> json) {
    final variables = discuzMap(json['Variables']);
    return _$ApiResultFromJson(json)
      ..postedPid = discuzInt(variables['pid'])
      ..postedTid = discuzInt(variables['tid']);
  }
}
