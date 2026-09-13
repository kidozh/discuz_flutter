// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'HotThread.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HotThread _$HotThreadFromJson(Map<String, dynamic> json) => HotThread()
  ..tid = const StringToIntConverter().fromJson(json['tid'])
  ..fid = const StringToIntConverter().fromJson(json['fid'])
  ..posttableid = const StringToIntConverter().fromJson(json['posttableid'])
  ..typeid = const StringToIntConverter().fromJson(json['typeid'])
  ..sortid = const StringToIntConverter().fromJson(json['sortid'])
  ..price = const StringToIntConverter().fromJson(json['price'])
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
  ..displayOrder = const StringToIntConverter().fromJson(json['displayorder'])
  ..highlight = json['highlight'] as String
  ..digest = const StringToBoolConverter().fromJson(json['digest'])
  ..typeHtml = json['typehtml'] as String? ?? ''
  ..typeName = json['typename'] as String? ?? ''
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
  'displayorder': const StringToIntConverter().toJson(instance.displayOrder),
  'highlight': instance.highlight,
  'digest': const StringToBoolConverter().toJson(instance.digest),
  'typehtml': instance.typeHtml,
  'typename': instance.typeName,
  'dbdateline': const SecondToDateTimeConverter().toJson(instance.publishAt),
  'dblastpost': const SecondToDateTimeConverter().toJson(instance.lastPostAt),
  'message': instance.message,
  'attachmentImageNumber': const StringToIntConverter().toJson(
    instance.attachmentImageNumber,
  ),
  'attachmentImagePreviewList': instance.attachmentImagePreviewList,
};
