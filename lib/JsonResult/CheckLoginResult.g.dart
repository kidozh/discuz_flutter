// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CheckLoginResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckLoginResult _$CheckLoginResultFromJson(Map<String, dynamic> json) =>
    CheckLoginResult()
      ..version = json['Version'] as String
      ..charset = json['Charset'] as String
      ..errorResult = json['Message'] == null
          ? null
          : ErrorResult.fromJson(json['Message'] as Map<String, dynamic>)
      ..error = json['error'] as String?
      ..variables = CheckLoginVariables.fromJson(
          json['Variables'] as Map<String, dynamic>);

Map<String, dynamic> _$CheckLoginResultToJson(CheckLoginResult instance) =>
    <String, dynamic>{
      'Version': instance.version,
      'Charset': instance.charset,
      'Message': instance.errorResult,
      'error': instance.error,
      'Variables': instance.variables,
    };

CheckLoginVariables _$CheckLoginVariablesFromJson(Map<String, dynamic> json) =>
    CheckLoginVariables()
      ..groupId =
          const StringToIntConverter().fromJson(json['groupid'] as String?)
      ..readAccess =
          const StringToIntConverter().fromJson(json['readaccess'] as String?)
      ..formHash = json['formhash'] as String
      ..noticeCount =
          NoticeCount.fromJson(json['notice'] as Map<String, dynamic>);

Map<String, dynamic> _$CheckLoginVariablesToJson(
        CheckLoginVariables instance) =>
    <String, dynamic>{
      'groupid': const StringToIntConverter().toJson(instance.groupId),
      'readaccess': const StringToIntConverter().toJson(instance.readAccess),
      'formhash': instance.formHash,
      'notice': instance.noticeCount,
    };
