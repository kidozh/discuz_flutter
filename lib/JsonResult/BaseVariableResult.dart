import 'dart:core';
import 'dart:core';
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
  String member_uid = "";
  int getUid(){
    return int.parse(this.member_uid);
  }

  String groupid = "";
  int getGroupId(){
    return int.parse(this.groupid);
  }

  String readaccess = "";
  int getReadAccessScore(){
    return int.parse(readaccess);
  }

  String? ismoderator;

  @JsonKey(name: "notice")
  NoticeCount noticeCount = NoticeCount();

  User getUser(Discuz discuz){
    return User(null, this.getAuth(), saltkey,
        this.member_username, this.member_avatar,
        this.getGroupId(), this.getUid(), this.getReadAccessScore(),
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