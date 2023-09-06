

import 'package:json_annotation/json_annotation.dart';

part 'ThreadSlideShowResult.g.dart';

@JsonSerializable()
class ThreadSlideShowResult{
  String result = "";
  @JsonKey(name: "channel_list")
  List<SlideShow> slideshow_list = [];
  String reason = "";

  ThreadSlideShowResult();

  factory ThreadSlideShowResult.fromJson(Map<String, dynamic> json) => _$ThreadSlideShowResultFromJson(json);

  bool isSuccess(){
    return result == "success";
  }
}

@JsonSerializable()
class SlideShow{
  @JsonKey(name: "_id")
  String id = "";
  String image_src = "";
  String title = "";
  String forum = "";
  String category = "";
  String author = "";
  int tid = 0;
  String identification = "";
  String discuz_site_host = "";
  String date = "";

  SlideShow();

  factory SlideShow.fromJson(Map<String, dynamic> json) => _$SlideShowFromJson(json);
}