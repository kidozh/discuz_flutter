// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UserDiscuzNotificationResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDiscuzNotificationResult _$UserDiscuzNotificationResultFromJson(
    Map<String, dynamic> json) {
  return UserDiscuzNotificationResult()
    ..version = json['Version'] as String
    ..charset = json['Charset'] as String
    ..errorResult = json['Message'] == null
        ? null
        : ErrorResult.fromJson(json['Message'] as Map<String, dynamic>)
    ..error = json['error'] as String?
    ..variables = DiscuzNotificationVariables.fromJson(
        json['Variables'] as Map<String, dynamic>);
}

Map<String, dynamic> _$UserDiscuzNotificationResultToJson(
        UserDiscuzNotificationResult instance) =>
    <String, dynamic>{
      'Version': instance.version,
      'Charset': instance.charset,
      'Message': instance.errorResult,
      'error': instance.error,
      'Variables': instance.variables,
    };

DiscuzNotificationVariables _$DiscuzNotificationVariablesFromJson(
    Map<String, dynamic> json) {
  return DiscuzNotificationVariables()
    ..groupId =
        const StringToIntConverter().fromJson(json['groupid'] as String?)
    ..readAccess =
        const StringToIntConverter().fromJson(json['readaccess'] as String?)
    ..formHash = json['formhash'] as String
    ..noticeCount = NoticeCount.fromJson(json['notice'] as Map<String, dynamic>)
    ..notificationList = (json['list'] as List<dynamic>?)
            ?.map((e) => DiscuzNotification.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
}

Map<String, dynamic> _$DiscuzNotificationVariablesToJson(
        DiscuzNotificationVariables instance) =>
    <String, dynamic>{
      'groupid': const StringToIntConverter().toJson(instance.groupId),
      'readaccess': const StringToIntConverter().toJson(instance.readAccess),
      'formhash': instance.formHash,
      'notice': instance.noticeCount,
      'list': instance.notificationList,
    };
