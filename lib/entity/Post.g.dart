// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) => Post()
  ..pid = const StringToIntConverter().fromJson(json['pid'])
  ..tid = const StringToIntConverter().fromJson(json['tid'])
  ..first = const StringToBoolConverter().fromJson(json['first'])
  ..anonymous = const StringToBoolConverter().fromJson(json['anonymous'])
  ..author = json['author'] as String? ?? ''
  ..dateline = json['dateline'] as String? ?? ''
  ..message = json['message'] as String? ?? ''
  ..ipLocation = json['ipLocation'] as String? ?? ''
  ..authorId = const StringToIntConverter().fromJson(json['authorid'])
  ..attachment = const StringToIntConverter().fromJson(json['attachment'])
  ..status = const StringToIntConverter().fromJson(json['status'])
  ..replycredit = const StringToIntConverter().fromJson(json['replycredit'])
  ..number = const StringToIntConverter().fromJson(json['number'])
  ..position = const StringToIntConverter().fromJson(json['position'])
  ..groupId = const StringToIntConverter().fromJson(json['groupid'])
  ..memberStatus = const StringToIntConverter().fromJson(json['memberstatus'])
  ..publishAt = const SecondToDateTimeConverter().fromJson(json['dbdateline'])
  ..attachmentIdList = discuzIds(json['attachlist'])
  ..imageIdList = discuzIds(json['imagelist'])
  ..groupIconId = json['groupiconid'] as String? ?? '0'
  ..attachmentMapper = const AttachmentConverter().fromJson(
    json['attachments'],
  );

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
  'pid': const StringToIntConverter().toJson(instance.pid),
  'tid': const StringToIntConverter().toJson(instance.tid),
  'first': const StringToBoolConverter().toJson(instance.first),
  'anonymous': const StringToBoolConverter().toJson(instance.anonymous),
  'author': instance.author,
  'dateline': instance.dateline,
  'message': instance.message,
  'ipLocation': instance.ipLocation,
  'authorid': const StringToIntConverter().toJson(instance.authorId),
  'attachment': const StringToIntConverter().toJson(instance.attachment),
  'status': const StringToIntConverter().toJson(instance.status),
  'replycredit': const StringToIntConverter().toJson(instance.replycredit),
  'number': const StringToIntConverter().toJson(instance.number),
  'position': const StringToIntConverter().toJson(instance.position),
  'groupid': const StringToIntConverter().toJson(instance.groupId),
  'memberstatus': const StringToIntConverter().toJson(instance.memberStatus),
  'dbdateline': const SecondToDateTimeConverter().toJson(instance.publishAt),
  'attachlist': instance.attachmentIdList,
  'imagelist': instance.imageIdList,
  'groupiconid': instance.groupIconId,
  'attachments': const AttachmentConverter().toJson(instance.attachmentMapper),
};

Attachment _$AttachmentFromJson(Map<String, dynamic> json) => Attachment()
  ..price = const StringToIntConverter().fromJson(json['price'])
  ..aid = const StringToIntConverter().fromJson(json['aid'])
  ..tid = const StringToIntConverter().fromJson(json['tid'])
  ..pid = const StringToIntConverter().fromJson(json['pid'])
  ..uid = const StringToIntConverter().fromJson(json['uid'])
  ..dateline = json['dateline'] as String? ?? ''
  ..filename = json['filename'] as String? ?? ''
  ..fileSize = json['filesize'] == null
      ? 0
      : const StringToIntConverter().fromJson(json['filesize'])
  ..remote = const StringToBoolConverter().fromJson(json['remote'])
  ..thumb = const StringToBoolConverter().fromJson(json['thumb'])
  ..payed = const StringToBoolConverter().fromJson(json['payed'])
  ..readPerm = const StringToIntConverter().fromJson(json['readperm'])
  ..aidEncode = json['aidencode'] as String? ?? ''
  ..url = json['url'] as String? ?? ''
  ..downloads = json['downloads'] == null
      ? 0
      : const StringToIntConverter().fromJson(json['downloads'])
  ..updateAt = const SecondToDateTimeConverter().fromJson(json['dbdateline'])
  ..attachmentSizeString = json['attachsize'] as String? ?? ''
  ..attachmentPathName = json['attachment'] as String? ?? ''
  ..ext = json['ext'] as String? ?? '';

Map<String, dynamic> _$AttachmentToJson(Attachment instance) =>
    <String, dynamic>{
      'price': const StringToIntConverter().toJson(instance.price),
      'aid': const StringToIntConverter().toJson(instance.aid),
      'tid': const StringToIntConverter().toJson(instance.tid),
      'pid': const StringToIntConverter().toJson(instance.pid),
      'uid': const StringToIntConverter().toJson(instance.uid),
      'dateline': instance.dateline,
      'filename': instance.filename,
      'filesize': const StringToIntConverter().toJson(instance.fileSize),
      'remote': const StringToBoolConverter().toJson(instance.remote),
      'thumb': const StringToBoolConverter().toJson(instance.thumb),
      'payed': const StringToBoolConverter().toJson(instance.payed),
      'readperm': const StringToIntConverter().toJson(instance.readPerm),
      'aidencode': instance.aidEncode,
      'url': instance.url,
      'downloads': const StringToIntConverter().toJson(instance.downloads),
      'dbdateline': const SecondToDateTimeConverter().toJson(instance.updateAt),
      'attachsize': instance.attachmentSizeString,
      'attachment': instance.attachmentPathName,
      'ext': instance.ext,
    };
