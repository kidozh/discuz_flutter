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
    ..readPerm =
        const StringToIntConverter().fromJson(json['readperm'] as String)
    ..authorId =
        const StringToIntConverter().fromJson(json['authorid'] as String)
    ..sortId = json['sortid'] as String
    ..lastPostTime = json['dateline'] as String
    ..lastPostTimeString = json['lastpost'] as String
    ..lastposter = json['lastposter'] as String? ?? ''
    ..displayOrder = json['displayorder'] as String
    ..replies = const StringToIntConverter().fromJson(json['replies'] as String)
    ..highlight = json['highlight'] as String? ?? ''
    ..special = json['special'] as String? ?? '0'
    ..moderated = json['moderated'] as String? ?? '0'
    ..is_archived = json['is_archived'] as String? ?? '0'
    ..rate = json['rate'] as String? ?? '0'
    ..status = json['status'] as String? ?? '0'
    ..digest = json['digest'] as String? ?? '0'
    ..closed = json['closed'] as String? ?? '0'
    ..attachment = json['attachment'] as String? ?? '0'
    ..stickReply = json['stickreply'] as String
    ..recommends = json['recommends'] as String? ?? '0'
    ..recommend_add = json['recommend_add'] as String? ?? '0'
    ..recommend_sub = json['recommend_sub'] as String? ?? '0'
    ..favtimes = json['favtimes'] as String? ?? '0'
    ..sharedtimes = json['sharedtimes'] as String? ?? '0'
    ..heats = json['heats'] as String? ?? '0'
    ..stamp = json['stamp'] as String? ?? '0'
    ..icon = json['icon'] as String? ?? '0'
    ..pushedaid = json['pushedaid'] as String? ?? '0'
    ..cover = json['cover'] as String? ?? '0'
    ..replyCredit = json['replycredit'] as String
    ..relatebytag = json['relatebytag'] as String? ?? ''
    ..bgcolor = json['bgcolor'] as String? ?? ''
    ..maxPosition = json['maxposition'] as String
    ..comments = json['comments'] as String? ?? '0'
    ..hidden = json['hidden'] as String? ?? '0'
    ..allreplies = json['allreplies'] as String
    ..archiveid = json['archiveid'] as String? ?? ''
    ..subjectenc = json['subjectenc'] as String? ?? ''
    ..short_subject = json['short_subject'] as String? ?? ''
    ..relay = json['relay'] as String? ?? ''
    ..ordertype = json['ordertype'] as String? ?? ''
    ..recommend = json['recommend'] as String? ?? ''
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
      'readperm': const StringToIntConverter().toJson(instance.readPerm),
      'authorid': const StringToIntConverter().toJson(instance.authorId),
      'sortid': instance.sortId,
      'dateline': instance.lastPostTime,
      'lastpost': instance.lastPostTimeString,
      'lastposter': instance.lastposter,
      'displayorder': instance.displayOrder,
      'replies': const StringToIntConverter().toJson(instance.replies),
      'highlight': instance.highlight,
      'special': instance.special,
      'moderated': instance.moderated,
      'is_archived': instance.is_archived,
      'rate': instance.rate,
      'status': instance.status,
      'digest': instance.digest,
      'closed': instance.closed,
      'attachment': instance.attachment,
      'stickreply': instance.stickReply,
      'recommends': instance.recommends,
      'recommend_add': instance.recommend_add,
      'recommend_sub': instance.recommend_sub,
      'favtimes': instance.favtimes,
      'sharedtimes': instance.sharedtimes,
      'heats': instance.heats,
      'stamp': instance.stamp,
      'icon': instance.icon,
      'pushedaid': instance.pushedaid,
      'cover': instance.cover,
      'replycredit': instance.replyCredit,
      'relatebytag': instance.relatebytag,
      'bgcolor': instance.bgcolor,
      'maxposition': instance.maxPosition,
      'comments': instance.comments,
      'hidden': instance.hidden,
      'allreplies': instance.allreplies,
      'archiveid': instance.archiveid,
      'subjectenc': instance.subjectenc,
      'short_subject': instance.short_subject,
      'relay': instance.relay,
      'ordertype': instance.ordertype,
      'recommend': instance.recommend,
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
