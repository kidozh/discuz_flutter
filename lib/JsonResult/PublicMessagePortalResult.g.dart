// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PublicMessagePortalResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublicMessagePortalResult _$PublicMessagePortalResultFromJson(
  Map<String, dynamic> json,
) => PublicMessagePortalResult()
  ..version = json['Version'] as String? ?? ''
  ..charset = json['Charset'] as String? ?? ''
  ..errorResult = json['Message'] == null
      ? null
      : ErrorResult.fromJson(json['Message'] as Map<String, dynamic>)
  ..error = json['error'] as String?
  ..variables = PublicMessagePortalVariables.fromJson(
    json['Variables'] as Map<String, dynamic>,
  );

Map<String, dynamic> _$PublicMessagePortalResultToJson(
  PublicMessagePortalResult instance,
) => <String, dynamic>{
  'Version': instance.version,
  'Charset': instance.charset,
  'Message': instance.errorResult,
  'error': instance.error,
  'Variables': instance.variables,
};

PublicMessagePortalVariables _$PublicMessagePortalVariablesFromJson(
  Map<String, dynamic> json,
) => PublicMessagePortalVariables()
  ..cookiepre = json['cookiepre'] as String? ?? ''
  ..auth = json['auth'] as String?
  ..saltkey = json['saltkey'] as String? ?? ''
  ..member_username = json['member_username'] as String? ?? ''
  ..member_avatar = json['member_avatar'] as String? ?? ''
  ..member_uid = const StringToIntConverter().fromJson(json['member_uid'])
  ..groupId = const StringToIntConverter().fromJson(json['groupid'])
  ..readAccess = const StringToIntConverter().fromJson(json['readaccess'])
  ..formHash = json['formhash'] as String? ?? ''
  ..isModerator = const StringToIntConverter().fromJson(json['ismoderator'])
  ..noticeCount = noticeFromJson(json['notice'])
  ..pmList = (json['list'] as List<dynamic>)
      .map((e) => PublicMessagePortal.fromJson(e as Map<String, dynamic>))
      .toList()
  ..count = const StringToIntConverter().fromJson(json['count'])
  ..perPage = const StringToIntConverter().fromJson(json['perpage'])
  ..page = const StringToIntConverter().fromJson(json['page']);

Map<String, dynamic> _$PublicMessagePortalVariablesToJson(
  PublicMessagePortalVariables instance,
) => <String, dynamic>{
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
  'list': instance.pmList,
  'count': const StringToIntConverter().toJson(instance.count),
  'perpage': const StringToIntConverter().toJson(instance.perPage),
  'page': const StringToIntConverter().toJson(instance.page),
};

PublicMessagePortal _$PublicMessagePortalFromJson(Map<String, dynamic> json) =>
    PublicMessagePortal()
      ..id = const StringToIntConverter().fromJson(json['id'])
      ..authorId = const StringToIntConverter().fromJson(json['authorid'])
      ..message = json['message'] as String? ?? ''
      ..publishAt = const SecondToDateTimeConverter().fromJson(
        json['dateline'],
      );

Map<String, dynamic> _$PublicMessagePortalToJson(
  PublicMessagePortal instance,
) => <String, dynamic>{
  'id': const StringToIntConverter().toJson(instance.id),
  'authorid': const StringToIntConverter().toJson(instance.authorId),
  'message': instance.message,
  'dateline': const SecondToDateTimeConverter().toJson(instance.publishAt),
};
