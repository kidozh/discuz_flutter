// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'SmmsProfileResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SmmsProfileResult _$SmmsProfileResultFromJson(Map<String, dynamic> json) =>
    SmmsProfileResult(
      success: json['success'] as bool,
      code: json['code'] as String,
      message: json['message'] as String,
      data: SmmsProfileData.fromJson(json['data'] as Map<String, dynamic>),
      requestId: json['RequestId'] as String,
    );

Map<String, dynamic> _$SmmsProfileResultToJson(SmmsProfileResult instance) =>
    <String, dynamic>{
      'success': instance.success,
      'code': instance.code,
      'message': instance.message,
      'data': instance.data.toJson(),
      'RequestId': instance.requestId,
    };

SmmsProfileData _$SmmsProfileDataFromJson(Map<String, dynamic> json) =>
    SmmsProfileData(
      username: json['username'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      groupExpire: json['group_expire'] as String,
      emailVerified: (json['email_verified'] as num).toInt(),
      diskUsage: json['disk_usage'] as String,
      diskLimit: json['disk_limit'] as String,
      diskUsageRaw: (json['disk_usage_raw'] as num).toInt(),
      diskLimitRaw: (json['disk_limit_raw'] as num).toInt(),
    );

Map<String, dynamic> _$SmmsProfileDataToJson(SmmsProfileData instance) =>
    <String, dynamic>{
      'username': instance.username,
      'email': instance.email,
      'role': instance.role,
      'group_expire': instance.groupExpire,
      'email_verified': instance.emailVerified,
      'disk_usage': instance.diskUsage,
      'disk_limit': instance.diskLimit,
      'disk_usage_raw': instance.diskUsageRaw,
      'disk_limit_raw': instance.diskLimitRaw,
    };
