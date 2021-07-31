// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UserProfileResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfileResult _$UserProfileResultFromJson(Map<String, dynamic> json) {
  return UserProfileResult()
    ..version = json['Version'] as String
    ..charset = json['Charset'] as String
    ..errorResult = json['Message'] == null
        ? null
        : ErrorResult.fromJson(json['Message'] as Map<String, dynamic>)
    ..error = json['error'] as String?
    ..variables = UserProfileVariables.fromJson(
        json['Variables'] as Map<String, dynamic>);
}

Map<String, dynamic> _$UserProfileResultToJson(UserProfileResult instance) =>
    <String, dynamic>{
      'Version': instance.version,
      'Charset': instance.charset,
      'Message': instance.errorResult,
      'error': instance.error,
      'Variables': instance.variables,
    };

UserProfileVariables _$UserProfileVariablesFromJson(Map<String, dynamic> json) {
  return UserProfileVariables()
    ..groupId =
        const StringToIntConverter().fromJson(json['groupid'] as String?)
    ..readAccess =
        const StringToIntConverter().fromJson(json['readaccess'] as String?)
    ..formHash = json['formhash'] as String
    ..noticeCount = NoticeCount.fromJson(json['notice'] as Map<String, dynamic>)
    ..space = json['space'] == null
        ? null
        : SpaceVariables.fromJson(json['space'] as Map<String, dynamic>)
    ..extendCreditMap = (json['extcredits'] as Map<String, dynamic>?)?.map(
          (k, e) =>
              MapEntry(k, ExtendCredit.fromJson(e as Map<String, dynamic>)),
        ) ??
        {};
}

Map<String, dynamic> _$UserProfileVariablesToJson(
        UserProfileVariables instance) =>
    <String, dynamic>{
      'groupid': const StringToIntConverter().toJson(instance.groupId),
      'readaccess': const StringToIntConverter().toJson(instance.readAccess),
      'formhash': instance.formHash,
      'notice': instance.noticeCount,
      'space': instance.space,
      'extcredits': instance.extendCreditMap,
    };

SpaceVariables _$SpaceVariablesFromJson(Map<String, dynamic> json) {
  return SpaceVariables()
    ..uid = const StringToIntConverter().fromJson(json['uid'] as String?)
    ..username = json['username'] as String
    ..status = const StringToIntConverter().fromJson(json['status'] as String?)
    ..registerDateString = json['regdate'] as String? ?? ''
    ..credits =
        const StringToIntConverter().fromJson(json['credits'] as String?)
    ..extcredits1 =
        const StringToIntConverter().fromJson(json['extcredits1'] as String?)
    ..extcredits2 =
        const StringToIntConverter().fromJson(json['extcredits2'] as String?)
    ..extcredits3 =
        const StringToIntConverter().fromJson(json['extcredits3'] as String?)
    ..extcredits4 =
        const StringToIntConverter().fromJson(json['extcredits4'] as String?)
    ..extcredits5 =
        const StringToIntConverter().fromJson(json['extcredits5'] as String?)
    ..extcredits6 =
        const StringToIntConverter().fromJson(json['extcredits6'] as String?)
    ..extcredits7 =
        const StringToIntConverter().fromJson(json['extcredits7'] as String?)
    ..extcredits8 =
        const StringToIntConverter().fromJson(json['extcredits8'] as String?)
    ..friends =
        const StringToIntConverter().fromJson(json['friends'] as String?)
    ..posts = const StringToIntConverter().fromJson(json['posts'] as String?)
    ..threads =
        const StringToIntConverter().fromJson(json['threads'] as String?)
    ..digestposts =
        const StringToIntConverter().fromJson(json['digestposts'] as String?)
    ..oltime = const StringToIntConverter().fromJson(json['oltime'] as String?)
    ..recentNote = json['recentnote'] as String? ?? ''
    ..customStatus = json['customstatus'] as String? ?? ''
    ..medalList = const MedalListConverter().fromJson(json['medals'])
    ..signatureHtml = json['sightml'] as String? ?? ''
    ..male = const StringToBoolConverter().fromJson(json['gender'] as String?)
    ..birthYear =
        const StringToIntConverter().fromJson(json['birthyear'] as String?)
    ..birthMonth =
        const StringToIntConverter().fromJson(json['birthmonth'] as String?)
    ..birthDay =
        const StringToIntConverter().fromJson(json['birthday'] as String?)
    ..constellation = json['constellation'] as String? ?? ''
    ..zodiac = json['zodiac'] as String? ?? ''
    ..nationality = json['nationality'] as String? ?? ''
    ..birthprovince = json['birthprovince'] as String? ?? ''
    ..birthcity = json['birthcity'] as String? ?? ''
    ..birthdist = json['birthdist'] as String? ?? ''
    ..birthcommunity = json['birthcommunity'] as String? ?? ''
    ..resideprovince = json['resideprovince'] as String? ?? ''
    ..residecity = json['residecity'] as String? ?? ''
    ..residedist = json['residedist'] as String? ?? ''
    ..residecommunity = json['residecommunity'] as String? ?? ''
    ..residesuite = json['residesuite'] as String? ?? ''
    ..graduateschool = json['graduateschool'] as String? ?? ''
    ..education = json['education'] as String? ?? ''
    ..company = json['company'] as String? ?? ''
    ..occupation = json['occupation'] as String? ?? ''
    ..position = json['position'] as String? ?? ''
    ..revenue = json['revenue'] as String? ?? ''
    ..lookingfor = json['lookingfor'] as String? ?? ''
    ..bloodtype = json['bloodtype'] as String? ?? ''
    ..height = json['height'] as String? ?? ''
    ..weight = json['weight'] as String? ?? ''
    ..site = json['site'] as String? ?? ''
    ..lastvisit = json['lastvisit'] as String? ?? ''
    ..lastactivity = json['lastactivity'] as String? ?? ''
    ..lastpost = json['lastpost'] as String? ?? ''
    ..lastsendmail = json['lastsendmail'] as String? ?? ''
    ..favtimes =
        const StringToIntConverter().fromJson(json['favtimes'] as String?)
    ..sharetimes =
        const StringToIntConverter().fromJson(json['sharetimes'] as String?)
    ..profileprogress = const StringToIntConverter()
        .fromJson(json['profileprogress'] as String?)
    ..adminGroupInfo =
        AdminGroupInfo.fromJson(json['admingroup'] as Map<String, dynamic>)
    ..groupInfo = GroupInfo.fromJson(json['group'] as Map<String, dynamic>)
    ..bio = json['bio'] as String
    ..interest = json['interest'] as String;
}

