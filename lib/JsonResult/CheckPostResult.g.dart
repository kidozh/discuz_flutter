// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CheckPostResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckPostResult _$CheckPostResultFromJson(Map<String, dynamic> json) {
  return CheckPostResult()
    ..version = json['Version'] as String
    ..charset = json['Charset'] as String
    ..errorResult = json['Message'] == null
        ? null
        : ErrorResult.fromJson(json['Message'] as Map<String, dynamic>)
    ..error = json['error'] as String?
    ..variables =
        CheckPostVariables.fromJson(json['Variables'] as Map<String, dynamic>);
}

Map<String, dynamic> _$CheckPostResultToJson(CheckPostResult instance) =>
    <String, dynamic>{
      'Version': instance.version,
      'Charset': instance.charset,
      'Message': instance.errorResult,
      'error': instance.error,
      'Variables': instance.variables,
    };

CheckPostVariables _$CheckPostVariablesFromJson(Map<String, dynamic> json) {
  return CheckPostVariables()
    ..groupId =
        const StringToIntConverter().fromJson(json['groupid'] as String?)
    ..readAccess =
        const StringToIntConverter().fromJson(json['readaccess'] as String?)
    ..formHash = json['formhash'] as String
    ..noticeCount = NoticeCount.fromJson(json['notice'] as Map<String, dynamic>)
    ..allowPerm = AllowPerm.fromJson(json['allowperm'] as Map<String, dynamic>);
}

Map<String, dynamic> _$CheckPostVariablesToJson(CheckPostVariables instance) =>
    <String, dynamic>{
      'groupid': const StringToIntConverter().toJson(instance.groupId),
      'readaccess': const StringToIntConverter().toJson(instance.readAccess),
      'formhash': instance.formHash,
      'notice': instance.noticeCount,
      'allowperm': instance.allowPerm,
    };

AllowPerm _$AllowPermFromJson(Map<String, dynamic> json) {
  return AllowPerm()
    ..allowPost =
        const StringToBoolConverter().fromJson(json['allowpost'] as String?)
    ..allowReply =
        const StringToBoolConverter().fromJson(json['allowreply'] as String?)
    ..uploadHash = json['uploadhash'] as String
    ..allowUpload =
        AllowUpload.fromJson(json['allowupload'] as Map<String, dynamic>)
    ..attachRemain =
        AttachRemain.fromJson(json['attachremain'] as Map<String, dynamic>);
}

Map<String, dynamic> _$AllowPermToJson(AllowPerm instance) => <String, dynamic>{
      'allowpost': const StringToBoolConverter().toJson(instance.allowPost),
      'allowreply': const StringToBoolConverter().toJson(instance.allowReply),
      'uploadhash': instance.uploadHash,
      'allowupload': instance.allowUpload,
      'attachremain': instance.attachRemain,
    };

AllowUpload _$AllowUploadFromJson(Map<String, dynamic> json) {
  return AllowUpload();
}

Map<String, dynamic> _$AllowUploadToJson(AllowUpload instance) =>
    <String, dynamic>{};

AttachRemain _$AttachRemainFromJson(Map<String, dynamic> json) {
  return AttachRemain();
}

Map<String, dynamic> _$AttachRemainToJson(AttachRemain instance) =>
    <String, dynamic>{};
