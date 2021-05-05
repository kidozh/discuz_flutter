// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CaptchaResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CaptchaResult _$CaptchaResultFromJson(Map<String, dynamic> json) {
  return CaptchaResult()
    ..version = json['Version'] as String
    ..charset = json['Charset'] as String
    ..errorResult = json['Message'] == null
        ? null
        : ErrorResult.fromJson(json['Message'] as Map<String, dynamic>)
    ..error = json['error'] as String?
    ..variables =
        CaptchaVariable.fromJson(json['Variables'] as Map<String, dynamic>);
}

Map<String, dynamic> _$CaptchaResultToJson(CaptchaResult instance) =>
    <String, dynamic>{
      'Version': instance.version,
      'Charset': instance.charset,
      'Message': instance.errorResult,
      'error': instance.error,
      'Variables': instance.variables,
    };

CaptchaVariable _$CaptchaVariableFromJson(Map<String, dynamic> json) {
  return CaptchaVariable()
    ..groupId =
        const StringToIntConverter().fromJson(json['groupid'] as String?)
    ..readAccess =
        const StringToIntConverter().fromJson(json['readaccess'] as String?)
    ..formHash = json['formhash'] as String
    ..noticeCount = NoticeCount.fromJson(json['notice'] as Map<String, dynamic>)
    ..secHash = json['sechash'] as String? ?? ''
    ..secCodeURL = json['seccode'] as String? ?? '';
}

Map<String, dynamic> _$CaptchaVariableToJson(CaptchaVariable instance) =>
    <String, dynamic>{
      'groupid': const StringToIntConverter().toJson(instance.groupId),
      'readaccess': const StringToIntConverter().toJson(instance.readAccess),
      'formhash': instance.formHash,
      'notice': instance.noticeCount,
      'sechash': instance.secHash,
      'seccode': instance.secCodeURL,
    };
