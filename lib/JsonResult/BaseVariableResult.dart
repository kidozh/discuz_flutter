import 'dart:core';
import 'dart:core';
import 'package:discuz_flutter/converter/StringToIntConverter.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:discuz_flutter/JsonResult/ErrorResult.dart';

part 'BaseVariableResult.g.dart';

@JsonSerializable()
class BaseVariableResult{

  String cookiepre = "";
  String? auth = null;
  String getAuth(){
    if(this.auth == null){
      return "";
    }
    else{
      return this.auth!;
    }
  }
  String saltkey = "";

  String member_username = "";
  String member_avatar = "";
  @StringToIntConverter()
  int member_uid = 0;
  @JsonKey(name:"groupid")
  @StringToIntConverter()
  int groupId = 0;

  @JsonKey(name: "readaccess")
  @StringToIntConverter()
  int readAccess = 0;

  String? ismoderator;

  @JsonKey(name: "notice")
  NoticeCount noticeCount = NoticeCount();

  User getUser(Discuz discuz){
    return User(null, this.getAuth(), saltkey,
        this.member_username, this.member_avatar,
        this.groupId, this.member_uid, this.readAccess,
        discuz.id!);
  }

}

@JsonSerializable()
class NoticeCount{
  String newpush = "";
  int getPush(){
    return int.parse(newpush);
  }

  String newpm = "";
  int getPM(){
    return int.parse(newpm);
  }

  String newprompt = "";

  int getPrompt(){
    return int.parse(newprompt);
  }

  String newmypost = "";

  int getPost(){
    return int.parse(newmypost);
  }

  NoticeCount(){}

  factory NoticeCount.fromJson(Map<String, dynamic> json) => _$NoticeCountFromJson(json);
}