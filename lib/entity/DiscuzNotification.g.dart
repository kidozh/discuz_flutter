// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'DiscuzNotification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiscuzNotification _$DiscuzNotificationFromJson(Map<String, dynamic> json) {
  return DiscuzNotification()
    ..id = const StringToIntConverter().fromJson(json['id'] as String?) ?? 0
    ..uid = const StringToIntConverter().fromJson(json['uid'] as String?) ?? 0
    ..type = json['type'] as String
    ..isNew = json['new'] as String? ?? '0'
    ..author = json['author'] as String? ?? ''
    ..authorId =
        const StringToIntConverter().fromJson(json['authorid'] as String?) ?? 0
    ..note = json['note'] as String
    ..dateline =
        const SecondToDateTimeConverter().fromJson(json['dateline'] as String)
    ..fromId = const StringToIntConverter().fromJson(json['from_id'] as String?)
    ..fromIdType = json['from_idtype'] as String? ?? '';
}

Map<String, dynamic> _$DiscuzNotificationToJson(DiscuzNotification instance) =>
    <String, dynamic>{
      'id': const StringToIntConverter().toJson(instance.id),
      'uid': const StringToIntConverter().toJson(instance.uid),
      'type': instance.type,
      'new': instance.isNew,
      'author': instance.author,
      'authorid': const StringToIntConverter().toJson(instance.authorId),
      'note': instance.note,
      'dateline': const SecondToDateTimeConverter().toJson(instance.dateline),
      'from_id': const StringToIntConverter().toJson(instance.fromId),
      'from_idtype': instance.fromIdType,
    };
