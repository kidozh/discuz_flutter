// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'NewThreadResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewThreadResult _$NewThreadResultFromJson(Map<String, dynamic> json) =>
    NewThreadResult()
      ..version = json['Version'] as String
      ..charset = json['Charset'] as String
      ..errorResult = json['Message'] == null
          ? null
          : ErrorResult.fromJson(json['Message'] as Map<String, dynamic>)
      ..error = json['error'] as String?
      ..variables = NewThreadVariables.fromJson(
          json['Variables'] as Map<String, dynamic>);

Map<String, dynamic> _$NewThreadResultToJson(NewThreadResult instance) =>
    <String, dynamic>{
      'Version': instance.version,
      'Charset': instance.charset,
      'Message': instance.errorResult,
      'error': instance.error,
      'Variables': instance.variables,
    };

NewThreadVariables _$NewThreadVariablesFromJson(Map<String, dynamic> json) =>
    NewThreadVariables()
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
          NoticeCount.fromJson(json['notice'] as Map<String, dynamic>)
      ..newThreadList = (json['data'] as List<dynamic>?)
              ?.map((e) => NewThread.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];

Map<String, dynamic> _$NewThreadVariablesToJson(NewThreadVariables instance) =>
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
      'data': instance.newThreadList,
    };
