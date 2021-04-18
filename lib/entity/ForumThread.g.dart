// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ForumThread.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForumThread _$ForumThreadFromJson(Map<String, dynamic> json) {
  return ForumThread()
    ..tid = json['tid'] as String
    ..typeId = json['typeid'] as String
    ..price = json['price'] as String? ?? '0'
    ..readPerm = json['readperm'] as String
    ..author = json['author'] as String
    ..authorId = json['authorid'] as String
    ..subject = json['subject'] as String
    ..dateline = json['dateline'] as String
    ..lastpost = json['lastpost'] as String
    ..lastposter = json['lastposter'] as String
    ..views = json['views'] as String
    ..replies = json['replies'] as String
    ..displayOrder = json['displayorder'] as String
    ..digest = json['digest'] as String
    ..special = json['special'] as String
    ..attachment = json['attachment'] as String
    ..replyCredit = json['replycredit'] as String
    ..dbdatelineMinutes = json['dbdateline'] as String
    ..dblastpostMinutes = json['dblastpost'] as String
    ..reply = (json['reply'] as List<dynamic>?)
            ?.map((e) => ShortReply.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
}

Map<String, dynamic> _$ForumThreadToJson(ForumThread instance) =>
    <String, dynamic>{
      'tid': instance.tid,
      'typeid': instance.typeId,
      'price': instance.price,
      'readperm': instance.readPerm,
      'author': instance.author,
      'authorid': instance.authorId,
      'subject': instance.subject,
      'dateline': instance.dateline,
      'lastpost': instance.lastpost,
      'lastposter': instance.lastposter,
      'views': instance.views,
      'replies': instance.replies,
      'displayorder': instance.displayOrder,
      'digest': instance.digest,
      'special': instance.special,
      'attachment': instance.attachment,
      'replycredit': instance.replyCredit,
      'dbdateline': instance.dbdatelineMinutes,
      'dblastpost': instance.dblastpostMinutes,
      'reply': instance.reply,
    };

ShortReply _$ShortReplyFromJson(Map<String, dynamic> json) {
  return ShortReply()
    ..pid = json['pid'] as String
    ..author = json['author'] as String
    ..authorId = json['authorid'] as String
    ..message = json['message'] as String
    ..avatar = json['avatar'] as String? ?? '';
}

Map<String, dynamic> _$ShortReplyToJson(ShortReply instance) =>
    <String, dynamic>{
      'pid': instance.pid,
      'author': instance.author,
      'authorid': instance.authorId,
      'message': instance.message,
      'avatar': instance.avatar,
    };
