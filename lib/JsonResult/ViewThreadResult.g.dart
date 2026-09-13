// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ViewThreadResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ViewThreadResult _$ViewThreadResultFromJson(Map<String, dynamic> json) =>
    ViewThreadResult()
      ..version = json['Version'] as String? ?? ''
      ..charset = json['Charset'] as String? ?? ''
      ..errorResult = json['Message'] == null
          ? null
          : ErrorResult.fromJson(json['Message'] as Map<String, dynamic>)
      ..error = json['error'] as String?
      ..threadVariables = ThreadVariables.fromJson(
        json['Variables'] as Map<String, dynamic>,
      );

Map<String, dynamic> _$ViewThreadResultToJson(ViewThreadResult instance) =>
    <String, dynamic>{
      'Version': instance.version,
      'Charset': instance.charset,
      'Message': instance.errorResult?.toJson(),
      'error': instance.error,
      'Variables': instance.threadVariables.toJson(),
    };

ThreadVariables _$ThreadVariablesFromJson(Map<String, dynamic> json) =>
    ThreadVariables()
      ..cookiepre = json['cookiepre'] as String? ?? ''
      ..auth = json['auth'] as String?
      ..saltkey = json['saltkey'] as String? ?? ''
      ..member_username = json['member_username'] as String? ?? ''
      ..member_avatar = json['member_avatar'] as String? ?? ''
      ..member_uid = const StringToIntConverter().fromJson(json['member_uid'])
      ..groupId = const StringToIntConverter().fromJson(json['groupid'])
      ..readAccess = const StringToIntConverter().fromJson(json['readaccess'])
      ..formHash = json['formhash'] as String? ?? ''
      ..isModerator = const StringToIntConverter().fromJson(json['ismoderator'])
      ..noticeCount = noticeFromJson(json['notice'])
      ..threadInfo = DetailedThreadInfo.fromJson(
        json['thread'] as Map<String, dynamic>,
      )
      ..fid = const StringToIntConverter().fromJson(json['fid'])
      ..postList =
          (json['postlist'] as List<dynamic>?)
              ?.map((e) => Post.fromJson(e as Map<String, dynamic>))
              .toList() ??
          []
      ..commentModes = discuzIds(json['allowpostcomment'])
      ..commentList = const ViewThreadCommentConverter().fromJson(
        json['comments'],
      )
      ..rewriteRule = const RewriteRuleConverter().fromJson(
        json['setting_rewriterule'],
      )
      ..ppp = json['ppp'] as String? ?? '0'
      ..page = json['page'] as String? ?? '1'
      ..poll = json['special_poll'] == null
          ? null
          : Poll.fromJson(json['special_poll'] as Map<String, dynamic>)
      ..reward = RewardInfo.parse(json['special_reward'])
      ..activity = ActivityInfo.parse(json['special_activity'])
      ..threadSort = ThreadSortInfo.parse(json['threadsortshow'])
      ..threadPayRequired = const StringToBoolConverter().fromJson(
        json['forum_threadpay'],
      )
      ..commentCounts = discuzMap(json['commentcount']);

Map<String, dynamic> _$ThreadVariablesToJson(
  ThreadVariables instance,
) => <String, dynamic>{
  'cookiepre': instance.cookiepre,
  'auth': instance.auth,
  'saltkey': instance.saltkey,
  'member_username': instance.member_username,
  'member_avatar': instance.member_avatar,
  'member_uid': const StringToIntConverter().toJson(instance.member_uid),
  'groupid': const StringToIntConverter().toJson(instance.groupId),
  'readaccess': const StringToIntConverter().toJson(instance.readAccess),
  'formhash': instance.formHash,
  'ismoderator': const StringToIntConverter().toJson(instance.isModerator),
  'notice': instance.noticeCount.toJson(),
  'thread': instance.threadInfo.toJson(),
  'fid': const StringToIntConverter().toJson(instance.fid),
  'postlist': instance.postList.map((e) => e.toJson()).toList(),
  'allowpostcomment': instance.commentModes,
  'comments': const ViewThreadCommentConverter().toJson(instance.commentList),
  'setting_rewriterule': const RewriteRuleConverter().toJson(
    instance.rewriteRule,
  ),
  'ppp': instance.ppp,
  'page': instance.page,
  'special_poll': instance.poll?.toJson(),
  'special_reward': instance.reward?.toJson(),
  'special_activity': instance.activity?.toJson(),
  'threadsortshow': instance.threadSort?.toJson(),
  'forum_threadpay': const StringToBoolConverter().toJson(
    instance.threadPayRequired,
  ),
  'commentcount': instance.commentCounts,
};

