// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PrivateMessageDetailResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrivateMessageDetailResult _$PrivateMessageDetailResultFromJson(
    Map<String, dynamic> json) {
  return PrivateMessageDetailResult()
    ..version = json['Version'] as String
    ..charset = json['Charset'] as String
    ..errorResult = json['Message'] == null
        ? null
        : ErrorResult.fromJson(json['Message'] as Map<String, dynamic>)
    ..error = json['error'] as String?
    ..variables = PrivateMessageDetailVariables.fromJson(
        json['Variables'] as Map<String, dynamic>);
}

Map<String, dynamic> _$PrivateMessageDetailResultToJson(
        PrivateMessageDetailResult instance) =>
    <String, dynamic>{
      'Version': instance.version,
      'Charset': instance.charset,
      'Message': instance.errorResult,
      'error': instance.error,
      'Variables': instance.variables,
    };

PrivateMessageDetailVariables _$PrivateMessageDetailVariablesFromJson(
    Map<String, dynamic> json) {
  return PrivateMessageDetailVariables()
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
    ..ismoderator = json['ismoderator'] as String?
    ..noticeCount = NoticeCount.fromJson(json['notice'] as Map<String, dynamic>)
    ..pmList = (json['list'] as List<dynamic>)
        .map((e) => PrivateMessageDetail.fromJson(e as Map<String, dynamic>))
        .toList()
    ..count = const StringToIntConverter().fromJson(json['count'] as String?)
    ..perPage =
        const StringToIntConverter().fromJson(json['perpage'] as String?)
    ..page = const StringToIntConverter().fromJson(json['page'] as String?)
    ..pmId = const StringToIntConverter().fromJson(json['pmid'] as String?);
}

Map<String, dynamic> _$PrivateMessageDetailVariablesToJson(
        PrivateMessageDetailVariables instance) =>
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
      'ismoderator': instance.ismoderator,
      'notice': instance.noticeCount,
      'list': instance.pmList,
      'count': const StringToIntConverter().toJson(instance.count),
      'perpage': const StringToIntConverter().toJson(instance.perPage),
      'page': const StringToIntConverter().toJson(instance.page),
      'pmid': const StringToIntConverter().toJson(instance.pmId),
    };

PrivateMessageDetail _$PrivateMessageDetailFromJson(Map<String, dynamic> json) {
  return PrivateMessageDetail()
    ..plid = const StringToIntConverter().fromJson(json['plid'] as String?)
    ..subject = json['subject'] as String
    ..toUid = const StringToIntConverter().fromJson(json['touid'] as String?)
    ..pmId = const StringToIntConverter().fromJson(json['pmid'] as String?)
    ..msgFromId =
        const StringToIntConverter().fromJson(json['msgfromid'] as String?)
    ..msgFromName = json['msgfrom'] as String
    ..message = json['message'] as String
    ..dateTimeString = json['vdateline'] as String;
}

Map<String, dynamic> _$PrivateMessageDetailToJson(
        PrivateMessageDetail instance) =>
    <String, dynamic>{
      'plid': const StringToIntConverter().toJson(instance.plid),
      'subject': instance.subject,
      'touid': const StringToIntConverter().toJson(instance.toUid),
      'pmid': const StringToIntConverter().toJson(instance.pmId),
      'msgfromid': const StringToIntConverter().toJson(instance.msgFromId),
      'msgfrom': instance.msgFromName,
      'message': instance.message,
      'vdateline': instance.dateTimeString,
    };
