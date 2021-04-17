// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ErrorResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ErrorResult _$ErrorResultFromJson(Map<String, dynamic> json) {
  return ErrorResult()
    ..key = json['messageval'] as String
    ..content = json['messagestr'] as String;
}

Map<String, dynamic> _$ErrorResultToJson(ErrorResult instance) =>
    <String, dynamic>{
      'messageval': instance.key,
      'messagestr': instance.content,
    };
