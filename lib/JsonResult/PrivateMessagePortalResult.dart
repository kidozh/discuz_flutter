import 'package:discuz_flutter/JsonResult/BaseVariableResult.dart';
import 'package:discuz_flutter/converter/StringToBoolConverter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:discuz_flutter/converter/StringToIntConverter.dart';

import 'BaseResult.dart';
import 'ErrorResult.dart';


part 'PrivateMessagePortalResult.g.dart';

@JsonSerializable()
class PrivateMessagePortalResult extends BaseResult{

  @JsonKey(name: "Variables")
  late PrivateMessagePortalVariables variables;

  PrivateMessagePortalResult(){}

  factory PrivateMessagePortalResult.fromJson(Map<String, dynamic> json) => _$PrivateMessagePortalResultFromJson(json);
}

@JsonSerializable()
class PrivateMessagePortalVariables extends BaseVariableResult{
  @JsonKey(name: "list")
  List<PrivateMessagePortal> pmList = [];
  @StringToIntConverter()
  int count = 0;
  @JsonKey(name: "perpage")
  @StringToIntConverter()
  int perPage = 0;
  @StringToIntConverter()
  int page = 1;

  PrivateMessagePortalVariables(){}
  factory PrivateMessagePortalVariables.fromJson(Map<String, dynamic> json) => _$PrivateMessagePortalVariablesFromJson(json);

}

@JsonSerializable()
class PrivateMessagePortal{
  @StringToIntConverter()
  int plid = 0;
  @JsonKey(name: "isnew")
  @StringToBoolConverter()
  bool isNew = false;
  String subject = "";
  @JsonKey(name: "touid")
  @StringToIntConverter()
  int toUid = 0;
  @JsonKey(name: "pmid")
  @StringToIntConverter()
  int pmId = 0;
  @JsonKey(name: "msgfromid")
  @StringToIntConverter()
  int msgFromId = 0;
  @JsonKey(name: "msgfrom")
  String msgFromName = "";
  @JsonKey(defaultValue: "")
  String message = "";
  @JsonKey(name: "tousername")
  String toUserName = "";
  @JsonKey(name: "vdateline")
  String dateTimeString = "";

  get readableString => dateTimeString.replaceAll("&nbsp;", "");

  PrivateMessagePortal();

  factory PrivateMessagePortal.fromJson(Map<String, dynamic> json) => _$PrivateMessagePortalFromJson(json);
}

