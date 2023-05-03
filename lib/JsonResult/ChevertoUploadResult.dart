
import 'package:json_annotation/json_annotation.dart';

part 'ChevertoUploadResult.g.dart';

@JsonSerializable()
class ChevertoUploadResult{
  int status_code = 0;
  String status_txt = "";
  ChevertoSuccessMessage success = ChevertoSuccessMessage();
}

class ChevertoSuccessMessage {
  String message = "";
  int code = 0;
}

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
}