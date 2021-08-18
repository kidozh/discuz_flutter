import 'package:discuz_flutter/converter/SecondToDateTimeConverter.dart';
import 'package:discuz_flutter/converter/StringToBoolConverter.dart';
import 'package:discuz_flutter/converter/ViewThreadCommentConverter.dart';
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
  ThreadVariables threadVariables = ThreadVariables();

  ViewThreadResult();

  factory ViewThreadResult.fromJson(Map<String, dynamic> json) => _$ViewThreadResultFromJson(json);
  Map<String, dynamic> toJson() => _$ViewThreadResultToJson(this);

}

@JsonSerializable()
class ThreadVariables extends BaseVariableResult{

  @JsonKey(name:"thread")
  DetailedThreadInfo threadInfo = DetailedThreadInfo();
  @StringToIntConverter()
  int fid = 0;
  @JsonKey(name:"postlist",defaultValue: [])
  List<Post> postList = [];



  // @JsonKey(name:"allowpostcomment",defaultValue: [])
  // List<String>? allowPostCommentList = [];
  @ViewThreadCommentConverter()
  @JsonKey(name: "comments",defaultValue: {})
  Map<String, List<Comment>> commentList = {};

  @JsonKey(name: "setting_rewriterule",required: false)
  RewriteRule? rewriteRule = RewriteRule();


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
  // for poll
  @JsonKey(name: "special_poll",defaultValue: null)
  Poll? poll;


  ThreadVariables();

  factory ThreadVariables.fromJson(Map<String, dynamic> json) => _$ThreadVariablesFromJson(json);
  Map<String, dynamic> toJson() => _$ThreadVariablesToJson(this);

}

@JsonSerializable()
class DetailedThreadInfo {

  @StringToIntConverter()
  int tid = 0;

  @StringToIntConverter()
  int fid = 0;

  // @JsonKey(name:"posttableid",defaultValue: "0")
  // String postableId= "";
  // @StringToIntConverter()
  // @JsonKey(name:"typeid")
  // int typeId= 0;
  String author= "", subject= "";
  @JsonKey(name: "readperm")
  @StringToIntConverter()
  int readPerm = 0;
  @StringToIntConverter()
  int price = 0;
  @JsonKey(name:"authorid")
  @StringToIntConverter()
  int authorId = 0;
  @JsonKey(name:"sortid",defaultValue: "0")
  String sortId = "0";
  // @JsonFormat(shape=JsonFormat.Shape.STRING, pattern="s")
  // public Date lastPostTime = new Date();
  @JsonKey(name:"lastpost",defaultValue: "")
  String lastPostTimeString = "";
  @JsonKey(defaultValue: "")
  String lastposter= "";

  @JsonKey(name:"displayorder")
  String displayOrder = "";

  String views = "";
  @JsonKey(name:"replies")
  @StringToIntConverter()
  int replies = 0;
  @JsonKey(defaultValue: "")
  String highlight = "";
  @JsonKey(defaultValue: "0")
  // String special="0", moderated="0", is_archived="0";
  @JsonKey(defaultValue: "0")
  String rate = "0", status = "0", digest= "0", closed= "0";

  // @JsonKey(defaultValue: "0")
  // String attachment = "0";

  // @JsonKey(name:"stickreply")
  // String stickReply = "0";
  // @JsonKey(defaultValue: "0")
  // String recommends = "0", recommend_add= "0", recommend_sub= "0";
  // String isgroup = "0";
  // @JsonKey(defaultValue: "0")
  // String favtimes = "0", sharedtimes = "0", heats = "0";
  // @JsonKey(defaultValue: "0")
  // String stamp = "0", icon = "0", pushedaid = "0", cover = "0";
  // @JsonKey(name:"replycredit")
  // String replyCredit = "";
  // @JsonKey(defaultValue: "")
  // String relatebytag = "", bgcolor= "";
  // @JsonKey(name:"maxposition")
  // String maxPosition = "";
  // @JsonKey(name:"comments",defaultValue: "0")
  // String comments = "0";
  // @JsonKey(defaultValue: "0")
  // String hidden = "0";
  // String threadtable = "", threadtableid = "", posttable = "";
  @JsonKey(name:"allreplies")
  @StringToIntConverter()
  int allreplies = 0;

  // @JsonKey(defaultValue: "")
  // String archiveid = "";
  // @JsonKey(defaultValue: "")
  // String subjectenc = "", short_subject="";
  // @JsonKey(defaultValue: "")
  // String relay = "", ordertype = "", recommend = "";
  // @JsonKey(name:"recommendlevel",defaultValue: "0")
  // String recommendLevel = "0";
  // @JsonKey(name:"heatlevel",defaultValue: "0")
  // String heatLevel = "0";
  @JsonKey(name:"freemessage",defaultValue: "")
  String freeMessage = "";

