import 'package:discuz_flutter/JsonResult/BaseVariableResult.dart';
import 'package:discuz_flutter/converter/StringToBoolConverter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:discuz_flutter/converter/StringToIntConverter.dart';

import 'BaseResult.dart';
import 'ErrorResult.dart';


part 'CheckPostResult.g.dart';

@JsonSerializable(disallowUnrecognizedKeys: false, ignoreUnannotated:true)
class CheckPostResult extends BaseResult{

  @JsonKey(name: "Variables")
  CheckPostVariables variables = CheckPostVariables();

  CheckPostResult(){}

  factory CheckPostResult.fromJson(Map<String, dynamic> json) => _$CheckPostResultFromJson(json);
}

@JsonSerializable(ignoreUnannotated: true)
class CheckPostVariables extends BaseVariableResult{
  @JsonKey(name: "allowperm")
  AllowPerm allowPerm = AllowPerm();

  CheckPostVariables(){}
  factory CheckPostVariables.fromJson(Map<String, dynamic> json) => _$CheckPostVariablesFromJson(json);

}

@JsonSerializable(ignoreUnannotated: true)
class AllowPerm{
  @JsonKey(name: "allowpost")
  @StringToBoolConverter()
  bool allowPost = true;
  @JsonKey(name: "allowreply")
  @StringToBoolConverter()
  bool allowReply = true;
  @JsonKey(name: "uploadhash")
  String uploadHash = "";
  @JsonKey(name: "allowupload")
  AllowUpload allowUpload = AllowUpload();
  @JsonKey(name: "attachremain")
  AttachRemain attachRemain = AttachRemain();

  AllowPerm();

  factory AllowPerm.fromJson(Map<String, dynamic> json) => _$AllowPermFromJson(json);

}

@JsonSerializable(ignoreUnannotated: true)
class AllowUpload{
  @StringToIntConverter()
  int jpg = 0, jpeg = 0, gif = 0, png = 0, mp3 = 0, txt = 0, zip = -1, rar = -1, pdf = -1;

  AllowUpload();

  factory AllowUpload.fromJson(Map<String, dynamic> json) => _$AllowUploadFromJson(json);
}

@JsonSerializable()
class AttachRemain{
  @StringToIntConverter()
  int size = 0, count = 0;

  AttachRemain();

  factory AttachRemain.fromJson(Map<String, dynamic> json) => _$AttachRemainFromJson(json);
}

