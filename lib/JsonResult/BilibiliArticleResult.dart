

import 'package:json_annotation/json_annotation.dart';

part 'BilibiliArticleResult.g.dart';

@JsonSerializable()
class BilibiliArticleResult{

  int code = 0;
  String message = "";
  int ttl = 0;

  BilibiliArticleData data = BilibiliArticleData();



  BilibiliArticleResult();

  factory BilibiliArticleResult.fromJson(Map<String, dynamic> json) => _$BilibiliArticleResultFromJson(json);
}

final int BILIBILI_ARTICLE_TYPE_ARTICLE = 0;
final int BILIBILI_ARTICLE_TYPE_NOTE = 2;

@JsonSerializable()
class BilibiliArticleData{
  int like = 0;
  bool attention = false;
  bool favorite = false;
  int coin = 0;
  String banner_url = "";
  int mid = 0;
  String author_name = "";
  List<String> image_urls = [];
  List<String> origin_image_urls	 = [];
  bool sharable = false;
  bool show_later_watch = false;
  bool show_small_window = false;
  bool in_list = false;
  int pre = 0, next = 0;
  int type = 0;

  List<BilibiliArticleShareChannel> share_channels = [];


  @JsonKey(name: "View")
  BilibiliArticleStatsData viewData = BilibiliArticleStatsData();

  BilibiliArticleData();

  factory BilibiliArticleData.fromJson(Map<String, dynamic> json) => _$BilibiliArticleDataFromJson(json);
}

@JsonSerializable()
class BilibiliArticleStatsData{

  int view = 0, favorite=0, like=0, dislike=0, reply = 0, share = 0, coin = 0;
  @JsonKey(name: "dynamic")
  int dynamic_num = 0;


  BilibiliArticleStatsData();

  factory BilibiliArticleStatsData.fromJson(Map<String, dynamic> json) => _$BilibiliArticleStatsDataFromJson(json);
}

@JsonSerializable()
class BilibiliArticleShareChannel{

  String name = "";
  String picture = "";
  String share_channel = "";

  BilibiliArticleShareChannel();

  factory BilibiliArticleShareChannel.fromJson(Map<String, dynamic> json) => _$BilibiliArticleShareChannelFromJson(json);

}