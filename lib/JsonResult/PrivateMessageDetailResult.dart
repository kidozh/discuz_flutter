import 'package:discuz_flutter/JsonResult/BaseVariableResult.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:discuz_flutter/converter/StringToIntConverter.dart';

import 'BaseResult.dart';
import 'ErrorResult.dart';


part 'PrivateMessageDetailResult.g.dart';

@JsonSerializable()
class PrivateMessageDetailResult extends BaseResult{

  @JsonKey(name: "Variables")
  late PrivateMessageDetailVariables variables;

  PrivateMessageDetailResult(){}

  factory PrivateMessageDetailResult.fromJson(Map<String, dynamic> json) => _$PrivateMessageDetailResultFromJson(json);
}

@JsonSerializable()
class PrivateMessageDetailVariables extends BaseVariableResult{
  @JsonKey(name: "list")
  List<PrivateMessageDetail> pmList = [];
  @StringToIntConverter()
  int count = 0;
  @JsonKey(name: "perpage")
  @StringToIntConverter()
  int perPage = 0;
  @StringToIntConverter()
  int page = 1;
  @JsonKey(name: "pmid")
  @StringToIntConverter()
  int pmId = 0;

  PrivateMessageDetailVariables(){}
  factory PrivateMessageDetailVariables.fromJson(Map<String, dynamic> json) => _$PrivateMessageDetailVariablesFromJson(json);

}

@JsonSerializable()
class PrivateMessageDetail{
  @StringToIntConverter()
  int plid = 0;
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
  String message = "";
  @JsonKey(name: "vdateline")
  String dateTimeString = "";

  get readableString => dateTimeString.replaceAll("&nbsp;", "");

  PrivateMessageDetail();

  factory PrivateMessageDetail.fromJson(Map<String, dynamic> json) => _$PrivateMessageDetailFromJson(json);
}

