import 'dart:convert';
import 'dart:core';
import 'dart:developer';

import 'package:discuz_flutter/JsonResult/BaseVariableResult.dart';
import 'package:discuz_flutter/entity/ForumThread.dart';
import 'package:json_annotation/json_annotation.dart';

import 'BaseResult.dart';
import 'ErrorResult.dart';
import 'package:discuz_flutter/converter/StringToIntConverter.dart';


part 'DisplayForumResult.g.dart';

@JsonSerializable()
class DisplayForumResult extends BaseResult{

  @JsonKey(name: "Variables")
  late ForumVariables discuzIndexVariables;

  DisplayForumResult(){}

  factory DisplayForumResult.fromJson(Map<String, dynamic> json) => _$DisplayForumResultFromJson(json);
  Map<String, dynamic> toJson() => _$DisplayForumResultToJson(this);

}

@JsonSerializable()
class ForumVariables extends BaseVariableResult{
  @JsonKey(name: "forum")
  ForumDetail forum = ForumDetail();
  @JsonKey(name: "group")
  Group group = Group();
  @JsonKey(name:"forum_threadlist")
  List<ForumThread> forumThreadList = [];

  String tpp = "0";
  @JsonKey(defaultValue: "1")
  String? page = "1";
  int getPage(){
    if(page == null){
      return 1;
    }
    else{
      return int.parse(page!);
    }

  }

  @JsonKey(name:"reward_unit",defaultValue: "")
  String rewardUnit = "";

  @JsonKey(name: "threadtypes")
  ThreadType? threadType = ThreadType();

  ThreadType getThreadType(){
    if(threadType == null){
      return ThreadType();
    }
    else{
      return threadType!;
    }
  }

  ForumVariables();

  factory ForumVariables.fromJson(Map<String, dynamic> json) => _$ForumVariablesFromJson(json);
  Map<String, dynamic> toJson() => _$ForumVariablesToJson(this);

}

@JsonSerializable()
class ForumDetail{
  @StringToIntConverter()
  int fid = 0, fup=0, threads = 0, posts = 0;
  @JsonKey(defaultValue: "")
  String description = "", rules = "", name = "", password="";
  @JsonKey(name:"picstyle",defaultValue: "")
  String picStyle= "";
  @JsonKey(name:"autoclose",defaultValue: "")
  String autoClose = "";

  @JsonKey(name:"threadcount",defaultValue: "0")
  String threadCount = "0";
  int getThreadCount(){
    return int.parse(this.threadCount);
  }
  @JsonKey(name:"icon",defaultValue: "")
  String iconUrl = "";
  @JsonKey(name:"todayposts",defaultValue: "0")
  String todayPosts = "0";

  @JsonKey(name:"redirect",defaultValue: "")
  String redirectURL= "";



  ForumDetail();
  factory ForumDetail.fromJson(Map<String, dynamic> json) => _$ForumDetailFromJson(json);
  Map<String, dynamic> toJson() => _$ForumDetailToJson(this);

  @override
  String toString() {
    // TODO: implement toString
    return "ForumDetail ${fid}, ${name}";
  }
}

@JsonSerializable()
class Group{
  @JsonKey(name: "groupid")
  String groupId = "0";

  @JsonKey(name:"grouptitle")
  String? groupTitle = null;
  Group();
  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
  Map<String, dynamic> toJson() => _$GroupToJson(this);
}

@JsonSerializable()
class ThreadType{

  String required = "0";
  bool typeRequired(){
    return required == "1";
  }


  String listable = "0";
  @JsonKey(defaultValue: "")
  String prefix = "";


  @JsonKey(name:"types",defaultValue: {})
  Map<String,String> idNameMap = {};

  @JsonKey(name:"icons",defaultValue: {})

  Map<String,String> idIconMap = {};

  @JsonKey(name :"moderators", defaultValue: {})
  Map<String, String?> idModeratorMap = {};

  ThreadType();

  factory ThreadType.fromJson(Map<String, dynamic> json) => _$ThreadTypeFromJson(json);
  Map<String, dynamic> toJson() => _$ThreadTypeToJson(this);
}
