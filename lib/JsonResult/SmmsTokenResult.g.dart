// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'SmmsTokenResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SmmsTokenResult _$SmmsTokenResultFromJson(Map<String, dynamic> json) =>
    SmmsTokenResult(
      success: json['success'] as bool,
      code: json['code'] as String,
      message: json['message'] as String,
      data: SmmsTokenData.fromJson(json['data'] as Map<String, dynamic>),
      requestId: json['RequestId'] as String,
    );

Map<String, dynamic> _$SmmsTokenResultToJson(SmmsTokenResult instance) =>
    <String, dynamic>{
      'success': instance.success,
      'code': instance.code,
      'message': instance.message,
      'data': instance.data.toJson(),
      'RequestId': instance.requestId,
    };

SmmsTokenData _$SmmsTokenDataFromJson(Map<String, dynamic> json) =>
    SmmsTokenData(
      token: json['token'] as String,
    );

Map<String, dynamic> _$SmmsTokenDataToJson(SmmsTokenData instance) =>
    <String, dynamic>{
      'token': instance.token,
    };
