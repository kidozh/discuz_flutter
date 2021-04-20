// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ViewThreadResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ViewThreadResult _$ViewThreadResultFromJson(Map<String, dynamic> json) {
  return ViewThreadResult()
    ..version = json['Version'] as String
    ..charset = json['Charset'] as String
    ..errorResult = json['Message'] == null
        ? null
        : ErrorResult.fromJson(json['Message'] as Map<String, dynamic>)
    ..error = json['error'] as String?
    ..threadVariables =
        ThreadVariables.fromJson(json['Variables'] as Map<String, dynamic>);
}

Map<String, dynamic> _$ViewThreadResultToJson(ViewThreadResult instance) =>
    <String, dynamic>{
      'Version': instance.version,
      'Charset': instance.charset,
      'Message': instance.errorResult,
      'error': instance.error,
      'Variables': instance.threadVariables,
    };

ThreadVariables _$ThreadVariablesFromJson(Map<String, dynamic> json) {
  return ThreadVariables()
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
    ..threadInfo =
        DetailedThreadInfo.fromJson(json['thread'] as Map<String, dynamic>)
    ..postList = (json['postlist'] as List<dynamic>?)
            ?.map((e) => Post.fromJson(e as Map<String, dynamic>))
            .toList() ??
        []
    ..allowPostCommentList = (json['allowpostcomment'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        []
    ..page = json['page'] as String? ?? '1';
}

Map<String, dynamic> _$ThreadVariablesToJson(ThreadVariables instance) =>
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
      'thread': instance.threadInfo,
      'postlist': instance.postList,
      'allowpostcomment': instance.allowPostCommentList,
      'page': instance.page,
    };

DetailedThreadInfo _$DetailedThreadInfoFromJson(Map<String, dynamic> json) {
  return DetailedThreadInfo()
    ..postableId = json['posttableid'] as String
    ..typeId = json['typeid'] as String
    ..authorId =
        const StringToIntConverter().fromJson(json['authorid'] as String)
    ..sortId = json['sortid'] as String
    ..lastPostTime = json['dateline'] as String
    ..lastPostTimeString = json['lastpost'] as String
    ..displayOrder = json['displayorder'] as String
    ..replies = const StringToIntConverter().fromJson(json['replies'] as String)
    ..stickReply = json['stickreply'] as String
    ..recommends = json['recommends'] as String? ?? '0'
    ..recommend_add = json['recommend_add'] as String? ?? '0'
    ..recommend_sub = json['recommend_sub'] as String? ?? '0'
    ..replyCredit = json['replycredit'] as String
    ..maxPosition = json['maxposition'] as String
    ..comments = json['comments'] as String
    ..allreplies = json['allreplies'] as String
    ..recommendLevel = json['recommendlevel'] as String? ?? '0'
    ..heatLevel = json['heatlevel'] as String? ?? '0'
    ..freeMessage = json['freemessage'] as String? ?? ''
    ..creditRule = json['replycredit_rule'] == null
        ? null
        : ReplyCreditRule.fromJson(
            json['replycredit_rule'] as Map<String, dynamic>);
}

Map<String, dynamic> _$DetailedThreadInfoToJson(DetailedThreadInfo instance) =>
    <String, dynamic>{
      'posttableid': instance.postableId,
      'typeid': instance.typeId,
      'authorid': const StringToIntConverter().toJson(instance.authorId),
      'sortid': instance.sortId,
      'dateline': instance.lastPostTime,
      'lastpost': instance.lastPostTimeString,
      'displayorder': instance.displayOrder,
      'replies': const StringToIntConverter().toJson(instance.replies),
      'stickreply': instance.stickReply,
      'recommends': instance.recommends,
      'recommend_add': instance.recommend_add,
      'recommend_sub': instance.recommend_sub,
      'replycredit': instance.replyCredit,
      'maxposition': instance.maxPosition,
      'comments': instance.comments,
      'allreplies': instance.allreplies,
      'recommendlevel': instance.recommendLevel,
      'heatlevel': instance.heatLevel,
      'freemessage': instance.freeMessage,
      'replycredit_rule': instance.creditRule,
    };

ReplyCreditRule _$ReplyCreditRuleFromJson(Map<String, dynamic> json) {
  return ReplyCreditRule();
}

Map<String, dynamic> _$ReplyCreditRuleToJson(ReplyCreditRule instance) =>
    <String, dynamic>{};

Comment _$CommentFromJson(Map<String, dynamic> json) {
  return Comment()
    ..authorId =
        const StringToIntConverter().fromJson(json['authorid'] as String);
}

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
      'authorid': const StringToIntConverter().toJson(instance.authorId),
    };
