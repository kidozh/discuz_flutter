// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ApiResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResult _$ApiResultFromJson(Map<String, dynamic> json) {
  return ApiResult()
    ..version = json['Version'] as String
    ..charset = json['Charset'] as String
    ..errorResult = json['Message'] == null
        ? null
        : ErrorResult.fromJson(json['Message'] as Map<String, dynamic>)
    ..error = json['error'] as String?
    ..variables =
        BaseVariableResult.fromJson(json['Variables'] as Map<String, dynamic>);
}

Map<String, dynamic> _$ApiResultToJson(ApiResult instance) => <String, dynamic>{
      'Version': instance.version,
      'Charset': instance.charset,
      'Message': instance.errorResult,
      'error': instance.error,
      'Variables': instance.variables,
    };
