

import 'package:json_annotation/json_annotation.dart';

part 'BilibiliDynamicDetailResult.g.dart';

@JsonSerializable()
class BilibiliDynamicDetailResult{

  int code = 0;
  String message = "";
  int ttl = 0;

  BilibiliDynamicDetailData data = BilibiliDynamicDetailData();



  BilibiliDynamicDetailResult();

  factory BilibiliDynamicDetailResult.fromJson(Map<String, dynamic> json) => _$BilibiliDynamicDetailResultFromJson(json);
}

final int BILIBILI_ARTICLE_TYPE_ARTICLE = 0;
final int BILIBILI_ARTICLE_TYPE_NOTE = 2;

@JsonSerializable()
class BilibiliDynamicDetailData{


  BilibiliDynamicDetailItemData item = BilibiliDynamicDetailItemData();

  BilibiliDynamicDetailData();

  factory BilibiliDynamicDetailData.fromJson(Map<String, dynamic> json) => _$BilibiliDynamicDetailDataFromJson(json);
}

@JsonSerializable()
class BilibiliDynamicDetailItemData{

  BilibiliDynamicDetailItemBasic basic = BilibiliDynamicDetailItemBasic();
  String id_str = "";
  BilibiliDynamicDetailItemModule module = BilibiliDynamicDetailItemModule();
  String type = "";
  bool visible = true;



  BilibiliDynamicDetailItemData();

  factory BilibiliDynamicDetailItemData.fromJson(Map<String, dynamic> json) => _$BilibiliDynamicDetailItemDataFromJson(json);
}

@JsonSerializable()
class BilibiliDynamicDetailItemBasic{

  String comment_id_str = "";
  int comment_type = 0;
  String rid_str = "";
  BilibiliDynamicDetailItemBasicLike like_icon = BilibiliDynamicDetailItemBasicLike();


  BilibiliDynamicDetailItemBasic();

  factory BilibiliDynamicDetailItemBasic.fromJson(Map<String, dynamic> json) => _$BilibiliDynamicDetailItemBasicFromJson(json);

}

@JsonSerializable()
class BilibiliDynamicDetailItemBasicLike{

  String action_url = "";
  String end_url = "";
  int id = 0;
  String start_url = "";


  BilibiliDynamicDetailItemBasicLike();

  factory BilibiliDynamicDetailItemBasicLike.fromJson(Map<String, dynamic> json) => _$BilibiliDynamicDetailItemBasicLikeFromJson(json);

}

@JsonSerializable()
class BilibiliDynamicDetailItemModule{

  BilibiliDynamicDetailItemModuleAuthor author = BilibiliDynamicDetailItemModuleAuthor();


  BilibiliDynamicDetailItemModule();

  factory BilibiliDynamicDetailItemModule.fromJson(Map<String, dynamic> json) => _$BilibiliDynamicDetailItemModuleFromJson(json);

}

@JsonSerializable()
class BilibiliDynamicDetailItemModuleAuthor{

  //Object avatar = new Object();
  String face = "";
  String face_nft = "";
  bool? following = false;
  String jump_url = "";
  String label = "";
  int num = 0;
  String name = "";
  BilibiliDynamicDetailItemModuleAuthorOfficialVerify official_verify = BilibiliDynamicDetailItemModuleAuthorOfficialVerify();
  BilibiliDynamicDetailItemModuleAuthorPendant pendant= BilibiliDynamicDetailItemModuleAuthorPendant();
  String pub_action = "";
  String? pub_location_text = "";
  String pub_time = "";
  int pub_ts = 0;
  String type = "";
  BilibiliDynamicDetailItemModuleAuthorVip vip= BilibiliDynamicDetailItemModuleAuthorVip();
  //Object decorate= new Object();
  //Object nft_info= new Object();
  int gender = 0;


  BilibiliDynamicDetailItemModuleAuthor();

  factory BilibiliDynamicDetailItemModuleAuthor.fromJson(Map<String, dynamic> json) => _$BilibiliDynamicDetailItemModuleAuthorFromJson(json);

}

@JsonSerializable()
class BilibiliDynamicDetailItemModuleAuthorOfficialVerify{

  String desc = "";
  int type = 0;


  BilibiliDynamicDetailItemModuleAuthorOfficialVerify();

  factory BilibiliDynamicDetailItemModuleAuthorOfficialVerify.fromJson(Map<String, dynamic> json) => _$BilibiliDynamicDetailItemModuleAuthorOfficialVerifyFromJson(json);

}

@JsonSerializable()
class BilibiliDynamicDetailItemModuleAuthorPendant{

  int expire = 0;
  String image = "";
  String image_enhance = "";
  String image_enhance_frame = "";
  String name = "";
  int pid = 0, n_pid = 0;


  BilibiliDynamicDetailItemModuleAuthorPendant();

  factory BilibiliDynamicDetailItemModuleAuthorPendant.fromJson(Map<String, dynamic> json) => _$BilibiliDynamicDetailItemModuleAuthorPendantFromJson(json);

}

@JsonSerializable()
class BilibiliDynamicDetailItemModuleAuthorVip{

  int avatar_subscript = 0;
  String avatar_subscript_url = "";
  int due_date = 0;
  String nickname_color = "";
  int status = 0;
  int theme_type = 0;
  int type = 0;
  BilibiliDynamicDetailItemModuleAuthorVipLabel label = BilibiliDynamicDetailItemModuleAuthorVipLabel();


  BilibiliDynamicDetailItemModuleAuthorVip();

  factory BilibiliDynamicDetailItemModuleAuthorVip.fromJson(Map<String, dynamic> json) => _$BilibiliDynamicDetailItemModuleAuthorVipFromJson(json);

}

@JsonSerializable()
class BilibiliDynamicDetailItemModuleAuthorVipLabel{

  String bg_color = "";
  int bg_style = 0;
  String? border_color = "";
  String img_label_uri_hans = "", img_label_uri_hant = "";
  String img_label_uri_hans_static = "", img_label_uri_hant_static = "";
  String label_theme = "";
  String? path = "";
  String text = "";
  int text_color = 0;
  bool use_img_label = false;


  BilibiliDynamicDetailItemModuleAuthorVipLabel();

  factory BilibiliDynamicDetailItemModuleAuthorVipLabel.fromJson(Map<String, dynamic> json) => _$BilibiliDynamicDetailItemModuleAuthorVipLabelFromJson(json);

}

@JsonSerializable()
class BilibiliDynamicDetailItemModuleAuthorDecorate{

  String card_url = "";
  int id = 0;
  String jump_url = "";
  String name = "";
  int type = 0;
  BilibiliDynamicDetailItemModuleAuthorDecorateFan fan = BilibiliDynamicDetailItemModuleAuthorDecorateFan();


  BilibiliDynamicDetailItemModuleAuthorDecorate();

  factory BilibiliDynamicDetailItemModuleAuthorDecorate.fromJson(Map<String, dynamic> json) => _$BilibiliDynamicDetailItemModuleAuthorDecorateFromJson(json);

}

@JsonSerializable()
class BilibiliDynamicDetailItemModuleAuthorDecorateFan{

  String color = "";
  bool is_fan = false;
  String num_str = "";
  int number = 0;


  BilibiliDynamicDetailItemModuleAuthorDecorateFan();

  factory BilibiliDynamicDetailItemModuleAuthorDecorateFan.fromJson(Map<String, dynamic> json) => _$BilibiliDynamicDetailItemModuleAuthorDecorateFanFromJson(json);

}

