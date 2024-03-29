// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'HotThread.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HotThread _$HotThreadFromJson(Map<String, dynamic> json) => HotThread()
  ..tid = const StringToIntConverter().fromJson(json['tid'] as String?)
  ..fid = const StringToIntConverter().fromJson(json['fid'] as String?)
  ..posttableid =
      const StringToIntConverter().fromJson(json['posttableid'] as String?)
  ..typeid = const StringToIntConverter().fromJson(json['typeid'] as String?)
  ..sortid = const StringToIntConverter().fromJson(json['sortid'] as String?)
  ..price = const StringToIntConverter().fromJson(json['price'] as String?)
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
  ..replies = json['replies'] == null
      ? 0
      : const StringToIntConverter().fromJson(json['replies'] as String?)
  ..displayOrder =
      const StringToIntConverter().fromJson(json['displayorder'] as String?)
  ..highlight = json['highlight'] as String
  ..digest = const StringToBoolConverter().fromJson(json['digest'] as String?)
  ..typeHtml = json['typehtml'] as String? ?? ''
  ..typeName = json['typename'] as String? ?? ''
  ..publishAt =
      const SecondToDateTimeConverter().fromJson(json['dbdateline'] as String?)
  ..lastPostAt =
      const SecondToDateTimeConverter().fromJson(json['dblastpost'] as String?)
  ..message = json['message'] as String? ?? ''
  ..attachmentImageNumber = json['attachmentImageNumber'] == null
      ? 0
      : const StringToIntConverter()
          .fromJson(json['attachmentImageNumber'] as String?)
  ..attachmentImagePreviewList =
      (json['attachmentImagePreviewList'] as List<dynamic>?)
              ?.map(AttachmentPreview.fromJson)
              .toList() ??
          [];

Map<String, dynamic> _$HotThreadToJson(HotThread instance) => <String, dynamic>{
      'tid': const StringToIntConverter().toJson(instance.tid),
      'fid': const StringToIntConverter().toJson(instance.fid),
      'posttableid': const StringToIntConverter().toJson(instance.posttableid),
      'typeid': const StringToIntConverter().toJson(instance.typeid),
      'sortid': const StringToIntConverter().toJson(instance.sortid),
      'price': const StringToIntConverter().toJson(instance.price),
      'readperm': const StringToIntConverter().toJson(instance.readPerm),
      'author': instance.author,
      'authorid': const StringToIntConverter().toJson(instance.authorId),
      'subject': instance.subject,
      'dateline': instance.dateline,
      'lastpost': instance.lastPostTime,
      'lastposter': instance.lastPoster,
      'views': instance.views,
      'replies': const StringToIntConverter().toJson(instance.replies),
      'displayorder':
          const StringToIntConverter().toJson(instance.displayOrder),
      'highlight': instance.highlight,
      'digest': const StringToBoolConverter().toJson(instance.digest),
      'typehtml': instance.typeHtml,
      'typename': instance.typeName,
      'dbdateline':
          const SecondToDateTimeConverter().toJson(instance.publishAt),
      'dblastpost':
          const SecondToDateTimeConverter().toJson(instance.lastPostAt),
      'message': instance.message,
      'attachmentImageNumber':
          const StringToIntConverter().toJson(instance.attachmentImageNumber),
      'attachmentImagePreviewList': instance.attachmentImagePreviewList,
    };
