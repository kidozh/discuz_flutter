// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'SupportDiscuzListResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupportDiscuzListResult _$SupportDiscuzListResultFromJson(
        Map<String, dynamic> json) =>
    SupportDiscuzListResult()
      ..list = (json['list'] as List<dynamic>)
          .map((e) => SupportDiscuzSite.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$SupportDiscuzListResultToJson(
        SupportDiscuzListResult instance) =>
    <String, dynamic>{
      'list': instance.list,
    };

SupportDiscuzSite _$SupportDiscuzSiteFromJson(Map<String, dynamic> json) =>
    SupportDiscuzSite()
      ..name = json['name'] as String
      ..url = json['url'] as String
      ..desc = json['desc'] as String
      ..beian = json['beian'] as String
      ..type = json['type'] as String
      ..icon = json['icon'] as String? ?? '';

Map<String, dynamic> _$SupportDiscuzSiteToJson(SupportDiscuzSite instance) =>
    <String, dynamic>{
      'name': instance.name,
      'url': instance.url,
      'desc': instance.desc,
      'beian': instance.beian,
      'type': instance.type,
      'icon': instance.icon,
    };