  //
  // @JsonKey(name:"replycredit_rule")
  // ReplyCreditRule? creditRule = ReplyCreditRule();

  DetailedThreadInfo();
  factory DetailedThreadInfo.fromJson(Map<String, dynamic> json) => _$DetailedThreadInfoFromJson(json);
  Map<String, dynamic> toJson() => _$DetailedThreadInfoToJson(this);
}

@JsonSerializable(ignoreUnannotated: true, disallowUnrecognizedKeys: false)
class ReplyCreditRule{

  final String tid = "0";
  @JsonKey(name:"extcredits",defaultValue: "0")
  final String extCredits = "0";
  @JsonKey(name:"extcreditstype",defaultValue: "0")
  final String extCreditsType = "0";

  final String times = "0", membertimes = "0";
  final String random = "0";
  final String remaining = "0";

  const ReplyCreditRule();
  factory ReplyCreditRule.fromJson(Map<String, dynamic> json) => _$ReplyCreditRuleFromJson(json);
  Map<String, dynamic> toJson() => _$ReplyCreditRuleToJson(this);
}

@JsonSerializable()
class Comment{
  @StringToIntConverter()
  int id = 0;
  @StringToIntConverter()
  int tid = 0;

  @StringToIntConverter()
  int pid = 0;
  String author = "";
  String dateline = "";
  String comment = "";
  String avatar = "";
  @StringToIntConverter()
  @JsonKey(name:"authorid")
  int authorId = 0;

  Comment();
  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
  Map<String, dynamic> toJson() => _$CommentToJson(this);
}

@JsonSerializable()
class RewriteRule{
  @JsonKey(name: "portal_topic",defaultValue: "")
  String portalTopic = "";
  @JsonKey(name: "portal_article",defaultValue: "")
  String portalArticle = "";
  @JsonKey(name:"forum_forumdisplay",defaultValue: "")
  String forumDisplay = "";
  @JsonKey(name:"forum_viewthread",defaultValue: "")
  String viewThread = "";
  @JsonKey(name:"group_group",defaultValue: "")
  String group = "";
  @JsonKey(name:"home_space",defaultValue: "")
  String userSpace = "";
  @JsonKey(name:"home_blog",defaultValue: "")
  String homeBlog = "";
  @JsonKey(name:"forum_archiver",defaultValue: "")
  String forumArchiver = "";
  @JsonKey(name:"plugin",defaultValue: "")
  String plugin = "";

  RewriteRule();
  factory RewriteRule.fromJson(Map<String, dynamic> json) => _$RewriteRuleFromJson(json);
  Map<String, dynamic> toJson() => _$RewriteRuleToJson(this);

}

@JsonSerializable(ignoreUnannotated: true)
class Poll{
  @JsonKey(name:"expirations")
  @SecondToDateTimeConverter()
  DateTime expiredAt = DateTime.now();
  @JsonKey(name: "multiple")
  @StringToBoolConverter()
  bool multipleChoice = true;
  @JsonKey(name: "maxchoices")
  @StringToIntConverter()
  int maxChoice = 1;
  @JsonKey(name:"visiblepoll")
  @StringToBoolConverter()
  bool isResultVisible = true;
  @JsonKey(name: "allowvote")
  @StringToBoolConverter()
  bool allowVote = true;
  @JsonKey(name: "voterscount")
  @StringToIntConverter()
  int votersCount = 0;

  @JsonKey(name: "polloptions", defaultValue: {})
  Map<String, PollOption> pollOptionsMap = {};

  Poll();
  factory Poll.fromJson(Map<String, dynamic> json) => _$PollFromJson(json);
  Map<String, dynamic> toJson() => _$PollToJson(this);
}

@JsonSerializable(ignoreUnannotated: true)
class PollOption{
  @JsonKey(name: "polloptionid")
  @StringToIntConverter()
  int id = 0;
  @JsonKey(name: "polloption",defaultValue: "")
  String name = "";
  @JsonKey(name: "votes")
  @StringToIntConverter()
  int voteNumber = 0;
  @JsonKey(defaultValue: "EEEEEE")
  String color = "";
  PollOption();

  factory PollOption.fromJson(Map<String, dynamic> json) => _$PollOptionFromJson(json);
  Map<String, dynamic> toJson() => _$PollOptionToJson(this);

}
