// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'LoginResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginResult _$LoginResultFromJson(Map<String, dynamic> json) {
  return LoginResult()
    ..version = json['Version'] as String
    ..charset = json['Charset'] as String
    ..errorResult = json['Message'] == null
        ? null
        : ErrorResult.fromJson(json['Message'] as Map<String, dynamic>)
    ..error = json['error'] as String?
    ..loginVariables =
        LoginVariables.fromJson(json['Variables'] as Map<String, dynamic>);
}

Map<String, dynamic> _$LoginResultToJson(LoginResult instance) =>
    <String, dynamic>{
      'Version': instance.version,
      'Charset': instance.charset,
      'Message': instance.errorResult,
      'error': instance.error,
      'Variables': instance.loginVariables,
    };

LoginVariables _$LoginVariablesFromJson(Map<String, dynamic> json) {
  return LoginVariables()
    ..noticeCount =
        NoticeCount.fromJson(json['notice'] as Map<String, dynamic>);
}

Map<String, dynamic> _$LoginVariablesToJson(LoginVariables instance) =>
    <String, dynamic>{
      'notice': instance.noticeCount,
    };
