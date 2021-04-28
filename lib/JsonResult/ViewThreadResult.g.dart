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
    ..member_uid =
        const StringToIntConverter().fromJson(json['member_uid'] as String?)
    ..groupId =
        const StringToIntConverter().fromJson(json['groupid'] as String?)
    ..readAccess =
        const StringToIntConverter().fromJson(json['readaccess'] as String?)
    ..formHash = json['formhash'] as String
    ..ismoderator = json['ismoderator'] as String?
    ..noticeCount = NoticeCount.fromJson(json['notice'] as Map<String, dynamic>)
    ..threadInfo =
        DetailedThreadInfo.fromJson(json['thread'] as Map<String, dynamic>)
    ..fid = const StringToIntConverter().fromJson(json['fid'] as String?)
    ..postList = (json['postlist'] as List<dynamic>?)
            ?.map((e) => Post.fromJson(e as Map<String, dynamic>))
            .toList() ??
        []
    ..rewriteRule = json['setting_rewriterule'] == null
        ? null
        : RewriteRule.fromJson(
            json['setting_rewriterule'] as Map<String, dynamic>)
    ..ppp = json['ppp'] as String
    ..page = json['page'] as String? ?? '1';
}

Map<String, dynamic> _$ThreadVariablesToJson(ThreadVariables instance) =>
    <String, dynamic>{
      'cookiepre': instance.cookiepre,
      'auth': instance.auth,
      'saltkey': instance.saltkey,
      'member_username': instance.member_username,
      'member_avatar': instance.member_avatar,
      'member_uid': const StringToIntConverter().toJson(instance.member_uid),
      'groupid': const StringToIntConverter().toJson(instance.groupId),
      'readaccess': const StringToIntConverter().toJson(instance.readAccess),
      'formhash': instance.formHash,
      'ismoderator': instance.ismoderator,
      'notice': instance.noticeCount,
      'thread': instance.threadInfo,
      'fid': const StringToIntConverter().toJson(instance.fid),
      'postlist': instance.postList,
      'setting_rewriterule': instance.rewriteRule,
      'ppp': instance.ppp,
      'page': instance.page,
    };

DetailedThreadInfo _$DetailedThreadInfoFromJson(Map<String, dynamic> json) {
  return DetailedThreadInfo()
    ..tid = const StringToIntConverter().fromJson(json['tid'] as String?)
    ..fid = const StringToIntConverter().fromJson(json['fid'] as String?)
    ..author = json['author'] as String
    ..subject = json['subject'] as String
    ..readPerm =
        const StringToIntConverter().fromJson(json['readperm'] as String?)
    ..price = const StringToIntConverter().fromJson(json['price'] as String?)
    ..authorId =
        const StringToIntConverter().fromJson(json['authorid'] as String?)
    ..sortId = json['sortid'] as String
    ..lastPostTimeString = json['lastpost'] as String
    ..lastposter = json['lastposter'] as String? ?? ''
    ..displayOrder = json['displayorder'] as String
    ..views = json['views'] as String
    ..replies =
        const StringToIntConverter().fromJson(json['replies'] as String?)
    ..highlight = json['highlight'] as String? ?? ''
    ..rate = json['rate'] as String? ?? '0'
    ..status = json['status'] as String? ?? '0'
    ..digest = json['digest'] as String? ?? '0'
    ..closed = json['closed'] as String? ?? '0'
    ..allreplies =
        const StringToIntConverter().fromJson(json['allreplies'] as String?)
    ..freeMessage = json['freemessage'] as String? ?? '';
}

Map<String, dynamic> _$DetailedThreadInfoToJson(DetailedThreadInfo instance) =>
    <String, dynamic>{
      'tid': const StringToIntConverter().toJson(instance.tid),
      'fid': const StringToIntConverter().toJson(instance.fid),
      'author': instance.author,
      'subject': instance.subject,
      'readperm': const StringToIntConverter().toJson(instance.readPerm),
      'price': const StringToIntConverter().toJson(instance.price),
      'authorid': const StringToIntConverter().toJson(instance.authorId),
      'sortid': instance.sortId,
      'lastpost': instance.lastPostTimeString,
      'lastposter': instance.lastposter,
      'displayorder': instance.displayOrder,
      'views': instance.views,
      'replies': const StringToIntConverter().toJson(instance.replies),
      'highlight': instance.highlight,
      'rate': instance.rate,
      'status': instance.status,
      'digest': instance.digest,
      'closed': instance.closed,
      'allreplies': const StringToIntConverter().toJson(instance.allreplies),
      'freemessage': instance.freeMessage,
    };

ReplyCreditRule _$ReplyCreditRuleFromJson(Map<String, dynamic> json) {
  return ReplyCreditRule();
}

Map<String, dynamic> _$ReplyCreditRuleToJson(ReplyCreditRule instance) =>
    <String, dynamic>{};

Comment _$CommentFromJson(Map<String, dynamic> json) {
  return Comment()
    ..authorId =
        const StringToIntConverter().fromJson(json['authorid'] as String?);
}

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
      'authorid': const StringToIntConverter().toJson(instance.authorId),
    };

RewriteRule _$RewriteRuleFromJson(Map<String, dynamic> json) {
  return RewriteRule()
    ..portalTopic = json['portal_topic'] as String? ?? ''
    ..portalArticle = json['portal_article'] as String? ?? ''
    ..forumDisplay = json['forum_forumdisplay'] as String? ?? ''
    ..viewThread = json['forum_viewthread'] as String? ?? ''
    ..group = json['group_group'] as String? ?? ''
    ..userSpace = json['home_space'] as String? ?? ''
    ..homeBlog = json['home_blog'] as String? ?? ''
    ..forumArchiver = json['forum_archiver'] as String? ?? ''
    ..plugin = json['plugin'] as String? ?? '';
}

Map<String, dynamic> _$RewriteRuleToJson(RewriteRule instance) =>
    <String, dynamic>{
      'portal_topic': instance.portalTopic,
      'portal_article': instance.portalArticle,
      'forum_forumdisplay': instance.forumDisplay,
      'forum_viewthread': instance.viewThread,
      'group_group': instance.group,
      'home_space': instance.userSpace,
      'home_blog': instance.homeBlog,
      'forum_archiver': instance.forumArchiver,
      'plugin': instance.plugin,
    };
