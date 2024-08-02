// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UserDiscuzNotificationResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDiscuzNotificationResult _$UserDiscuzNotificationResultFromJson(
        Map<String, dynamic> json) =>
    UserDiscuzNotificationResult()
      ..version = json['Version'] as String
      ..charset = json['Charset'] as String
      ..errorResult = json['Message'] == null
          ? null
          : ErrorResult.fromJson(json['Message'] as Map<String, dynamic>)
      ..error = json['error'] as String?
      ..variables = DiscuzNotificationVariables.fromJson(
          json['Variables'] as Map<String, dynamic>);

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
        Map<String, dynamic> json) =>
    DiscuzNotificationVariables()
      ..cookiepre = json['cookiepre'] as String
      ..auth = json['auth'] as String?
      ..saltkey = json['saltkey'] as String
      ..member_username = json['member_username'] as String
      ..member_avatar = json['member_avatar'] as String
      ..member_uid =
          const StringToIntConverter().fromJson(json['member_uid'] as String?)
      ..groupId =
          const StringToIntConverter().fromJson(json['groupid'] as String?)
      ..readAccess =
          const StringToIntConverter().fromJson(json['readaccess'] as String?)
      ..formHash = json['formhash'] as String
      ..isModerator =
          const StringToIntConverter().fromJson(json['ismoderator'] as String?)
      ..noticeCount =
          NoticeCount.fromJson(json['notice'] as Map<String, dynamic>)
      ..notificationList = (json['list'] as List<dynamic>?)
              ?.map(
                  (e) => DiscuzNotification.fromJson(e as Map<String, dynamic>))
              .toList() ??
          []
      ..count = const StringToIntConverter().fromJson(json['count'] as String?)
      ..perPage =
          const StringToIntConverter().fromJson(json['perpage'] as String?)
      ..page = const StringToIntConverter().fromJson(json['page'] as String?);

Map<String, dynamic> _$DiscuzNotificationVariablesToJson(
        DiscuzNotificationVariables instance) =>
    <String, dynamic>{
      'cookiepre': instance.cookiepre,
      'auth': instance.auth,
      'saltkey': instance.saltkey,
      'member_username': instance.member_username,
      'member_avatar': instance.member_avatar,
      'member_uid': const StringToIntConverter().toJson(instance.member_uid),
      'groupid': const StringToIntConverter().toJson(instance.groupId),
      'readaccess': const StringToIntConverter().toJson(instance.readAccess),
      'formhash': instance.formHash,
      'ismoderator': const StringToIntConverter().toJson(instance.isModerator),
      'notice': instance.noticeCount,
      'list': instance.notificationList,
      'count': const StringToIntConverter().toJson(instance.count),
      'perpage': const StringToIntConverter().toJson(instance.perPage),
      'page': const StringToIntConverter().toJson(instance.page),
    };
