// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'DisplayForumResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DisplayForumResult _$DisplayForumResultFromJson(Map<String, dynamic> json) {
  return DisplayForumResult()
    ..version = json['Version'] as String
    ..charset = json['Charset'] as String
    ..errorResult = json['Message'] == null
        ? null
        : ErrorResult.fromJson(json['Message'] as Map<String, dynamic>)
    ..error = json['error'] as String?
    ..discuzIndexVariables =
        ForumVariables.fromJson(json['Variables'] as Map<String, dynamic>);
}

Map<String, dynamic> _$DisplayForumResultToJson(DisplayForumResult instance) =>
    <String, dynamic>{
      'Version': instance.version,
      'Charset': instance.charset,
      'Message': instance.errorResult,
      'error': instance.error,
      'Variables': instance.discuzIndexVariables,
    };

ForumVariables _$ForumVariablesFromJson(Map<String, dynamic> json) {
  return ForumVariables()
    ..cookiepre = json['cookiepre'] as String
    ..auth = json['auth'] as String?
    ..saltkey = json['saltkey'] as String
    ..member_username = json['member_username'] as String
    ..member_avatar = json['member_avatar'] as String
    ..member_uid = json['member_uid'] as String
    ..groupid = json['groupid'] as String
    ..readaccess = json['readaccess'] as String
    ..ismoderator = json['ismoderator'] as String?
    ..noticeCount = NoticeCount.fromJson(json['notice'] as Map<String, dynamic>)
    ..forum = ForumDetail.fromJson(json['forum'] as Map<String, dynamic>)
    ..group = Group.fromJson(json['group'] as Map<String, dynamic>)
    ..forumThreadList = (json['forum_threadlist'] as List<dynamic>)
        .map((e) => ForumThread.fromJson(e as Map<String, dynamic>))
        .toList()
    ..tpp = json['tpp'] as String
    ..page = json['page'] as String? ?? '1'
    ..rewardUnit = json['reward_unit'] as String? ?? ''
    ..threadType = json['threadtypes'] == null
        ? null
        : ThreadType.fromJson(json['threadtypes'] as Map<String, dynamic>);
}

Map<String, dynamic> _$ForumVariablesToJson(ForumVariables instance) =>
    <String, dynamic>{
      'cookiepre': instance.cookiepre,
      'auth': instance.auth,
      'saltkey': instance.saltkey,
      'member_username': instance.member_username,
      'member_avatar': instance.member_avatar,
      'member_uid': instance.member_uid,
      'groupid': instance.groupid,
      'readaccess': instance.readaccess,
      'ismoderator': instance.ismoderator,
      'notice': instance.noticeCount,
      'forum': instance.forum,
      'group': instance.group,
      'forum_threadlist': instance.forumThreadList,
      'tpp': instance.tpp,
      'page': instance.page,
      'reward_unit': instance.rewardUnit,
      'threadtypes': instance.threadType,
    };

ForumDetail _$ForumDetailFromJson(Map<String, dynamic> json) {
  return ForumDetail()
    ..fid = json['fid'] as String
    ..fup = json['fup'] as String
    ..threads = json['threads'] as String
    ..posts = json['posts'] as String
    ..description = json['description'] as String? ?? ''
    ..rules = json['rules'] as String? ?? ''
    ..name = json['name'] as String? ?? ''
    ..password = json['password'] as String? ?? ''
    ..picStyle = json['picstyle'] as String? ?? ''
    ..autoClose = json['autoclose'] as String? ?? ''
    ..threadCount = json['threadcount'] as String? ?? '0'
    ..iconUrl = json['icon'] as String? ?? ''
    ..todayPosts = json['todayposts'] as String? ?? '0'
    ..redirectURL = json['redirect'] as String? ?? '';
}

Map<String, dynamic> _$ForumDetailToJson(ForumDetail instance) =>
    <String, dynamic>{
      'fid': instance.fid,
      'fup': instance.fup,
      'threads': instance.threads,
      'posts': instance.posts,
      'description': instance.description,
      'rules': instance.rules,
      'name': instance.name,
      'password': instance.password,
      'picstyle': instance.picStyle,
      'autoclose': instance.autoClose,
      'threadcount': instance.threadCount,
      'icon': instance.iconUrl,
      'todayposts': instance.todayPosts,
      'redirect': instance.redirectURL,
    };

Group _$GroupFromJson(Map<String, dynamic> json) {
  return Group()
    ..groupId = json['groupid'] as String
    ..groupTitle = json['grouptitle'] as String?;
}

Map<String, dynamic> _$GroupToJson(Group instance) => <String, dynamic>{
      'groupid': instance.groupId,
      'grouptitle': instance.groupTitle,
    };

ThreadType _$ThreadTypeFromJson(Map<String, dynamic> json) {
  return ThreadType()
    ..required = json['required'] as String
    ..listable = json['listable'] as String
    ..prefix = json['prefix'] as String? ?? ''
    ..idNameMap = (json['types'] as Map<String, dynamic>?)?.map(
          (k, e) => MapEntry(k, e as String),
        ) ??
        {}
    ..idIconMap = (json['icons'] as Map<String, dynamic>?)?.map(
          (k, e) => MapEntry(k, e as String),
        ) ??
        {}
    ..idModeratorMap = (json['moderators'] as Map<String, dynamic>?)?.map(
          (k, e) => MapEntry(k, e as String?),
        ) ??
        {};
}

Map<String, dynamic> _$ThreadTypeToJson(ThreadType instance) =>
    <String, dynamic>{
      'required': instance.required,
      'listable': instance.listable,
      'prefix': instance.prefix,
      'types': instance.idNameMap,
      'icons': instance.idIconMap,
      'moderators': instance.idModeratorMap,
    };