Map<String, dynamic> _$SpaceVariablesToJson(SpaceVariables instance) =>
    <String, dynamic>{
      'uid': const StringToIntConverter().toJson(instance.uid),
      'username': instance.username,
      'status': const StringToIntConverter().toJson(instance.status),
      'regdate': instance.registerDateString,
      'credits': const StringToIntConverter().toJson(instance.credits),
      'extcredits1': const StringToIntConverter().toJson(instance.extcredits1),
      'extcredits2': const StringToIntConverter().toJson(instance.extcredits2),
      'extcredits3': const StringToIntConverter().toJson(instance.extcredits3),
      'extcredits4': const StringToIntConverter().toJson(instance.extcredits4),
      'extcredits5': const StringToIntConverter().toJson(instance.extcredits5),
      'extcredits6': const StringToIntConverter().toJson(instance.extcredits6),
      'extcredits7': const StringToIntConverter().toJson(instance.extcredits7),
      'extcredits8': const StringToIntConverter().toJson(instance.extcredits8),
      'friends': const StringToIntConverter().toJson(instance.friends),
      'posts': const StringToIntConverter().toJson(instance.posts),
      'threads': const StringToIntConverter().toJson(instance.threads),
      'digestposts': const StringToIntConverter().toJson(instance.digestposts),
      'oltime': const StringToIntConverter().toJson(instance.oltime),
      'recentnote': instance.recentNote,
      'customstatus': instance.customStatus,
      'medals': const MedalListConverter().toJson(instance.medalList),
      'sightml': instance.signatureHtml,
      'gender': const StringToBoolConverter().toJson(instance.male),
      'birthyear': const StringToIntConverter().toJson(instance.birthYear),
      'birthmonth': const StringToIntConverter().toJson(instance.birthMonth),
      'birthday': const StringToIntConverter().toJson(instance.birthDay),
      'constellation': instance.constellation,
      'zodiac': instance.zodiac,
      'nationality': instance.nationality,
      'birthprovince': instance.birthprovince,
      'birthcity': instance.birthcity,
      'birthdist': instance.birthdist,
      'birthcommunity': instance.birthcommunity,
      'resideprovince': instance.resideprovince,
      'residecity': instance.residecity,
      'residedist': instance.residedist,
      'residecommunity': instance.residecommunity,
      'residesuite': instance.residesuite,
      'graduateschool': instance.graduateschool,
      'education': instance.education,
      'company': instance.company,
      'occupation': instance.occupation,
      'position': instance.position,
      'revenue': instance.revenue,
      'lookingfor': instance.lookingfor,
      'bloodtype': instance.bloodtype,
      'height': instance.height,
      'weight': instance.weight,
      'site': instance.site,
      'lastvisit': instance.lastvisit,
      'lastactivity': instance.lastactivity,
      'lastpost': instance.lastpost,
      'lastsendmail': instance.lastsendmail,
      'favtimes': const StringToIntConverter().toJson(instance.favtimes),
      'sharetimes': const StringToIntConverter().toJson(instance.sharetimes),
      'profileprogress':
          const StringToIntConverter().toJson(instance.profileprogress),
      'admingroup': instance.adminGroupInfo,
      'group': instance.groupInfo,
      'bio': instance.bio,
      'interest': instance.interest,
    };

