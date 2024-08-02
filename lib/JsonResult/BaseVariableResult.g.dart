// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'BaseVariableResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseVariableResult _$BaseVariableResultFromJson(Map<String, dynamic> json) =>
    BaseVariableResult()
      ..cookiepre = json['cookiepre'] as String
      ..auth = json['auth'] as String?
      ..saltkey = json['saltkey'] as String
      ..member_username = json['member_username'] as String
      ..member_avatar = json['member_avatar'] as String
      ..member_uid =
          const StringToIntConverter().fromJson(json['member_uid'] as String?)
      ..groupId =
          const StringToIntConverter().fromJson(json['groupid'] as String?)
      ..readAccess =
          const StringToIntConverter().fromJson(json['readaccess'] as String?)
      ..formHash = json['formhash'] as String
      ..isModerator =
          const StringToIntConverter().fromJson(json['ismoderator'] as String?)
      ..noticeCount =
          NoticeCount.fromJson(json['notice'] as Map<String, dynamic>);

Map<String, dynamic> _$BaseVariableResultToJson(BaseVariableResult instance) =>
    <String, dynamic>{
      'cookiepre': instance.cookiepre,
      'auth': instance.auth,
      'saltkey': instance.saltkey,
      'member_username': instance.member_username,
      'member_avatar': instance.member_avatar,
      'member_uid': const StringToIntConverter().toJson(instance.member_uid),
      'groupid': const StringToIntConverter().toJson(instance.groupId),
      'readaccess': const StringToIntConverter().toJson(instance.readAccess),
      'formhash': instance.formHash,
      'ismoderator': const StringToIntConverter().toJson(instance.isModerator),
      'notice': instance.noticeCount.toJson(),
    };

NoticeCount _$NoticeCountFromJson(Map<String, dynamic> json) => NoticeCount()
  ..newpush = const StringToIntConverter().fromJson(json['newpush'] as String?)
  ..newpm = const StringToIntConverter().fromJson(json['newpm'] as String?)
  ..newprompt =
      const StringToIntConverter().fromJson(json['newprompt'] as String?)
  ..newmypost =
      const StringToIntConverter().fromJson(json['newmypost'] as String?);

Map<String, dynamic> _$NoticeCountToJson(NoticeCount instance) =>
    <String, dynamic>{
      'newpush': const StringToIntConverter().toJson(instance.newpush),
      'newpm': const StringToIntConverter().toJson(instance.newpm),
      'newprompt': const StringToIntConverter().toJson(instance.newprompt),
      'newmypost': const StringToIntConverter().toJson(instance.newmypost),
    };
