import 'package:discuz_flutter/JsonResult/BaseVariableResult.dart';
import 'package:discuz_flutter/converter/SecondToDateTimeConverter.dart';
import 'package:discuz_flutter/converter/StringToBoolConverter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:discuz_flutter/converter/StringToIntConverter.dart';

import 'BaseResult.dart';
import 'ErrorResult.dart';


part 'PublicMessagePortalResult.g.dart';

@JsonSerializable()
class PublicMessagePortalResult extends BaseResult{

  @JsonKey(name: "Variables")
  late PublicMessagePortalVariables variables;

  PublicMessagePortalResult(){}

  factory PublicMessagePortalResult.fromJson(Map<String, dynamic> json) => _$PublicMessagePortalResultFromJson(json);
}

@JsonSerializable()
class PublicMessagePortalVariables extends BaseVariableResult{
  @JsonKey(name: "list")
  List<PublicMessagePortal> pmList = [];
  @StringToIntConverter()
  int count = 0;
  @JsonKey(name: "perpage")
  @StringToIntConverter()
  int perPage = 0;
  @StringToIntConverter()
  int page = 1;

  PublicMessagePortalVariables(){}
  factory PublicMessagePortalVariables.fromJson(Map<String, dynamic> json) => _$PublicMessagePortalVariablesFromJson(json);

}

@JsonSerializable()
class PublicMessagePortal{
  @StringToIntConverter()
  int id = 0;
  @JsonKey(name: "authorid")
  @StringToIntConverter()
  int authorId = 0;
  @JsonKey(defaultValue: "")
  String message = "";
  @JsonKey(name: "dateline")
  @SecondToDateTimeConverter()
  DateTime publishAt = DateTime.now();

  PublicMessagePortal();

  factory PublicMessagePortal.fromJson(Map<String, dynamic> json) => _$PublicMessagePortalFromJson(json);
}

