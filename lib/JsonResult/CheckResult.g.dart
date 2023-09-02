// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CheckResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckResult _$CheckResultFromJson(Map<String, dynamic> json) => CheckResult(
      json['discuzversion'] as String,
      json['charset'] as String,
      json['version'] as String? ?? '4',
      json['pluginversion'] as String,
      json['regname'] as String,
      json['qqconnect'] as String,
      json['wsqqqconnect'] as String,
      json['wsqhideregister'] as String,
      json['sitename'] as String,
      json['mysiteid'] as String,
      json['ucenterurl'] as String,
      json['defaultfid'] as String? ?? '0',
    )..testcookie = json['testcookie'] as String? ?? '';

Map<String, dynamic> _$CheckResultToJson(CheckResult instance) =>
    <String, dynamic>{
      'discuzversion': instance.discuzVersion,
      'charset': instance.charset,
      'version': instance.apiVersion,
      'pluginversion': instance.pluginVersion,
      'regname': instance.regname,
      'qqconnect': instance.qqconnect,
      'wsqqqconnect': instance.wsqqqconnect,
      'wsqhideregister': instance.wsqhideregister,
      'sitename': instance.siteName,
      'mysiteid': instance.siteId,
      'ucenterurl': instance.uCenterURL,
      'defaultfid': instance.defaultFid,
      'testcookie': instance.testcookie,
    };
