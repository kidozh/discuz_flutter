import 'dart:core';
import 'dart:developer';
import 'package:discuz_flutter/converter/StringToIntConverter.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:json_annotation/json_annotation.dart';

part 'BaseVariableResult.g.dart';

@JsonSerializable(ignoreUnannotated: true, explicitToJson: true)
class BaseVariableResult{
  @JsonKey(name:"cookiepre")
  String cookiepre = "";
  @JsonKey(name:"auth")
  String? auth;
  String getAuth(){
    if(this.auth == null){
      return "";
    }
    else{
      return this.auth!;
    }
  }
  @JsonKey(name:"saltkey")
  String saltkey = "";
  @JsonKey(name:"member_username")
  String member_username = "";
  @JsonKey(name:"member_avatar")
  String member_avatar = "";
  @JsonKey(name:"member_uid")
  @StringToIntConverter()
  int member_uid = 0;
  @JsonKey(name:"groupid")
  @StringToIntConverter()
  int groupId = 0;

  @JsonKey(name: "readaccess")
  @StringToIntConverter()
  int readAccess = 0;
  @JsonKey(name: "formhash")
  String formHash = "";
  @StringToIntConverter()
  @JsonKey(name: "ismoderator")
  int isModerator = 0;

  @JsonKey(name: "notice")
  NoticeCount noticeCount = NoticeCount();

  User getUser(Discuz discuz){
    log("User ${this.member_uid} ${this.member_username}");
    return User(this.getAuth(), saltkey,
        this.member_username, this.member_avatar,
        this.groupId, this.member_uid, this.readAccess,
        discuz);
  }

  BaseVariableResult();

  factory BaseVariableResult.fromJson(Map<String, dynamic> json) => _$BaseVariableResultFromJson(json);
  Map<String, dynamic> toJson() => _$BaseVariableResultToJson(this);



}

@JsonSerializable(explicitToJson: true)
class NoticeCount{

  @StringToIntConverter()
  int newpush = 0;

  @StringToIntConverter()
  int newpm = 0;

  @StringToIntConverter()
  int newprompt = 0;

  @StringToIntConverter()
  int newmypost = 0;

  NoticeCount();

  factory NoticeCount.fromJson(Map<String, dynamic> json) => _$NoticeCountFromJson(json);
  Map<String, dynamic> toJson() => _$NoticeCountToJson(this);

  @override
  String toString() {
    return super.toString().toString();
  }
}