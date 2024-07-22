import 'package:discuz_flutter/JsonResult/BaseVariableResult.dart';
import 'package:discuz_flutter/converter/StringToIntConverter.dart';
import 'package:json_annotation/json_annotation.dart';

import 'BaseResult.dart';
import 'ErrorResult.dart';

part 'DiscuzIndexResult.g.dart';

@JsonSerializable()
class DiscuzIndexResult extends BaseResult{

  @JsonKey(name: "Variables")
  DiscuzIndexVariables discuzIndexVariables = DiscuzIndexVariables();

  DiscuzIndexResult(){}

  factory DiscuzIndexResult.fromJson(Map<String, dynamic> json) => _$DiscuzIndexResultFromJson(json);
  Map<String, dynamic> toJson() => _$DiscuzIndexResultToJson(this);
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
  Map<String, dynamic> toJson() => _$DiscuzIndexVariablesToJson(this);

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
  Map<String, dynamic> toJson() => _$GroupInfoToJson(this);
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
  Map<String, dynamic> toJson() => _$ForumPartitionToJson(this);

  List<Forum> getForumList(List<Forum> forumList){
    List<Forum> subforumList = [];

    for(var forumId in forumIdList){

      for(Forum eachForum in forumList){

        if(eachForum.fid == forumId){
          subforumList.add(eachForum);
          break;
        }
      }
    }

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
  @JsonKey(defaultValue: "0")
  String threads = "0", posts = "0";
  @JsonKey(name:"icon",required: false, defaultValue: "")
  String iconUrl = "";

  @JsonKey(name:"todayposts", defaultValue: "")
  String todayPosts = "0";

  @JsonKey(name:"sublist",required: false, defaultValue: [])
  List<Forum> subForumList = [];
  Forum();
  factory Forum.fromJson(Map<String, dynamic> json) => _$ForumFromJson(json);
  Map<String, dynamic> toJson() => _$ForumToJson(this);

  @override
  String toString() {
    return "Forum ${fid}, ${name}";
  }
}
