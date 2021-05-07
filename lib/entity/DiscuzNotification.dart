
import 'package:discuz_flutter/converter/SecondToDateTimeConverter.dart';
import 'package:discuz_flutter/converter/StringToIntConverter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'DiscuzNotification.g.dart';

@JsonSerializable()
class DiscuzNotification{

  @StringToIntConverter()
  int id = 0, uid = 0;
  String type = "";
  @JsonKey(name: "new",required: false,defaultValue: "0")
  String isNew = "0";
  @JsonKey(required: false, defaultValue: "")
  String author = "";
  @JsonKey(name: "authorid")
  @StringToIntConverter()
  int authorId = 0;
  String note = "";
  @JsonKey(name: "dateline")
  @SecondToDateTimeConverter()
  DateTime dateline = DateTime.now();
  @JsonKey(name: "from_id")
  @StringToIntConverter()
  int fromId = 0;
  @JsonKey(name: "from_idtype", defaultValue: "")
  String fromIdType = "";

  DiscuzNotification();
  factory DiscuzNotification.fromJson(Map<String, dynamic> json) => _$DiscuzNotificationFromJson(json);
  Map<String, dynamic> toJson() => _$DiscuzNotificationToJson(this);
}