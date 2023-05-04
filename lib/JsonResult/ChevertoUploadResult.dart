
import 'package:json_annotation/json_annotation.dart';

part 'ChevertoUploadResult.g.dart';

@JsonSerializable()
class ChevertoUploadResult{
  int status_code = 0;
  String status_txt = "";
  ChevertoSuccessMessage success = ChevertoSuccessMessage();
  ChevertoUploadedImage image = ChevertoUploadedImage();

  ChevertoUploadResult();
  factory ChevertoUploadResult.fromJson(Map<String, dynamic> json) => _$ChevertoUploadResultFromJson(json);
  Map<String, dynamic> toJson() => _$ChevertoUploadResultToJson(this);
}

@JsonSerializable()
class ChevertoSuccessMessage {
  String message = "";
  int code = 0;

  ChevertoSuccessMessage();
  factory ChevertoSuccessMessage.fromJson(Map<String, dynamic> json) => _$ChevertoSuccessMessageFromJson(json);
  Map<String, dynamic> toJson() => _$ChevertoSuccessMessageToJson(this);
}

@JsonSerializable()
class ChevertoUploadedImage{
  String name = "", extension = "";
  int size = 0, width = 0, height= 0;
  String date = "", date_gmt = "";
  String nsfw = "0";
  String md5 = "";
  String storage = "", original_filename = "";
  String views = "";
  String id_encoded = "", filename="";
  double ratio = 0.0;
  String size_formatted = "", mime = "";
  int bits = 0;
  String url = "", url_viewer = "";
  String views_label = "", display_url = "", how_long_ago="";

  ChevertoCompressedImage thumb = ChevertoCompressedImage();
  ChevertoCompressedImage medium = ChevertoCompressedImage();

  ChevertoUploadedImage();
  factory ChevertoUploadedImage.fromJson(Map<String, dynamic> json) => _$ChevertoUploadedImageFromJson(json);
  Map<String, dynamic> toJson() => _$ChevertoUploadedImageToJson(this);
}

@JsonSerializable()
class ChevertoCompressedImage{
  String filename = "", name = "";
  int width = 0, height = 0;
  double ratio = 0.0;
  int size = 0;
  String size_formatted = "";
  String mime = "", extension = "";
  int bits = 0;
  String url = "";

  ChevertoCompressedImage();
  factory ChevertoCompressedImage.fromJson(Map<String, dynamic> json) => _$ChevertoCompressedImageFromJson(json);
  Map<String, dynamic> toJson() => _$ChevertoCompressedImageToJson(this);
}