// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ForumThread.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForumThread _$ForumThreadFromJson(Map<String, dynamic> json) => ForumThread()
  ..tid = json['tid'] as String
  ..typeId = json['typeid'] as String? ?? '0'
  ..price = json['price'] as String? ?? '0'
  ..readPerm = const StringToIntConverter().fromJson(json['readperm'])
  ..author = json['author'] as String? ?? ''
  ..authorId = json['authorid'] as String
  ..subject = json['subject'] as String? ?? ''
  ..dateline = json['dateline'] as String? ?? ''
  ..lastpost = json['lastpost'] as String? ?? ''
  ..lastposter = json['lastposter'] as String? ?? ''
  ..views = json['views'] as String? ?? ''
  ..replies = json['replies'] == null
      ? 0
      : const StringToIntConverter().fromJson(json['replies'])
  ..displayOrder = json['displayorder'] as String? ?? '0'
  ..digest = json['digest'] as String? ?? '0'
  ..special = json['special'] as String? ?? '0'
  ..attachment = json['attachment'] as String? ?? '0'
  ..coverPath = discuzString(json['coverpath'])
  ..replyCredit = json['replycredit'] as String? ?? '0'
  ..dbdatelineMinutes = const SecondToDateTimeConverter().fromJson(
    json['dbdateline'],
  )
  ..dblastpostMinutes = json['dblastpost'] as String
  ..reply =
      (json['reply'] as List<dynamic>?)
          ?.map((e) => ShortReply.fromJson(e as Map<String, dynamic>))
          .toList() ??
      []
  ..message = json['message'] as String? ?? ''
  ..attachmentImageNumber = json['attachmentImageNumber'] == null
      ? 0
      : const StringToIntConverter().fromJson(json['attachmentImageNumber'])
  ..attachmentImagePreviewList =
      (json['attachmentImagePreviewList'] as List<dynamic>?)
          ?.map(AttachmentPreview.fromJson)
          .toList() ??
      []
  ..typeName = json['typename'] as String? ?? '';

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
      'replies': const StringToIntConverter().toJson(instance.replies),
      'displayorder': instance.displayOrder,
      'digest': instance.digest,
      'special': instance.special,
      'attachment': instance.attachment,
      'coverpath': instance.coverPath,
      'replycredit': instance.replyCredit,
      'dbdateline': const SecondToDateTimeConverter().toJson(
        instance.dbdatelineMinutes,
      ),
      'dblastpost': instance.dblastpostMinutes,
      'reply': instance.reply,
      'message': instance.message,
      'attachmentImageNumber': const StringToIntConverter().toJson(
        instance.attachmentImageNumber,
      ),
      'attachmentImagePreviewList': instance.attachmentImagePreviewList,
      'typename': instance.typeName,
    };

ShortReply _$ShortReplyFromJson(Map<String, dynamic> json) => ShortReply()
  ..pid = json['pid'] as String
  ..author = json['author'] as String
  ..authorId = const StringToIntConverter().fromJson(json['authorid'])
  ..message = json['message'] as String;

Map<String, dynamic> _$ShortReplyToJson(ShortReply instance) =>
    <String, dynamic>{
      'pid': instance.pid,
      'author': instance.author,
      'authorid': const StringToIntConverter().toJson(instance.authorId),
      'message': instance.message,
    };

AttachmentPreview _$AttachmentPreviewFromJson(Map<String, dynamic> json) =>
    AttachmentPreview()
      ..aid = const StringToIntConverter().fromJson(json['aid'])
      ..tid = const StringToIntConverter().fromJson(json['tid'])
      ..pid = const StringToIntConverter().fromJson(json['pid'])
      ..uid = const StringToIntConverter().fromJson(json['uid'])
      ..dateline = json['dateline'] as String? ?? ''
      ..filename = json['filename'] as String? ?? ''
      ..attachment = json['attachment'] as String? ?? ''
      ..url = discuzString(json['url'])
      ..aidEncode = discuzString(json['aidencode'])
      ..remote = const StringToBoolConverter().fromJson(json['remote'])
      ..price = const StringToIntConverter().fromJson(json['price'])
      ..fileSize = json['filesize'] == null
          ? 0
          : const StringToIntConverter().fromJson(json['filesize'])
      ..description = json['description'] as String? ?? ''
      ..readPerm = json['readperm'] == null
          ? 0
          : const StringToIntConverter().fromJson(json['readperm'])
      ..width = json['width'] == null
          ? 0
          : const StringToIntConverter().fromJson(json['width'])
      ..height = json['height'] == null
          ? 0
          : const StringToIntConverter().fromJson(json['height']);

Map<String, dynamic> _$AttachmentPreviewToJson(AttachmentPreview instance) =>
    <String, dynamic>{
      'aid': const StringToIntConverter().toJson(instance.aid),
      'tid': const StringToIntConverter().toJson(instance.tid),
      'pid': const StringToIntConverter().toJson(instance.pid),
      'uid': const StringToIntConverter().toJson(instance.uid),
      'dateline': instance.dateline,
      'filename': instance.filename,
      'attachment': instance.attachment,
      'url': instance.url,
      'aidencode': instance.aidEncode,
      'remote': const StringToBoolConverter().toJson(instance.remote),
      'price': const StringToIntConverter().toJson(instance.price),
      'filesize': const StringToIntConverter().toJson(instance.fileSize),
      'description': instance.description,
      'readperm': const StringToIntConverter().toJson(instance.readPerm),
      'width': const StringToIntConverter().toJson(instance.width),
      'height': const StringToIntConverter().toJson(instance.height),
    };
