import 'package:json_annotation/json_annotation.dart';

part 'ChevertoUploadResult.g.dart';

@JsonSerializable(explicitToJson: true) // explicitToJson is good for nested objects
class ChevertoUploadResult {
  @JsonKey(name: 'status_code')
  int statusCode;

  ChevertoSuccessMessage success;

  ChevertoUploadedImage image;

  @JsonKey(name: 'status_txt')
  String statusTxt;

  ChevertoUploadResult({
    required this.statusCode,
    required this.success,
    required this.image,
    required this.statusTxt,
  });

  factory ChevertoUploadResult.fromJson(Map<String, dynamic> json) =>
      _$ChevertoUploadResultFromJson(json);
  Map<String, dynamic> toJson() => _$ChevertoUploadResultToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ChevertoSuccessMessage {
  String message;
  int code;

  ChevertoSuccessMessage({
    required this.message,
    required this.code,
  });

  factory ChevertoSuccessMessage.fromJson(Map<String, dynamic> json) =>
      _$ChevertoSuccessMessageFromJson(json);
  Map<String, dynamic> toJson() => _$ChevertoSuccessMessageToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ChevertoUploadedImage {
  String name;
  String extension;
  int size;
  int? width; // Can be null if not an image/video with dimensions
  int? height;
  String date;

  @JsonKey(name: 'date_gmt')
  String dateGmt;

  String title;
  List<dynamic> tags; // Or List<String> if tags are always strings
  String? description;

  int nsfw;

  @JsonKey(name: 'storage_mode')
  String? storageMode;

  String md5;

  @JsonKey(name: 'source_md5')
  String? sourceMd5;

  @JsonKey(name: 'original_filename')
  String? originalFilename;

  @JsonKey(name: 'original_exifdata')
  dynamic originalExifdata; // Type accordingly if structure is known

  int views;

  @JsonKey(name: 'category_id')
  int? categoryId;

  int? chain; // Assuming int, adjust if different

  @JsonKey(name: 'thumb_size')
  int? thumbSize;

  @JsonKey(name: 'medium_size')
  int? mediumSize;

  @JsonKey(name: 'frame_size')
  int? frameSize;

  @JsonKey(name: 'expiration_date_gmt')
  String? expirationDateGmt;

  int likes;

  @JsonKey(name: 'is_animated')
  int isAnimated; // 0 or 1, can be bool with a converter

  @JsonKey(name: 'is_approved')
  int isApproved; // 0 or 1, can be bool with a converter

  @JsonKey(name: 'is_360')
  int is360; // 0 or 1, can be bool with a converter

  double? duration; // Duration in seconds
  String type;

  @JsonKey(name: 'tags_string')
  String? tagsString;

  ChevertoFileObject file;

  @JsonKey(name: 'id_encoded')
  String idEncoded;

  String filename;
  String mime;
  String url;
  double? ratio;

  @JsonKey(name: 'size_formatted')
  String? sizeFormatted;

  ChevertoFrame? frame; // Nested frame object

  @JsonKey(name: 'image') // This is the nested "image" object
  ChevertoImageDetails? imageDetails;

  ChevertoCompressedImage thumb;

  @JsonKey(name: 'url_frame')
  String? urlFrame;

  ChevertoCompressedImage? medium; // Medium can be null or have null fields

  @JsonKey(name: 'duration_time')
  String? durationTime; // e.g., "01:13"

  @JsonKey(name: 'url_viewer')
  String urlViewer;

  @JsonKey(name: 'path_viewer')
  String? pathViewer;

  @JsonKey(name: 'url_short')
  String? urlShort;

  @JsonKey(name: 'display_url')
  String? displayUrl;

  @JsonKey(name: 'display_width')
  int? displayWidth;

  @JsonKey(name: 'display_height')
  int? displayHeight;

  @JsonKey(name: 'views_label')
  String? viewsLabel;

  @JsonKey(name: 'likes_label')
  String? likesLabel;

  @JsonKey(name: 'how_long_ago')
  String? howLongAgo;

  @JsonKey(name: 'date_fixed_peer')
  String? dateFixedPeer;

  @JsonKey(name: 'title_truncated')
  String? titleTruncated;

  @JsonKey(name: 'title_truncated_html')
  String? titleTruncatedHtml;

  @JsonKey(name: 'is_use_loader')
  bool? isUseLoader;

  @JsonKey(name: 'display_title')
  String? displayTitle;

  @JsonKey(name: 'delete_url')
  String? deleteUrl;


  ChevertoUploadedImage({
    required this.name,
    required this.extension,
    required this.size,
    this.width,
    this.height,
    required this.date,
    required this.dateGmt,
    required this.title,
    required this.tags,
    this.description,
    required this.nsfw,
    this.storageMode,
    required this.md5,
    this.sourceMd5,
    this.originalFilename,
    this.originalExifdata,
    required this.views,
    this.categoryId,
    this.chain,
    this.thumbSize,
    this.mediumSize,
    this.frameSize,
    this.expirationDateGmt,
    required this.likes,
    required this.isAnimated,
    required this.isApproved,
    required this.is360,
    this.duration,
    required this.type,
    this.tagsString,
    required this.file,
    required this.idEncoded,
    required this.filename,
    required this.mime,
    required this.url,
    this.ratio,
    this.sizeFormatted,
    this.frame,
    this.imageDetails,
    required this.thumb,
    this.urlFrame,
    this.medium,
    this.durationTime,
    required this.urlViewer,
    this.pathViewer,
    this.urlShort,
    this.displayUrl,
    this.displayWidth,
    this.displayHeight,
    this.viewsLabel,
    this.likesLabel,
    this.howLongAgo,
    this.dateFixedPeer,
    this.titleTruncated,
    this.titleTruncatedHtml,
    this.isUseLoader,
    this.displayTitle,
    this.deleteUrl,
  });

  factory ChevertoUploadedImage.fromJson(Map<String, dynamic> json) =>
      _$ChevertoUploadedImageFromJson(json);
  Map<String, dynamic> toJson() => _$ChevertoUploadedImageToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ChevertoFileObject {
  ChevertoFileResource resource;

  ChevertoFileObject({required this.resource});

  factory ChevertoFileObject.fromJson(Map<String, dynamic> json) =>
      _$ChevertoFileObjectFromJson(json);
  Map<String, dynamic> toJson() => _$ChevertoFileObjectToJson(this);
}

@JsonSerializable()
class ChevertoFileResource {
  String type; // "url"

  ChevertoFileResource({required this.type});

  factory ChevertoFileResource.fromJson(Map<String, dynamic> json) =>
      _$ChevertoFileResourceFromJson(json);
  Map<String, dynamic> toJson() => _$ChevertoFileResourceToJson(this);
}

@JsonSerializable()
class ChevertoImageDetails { // For the nested "image" object
  String? filename;
  String? name;
  String? mime;
  String? extension;
  String? url;
  int? size;

  ChevertoImageDetails({
    this.filename,
    this.name,
    this.mime,
    this.extension,
    this.url,
    this.size,
  });

  factory ChevertoImageDetails.fromJson(Map<String, dynamic> json) =>
      _$ChevertoImageDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$ChevertoImageDetailsToJson(this);
}


@JsonSerializable()
class ChevertoFrame {
  String? filename;
  String? name;
  String? mime;
  String? extension;
  String? url;
  int? size;
  // Add other fields if 'frame' can have more, similar to ChevertoCompressedImage

  ChevertoFrame({
    this.filename,
    this.name,
    this.mime,
    this.extension,
    this.url,
    this.size,
  });

  factory ChevertoFrame.fromJson(Map<String, dynamic> json) =>
      _$ChevertoFrameFromJson(json);
  Map<String, dynamic> toJson() => _$ChevertoFrameToJson(this);
}

@JsonSerializable()
class ChevertoCompressedImage {
  String? filename; // Made nullable as per "medium" example
  String? name;
  int? width;
  int? height;
  double? ratio;
  int? size;
  @JsonKey(name: 'size_formatted')
  String? sizeFormatted;
  String? mime;
  String? extension;
  int? bits;
  String? url;

  ChevertoCompressedImage({
    this.filename,
    this.name,
    this.width,
    this.height,
    this.ratio,
    this.size,
    this.sizeFormatted,
    this.mime,
    this.extension,
    this.bits,
    this.url,
  });

  factory ChevertoCompressedImage.fromJson(Map<String, dynamic> json) =>
      _$ChevertoCompressedImageFromJson(json);
  Map<String, dynamic> toJson() => _$ChevertoCompressedImageToJson(this);
}

