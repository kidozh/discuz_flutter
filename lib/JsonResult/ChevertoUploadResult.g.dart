// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ChevertoUploadResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChevertoUploadResult _$ChevertoUploadResultFromJson(
        Map<String, dynamic> json) =>
    ChevertoUploadResult()
      ..status_code = json['status_code'] as int
      ..status_txt = json['status_txt'] as String
      ..success = ChevertoSuccessMessage.fromJson(
          json['success'] as Map<String, dynamic>)
      ..image =
          ChevertoUploadedImage.fromJson(json['image'] as Map<String, dynamic>);

Map<String, dynamic> _$ChevertoUploadResultToJson(
        ChevertoUploadResult instance) =>
    <String, dynamic>{
      'status_code': instance.status_code,
      'status_txt': instance.status_txt,
      'success': instance.success,
      'image': instance.image,
    };

ChevertoSuccessMessage _$ChevertoSuccessMessageFromJson(
        Map<String, dynamic> json) =>
    ChevertoSuccessMessage()
      ..message = json['message'] as String
      ..code = json['code'] as int;

Map<String, dynamic> _$ChevertoSuccessMessageToJson(
        ChevertoSuccessMessage instance) =>
    <String, dynamic>{
      'message': instance.message,
      'code': instance.code,
    };

ChevertoUploadedImage _$ChevertoUploadedImageFromJson(
        Map<String, dynamic> json) =>
    ChevertoUploadedImage()
      ..name = json['name'] as String
      ..extension = json['extension'] as String
      ..size = json['size'] as int
      ..width = json['width'] as int
      ..height = json['height'] as int
      ..date = json['date'] as String
      ..date_gmt = json['date_gmt'] as String
      ..nsfw = json['nsfw'] as String
      ..md5 = json['md5'] as String
      ..storage = json['storage'] as String
      ..original_filename = json['original_filename'] as String
      ..views = json['views'] as String
      ..id_encoded = json['id_encoded'] as String
      ..filename = json['filename'] as String
      ..ratio = (json['ratio'] as num).toDouble()
      ..size_formatted = json['size_formatted'] as String
      ..mime = json['mime'] as String
      ..bits = json['bits'] as int
      ..url = json['url'] as String
      ..url_viewer = json['url_viewer'] as String
      ..views_label = json['views_label'] as String
      ..display_url = json['display_url'] as String
      ..how_long_ago = json['how_long_ago'] as String
      ..thumb = ChevertoCompressedImage.fromJson(
          json['thumb'] as Map<String, dynamic>)
      ..medium = ChevertoCompressedImage.fromJson(
          json['medium'] as Map<String, dynamic>);

Map<String, dynamic> _$ChevertoUploadedImageToJson(
        ChevertoUploadedImage instance) =>
    <String, dynamic>{
      'name': instance.name,
      'extension': instance.extension,
      'size': instance.size,
      'width': instance.width,
      'height': instance.height,
      'date': instance.date,
      'date_gmt': instance.date_gmt,
      'nsfw': instance.nsfw,
      'md5': instance.md5,
      'storage': instance.storage,
      'original_filename': instance.original_filename,
      'views': instance.views,
      'id_encoded': instance.id_encoded,
      'filename': instance.filename,
      'ratio': instance.ratio,
      'size_formatted': instance.size_formatted,
      'mime': instance.mime,
      'bits': instance.bits,
      'url': instance.url,
      'url_viewer': instance.url_viewer,
      'views_label': instance.views_label,
      'display_url': instance.display_url,
      'how_long_ago': instance.how_long_ago,
      'thumb': instance.thumb,
      'medium': instance.medium,
    };

ChevertoCompressedImage _$ChevertoCompressedImageFromJson(
        Map<String, dynamic> json) =>
    ChevertoCompressedImage()
      ..filename = json['filename'] as String
      ..name = json['name'] as String
      ..width = json['width'] as int
      ..height = json['height'] as int
      ..ratio = (json['ratio'] as num).toDouble()
      ..size = json['size'] as int
      ..size_formatted = json['size_formatted'] as String
      ..mime = json['mime'] as String
      ..extension = json['extension'] as String
      ..bits = json['bits'] as int
      ..url = json['url'] as String;

Map<String, dynamic> _$ChevertoCompressedImageToJson(
        ChevertoCompressedImage instance) =>
    <String, dynamic>{
      'filename': instance.filename,
      'name': instance.name,
      'width': instance.width,
      'height': instance.height,
      'ratio': instance.ratio,
      'size': instance.size,
      'size_formatted': instance.size_formatted,
      'mime': instance.mime,
      'extension': instance.extension,
      'bits': instance.bits,
      'url': instance.url,
    };
