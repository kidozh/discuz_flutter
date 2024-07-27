import 'dart:convert';

import 'package:discuz_flutter/utility/ConstUtils.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import 'Discuz.dart';

part 'Smiley.g.dart';

@JsonSerializable()
@HiveType(typeId: ConstUtils.HIVE_TYPE_ID_SMILEY)
class Smiley extends HiveObject{

  @HiveField(0)
  String code = "";
  @JsonKey(name: "image")
  @HiveField(1)
  String relativePath = "";

  @JsonKey(ignore: true)
  @HiveField(2)
  DateTime dateTime = DateTime.now();

  @JsonKey(includeFromJson: false, includeToJson: false)
  @HiveField(3)
  Discuz discuz = Discuz("", "discuzVersion", "charset", 4, "pluginVersion", "regname", true, "wsqqqconnect", "wsqhideregister", "siteName", "siteId", "uCenterURL", "defaultFid");

  Smiley();


  factory Smiley.fromJson(Map<String, dynamic> json) => _$SmileyFromJson(json);
  // Map<String, dynamic> toJson => $_SmileyToJson(this);
  Map<String, dynamic> toJson() => _$SmileyToJson(this);

  @override
  String toString() {
    return jsonEncode(toJson()).toString();
  }
}