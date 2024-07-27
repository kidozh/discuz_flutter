
import 'package:discuz_flutter/JsonResult/BaseVariableResult.dart';
import 'package:discuz_flutter/entity/Smiley.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:discuz_flutter/converter/StringToIntConverter.dart';

import 'BaseResult.dart';
import 'ErrorResult.dart';


part 'SupportDiscuzListResult.g.dart';

@JsonSerializable()
class SupportDiscuzListResult{

  List<SupportDiscuzSite> list = [];

  SupportDiscuzListResult(){}

  factory SupportDiscuzListResult.fromJson(Map<String, dynamic> json) => _$SupportDiscuzListResultFromJson(json);
  Map<String, dynamic> toJson() => _$SupportDiscuzListResultToJson(this);
}

@JsonSerializable()
class SupportDiscuzSite{

  String name = "";
  String url = "";
  String desc = "";
  String beian = "";
  String type = "";
  @JsonKey(defaultValue: "", required: false)
  String icon = "";

  SupportDiscuzSite(){}

  factory SupportDiscuzSite.fromJson(Map<String, dynamic> json) => _$SupportDiscuzSiteFromJson(json);
  Map<String, dynamic> toJson() => _$SupportDiscuzSiteToJson(this);
}