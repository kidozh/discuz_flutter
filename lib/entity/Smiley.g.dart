// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Smiley.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Smiley _$SmileyFromJson(Map<String, dynamic> json) => Smiley()
  ..code = json['code'] as String
  ..relativePath = json['image'] as String;

Map<String, dynamic> _$SmileyToJson(Smiley instance) => <String, dynamic>{
      'code': instance.code,
      'image': instance.relativePath,
    };
