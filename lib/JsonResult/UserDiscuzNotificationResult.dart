import 'package:discuz_flutter/entity/DiscuzNotification.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:discuz_flutter/JsonResult/BaseVariableResult.dart';
import 'package:discuz_flutter/converter/StringToIntConverter.dart';
import 'package:discuz_flutter/entity/Post.dart';


import 'BaseResult.dart';
import 'ErrorResult.dart';


part "UserDiscuzNotificationResult.g.dart";

@JsonSerializable()
class UserDiscuzNotificationResult extends BaseResult{

  @JsonKey(name: "Variables")
  DiscuzNotificationVariables variables = DiscuzNotificationVariables();

  UserDiscuzNotificationResult();

  factory UserDiscuzNotificationResult.fromJson(Map<String, dynamic> json) => _$UserDiscuzNotificationResultFromJson(json);
  Map<String, dynamic> toJson() => _$UserDiscuzNotificationResultToJson(this);

}

@JsonSerializable(ignoreUnannotated: true)
class DiscuzNotificationVariables extends BaseVariableResult{


  @JsonKey(name:"list",defaultValue: [])
  List<DiscuzNotification> notificationList = [];
  @StringToIntConverter()
  int count = 0;
  int perpage = 0;
  @StringToIntConverter()
  int page = 0;


  DiscuzNotificationVariables();

  factory DiscuzNotificationVariables.fromJson(Map<String, dynamic> json) => _$DiscuzNotificationVariablesFromJson(json);
  Map<String, dynamic> toJson() => _$DiscuzNotificationVariablesToJson(this);

}

