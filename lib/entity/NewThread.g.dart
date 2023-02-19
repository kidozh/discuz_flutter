// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'NewThread.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewThread _$NewThreadFromJson(Map<String, dynamic> json) => NewThread()
  ..tid = const StringToIntConverter().fromJson(json['tid'] as String?)
  ..readPerm =
      const StringToIntConverter().fromJson(json['readperm'] as String?)
  ..author = json['author'] as String
  ..authorId =
      const StringToIntConverter().fromJson(json['authorid'] as String?)
  ..subject = json['subject'] as String
  ..dateline = json['dateline'] as String
  ..lastPostTime = json['lastpost'] as String
  ..lastPoster = json['lastposter'] as String
  ..views = json['views'] as String
  ..replies = json['replies'] as String
  ..digest = const StringToBoolConverter().fromJson(json['digest'] as String?)
  ..attachment =
      const StringToIntConverter().fromJson(json['attachment'] as String?)
  ..publishAt =
      const SecondToDateTimeConverter().fromJson(json['dbdateline'] as String?)
  ..lastPostAt =
      const SecondToDateTimeConverter().fromJson(json['dblastpost'] as String?)
  ..attachmentImageNumber = json['attachmentImageNumber'] == null
      ? 0
      : const StringToIntConverter()
          .fromJson(json['attachmentImageNumber'] as String?)
  ..attachmentImagePreviewList =
      (json['attachmentImagePreviewList'] as List<dynamic>?)
              ?.map((e) => AttachmentPreview.fromJson(e))
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
      'replies': instance.replies,
      'digest': const StringToBoolConverter().toJson(instance.digest),
      'attachment': const StringToIntConverter().toJson(instance.attachment),
      'dbdateline':
          const SecondToDateTimeConverter().toJson(instance.publishAt),
      'dblastpost':
          const SecondToDateTimeConverter().toJson(instance.lastPostAt),
      'attachmentImageNumber':
          const StringToIntConverter().toJson(instance.attachmentImageNumber),
      'attachmentImagePreviewList': instance.attachmentImagePreviewList,
    };
