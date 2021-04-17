import 'dart:developer';

import 'package:discuz_flutter/JsonResult/BaseVariableResult.dart';
import 'package:json_annotation/json_annotation.dart';

import 'BaseResult.dart';
import 'ErrorResult.dart';


part 'DiscuzIndexResult.g.dart';

@JsonSerializable()
class DiscuzIndexResult extends BaseResult{

  @JsonKey(name: "Variables")
  late DiscuzIndexVariables discuzIndexVariables;

  DiscuzIndexResult(){}

  factory DiscuzIndexResult.fromJson(Map<String, dynamic> json) => _$DiscuzIndexResultFromJson(json);
}

@JsonSerializable()
class DiscuzIndexVariables extends BaseVariableResult{
  @JsonKey(name:"member_email")
  String? memberEmail = "";
  @JsonKey(name:"member_credits")
  String memberCredits = "";
  @JsonKey(name:"setting_bbclosed")
  String bbClosed = "";
  bool isDiscuzClosed(){
    return this.bbClosed == "1";
  }
  @JsonKey(name:"group")
  GroupInfo groupInfo = GroupInfo();
  @JsonKey(name:"catlist")
  List<ForumPartition> forumPartitionList = [];
  @JsonKey(name:"forumlist")
  List<Forum> forumList = [];

  DiscuzIndexVariables();

  factory DiscuzIndexVariables.fromJson(Map<String, dynamic> json) => _$DiscuzIndexVariablesFromJson(json);

}

@JsonSerializable()
class GroupInfo{
  @JsonKey(name:"groupid")
  String groupId = "";

  int getGroupId(){
    return int.parse(this.groupId);
  }
  @JsonKey(name:"grouptitle")
  String groupTitle = "";
  // @JsonKey(required: false)
  // late String allowvisit,allowsendpm,allowinvite,allowmailinvite,allowpost, allowreply
  // ,allowpostpoll,allowpostreward,allowposttrade,allowpostactivity,allowdirectpost,allowgetattach,
  // allowgetimage,allowpostattach,allowpostimage,allowvote,allowsearch,allowcstatus,allowinvisible,
  // allowtransfer,allowsetreadperm,allowsetattachperm,allowposttag,allowhidecode,allowhtml,allowanonymous,
  // allowsigbbcode,allowsigimgcode,allowmagics,allowpostdebate,allowposturl,allowrecommend,
  // allowpostrushreply, allowcomment,allowcommentarticle,allowblog,allowdoing,allowupload,allowshare,
  // allowblogmod,allowdoingmod, allowuploadmod,allowsharemod,allowcss,allowpoke,allowfriend,allowclick,
  // allowmagic,allowstat,allowstatdata,
  // allowviewvideophoto,allowmyop,allowbuildgroup,allowgroupdirectpost,allowgroupposturl,allowpostarticle,
  // allowdownlocalimg,allowdownremoteimg,allowpostarticlemod,allowspacediyhtml,allowspacediybbcode,
  // allowspacediyimgcode,allowcommentpost,allowcommentitem,allowcommentreply,allowreplycredit,
  // allowsendallpm,allowsendpmmaxnum,allowmediacode,allowbegincode,allowat,allowsave,allowsavereply,
  // allowsavenum,allowsetpublishdate,allowfollowcollection,allowcommentcollection,allowcreatecollection,
  // allowimgcontent;
  @JsonKey(name:"allowthreadplugin",required: false,defaultValue: [])
  List<String> allowThreadPlugins = [];
  GroupInfo();
  factory GroupInfo.fromJson(Map<String, dynamic> json) => _$GroupInfoFromJson(json);
}

@JsonSerializable()
class ForumPartition{
  String fid = "0";
  int getFid(){
    return int.parse(this.fid);
  }
  String name = "";
  @JsonKey(name:"forums")
  List<String> forumIdList = [];

  ForumPartition();
  factory ForumPartition.fromJson(Map<String, dynamic> json) => _$ForumPartitionFromJson(json);

  List<Forum> getForumList(List<Forum> forumList){
    List<Forum> subforumList = [];
    //log("Get ${forumIdList} from ${forumList}");
    for(var forumId in forumIdList){
      log("fid ${forumId}");
      for(Forum eachForum in forumList){
        //log("searched fid ${eachForum.fid} ${eachForum.name}");
        if(eachForum.fid == forumId){
          subforumList.add(eachForum);
          break;
        }
      }
    }
    // log("Get ${subforumList} length ${subforumList.length}");
    return subforumList;
  }
}

@JsonSerializable()
class Forum{
  String fid = "0";
  int getFid(){
    return int.parse(this.fid);
  }
  @JsonKey(required: false,defaultValue: "")
  String description = "";
  String name = "";
  String threads = "0", posts = "0";
  @JsonKey(name:"icon",required: false, defaultValue: "")
  String iconUrl = "";

  @JsonKey(name:"todayposts")
  String todayPosts = "0";

  @JsonKey(name:"sublist",required: false, defaultValue: [])
  List<Forum> subForumList = [];
  Forum();
  factory Forum.fromJson(Map<String, dynamic> json) => _$ForumFromJson(json);

  @override
  String toString() {
    // TODO: implement toString
    return "Forum ${fid}, ${name}";
  }
}
