// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'SmileyResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SmileyResult _$SmileyResultFromJson(Map<String, dynamic> json) => SmileyResult()
  ..version = json['Version'] as String
  ..charset = json['Charset'] as String
  ..errorResult = json['Message'] == null
      ? null
      : ErrorResult.fromJson(json['Message'] as Map<String, dynamic>)
  ..error = json['error'] as String?
  ..variables =
      SmileyVariables.fromJson(json['Variables'] as Map<String, dynamic>);

Map<String, dynamic> _$SmileyResultToJson(SmileyResult instance) =>
    <String, dynamic>{
      'Version': instance.version,
      'Charset': instance.charset,
      'Message': instance.errorResult,
      'error': instance.error,
      'Variables': instance.variables,
    };

SmileyVariables _$SmileyVariablesFromJson(Map<String, dynamic> json) =>
    SmileyVariables()
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
          NoticeCount.fromJson(json['notice'] as Map<String, dynamic>)
      ..smilies = (json['smilies'] as List<dynamic>)
          .map((e) => (e as List<dynamic>)
              .map((e) => Smiley.fromJson(e as Map<String, dynamic>))
              .toList())
          .toList();

Map<String, dynamic> _$SmileyVariablesToJson(SmileyVariables instance) =>
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
      'notice': instance.noticeCount,
      'smilies': instance.smilies,
    };
