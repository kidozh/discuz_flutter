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
      ..ismoderator = json['ismoderator'] as String?
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
      'ismoderator': instance.ismoderator,
      'notice': instance.noticeCount,
    };

NoticeCount _$NoticeCountFromJson(Map<String, dynamic> json) => NoticeCount()
  ..newpush = json['newpush'] as String
  ..newpm = json['newpm'] as String
  ..newprompt = json['newprompt'] as String
  ..newmypost = json['newmypost'] as String;

Map<String, dynamic> _$NoticeCountToJson(NoticeCount instance) =>
    <String, dynamic>{
      'newpush': instance.newpush,
      'newpm': instance.newpm,
      'newprompt': instance.newprompt,
      'newmypost': instance.newmypost,
    };