DetailedThreadInfo _$DetailedThreadInfoFromJson(Map<String, dynamic> json) =>
    DetailedThreadInfo()
      ..special = const StringToIntConverter().fromJson(json['special'])
      ..recommendCount = const StringToIntConverter().fromJson(
        json['recommend_add'],
      )
      ..disrecommendCount = const StringToIntConverter().fromJson(
        json['recommend_sub'],
      )
      ..recommended = const StringToBoolConverter().fromJson(json['recommend'])
      ..tid = const StringToIntConverter().fromJson(json['tid'])
      ..fid = const StringToIntConverter().fromJson(json['fid'])
      ..author = json['author'] as String? ?? ''
      ..subject = json['subject'] as String? ?? ''
      ..readPerm = const StringToIntConverter().fromJson(json['readperm'])
      ..price = const StringToIntConverter().fromJson(json['price'])
      ..authorId = const StringToIntConverter().fromJson(json['authorid'])
      ..sortId = json['sortid'] as String? ?? '0'
      ..lastPostTimeString = json['lastpost'] as String? ?? ''
      ..lastposter = json['lastposter'] as String? ?? ''
      ..displayOrder = json['displayorder'] as String? ?? '0'
      ..views = json['views'] as String? ?? '0'
      ..replies = const StringToIntConverter().fromJson(json['replies'])
      ..highlight = json['highlight'] as String? ?? ''
      ..rate = json['rate'] as String? ?? '0'
      ..status = json['status'] as String? ?? '0'
      ..digest = json['digest'] as String? ?? '0'
      ..closed = const StringToBoolConverter().fromJson(json['closed'])
      ..allreplies = const StringToIntConverter().fromJson(json['allreplies'])
      ..freeMessage = json['freemessage'] as String? ?? '';

Map<String, dynamic> _$DetailedThreadInfoToJson(
  DetailedThreadInfo instance,
) => <String, dynamic>{
  'special': const StringToIntConverter().toJson(instance.special),
  'recommend_add': const StringToIntConverter().toJson(instance.recommendCount),
  'recommend_sub': const StringToIntConverter().toJson(
    instance.disrecommendCount,
  ),
  'recommend': const StringToBoolConverter().toJson(instance.recommended),
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
  'closed': const StringToBoolConverter().toJson(instance.closed),
  'allreplies': const StringToIntConverter().toJson(instance.allreplies),
  'freemessage': instance.freeMessage,
};

ReplyCreditRule _$ReplyCreditRuleFromJson(Map<String, dynamic> json) =>
    ReplyCreditRule();

Map<String, dynamic> _$ReplyCreditRuleToJson(ReplyCreditRule instance) =>
    <String, dynamic>{};

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment()
  ..id = const StringToIntConverter().fromJson(json['id'])
  ..tid = const StringToIntConverter().fromJson(json['tid'])
  ..pid = const StringToIntConverter().fromJson(json['pid'])
  ..author = json['author'] as String
  ..dateline = json['dateline'] as String
  ..comment = json['comment'] as String
  ..avatar = json['avatar'] as String
  ..authorId = const StringToIntConverter().fromJson(json['authorid']);

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
  'id': const StringToIntConverter().toJson(instance.id),
  'tid': const StringToIntConverter().toJson(instance.tid),
  'pid': const StringToIntConverter().toJson(instance.pid),
  'author': instance.author,
  'dateline': instance.dateline,
  'comment': instance.comment,
  'avatar': instance.avatar,
  'authorid': const StringToIntConverter().toJson(instance.authorId),
};

RewriteRule _$RewriteRuleFromJson(Map<String, dynamic> json) => RewriteRule()
  ..portalTopic = json['portal_topic'] as String? ?? ''
  ..portalArticle = json['portal_article'] as String? ?? ''
  ..forumDisplay = json['forum_forumdisplay'] as String? ?? ''
  ..viewThread = json['forum_viewthread'] as String? ?? ''
  ..group = json['group_group'] as String? ?? ''
  ..userSpace = json['home_space'] as String? ?? ''
  ..homeBlog = json['home_blog'] as String? ?? ''
  ..forumArchiver = json['forum_archiver'] as String? ?? ''
  ..plugin = json['plugin'] as String? ?? '';

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

Poll _$PollFromJson(Map<String, dynamic> json) => Poll()
  ..expiredAt = const SecondToDateTimeConverter().fromJson(json['expirations'])
  ..multipleChoice = const StringToBoolConverter().fromJson(json['multiple'])
  ..maxChoice = const StringToIntConverter().fromJson(json['maxchoices'])
  ..isResultVisible = const StringToBoolConverter().fromJson(
    json['visiblepoll'],
  )
  ..allowVote = const StringToBoolConverter().fromJson(json['allowvote'])
  ..votersCount = const StringToIntConverter().fromJson(json['voterscount'])
  ..pollOptionsMap =
      (json['polloptions'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, PollOption.fromJson(e as Map<String, dynamic>)),
      ) ??
      {};

Map<String, dynamic> _$PollToJson(Poll instance) => <String, dynamic>{
  'expirations': const SecondToDateTimeConverter().toJson(instance.expiredAt),
  'multiple': const StringToBoolConverter().toJson(instance.multipleChoice),
  'maxchoices': const StringToIntConverter().toJson(instance.maxChoice),
  'visiblepoll': const StringToBoolConverter().toJson(instance.isResultVisible),
  'allowvote': const StringToBoolConverter().toJson(instance.allowVote),
  'voterscount': const StringToIntConverter().toJson(instance.votersCount),
  'polloptions': instance.pollOptionsMap.map((k, e) => MapEntry(k, e.toJson())),
};

PollOption _$PollOptionFromJson(Map<String, dynamic> json) => PollOption()
  ..id = const StringToIntConverter().fromJson(json['polloptionid'])
  ..name = json['polloption'] as String? ?? ''
  ..voteNumber = const StringToIntConverter().fromJson(json['votes'])
  ..color = json['color'] as String? ?? 'EEEEEE';

Map<String, dynamic> _$PollOptionToJson(PollOption instance) =>
    <String, dynamic>{
      'polloptionid': const StringToIntConverter().toJson(instance.id),
      'polloption': instance.name,
      'votes': const StringToIntConverter().toJson(instance.voteNumber),
      'color': instance.color,
    };
