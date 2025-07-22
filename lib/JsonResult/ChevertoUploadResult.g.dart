// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ChevertoUploadResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChevertoUploadResult _$ChevertoUploadResultFromJson(
        Map<String, dynamic> json) =>
    ChevertoUploadResult(
      statusCode: (json['status_code'] as num).toInt(),
      success: ChevertoSuccessMessage.fromJson(
          json['success'] as Map<String, dynamic>),
      image:
          ChevertoUploadedImage.fromJson(json['image'] as Map<String, dynamic>),
      statusTxt: json['status_txt'] as String,
    );

Map<String, dynamic> _$ChevertoUploadResultToJson(
        ChevertoUploadResult instance) =>
    <String, dynamic>{
      'status_code': instance.statusCode,
      'success': instance.success.toJson(),
      'image': instance.image.toJson(),
      'status_txt': instance.statusTxt,
    };

ChevertoSuccessMessage _$ChevertoSuccessMessageFromJson(
        Map<String, dynamic> json) =>
    ChevertoSuccessMessage(
      message: json['message'] as String,
      code: (json['code'] as num).toInt(),
    );

Map<String, dynamic> _$ChevertoSuccessMessageToJson(
        ChevertoSuccessMessage instance) =>
    <String, dynamic>{
      'message': instance.message,
      'code': instance.code,
    };

ChevertoUploadedImage _$ChevertoUploadedImageFromJson(
        Map<String, dynamic> json) =>
    ChevertoUploadedImage(
      name: json['name'] as String,
      extension: json['extension'] as String,
      size: (json['size'] as num).toInt(),
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      date: json['date'] as String,
      dateGmt: json['date_gmt'] as String,
      title: json['title'] as String,
      tags: json['tags'] as List<dynamic>,
      description: json['description'] as String?,
      nsfw: (json['nsfw'] as num).toInt(),
      storageMode: json['storage_mode'] as String?,
      md5: json['md5'] as String,
      sourceMd5: json['source_md5'] as String?,
      originalFilename: json['original_filename'] as String?,
      originalExifdata: json['original_exifdata'],
      views: (json['views'] as num).toInt(),
      categoryId: (json['category_id'] as num?)?.toInt(),
      chain: (json['chain'] as num?)?.toInt(),
      thumbSize: (json['thumb_size'] as num?)?.toInt(),
      mediumSize: (json['medium_size'] as num?)?.toInt(),
      frameSize: (json['frame_size'] as num?)?.toInt(),
      expirationDateGmt: json['expiration_date_gmt'] as String?,
      likes: (json['likes'] as num).toInt(),
      isAnimated: (json['is_animated'] as num).toInt(),
      isApproved: (json['is_approved'] as num).toInt(),
      is360: (json['is_360'] as num).toInt(),
      duration: (json['duration'] as num?)?.toDouble(),
      type: json['type'] as String,
      tagsString: json['tags_string'] as String?,
      file: ChevertoFileObject.fromJson(json['file'] as Map<String, dynamic>),
      idEncoded: json['id_encoded'] as String,
      filename: json['filename'] as String,
      mime: json['mime'] as String,
      url: json['url'] as String,
      ratio: (json['ratio'] as num?)?.toDouble(),
      sizeFormatted: json['size_formatted'] as String?,
      frame: json['frame'] == null
          ? null
          : ChevertoFrame.fromJson(json['frame'] as Map<String, dynamic>),
      imageDetails: json['image'] == null
          ? null
          : ChevertoImageDetails.fromJson(
              json['image'] as Map<String, dynamic>),
      thumb: ChevertoCompressedImage.fromJson(
          json['thumb'] as Map<String, dynamic>),
      urlFrame: json['url_frame'] as String?,
      medium: json['medium'] == null
          ? null
          : ChevertoCompressedImage.fromJson(
              json['medium'] as Map<String, dynamic>),
      durationTime: json['duration_time'] as String?,
      urlViewer: json['url_viewer'] as String,
      pathViewer: json['path_viewer'] as String?,
      urlShort: json['url_short'] as String?,
      displayUrl: json['display_url'] as String?,
      displayWidth: (json['display_width'] as num?)?.toInt(),
      displayHeight: (json['display_height'] as num?)?.toInt(),
      viewsLabel: json['views_label'] as String?,
      likesLabel: json['likes_label'] as String?,
      howLongAgo: json['how_long_ago'] as String?,
      dateFixedPeer: json['date_fixed_peer'] as String?,
      titleTruncated: json['title_truncated'] as String?,
      titleTruncatedHtml: json['title_truncated_html'] as String?,
      isUseLoader: json['is_use_loader'] as bool?,
      displayTitle: json['display_title'] as String?,
      deleteUrl: json['delete_url'] as String?,
    );

