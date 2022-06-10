

import 'package:discuz_flutter/converter/StringToBoolConverter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'PushTokenListResult.g.dart';

@JsonSerializable()
class PushTokenListResult{
  String result = "";
  int maxToken = 5;
  String formhash = "";
  List<PushToken> list = [];

  PushTokenListResult();

  factory PushTokenListResult.fromJson(Map<String, dynamic> json) => _$PushTokenListResultFromJson(json);
  Map<String, dynamic> toJson() => _$PushTokenListResultToJson(this);
}

@JsonSerializable()
class PushToken{
  int id = 0;
  int uid = 0;
  String username = "";
  String token = "";
  @StringToBoolConverter()
  bool allowPush = true;
  String deviceName = "";

  DateTime updateAt = DateTime.now();
  String channel = "";

  PushToken();

  factory PushToken.fromJson(Map<String, dynamic> json) => _$PushTokenFromJson(json);
  Map<String, dynamic> toJson() => _$PushTokenToJson(this);
}

@JsonSerializable()
class PostTokenResult{
  String result = "";
  String formhash = "";

  PostTokenResult();

  factory PostTokenResult.fromJson(Map<String, dynamic> json) => _$PostTokenResultFromJson(json);
  Map<String, dynamic> toJson() => _$PostTokenResultToJson(this);
}