Medal _$MedalFromJson(Map<String, dynamic> json) {
  return Medal()
    ..name = json['name'] as String
    ..image = json['image'] as String
    ..description = json['description'] as String
    ..medalId =
        const StringToIntConverter().fromJson(json['medalid'] as String?);
}

Map<String, dynamic> _$MedalToJson(Medal instance) => <String, dynamic>{
      'name': instance.name,
      'image': instance.image,
      'description': instance.description,
      'medalid': const StringToIntConverter().toJson(instance.medalId),
    };

AdminGroupInfo _$AdminGroupInfoFromJson(Map<String, dynamic> json) {
  return AdminGroupInfo()
    ..type = json['type'] as String? ?? ''
    ..groupTitle = json['grouptitle'] as String? ?? ''
    ..stars = const StringToIntConverter().fromJson(json['stars'] as String?)
    ..icon = json['icon'] as String? ?? ''
    ..color = json['color'] as String? ?? ''
    ..readAccess =
        const StringToIntConverter().fromJson(json['readaccess'] as String?);
}

Map<String, dynamic> _$AdminGroupInfoToJson(AdminGroupInfo instance) =>
    <String, dynamic>{
      'type': instance.type,
      'grouptitle': instance.groupTitle,
      'stars': const StringToIntConverter().toJson(instance.stars),
      'icon': instance.icon,
      'color': instance.color,
      'readaccess': const StringToIntConverter().toJson(instance.readAccess),
    };

GroupInfo _$GroupInfoFromJson(Map<String, dynamic> json) {
  return GroupInfo()
    ..type = json['type'] as String? ?? ''
    ..groupTitle = json['grouptitle'] as String
    ..stars = const StringToIntConverter().fromJson(json['stars'] as String?)
    ..icon = json['icon'] as String? ?? ''
    ..color = json['color'] as String? ?? ''
    ..readAccess =
        const StringToIntConverter().fromJson(json['readaccess'] as String?);
}

Map<String, dynamic> _$GroupInfoToJson(GroupInfo instance) => <String, dynamic>{
      'type': instance.type,
      'grouptitle': instance.groupTitle,
      'stars': const StringToIntConverter().toJson(instance.stars),
      'icon': instance.icon,
      'color': instance.color,
      'readaccess': const StringToIntConverter().toJson(instance.readAccess),
    };

ExtendCredit _$ExtendCreditFromJson(Map<String, dynamic> json) {
  return ExtendCredit()
    ..img = json['img'] as String? ?? ''
    ..title = json['title'] as String? ?? ''
    ..unit = json['unit'] as String? ?? ''
    ..ratio = json['ratio'] as String? ?? ''
    ..showInThread = json['showinthread'] as String? ?? ''
    ..allowExchangeIn = json['allowexchangein'] as String? ?? ''
    ..allowExchangeOut = json['allowexchangeout'] as String? ?? '';
}

Map<String, dynamic> _$ExtendCreditToJson(ExtendCredit instance) =>
    <String, dynamic>{
      'img': instance.img,
      'title': instance.title,
      'unit': instance.unit,
      'ratio': instance.ratio,
      'showinthread': instance.showInThread,
      'allowexchangein': instance.allowExchangeIn,
      'allowexchangeout': instance.allowExchangeOut,
    };
