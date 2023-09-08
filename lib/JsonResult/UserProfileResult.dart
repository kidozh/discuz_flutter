import 'package:discuz_flutter/JsonResult/BaseVariableResult.dart';
import 'package:discuz_flutter/converter/MedalListConverter.dart';
import 'package:discuz_flutter/converter/StringToBoolConverter.dart';
import 'package:discuz_flutter/converter/StringToIntConverter.dart';
import 'package:json_annotation/json_annotation.dart';

import 'BaseResult.dart';
import 'ErrorResult.dart';

part 'UserProfileResult.g.dart';

@JsonSerializable(disallowUnrecognizedKeys: false, ignoreUnannotated:true)
class UserProfileResult extends BaseResult{

  @JsonKey(name: "Variables")
  UserProfileVariables variables = UserProfileVariables();

  UserProfileResult();

  factory UserProfileResult.fromJson(Map<String, dynamic> json) => _$UserProfileResultFromJson(json);
}

@JsonSerializable(ignoreUnannotated: true)
class UserProfileVariables extends BaseVariableResult{
  @JsonKey(name: "space")
  SpaceVariables? space = SpaceVariables();

  @JsonKey(name: "extcredits",defaultValue: {})
  Map<String,ExtendCredit> extendCreditMap = {};

  SpaceVariables getSpace(){
    return space == null? SpaceVariables() : space!;
  }

  UserProfileVariables();
  factory UserProfileVariables.fromJson(Map<String, dynamic> json) => _$UserProfileVariablesFromJson(json);

}

@JsonSerializable()
class SpaceVariables{

  @StringToIntConverter()
  int uid = 0;
  String username = "";
  @StringToIntConverter()
  int status = 0;
  @JsonKey(name: "regdate",defaultValue: "")
  String registerDateString = "";
  @StringToIntConverter()
  int credits = 0, extcredits1 = 0, extcredits2 = 0, extcredits3 = 0, extcredits4 = 0, extcredits5 = 0, extcredits6 = 0, extcredits7 = 0, extcredits8 = 0;
  @StringToIntConverter()
  int friends = 0, posts = 0, threads = 0, digestposts = 0, oltime = 0;
  @JsonKey(name: "recentnote",defaultValue: "")
  String recentNote = "";
  @JsonKey(name: "customstatus",defaultValue: "")
  String customStatus = "";
  @JsonKey(name: "medals")
  @MedalListConverter()
  List<Medal> medalList = [];
  @JsonKey(name: "sightml",defaultValue: "")
  String signatureHtml = "";
  @JsonKey(name:"gender")
  @StringToBoolConverter()
  bool male = true;
  @JsonKey(name: "birthyear")
  @StringToIntConverter()
  int birthYear = 0;
  @JsonKey(name: "birthmonth")
  @StringToIntConverter()
  int birthMonth = 0;
  @JsonKey(name: "birthday")
  @StringToIntConverter()
  int birthDay = 0;
  @JsonKey(name: "groupid")
  @StringToIntConverter()
  int groupId = 0;
  String getBirthDay(){
    return "${birthYear} / ${birthMonth} / ${birthDay}";
  }
  @JsonKey(defaultValue: "")
  String constellation = "", zodiac = "", nationality = "";
  @JsonKey(defaultValue: "")
  String birthprovince = "", birthcity = "", birthdist="", birthcommunity = "";
  String getBirthPlace(){
    if(birthdist.startsWith("汉川") || birthdist.endsWith("市")){
      return birthprovince+birthdist+birthcommunity;
    }
    else{
      return birthprovince+birthcity+birthdist+birthcommunity;
    }
    
  }

  @JsonKey(defaultValue: "")
  String resideprovince = "", residecity = "", residedist="", residecommunity = "", residesuite = "";
  String getResidentPlace(){
    if(residedist.startsWith("汉川") || residedist.endsWith("市")){
      return resideprovince+residedist+residecommunity+residesuite;
    }
    else{
      return resideprovince+residecity+residedist+residecommunity+residesuite;
    }
    
  }
  @JsonKey(defaultValue: "")
  String graduateschool = "", education = "", company = "", occupation = "", position = "", revenue = "";
  @JsonKey(defaultValue: "")
  String lookingfor = "", bloodtype="", height = "", weight = "", site="";
  @JsonKey(defaultValue: "")
  String lastvisit = "", lastactivity="", lastpost="", lastsendmail = "";
  @StringToIntConverter()
  int favtimes = 0, sharetimes = 0, profileprogress=0;

  @JsonKey(name: "admingroup")
  AdminGroupInfo adminGroupInfo = AdminGroupInfo();
  @JsonKey(name: "group")
  GroupInfo groupInfo = GroupInfo();

  String bio = "", interest = "";


  SpaceVariables();
  factory SpaceVariables.fromJson(Map<String, dynamic> json){
    try{
      return _$SpaceVariablesFromJson(json);
    }
    catch (e,s){
      return SpaceVariables();
    }
  }


}

@JsonSerializable()
class Medal{
  String name = "";
  String image = "",description="";
  @JsonKey(name: "medalid")
  @StringToIntConverter()
  int medalId = 0;

  Medal();
  factory Medal.fromJson(Map<String, dynamic> json) => _$MedalFromJson(json);
}

@JsonSerializable()
class AdminGroupInfo{
  @JsonKey(defaultValue: "")
  String type = "";
  @JsonKey(name: "grouptitle",defaultValue: "")
  String groupTitle = "";
  @StringToIntConverter()
  int stars = 0;
  @JsonKey(defaultValue: "")
  String icon = "";
  @JsonKey(defaultValue: "")
  String color = "";
  @JsonKey(name: "readaccess")
  @StringToIntConverter()
  int readAccess = 0;

  AdminGroupInfo();
  factory AdminGroupInfo.fromJson(Map<String, dynamic> json) => _$AdminGroupInfoFromJson(json);
}

@JsonSerializable()
class GroupInfo{
  @JsonKey(defaultValue: "")
  String type = "";
  @JsonKey(name: "grouptitle")
  String groupTitle = "";
  @StringToIntConverter()
  int stars = 0;
  @JsonKey(defaultValue: "")
  String icon = "";
  @JsonKey(defaultValue: "")
  String color = "";
  @JsonKey(name: "readaccess")
  @StringToIntConverter()
  int readAccess = 0;

  GroupInfo();
  factory GroupInfo.fromJson(Map<String, dynamic> json) => _$GroupInfoFromJson(json);
}


@JsonSerializable(ignoreUnannotated: true)
class ExtendCredit{
  @JsonKey(defaultValue: "")
  String img = "";
  @JsonKey(defaultValue: "")
  String title = "";
  @JsonKey(defaultValue: "")
  String unit = "";
  @JsonKey(defaultValue: "")
  String ratio = "";
  @JsonKey(name:"showinthread",defaultValue: "")
  String showInThread = "";
  @JsonKey(name:"allowexchangein",defaultValue: "")
  String allowExchangeIn = "";
  @JsonKey(name:"allowexchangeout",defaultValue: "")
  String allowExchangeOut = "";


  ExtendCredit();
  factory ExtendCredit.fromJson(Map<String, dynamic> json) => _$ExtendCreditFromJson(json);
}