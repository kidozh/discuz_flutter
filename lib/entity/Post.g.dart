// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) {
  return Post()
    ..pid = const StringToIntConverter().fromJson(json['pid'] as String?)
    ..tid = const StringToIntConverter().fromJson(json['tid'] as String?)
    ..first = const StringToBoolConverter().fromJson(json['first'] as String)
    ..anonymous =
        const StringToBoolConverter().fromJson(json['anonymous'] as String)
    ..author = json['author'] as String
    ..dateline = json['dateline'] as String
    ..message = json['message'] as String
    ..username = json['username'] as String
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
        const StringToIntConverter().fromJson(json['groupid'] as String?) ?? 0
    ..memberStatus = const StringToIntConverter()
            .fromJson(json['memberstatus'] as String?) ??
        0
    ..publishAt =
        const SecondToDateTimeConverter().fromJson(json['dbdateline'] as String)
    ..attachmentIdList = (json['attachlist'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        []
    ..imageIdList = (json['imagelist'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        []
    ..groupIconId = json['groupiconid'] as String? ?? '0';
}

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
      'pid': const StringToIntConverter().toJson(instance.pid),
      'tid': const StringToIntConverter().toJson(instance.tid),
      'first': const StringToBoolConverter().toJson(instance.first),
      'anonymous': const StringToBoolConverter().toJson(instance.anonymous),
      'author': instance.author,
      'dateline': instance.dateline,
      'message': instance.message,
      'username': instance.username,
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
    };

Attachment _$AttachmentFromJson(Map<String, dynamic> json) {
  return Attachment()
    ..fileSize =
        const StringToIntConverter().fromJson(json['filesize'] as String?)
    ..description = json['description'] as String? ?? ''
    ..readPerm =
        const StringToIntConverter().fromJson(json['readperm'] as String?)
    ..picId = const StringToIntConverter().fromJson(json['picid'] as String?)
    ..aidEncode = json['aidencode'] as String? ?? ''
    ..downloads =
        const StringToIntConverter().fromJson(json['downloads'] as String?)
    ..imageAlt = json['imgalt'] as String? ?? '';
}

Map<String, dynamic> _$AttachmentToJson(Attachment instance) =>
    <String, dynamic>{
      'filesize': const StringToIntConverter().toJson(instance.fileSize),
      'description': instance.description,
      'readperm': const StringToIntConverter().toJson(instance.readPerm),
      'picid': const StringToIntConverter().toJson(instance.picId),
      'aidencode': instance.aidEncode,
      'downloads': const StringToIntConverter().toJson(instance.downloads),
      'imgalt': instance.imageAlt,
    };
