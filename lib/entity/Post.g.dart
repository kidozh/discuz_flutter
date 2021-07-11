// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) {
  return Post()
    ..pid = const StringToIntConverter().fromJson(json['pid'] as String?)
    ..tid = const StringToIntConverter().fromJson(json['tid'] as String?)
    ..first = const StringToBoolConverter().fromJson(json['first'] as String?)
    ..anonymous =
        const StringToBoolConverter().fromJson(json['anonymous'] as String?)
    ..author = json['author'] as String
    ..dateline = json['dateline'] as String
    ..message = json['message'] as String
    ..authorId =
        const StringToIntConverter().fromJson(json['authorid'] as String?)
    ..attachment =
        const StringToIntConverter().fromJson(json['attachment'] as String?)
    ..status = const StringToIntConverter().fromJson(json['status'] as String?)
    ..replycredit =
        const StringToIntConverter().fromJson(json['replycredit'] as String?)
    ..number = const StringToIntConverter().fromJson(json['number'] as String?)
    ..position =
        const StringToIntConverter().fromJson(json['position'] as String?)
    ..groupId =
        const StringToIntConverter().fromJson(json['groupid'] as String?)
    ..memberStatus =
        const StringToIntConverter().fromJson(json['memberstatus'] as String?)
    ..publishAt = const SecondToDateTimeConverter()
        .fromJson(json['dbdateline'] as String?)
    ..attachmentIdList = (json['attachlist'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        []
    ..imageIdList = (json['imagelist'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        []
    ..groupIconId = json['groupiconid'] as String? ?? '0'
    ..attachmentMapper =
        const AttachmentConverter().fromJson(json['attachments']);
}

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
      'pid': const StringToIntConverter().toJson(instance.pid),
      'tid': const StringToIntConverter().toJson(instance.tid),
      'first': const StringToBoolConverter().toJson(instance.first),
      'anonymous': const StringToBoolConverter().toJson(instance.anonymous),
      'author': instance.author,
      'dateline': instance.dateline,
      'message': instance.message,
      'authorid': const StringToIntConverter().toJson(instance.authorId),
      'attachment': const StringToIntConverter().toJson(instance.attachment),
      'status': const StringToIntConverter().toJson(instance.status),
      'replycredit': const StringToIntConverter().toJson(instance.replycredit),
      'number': const StringToIntConverter().toJson(instance.number),
      'position': const StringToIntConverter().toJson(instance.position),
      'groupid': const StringToIntConverter().toJson(instance.groupId),
      'memberstatus':
          const StringToIntConverter().toJson(instance.memberStatus),
      'dbdateline':
          const SecondToDateTimeConverter().toJson(instance.publishAt),
      'attachlist': instance.attachmentIdList,
      'imagelist': instance.imageIdList,
      'groupiconid': instance.groupIconId,
      'attachments':
          const AttachmentConverter().toJson(instance.attachmentMapper),
    };

Attachment _$AttachmentFromJson(Map<String, dynamic> json) {
  return Attachment()
    ..dateline = json['dateline'] as String? ?? ''
    ..filename = json['filename'] as String? ?? ''
    ..fileSize =
        const StringToIntConverter().fromJson(json['filesize'] as String?)
    ..readPerm =
        const StringToIntConverter().fromJson(json['readperm'] as String?)
    ..aidEncode = json['aidencode'] as String? ?? ''
    ..url = json['url'] as String? ?? ''
    ..downloads =
        const StringToIntConverter().fromJson(json['downloads'] as String?)
    ..updateAt = const SecondToDateTimeConverter()
        .fromJson(json['dbdateline'] as String?)
    ..attachmentSizeString = json['attachsize'] as String
    ..attachmentPathName = json['attachment'] as String? ?? ''
    ..ext = json['ext'] as String? ?? '';
}

Map<String, dynamic> _$AttachmentToJson(Attachment instance) =>
    <String, dynamic>{
      'dateline': instance.dateline,
      'filename': instance.filename,
      'filesize': const StringToIntConverter().toJson(instance.fileSize),
      'readperm': const StringToIntConverter().toJson(instance.readPerm),
      'aidencode': instance.aidEncode,
      'url': instance.url,
      'downloads': const StringToIntConverter().toJson(instance.downloads),
      'dbdateline': const SecondToDateTimeConverter().toJson(instance.updateAt),
      'attachsize': instance.attachmentSizeString,
      'attachment': instance.attachmentPathName,
      'ext': instance.ext,
    };
