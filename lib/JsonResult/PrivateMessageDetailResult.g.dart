// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PrivateMessageDetailResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrivateMessageDetailResult _$PrivateMessageDetailResultFromJson(
  Map<String, dynamic> json,
) => PrivateMessageDetailResult()
  ..version = json['Version'] as String? ?? ''
  ..charset = json['Charset'] as String? ?? ''
  ..errorResult = json['Message'] == null
      ? null
      : ErrorResult.fromJson(json['Message'] as Map<String, dynamic>)
  ..error = json['error'] as String?
  ..variables = PrivateMessageDetailVariables.fromJson(
    json['Variables'] as Map<String, dynamic>,
  );

Map<String, dynamic> _$PrivateMessageDetailResultToJson(
  PrivateMessageDetailResult instance,
) => <String, dynamic>{
  'Version': instance.version,
  'Charset': instance.charset,
  'Message': instance.errorResult,
  'error': instance.error,
  'Variables': instance.variables,
};

PrivateMessageDetailVariables _$PrivateMessageDetailVariablesFromJson(
  Map<String, dynamic> json,
) => PrivateMessageDetailVariables()
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
      .map((e) => PrivateMessageDetail.fromJson(e as Map<String, dynamic>))
      .toList()
  ..count = const StringToIntConverter().fromJson(json['count'])
  ..perPage = const StringToIntConverter().fromJson(json['perpage'])
  ..page = const StringToIntConverter().fromJson(json['page'])
  ..pmId = const StringToIntConverter().fromJson(json['pmid']);

Map<String, dynamic> _$PrivateMessageDetailVariablesToJson(
  PrivateMessageDetailVariables instance,
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
  'pmid': const StringToIntConverter().toJson(instance.pmId),
};

PrivateMessageDetail _$PrivateMessageDetailFromJson(
  Map<String, dynamic> json,
) => PrivateMessageDetail()
  ..plid = const StringToIntConverter().fromJson(json['plid'])
  ..subject = json['subject'] as String
  ..toUid = const StringToIntConverter().fromJson(json['touid'])
  ..pmId = const StringToIntConverter().fromJson(json['pmid'])
  ..msgFromId = const StringToIntConverter().fromJson(json['msgfromid'])
  ..msgFromName = json['msgfrom'] as String
  ..message = json['message'] as String
  ..dateTimeString = json['vdateline'] as String;

Map<String, dynamic> _$PrivateMessageDetailToJson(
  PrivateMessageDetail instance,
) => <String, dynamic>{
  'plid': const StringToIntConverter().toJson(instance.plid),
  'subject': instance.subject,
  'touid': const StringToIntConverter().toJson(instance.toUid),
  'pmid': const StringToIntConverter().toJson(instance.pmId),
  'msgfromid': const StringToIntConverter().toJson(instance.msgFromId),
  'msgfrom': instance.msgFromName,
  'message': instance.message,
  'vdateline': instance.dateTimeString,
};
