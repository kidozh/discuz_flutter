// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CheckPostResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckPostResult _$CheckPostResultFromJson(Map<String, dynamic> json) =>
    CheckPostResult()
      ..version = json['Version'] as String? ?? ''
      ..charset = json['Charset'] as String? ?? ''
      ..errorResult = json['Message'] == null
          ? null
          : ErrorResult.fromJson(json['Message'] as Map<String, dynamic>)
      ..error = json['error'] as String?
      ..variables = _variablesFromJson(json['Variables']);

Map<String, dynamic> _$CheckPostResultToJson(CheckPostResult instance) =>
    <String, dynamic>{
      'Version': instance.version,
      'Charset': instance.charset,
      'Message': instance.errorResult?.toJson(),
      'error': instance.error,
      'Variables': instance.variables.toJson(),
    };

CheckPostVariables _$CheckPostVariablesFromJson(Map<String, dynamic> json) =>
    CheckPostVariables()
      ..cookiepre = json['cookiepre'] as String? ?? ''
      ..auth = json['auth'] as String?
      ..saltkey = json['saltkey'] as String? ?? ''
      ..member_username = json['member_username'] as String? ?? ''
      ..member_avatar = json['member_avatar'] as String? ?? ''
      ..member_uid = const StringToIntConverter().fromJson(json['member_uid'])
      ..groupId = const StringToIntConverter().fromJson(json['groupid'])
      ..readAccess = const StringToIntConverter().fromJson(json['readaccess'])
      ..formHash = json['formhash'] as String? ?? ''
      ..isModerator = const StringToIntConverter().fromJson(json['ismoderator'])
      ..noticeCount = noticeFromJson(json['notice'])
      ..allowPerm = AllowPerm.fromJson(json['allowperm']);

Map<String, dynamic> _$CheckPostVariablesToJson(CheckPostVariables instance) =>
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
      'allowperm': instance.allowPerm.toJson(),
    };
