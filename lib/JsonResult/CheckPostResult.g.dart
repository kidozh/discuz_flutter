// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CheckPostResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckPostResult _$CheckPostResultFromJson(Map<String, dynamic> json) =>
    CheckPostResult()
      ..version = json['Version'] as String
      ..charset = json['Charset'] as String
      ..errorResult = json['Message'] == null
          ? null
          : ErrorResult.fromJson(json['Message'] as Map<String, dynamic>)
      ..error = json['error'] as String?
      ..variables = CheckPostVariables.fromJson(
          json['Variables'] as Map<String, dynamic>);

Map<String, dynamic> _$CheckPostResultToJson(CheckPostResult instance) =>
    <String, dynamic>{
      'Version': instance.version,
      'Charset': instance.charset,
      'Message': instance.errorResult,
      'error': instance.error,
      'Variables': instance.variables,
    };

CheckPostVariables _$CheckPostVariablesFromJson(Map<String, dynamic> json) =>
    CheckPostVariables()
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
      ..noticeCount =
          NoticeCount.fromJson(json['notice'] as Map<String, dynamic>)
      ..allowPerm =
          AllowPerm.fromJson(json['allowperm'] as Map<String, dynamic>);

Map<String, dynamic> _$CheckPostVariablesToJson(CheckPostVariables instance) =>
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
      'notice': instance.noticeCount,
      'allowperm': instance.allowPerm,
    };

AllowPerm _$AllowPermFromJson(Map<String, dynamic> json) => AllowPerm()
  ..allowPost =
      const StringToBoolConverter().fromJson(json['allowpost'] as String?)
  ..allowReply =
      const StringToBoolConverter().fromJson(json['allowreply'] as String?)
  ..uploadHash = json['uploadhash'] as String
  ..allowUpload =
      AllowUpload.fromJson(json['allowupload'] as Map<String, dynamic>)
  ..attachRemain =
      AttachRemain.fromJson(json['attachremain'] as Map<String, dynamic>);

Map<String, dynamic> _$AllowPermToJson(AllowPerm instance) => <String, dynamic>{
      'allowpost': const StringToBoolConverter().toJson(instance.allowPost),
      'allowreply': const StringToBoolConverter().toJson(instance.allowReply),
      'uploadhash': instance.uploadHash,
      'allowupload': instance.allowUpload,
      'attachremain': instance.attachRemain,
    };

AllowUpload _$AllowUploadFromJson(Map<String, dynamic> json) => AllowUpload();

Map<String, dynamic> _$AllowUploadToJson(AllowUpload instance) =>
    <String, dynamic>{};

AttachRemain _$AttachRemainFromJson(Map<String, dynamic> json) =>
    AttachRemain();

Map<String, dynamic> _$AttachRemainToJson(AttachRemain instance) =>
    <String, dynamic>{};