Map<String, dynamic> _$ChevertoUploadedImageToJson(
        ChevertoUploadedImage instance) =>
    <String, dynamic>{
      'name': instance.name,
      'extension': instance.extension,
      'size': instance.size,
      'width': instance.width,
      'height': instance.height,
      'date': instance.date,
      'date_gmt': instance.dateGmt,
      'title': instance.title,
      'tags': instance.tags,
      'description': instance.description,
      'nsfw': instance.nsfw,
      'storage_mode': instance.storageMode,
      'md5': instance.md5,
      'source_md5': instance.sourceMd5,
      'original_filename': instance.originalFilename,
      'original_exifdata': instance.originalExifdata,
      'views': instance.views,
      'category_id': instance.categoryId,
      'chain': instance.chain,
      'thumb_size': instance.thumbSize,
      'medium_size': instance.mediumSize,
      'frame_size': instance.frameSize,
      'expiration_date_gmt': instance.expirationDateGmt,
      'likes': instance.likes,
      'is_animated': instance.isAnimated,
      'is_approved': instance.isApproved,
      'is_360': instance.is360,
      'duration': instance.duration,
      'type': instance.type,
      'tags_string': instance.tagsString,
      'file': instance.file.toJson(),
      'id_encoded': instance.idEncoded,
      'filename': instance.filename,
      'mime': instance.mime,
      'url': instance.url,
      'ratio': instance.ratio,
      'size_formatted': instance.sizeFormatted,
      'frame': instance.frame?.toJson(),
      'image': instance.imageDetails?.toJson(),
      'thumb': instance.thumb.toJson(),
      'url_frame': instance.urlFrame,
      'medium': instance.medium?.toJson(),
      'duration_time': instance.durationTime,
      'url_viewer': instance.urlViewer,
      'path_viewer': instance.pathViewer,
      'url_short': instance.urlShort,
      'display_url': instance.displayUrl,
      'display_width': instance.displayWidth,
      'display_height': instance.displayHeight,
      'views_label': instance.viewsLabel,
      'likes_label': instance.likesLabel,
      'how_long_ago': instance.howLongAgo,
      'date_fixed_peer': instance.dateFixedPeer,
      'title_truncated': instance.titleTruncated,
      'title_truncated_html': instance.titleTruncatedHtml,
      'is_use_loader': instance.isUseLoader,
      'display_title': instance.displayTitle,
      'delete_url': instance.deleteUrl,
    };

ChevertoFileObject _$ChevertoFileObjectFromJson(Map<String, dynamic> json) =>
    ChevertoFileObject(
      resource: ChevertoFileResource.fromJson(
          json['resource'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ChevertoFileObjectToJson(ChevertoFileObject instance) =>
    <String, dynamic>{
      'resource': instance.resource.toJson(),
    };

ChevertoFileResource _$ChevertoFileResourceFromJson(
        Map<String, dynamic> json) =>
    ChevertoFileResource(
      type: json['type'] as String,
    );

Map<String, dynamic> _$ChevertoFileResourceToJson(
        ChevertoFileResource instance) =>
    <String, dynamic>{
      'type': instance.type,
    };

ChevertoImageDetails _$ChevertoImageDetailsFromJson(
        Map<String, dynamic> json) =>
    ChevertoImageDetails(
      filename: json['filename'] as String?,
      name: json['name'] as String?,
      mime: json['mime'] as String?,
      extension: json['extension'] as String?,
      url: json['url'] as String?,
      size: (json['size'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ChevertoImageDetailsToJson(
        ChevertoImageDetails instance) =>
    <String, dynamic>{
      'filename': instance.filename,
      'name': instance.name,
      'mime': instance.mime,
      'extension': instance.extension,
      'url': instance.url,
      'size': instance.size,
    };

ChevertoFrame _$ChevertoFrameFromJson(Map<String, dynamic> json) =>
    ChevertoFrame(
      filename: json['filename'] as String?,
      name: json['name'] as String?,
      mime: json['mime'] as String?,
      extension: json['extension'] as String?,
      url: json['url'] as String?,
      size: (json['size'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ChevertoFrameToJson(ChevertoFrame instance) =>
    <String, dynamic>{
      'filename': instance.filename,
      'name': instance.name,
      'mime': instance.mime,
      'extension': instance.extension,
      'url': instance.url,
      'size': instance.size,
    };

ChevertoCompressedImage _$ChevertoCompressedImageFromJson(
        Map<String, dynamic> json) =>
    ChevertoCompressedImage(
      filename: json['filename'] as String?,
      name: json['name'] as String?,
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      ratio: (json['ratio'] as num?)?.toDouble(),
      size: (json['size'] as num?)?.toInt(),
      sizeFormatted: json['size_formatted'] as String?,
      mime: json['mime'] as String?,
      extension: json['extension'] as String?,
      bits: (json['bits'] as num?)?.toInt(),
      url: json['url'] as String?,
    );

Map<String, dynamic> _$ChevertoCompressedImageToJson(
        ChevertoCompressedImage instance) =>
    <String, dynamic>{
      'filename': instance.filename,
      'name': instance.name,
      'width': instance.width,
      'height': instance.height,
      'ratio': instance.ratio,
      'size': instance.size,
      'size_formatted': instance.sizeFormatted,
      'mime': instance.mime,
      'extension': instance.extension,
      'bits': instance.bits,
      'url': instance.url,
    };
