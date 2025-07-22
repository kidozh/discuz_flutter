// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'SmmsUploadImageResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SmmsUploadImageResult _$SmmsUploadImageResultFromJson(
        Map<String, dynamic> json) =>
    SmmsUploadImageResult(
      success: json['success'] as bool,
      code: json['code'] as String,
      message: json['message'] as String,
      data: SmmsUploadImageData.fromJson(json['data'] as Map<String, dynamic>),
      requestId: json['RequestId'] as String,
    );

Map<String, dynamic> _$SmmsUploadImageResultToJson(
        SmmsUploadImageResult instance) =>
    <String, dynamic>{
      'success': instance.success,
      'code': instance.code,
      'message': instance.message,
      'data': instance.data.toJson(),
      'RequestId': instance.requestId,
    };

SmmsUploadImageData _$SmmsUploadImageDataFromJson(Map<String, dynamic> json) =>
    SmmsUploadImageData(
      fileId: (json['file_id'] as num).toInt(),
      width: (json['width'] as num).toInt(),
      height: (json['height'] as num).toInt(),
      filename: json['filename'] as String,
      storename: json['storename'] as String,
      size: (json['size'] as num).toInt(),
      path: json['path'] as String,
      hash: json['hash'] as String,
      url: json['url'] as String,
      delete: json['delete'] as String,
      page: json['page'] as String,
    );

Map<String, dynamic> _$SmmsUploadImageDataToJson(
        SmmsUploadImageData instance) =>
    <String, dynamic>{
      'file_id': instance.fileId,
      'width': instance.width,
      'height': instance.height,
      'filename': instance.filename,
      'storename': instance.storename,
      'size': instance.size,
      'path': instance.path,
      'hash': instance.hash,
      'url': instance.url,
      'delete': instance.delete,
      'page': instance.page,
    };
