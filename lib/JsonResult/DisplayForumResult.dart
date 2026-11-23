import 'dart:core';

import 'package:discuz_flutter/JsonResult/BaseVariableResult.dart';
import 'package:discuz_flutter/converter/ThreadTypesConverter.dart';
import 'package:discuz_flutter/entity/ForumThread.dart';
import 'package:discuz_flutter/utility/discuz_json.dart';
import 'package:json_annotation/json_annotation.dart';

import 'BaseResult.dart';
import 'ErrorResult.dart';

import 'package:discuz_flutter/converter/StringToIntConverter.dart';

part 'DisplayForumResult.g.dart';

@JsonSerializable()
class DisplayForumResult extends BaseResult {
  @JsonKey(name: "Variables")
  ForumVariables discuzIndexVariables = ForumVariables();

  DisplayForumResult() {}

  factory DisplayForumResult.fromJson(Map<String, dynamic> json) =>
      _$DisplayForumResultFromJson(json);
  Map<String, dynamic> toJson() => _$DisplayForumResultToJson(this);
}

@JsonSerializable()
class ForumVariables extends BaseVariableResult {
  @JsonKey(name: "forum")
  ForumDetail forum = ForumDetail();
  @JsonKey(name: "group")
  Group group = Group();
  @JsonKey(name: "forum_threadlist")
  List<ForumThread> forumThreadList = [];

  String tpp = "0";
  @JsonKey(defaultValue: "1")
  String? page = "1";
  int getPage() {
    if (page == null) {
      return 1;
    } else {
      return int.parse(page!);
    }
  }

  @JsonKey(name: "reward_unit", defaultValue: "")
  String rewardUnit = "";

  @JsonKey(name: "threadtypes", fromJson: _threadTypes)
  ThreadType? threadType = ThreadType();
  @JsonKey(name: 'threadsorts', fromJson: discuzMap)
  Map<String, dynamic> threadSorts = {};
  @JsonKey(name: "sublist", defaultValue: [])
  List<SubForum> subForumList = [];

  ThreadType getThreadType() {
    if (threadType == null) {
      return ThreadType();
    } else {
      return threadType!;
    }
  }

  static ThreadType? _threadTypes(Object? value) =>
      value is Map ? ThreadType.fromJson(discuzMap(value)) : null;

  ForumVariables();

  factory ForumVariables.fromJson(Map<String, dynamic> json) =>
      _$ForumVariablesFromJson(json);
  Map<String, dynamic> toJson() => _$ForumVariablesToJson(this);
}

@JsonSerializable()
class ForumDetail {
  @StringToIntConverter()
  int fid = 0, fup = 0, threads = 0, posts = 0;
  @JsonKey(defaultValue: "")
  String description = "", rules = "", name = "", password = "";
  @JsonKey(name: 'picstyle', fromJson: _pictureMode)
  bool pictureMode = false;
  static bool _pictureMode(Object? value) => discuzPermission(value) == true;
  @JsonKey(name: "autoclose", defaultValue: "")
  String autoClose = "";

  @JsonKey(name: "threadcount", defaultValue: "0")
  String threadCount = "0";
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool threadCountReported = false;

  int getThreadCount() {
    return int.parse(this.threadCount);
  }

  @JsonKey(name: "icon", defaultValue: "")
  String iconUrl = "";
  @JsonKey(name: "todayposts", defaultValue: "0")
  String todayPosts = "0";

  @JsonKey(name: "redirect", defaultValue: "")
  String redirectURL = "";

  ForumDetail();
  factory ForumDetail.fromJson(Map<String, dynamic> json) =>
      _$ForumDetailFromJson(json)
        ..threadCountReported = json['threadcount'] != null;
  Map<String, dynamic> toJson() => _$ForumDetailToJson(this);

  @override
  String toString() {
    // TODO: implement toString
    return "ForumDetail ${fid}, ${name}";
  }
}

@JsonSerializable()
class Group {
  @JsonKey(name: "groupid")
  String groupId = "0";

  @JsonKey(name: "grouptitle")
  String? groupTitle = null;
  Group();
  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
  Map<String, dynamic> toJson() => _$GroupToJson(this);
}

@JsonSerializable()
class ThreadType {
  @JsonKey(fromJson: _flag)
  String required = "0";
  bool typeRequired() {
    return required == "1";
  }

  @JsonKey(fromJson: _flag)
  String listable = "0";
  @JsonKey(fromJson: discuzString)
  String prefix = "";

  @JsonKey(name: "types", defaultValue: {})
  @ThreadTypeConverter()
  Map<String, String> idNameMap = {};

  List<ThreadTypeInfo> getThreadTypeList() {
    List<ThreadTypeInfo> threadTypeList = [];
    for (var entry in idNameMap.entries) {
      final id = int.tryParse(entry.key);
      if (id != null && id > 0) {
        threadTypeList.add(ThreadTypeInfo(id, entry.value));
      }
    }
    return threadTypeList;
  }

  @JsonKey(name: "icons", defaultValue: {})
  @ThreadTypeConverter()
  Map<String, String> idIconMap = {};

  @JsonKey(name: "moderators", fromJson: _moderators)
  Map<String, String?> idModeratorMap = {};

  static String _flag(Object? value) =>
      discuzPermission(value) == true ? '1' : '0';

  static Map<String, String?> _moderators(Object? value) =>
      discuzMap(value).map((id, flag) => MapEntry(id, flag == null ? null : _flag(flag)));

  ThreadType();

  factory ThreadType.fromJson(Map<String, dynamic> json) =>
      _$ThreadTypeFromJson(json);
  Map<String, dynamic> toJson() => _$ThreadTypeToJson(this);
}

class ThreadTypeInfo {
  int typeId;
  String typeName;

  ThreadTypeInfo(this.typeId, this.typeName);
}

@JsonSerializable()
class SubForum {
  @StringToIntConverter()
  int fid = 0, threads = 0, posts = 0, todayposts = 0;
  String name = "";

  SubForum();

  factory SubForum.fromJson(Map<String, dynamic> json) =>
      _$SubForumFromJson(json);
  Map<String, dynamic> toJson() => _$SubForumToJson(this);
}
