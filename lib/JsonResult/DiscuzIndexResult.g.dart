// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'DiscuzIndexResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiscuzIndexResult _$DiscuzIndexResultFromJson(Map<String, dynamic> json) {
  return DiscuzIndexResult()
    ..version = json['Version'] as String
    ..charset = json['Charset'] as String
    ..errorResult = json['Message'] == null
        ? null
        : ErrorResult.fromJson(json['Message'] as Map<String, dynamic>)
    ..error = json['error'] as String?
    ..discuzIndexVariables = DiscuzIndexVariables.fromJson(
        json['Variables'] as Map<String, dynamic>);
}

Map<String, dynamic> _$DiscuzIndexResultToJson(DiscuzIndexResult instance) =>
    <String, dynamic>{
      'Version': instance.version,
      'Charset': instance.charset,
      'Message': instance.errorResult,
      'error': instance.error,
      'Variables': instance.discuzIndexVariables,
    };

DiscuzIndexVariables _$DiscuzIndexVariablesFromJson(Map<String, dynamic> json) {
  return DiscuzIndexVariables()
    ..cookiepre = json['cookiepre'] as String
    ..auth = json['auth'] as String?
    ..saltkey = json['saltkey'] as String
    ..member_username = json['member_username'] as String
    ..member_avatar = json['member_avatar'] as String
    ..member_uid =
        const StringToIntConverter().fromJson(json['member_uid'] as String)
    ..groupId = const StringToIntConverter().fromJson(json['groupid'] as String)
    ..readAccess =
        const StringToIntConverter().fromJson(json['readaccess'] as String)
    ..ismoderator = json['ismoderator'] as String?
    ..noticeCount = NoticeCount.fromJson(json['notice'] as Map<String, dynamic>)
    ..memberEmail = json['member_email'] as String?
    ..memberCredits = json['member_credits'] as String
    ..bbClosed = json['setting_bbclosed'] as String
    ..groupInfo = GroupInfo.fromJson(json['group'] as Map<String, dynamic>)
    ..forumPartitionList = (json['catlist'] as List<dynamic>)
        .map((e) => ForumPartition.fromJson(e as Map<String, dynamic>))
        .toList()
    ..forumList = (json['forumlist'] as List<dynamic>)
        .map((e) => Forum.fromJson(e as Map<String, dynamic>))
        .toList();
}

Map<String, dynamic> _$DiscuzIndexVariablesToJson(
        DiscuzIndexVariables instance) =>
    <String, dynamic>{
      'cookiepre': instance.cookiepre,
      'auth': instance.auth,
      'saltkey': instance.saltkey,
      'member_username': instance.member_username,
      'member_avatar': instance.member_avatar,
      'member_uid': const StringToIntConverter().toJson(instance.member_uid),
      'groupid': const StringToIntConverter().toJson(instance.groupId),
      'readaccess': const StringToIntConverter().toJson(instance.readAccess),
      'ismoderator': instance.ismoderator,
      'notice': instance.noticeCount,
      'member_email': instance.memberEmail,
      'member_credits': instance.memberCredits,
      'setting_bbclosed': instance.bbClosed,
      'group': instance.groupInfo,
      'catlist': instance.forumPartitionList,
      'forumlist': instance.forumList,
    };

GroupInfo _$GroupInfoFromJson(Map<String, dynamic> json) {
  return GroupInfo()
    ..groupId = json['groupid'] as String
    ..groupTitle = json['grouptitle'] as String
    ..allowThreadPlugins = (json['allowthreadplugin'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [];
}

Map<String, dynamic> _$GroupInfoToJson(GroupInfo instance) => <String, dynamic>{
      'groupid': instance.groupId,
      'grouptitle': instance.groupTitle,
      'allowthreadplugin': instance.allowThreadPlugins,
    };

ForumPartition _$ForumPartitionFromJson(Map<String, dynamic> json) {
  return ForumPartition()
    ..fid = json['fid'] as String
    ..name = json['name'] as String
    ..forumIdList =
        (json['forums'] as List<dynamic>).map((e) => e as String).toList();
}

Map<String, dynamic> _$ForumPartitionToJson(ForumPartition instance) =>
    <String, dynamic>{
      'fid': instance.fid,
      'name': instance.name,
      'forums': instance.forumIdList,
    };

Forum _$ForumFromJson(Map<String, dynamic> json) {
  return Forum()
    ..fid = json['fid'] as String
    ..description = json['description'] as String? ?? ''
    ..name = json['name'] as String
    ..threads = json['threads'] as String
    ..posts = json['posts'] as String
    ..iconUrl = json['icon'] as String? ?? ''
    ..todayPosts = json['todayposts'] as String
    ..subForumList = (json['sublist'] as List<dynamic>?)
            ?.map((e) => Forum.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
}

Map<String, dynamic> _$ForumToJson(Forum instance) => <String, dynamic>{
      'fid': instance.fid,
      'description': instance.description,
      'name': instance.name,
      'threads': instance.threads,
      'posts': instance.posts,
      'icon': instance.iconUrl,
      'todayposts': instance.todayPosts,
      'sublist': instance.subForumList,
    };
