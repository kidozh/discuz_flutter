import 'package:json_annotation/json_annotation.dart';
import 'package:discuz_flutter/JsonResult/BaseVariableResult.dart';
import 'package:discuz_flutter/converter/StringToIntConverter.dart';
import 'package:discuz_flutter/entity/Post.dart';


import 'BaseResult.dart';
import 'ErrorResult.dart';


part "ViewThreadResult.g.dart";

@JsonSerializable()
class ViewThreadResult extends BaseResult{

  @JsonKey(name: "Variables")
  late ThreadVariables threadVariables;

  ViewThreadResult();

  factory ViewThreadResult.fromJson(Map<String, dynamic> json) => _$ViewThreadResultFromJson(json);
  Map<String, dynamic> toJson() => _$ViewThreadResultToJson(this);

}

@JsonSerializable(ignoreUnannotated: true)
class ThreadVariables extends BaseVariableResult{

  @JsonKey(name:"thread")
  DetailedThreadInfo threadInfo = DetailedThreadInfo();
  @StringToIntConverter()
  int fid = 0;
  @JsonKey(name:"postlist",defaultValue: [])
  List<Post> postList = [];



  @JsonKey(name:"allowpostcomment",defaultValue: [])
  List<String>? allowPostCommentList = [];

  // @JsonKey(name: "comments",defaultValue: {})
  // Map<String, List<Comment>> commentList = {};


  String ppp = "0";
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


  ThreadVariables();

  factory ThreadVariables.fromJson(Map<String, dynamic> json) => _$ThreadVariablesFromJson(json);
  Map<String, dynamic> toJson() => _$ThreadVariablesToJson(this);

}

@JsonSerializable(ignoreUnannotated: true)
class DetailedThreadInfo {

  String tid = "0";
  int getTid(){
    return int.parse(tid);
  }
  String fid = "0";
  int getFid(){
    return int.parse(fid);
  }
  @JsonKey(name:"posttableid")
  String postableId= "";
  @JsonKey(name:"typeid")
  String typeId= "";
  String author= "", subject= "";
  @JsonKey(name:"authorid")
  String authorId = "0";
  int getAuthorId(){
    return int.parse(authorId);
  }
  @JsonKey(name:"sortid")
  String sortId = "0";
  @JsonKey(name:"dateline")
  String lastPostTime = "0";
  // @JsonFormat(shape=JsonFormat.Shape.STRING, pattern="s")
  // public Date lastPostTime = new Date();
  @JsonKey(name:"lastpost")
  String lastPostTimeString = "";
  String lastposter= "";

  @JsonKey(name:"displayorder")
  String displayOrder = "";

  String views = "";
  @StringToIntConverter()
  int replies = 0;
  String highlight = "";

  String special="0", moderated="0", is_archived="0";

  String rate = "0", status = "0", readperm = "0", price = "0", digest= "0", closed= "0";


  String attachment = "0";

  @JsonKey(name:"stickreply")
  String stickReply = "0";
  @JsonKey(defaultValue: "0")
  String recommends = "0", recommend_add= "0", recommend_sub= "0";
  String isgroup = "0";

  String favtimes = "0", sharedtimes = "0", heats = "0";
  String stamp = "0", icon = "0", pushedaid = "0", cover = "0";
  @JsonKey(name:"replycredit")
  String replyCredit = "";
  String relatebytag = "", bgcolor= "";
  @JsonKey(name:"maxposition")

  String maxPosition = "";
  @JsonKey(name:"comments")

  String comments = "0";

  String hidden = "0";
  String threadtable = "", threadtableid = "", posttable = "";
  @JsonKey(name:"allreplies")
  String allreplies = "0";
  int getReplyNumber(){
    return int.parse(allreplies);
  }
  String archiveid = "";
  String subjectenc = "", short_subject="";

  String relay = "", ordertype = "", recommend = "";
  @JsonKey(name:"recommendlevel")
  String recommendLevel = "0";
  @JsonKey(name:"heatlevel")
  String heatLevel = "0";
  @JsonKey(name:"freemessage",defaultValue: "")
  String freeMessage = "";

  //
  @JsonKey(name:"replycredit_rule")
  ReplyCreditRule creditRule = ReplyCreditRule();

  DetailedThreadInfo();
  factory DetailedThreadInfo.fromJson(Map<String, dynamic> json) => _$DetailedThreadInfoFromJson(json);
  Map<String, dynamic> toJson() => _$DetailedThreadInfoToJson(this);
}

@JsonSerializable(ignoreUnannotated: true)
class ReplyCreditRule{

  String tid = "0";
  @JsonKey(name:"extcredits",defaultValue: "0")
  String extCredits = "0";
  @JsonKey(name:"extcreditstype",defaultValue: "0")
  String extCreditsType = "0";

  String times = "0", membertimes = "0";
  String random = "0";
  String remaining = "0";

  ReplyCreditRule();
  factory ReplyCreditRule.fromJson(Map<String, dynamic> json) => _$ReplyCreditRuleFromJson(json);
  Map<String, dynamic> toJson() => _$ReplyCreditRuleToJson(this);
}

@JsonSerializable(ignoreUnannotated: true)
@StringToIntConverter()
class Comment{
  int id = 0;
  int tid = 0;


  int pid = 0;
  String author = "";
  String dateline = "";
  String comment = "";
  String avatar = "";

  @JsonKey(name:"authorid")
  int authorId = 0;

  Comment();
  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
  Map<String, dynamic> toJson() => _$CommentToJson(this);
}

