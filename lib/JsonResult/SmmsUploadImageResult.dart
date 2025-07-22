import 'package:json_annotation/json_annotation.dart';

part 'SmmsUploadImageResult.g.dart'; // Name your file, e.g., smms_upload_response.dart

@JsonSerializable(explicitToJson: true)
class SmmsUploadImageResult {
  bool success;
  String code;
  String message;
  SmmsUploadImageData data;

  @JsonKey(name: 'RequestId')
  String requestId;

  SmmsUploadImageResult({
    required this.success,
    required this.code,
    required this.message,
    required this.data,
    required this.requestId,
  });

  factory SmmsUploadImageResult.fromJson(Map<String, dynamic> json) =>
      _$SmmsUploadImageResultFromJson(json);

  Map<String, dynamic> toJson() => _$SmmsUploadImageResultToJson(this);
}

@JsonSerializable()
class SmmsUploadImageData {
  @JsonKey(name: 'file_id')
  int fileId; // Assuming it's always an int, even if 0

  int width;
  int height;
  String filename;
  String storename;
  int size;
  String path;
  String hash;
  String url;
  String delete;
  String page;

  SmmsUploadImageData({
    required this.fileId,
    required this.width,
    required this.height,
    required this.filename,
    required this.storename,
    required this.size,
    required this.path,
    required this.hash,
    required this.url,
    required this.delete,
    required this.page,
  });

  factory SmmsUploadImageData.fromJson(Map<String, dynamic> json) =>
      _$SmmsUploadImageDataFromJson(json);

  Map<String, dynamic> toJson() => _$SmmsUploadImageDataToJson(this);
}
