// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'BaseResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseResult _$BaseResultFromJson(Map<String, dynamic> json) => BaseResult()
  ..version = json['Version'] as String
  ..charset = json['Charset'] as String
  ..errorResult = json['Message'] == null
      ? null
      : ErrorResult.fromJson(json['Message'] as Map<String, dynamic>)
  ..error = json['error'] as String?;

Map<String, dynamic> _$BaseResultToJson(BaseResult instance) =>
    <String, dynamic>{
      'Version': instance.version,
      'Charset': instance.charset,
      'Message': instance.errorResult,
      'error': instance.error,
    };
