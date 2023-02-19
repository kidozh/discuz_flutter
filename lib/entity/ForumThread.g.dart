// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ForumThread.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForumThread _$ForumThreadFromJson(Map<String, dynamic> json) => ForumThread()
  ..tid = json['tid'] as String
  ..typeId = json['typeid'] as String
  ..price = json['price'] as String? ?? '0'
  ..readPerm =
      const StringToIntConverter().fromJson(json['readperm'] as String?)
  ..author = json['author'] as String
  ..authorId = json['authorid'] as String
  ..subject = json['subject'] as String
  ..dateline = json['dateline'] as String
  ..lastpost = json['lastpost'] as String
  ..lastposter = json['lastposter'] as String? ?? ''
  ..views = json['views'] as String
  ..replies = json['replies'] as String
  ..displayOrder = json['displayorder'] as String
  ..digest = json['digest'] as String
  ..special = json['special'] as String
  ..attachment = json['attachment'] as String
  ..replyCredit = json['replycredit'] as String
  ..dbdatelineMinutes =
      const SecondToDateTimeConverter().fromJson(json['dbdateline'] as String?)
  ..dblastpostMinutes = json['dblastpost'] as String
  ..reply = (json['reply'] as List<dynamic>?)
          ?.map((e) => ShortReply.fromJson(e as Map<String, dynamic>))
          .toList() ??
      []
  ..message = json['message'] as String? ?? ''
  ..attachmentImageNumber = json['attachmentImageNumber'] == null
      ? 0
      : const StringToIntConverter()
          .fromJson(json['attachmentImageNumber'] as String?)
  ..attachmentImagePreviewList = (json['attachmentImagePreviewList']
              as List<dynamic>?)
          ?.map((e) => AttachmentPreview.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [];

Map<String, dynamic> _$ForumThreadToJson(ForumThread instance) =>
    <String, dynamic>{
      'tid': instance.tid,
      'typeid': instance.typeId,
      'price': instance.price,
      'readperm': const StringToIntConverter().toJson(instance.readPerm),
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
      'dbdateline':
          const SecondToDateTimeConverter().toJson(instance.dbdatelineMinutes),
      'dblastpost': instance.dblastpostMinutes,
      'reply': instance.reply,
      'message': instance.message,
      'attachmentImageNumber':
          const StringToIntConverter().toJson(instance.attachmentImageNumber),
      'attachmentImagePreviewList': instance.attachmentImagePreviewList,
    };

ShortReply _$ShortReplyFromJson(Map<String, dynamic> json) => ShortReply()
  ..pid = json['pid'] as String
  ..author = json['author'] as String
  ..authorId = json['authorid'] as String
  ..message = json['message'] as String
  ..avatar = json['avatar'] as String? ?? '';

Map<String, dynamic> _$ShortReplyToJson(ShortReply instance) =>
    <String, dynamic>{
      'pid': instance.pid,
      'author': instance.author,
      'authorid': instance.authorId,
      'message': instance.message,
      'avatar': instance.avatar,
    };

AttachmentPreview _$AttachmentPreviewFromJson(Map<String, dynamic> json) =>
    AttachmentPreview()
      ..dateline = json['dateline'] as String? ?? ''
      ..filename = json['filename'] as String? ?? ''
      ..attachment = json['attachment'] as String? ?? ''
      ..fileSize = json['filesize'] == null
          ? 0
          : const StringToIntConverter().fromJson(json['filesize'] as String?)
      ..description = json['description'] as String? ?? ''
      ..readPerm = json['readperm'] == null
          ? 0
          : const StringToIntConverter().fromJson(json['readperm'] as String?)
      ..width = json['width'] == null
          ? 0
          : const StringToIntConverter().fromJson(json['width'] as String?)
      ..height = json['height'] == null
          ? 0
          : const StringToIntConverter().fromJson(json['height'] as String?);

Map<String, dynamic> _$AttachmentPreviewToJson(AttachmentPreview instance) =>
    <String, dynamic>{
      'dateline': instance.dateline,
      'filename': instance.filename,
      'attachment': instance.attachment,
      'filesize': const StringToIntConverter().toJson(instance.fileSize),
      'description': instance.description,
      'readperm': const StringToIntConverter().toJson(instance.readPerm),
      'width': const StringToIntConverter().toJson(instance.width),
      'height': const StringToIntConverter().toJson(instance.height),
    };
