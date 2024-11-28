

import 'package:discuz_flutter/converter/SecondToDateTimeConverter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'BilibiliVideoResult.g.dart';

@JsonSerializable()
class BilibiliVideoResult{

  int code = 0;
  String message = "";
  int ttl = 0;

  BilibiliVideoData data = BilibiliVideoData();



  BilibiliVideoResult();

  factory BilibiliVideoResult.fromJson(Map<String, dynamic> json) => _$BilibiliVideoResultFromJson(json);
}

@JsonSerializable()
class BilibiliVideoData{
  @JsonKey(name: "View")
  BilibiliVideoViewData viewData = BilibiliVideoViewData();

  BilibiliVideoData();

  factory BilibiliVideoData.fromJson(Map<String, dynamic> json) => _$BilibiliVideoDataFromJson(json);
}

@JsonSerializable()
class BilibiliVideoViewData{

  String bvid = "";
  int aid = 0;
  int videos = 0;
  int tid = 0;
  String tname = "";
  int copyright = 1;
  String pic = "";
  String title = "";
  int pubdate = 0, ctime = 0;
  String desc = "";
  int state = 0;
  int duration = 0, mission_id=0;

  BilibiliVideoViewDataOwner owner = BilibiliVideoViewDataOwner();


  BilibiliVideoViewData();

  factory BilibiliVideoViewData.fromJson(Map<String, dynamic> json) => _$BilibiliVideoViewDataFromJson(json);
}

@JsonSerializable()
class BilibiliVideoViewDataOwner{

  int mid = 0;
  String name = "", face="";

  BilibiliVideoViewDataOwner();

  factory BilibiliVideoViewDataOwner.fromJson(Map<String, dynamic> json) => _$BilibiliVideoViewDataOwnerFromJson(json);

}