// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'NewThread.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewThread _$NewThreadFromJson(Map<String, dynamic> json) => NewThread()
  ..tid = const StringToIntConverter().fromJson(json['tid'])
  ..readPerm = const StringToIntConverter().fromJson(json['readperm'])
  ..author = json['author'] as String
  ..authorId = const StringToIntConverter().fromJson(json['authorid'])
  ..subject = json['subject'] as String
  ..dateline = json['dateline'] as String
  ..lastPostTime = json['lastpost'] as String
  ..lastPoster = json['lastposter'] as String
  ..views = json['views'] as String
  ..replies = json['replies'] == null
      ? 0
      : const StringToIntConverter().fromJson(json['replies'])
  ..digest = const StringToBoolConverter().fromJson(json['digest'])
  ..attachment = const StringToIntConverter().fromJson(json['attachment'])
  ..publishAt = const SecondToDateTimeConverter().fromJson(json['dbdateline'])
  ..lastPostAt = const SecondToDateTimeConverter().fromJson(json['dblastpost'])
  ..message = json['message'] as String? ?? ''
  ..attachmentImageNumber = json['attachmentImageNumber'] == null
      ? 0
      : const StringToIntConverter().fromJson(json['attachmentImageNumber'])
  ..attachmentImagePreviewList =
      (json['attachmentImagePreviewList'] as List<dynamic>?)
          ?.map(AttachmentPreview.fromJson)
          .toList() ??
      [];

Map<String, dynamic> _$NewThreadToJson(NewThread instance) => <String, dynamic>{
  'tid': const StringToIntConverter().toJson(instance.tid),
  'readperm': const StringToIntConverter().toJson(instance.readPerm),
  'author': instance.author,
  'authorid': const StringToIntConverter().toJson(instance.authorId),
  'subject': instance.subject,
  'dateline': instance.dateline,
  'lastpost': instance.lastPostTime,
  'lastposter': instance.lastPoster,
  'views': instance.views,
  'replies': const StringToIntConverter().toJson(instance.replies),
  'digest': const StringToBoolConverter().toJson(instance.digest),
  'attachment': const StringToIntConverter().toJson(instance.attachment),
  'dbdateline': const SecondToDateTimeConverter().toJson(instance.publishAt),
  'dblastpost': const SecondToDateTimeConverter().toJson(instance.lastPostAt),
  'message': instance.message,
  'attachmentImageNumber': const StringToIntConverter().toJson(
    instance.attachmentImageNumber,
  ),
  'attachmentImagePreviewList': instance.attachmentImagePreviewList,
};
