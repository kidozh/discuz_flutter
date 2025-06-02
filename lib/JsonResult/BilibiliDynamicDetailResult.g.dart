// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'BilibiliDynamicDetailResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BilibiliDynamicDetailResult _$BilibiliDynamicDetailResultFromJson(
        Map<String, dynamic> json) =>
    BilibiliDynamicDetailResult()
      ..code = (json['code'] as num).toInt()
      ..message = json['message'] as String
      ..ttl = (json['ttl'] as num).toInt()
      ..data = BilibiliDynamicDetailData.fromJson(
          json['data'] as Map<String, dynamic>);

Map<String, dynamic> _$BilibiliDynamicDetailResultToJson(
        BilibiliDynamicDetailResult instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'ttl': instance.ttl,
      'data': instance.data,
    };

BilibiliDynamicDetailData _$BilibiliDynamicDetailDataFromJson(
        Map<String, dynamic> json) =>
    BilibiliDynamicDetailData()
      ..item = BilibiliDynamicDetailItemData.fromJson(
          json['item'] as Map<String, dynamic>);

Map<String, dynamic> _$BilibiliDynamicDetailDataToJson(
        BilibiliDynamicDetailData instance) =>
    <String, dynamic>{
      'item': instance.item,
    };

BilibiliDynamicDetailItemData _$BilibiliDynamicDetailItemDataFromJson(
        Map<String, dynamic> json) =>
    BilibiliDynamicDetailItemData()
      ..basic = BilibiliDynamicDetailItemBasic.fromJson(
          json['basic'] as Map<String, dynamic>)
      ..id_str = json['id_str'] as String
      ..module = BilibiliDynamicDetailItemModule.fromJson(
          json['module'] as Map<String, dynamic>)
      ..type = json['type'] as String
      ..visible = json['visible'] as bool;

Map<String, dynamic> _$BilibiliDynamicDetailItemDataToJson(
        BilibiliDynamicDetailItemData instance) =>
    <String, dynamic>{
      'basic': instance.basic,
      'id_str': instance.id_str,
      'module': instance.module,
      'type': instance.type,
      'visible': instance.visible,
    };

BilibiliDynamicDetailItemBasic _$BilibiliDynamicDetailItemBasicFromJson(
        Map<String, dynamic> json) =>
    BilibiliDynamicDetailItemBasic()
      ..comment_id_str = json['comment_id_str'] as String
      ..comment_type = (json['comment_type'] as num).toInt()
      ..rid_str = json['rid_str'] as String
      ..like_icon = BilibiliDynamicDetailItemBasicLike.fromJson(
          json['like_icon'] as Map<String, dynamic>);

Map<String, dynamic> _$BilibiliDynamicDetailItemBasicToJson(
        BilibiliDynamicDetailItemBasic instance) =>
    <String, dynamic>{
      'comment_id_str': instance.comment_id_str,
      'comment_type': instance.comment_type,
      'rid_str': instance.rid_str,
      'like_icon': instance.like_icon,
    };

BilibiliDynamicDetailItemBasicLike _$BilibiliDynamicDetailItemBasicLikeFromJson(
        Map<String, dynamic> json) =>
    BilibiliDynamicDetailItemBasicLike()
      ..action_url = json['action_url'] as String
      ..end_url = json['end_url'] as String
      ..id = (json['id'] as num).toInt()
      ..start_url = json['start_url'] as String;

Map<String, dynamic> _$BilibiliDynamicDetailItemBasicLikeToJson(
        BilibiliDynamicDetailItemBasicLike instance) =>
    <String, dynamic>{
      'action_url': instance.action_url,
      'end_url': instance.end_url,
      'id': instance.id,
      'start_url': instance.start_url,
    };

BilibiliDynamicDetailItemModule _$BilibiliDynamicDetailItemModuleFromJson(
        Map<String, dynamic> json) =>
    BilibiliDynamicDetailItemModule()
      ..author = BilibiliDynamicDetailItemModuleAuthor.fromJson(
          json['author'] as Map<String, dynamic>);

Map<String, dynamic> _$BilibiliDynamicDetailItemModuleToJson(
        BilibiliDynamicDetailItemModule instance) =>
    <String, dynamic>{
      'author': instance.author,
    };

BilibiliDynamicDetailItemModuleAuthor
    _$BilibiliDynamicDetailItemModuleAuthorFromJson(
            Map<String, dynamic> json) =>
        BilibiliDynamicDetailItemModuleAuthor()
          ..face = json['face'] as String
          ..face_nft = json['face_nft'] as String
          ..following = json['following'] as bool?
          ..jump_url = json['jump_url'] as String
          ..label = json['label'] as String
          ..num = (json['num'] as num).toInt()
          ..name = json['name'] as String
          ..official_verify =
              BilibiliDynamicDetailItemModuleAuthorOfficialVerify.fromJson(
                  json['official_verify'] as Map<String, dynamic>)
          ..pendant = BilibiliDynamicDetailItemModuleAuthorPendant.fromJson(
              json['pendant'] as Map<String, dynamic>)
          ..pub_action = json['pub_action'] as String
          ..pub_location_text = json['pub_location_text'] as String?
          ..pub_time = json['pub_time'] as String
          ..pub_ts = (json['pub_ts'] as num).toInt()
          ..type = json['type'] as String
          ..vip = BilibiliDynamicDetailItemModuleAuthorVip.fromJson(
              json['vip'] as Map<String, dynamic>)
          ..gender = (json['gender'] as num).toInt();

Map<String, dynamic> _$BilibiliDynamicDetailItemModuleAuthorToJson(
        BilibiliDynamicDetailItemModuleAuthor instance) =>
    <String, dynamic>{
      'face': instance.face,
      'face_nft': instance.face_nft,
      'following': instance.following,
      'jump_url': instance.jump_url,
      'label': instance.label,
      'num': instance.num,
      'name': instance.name,
      'official_verify': instance.official_verify,
      'pendant': instance.pendant,
      'pub_action': instance.pub_action,
      'pub_location_text': instance.pub_location_text,
      'pub_time': instance.pub_time,
      'pub_ts': instance.pub_ts,
      'type': instance.type,
      'vip': instance.vip,
      'gender': instance.gender,
    };

BilibiliDynamicDetailItemModuleAuthorOfficialVerify
    _$BilibiliDynamicDetailItemModuleAuthorOfficialVerifyFromJson(
            Map<String, dynamic> json) =>
        BilibiliDynamicDetailItemModuleAuthorOfficialVerify()
          ..desc = json['desc'] as String
          ..type = (json['type'] as num).toInt();

Map<String, dynamic>
    _$BilibiliDynamicDetailItemModuleAuthorOfficialVerifyToJson(
            BilibiliDynamicDetailItemModuleAuthorOfficialVerify instance) =>
        <String, dynamic>{
          'desc': instance.desc,
          'type': instance.type,
        };

BilibiliDynamicDetailItemModuleAuthorPendant
    _$BilibiliDynamicDetailItemModuleAuthorPendantFromJson(
            Map<String, dynamic> json) =>
        BilibiliDynamicDetailItemModuleAuthorPendant()
          ..expire = (json['expire'] as num).toInt()
          ..image = json['image'] as String
          ..image_enhance = json['image_enhance'] as String
          ..image_enhance_frame = json['image_enhance_frame'] as String
          ..name = json['name'] as String
          ..pid = (json['pid'] as num).toInt()
          ..n_pid = (json['n_pid'] as num).toInt();

Map<String, dynamic> _$BilibiliDynamicDetailItemModuleAuthorPendantToJson(
        BilibiliDynamicDetailItemModuleAuthorPendant instance) =>
    <String, dynamic>{
      'expire': instance.expire,
      'image': instance.image,
      'image_enhance': instance.image_enhance,
      'image_enhance_frame': instance.image_enhance_frame,
      'name': instance.name,
      'pid': instance.pid,
      'n_pid': instance.n_pid,
    };

BilibiliDynamicDetailItemModuleAuthorVip
    _$BilibiliDynamicDetailItemModuleAuthorVipFromJson(
            Map<String, dynamic> json) =>
        BilibiliDynamicDetailItemModuleAuthorVip()
          ..avatar_subscript = (json['avatar_subscript'] as num).toInt()
          ..avatar_subscript_url = json['avatar_subscript_url'] as String
          ..due_date = (json['due_date'] as num).toInt()
          ..nickname_color = json['nickname_color'] as String
          ..status = (json['status'] as num).toInt()
          ..theme_type = (json['theme_type'] as num).toInt()
          ..type = (json['type'] as num).toInt()
          ..label = BilibiliDynamicDetailItemModuleAuthorVipLabel.fromJson(
              json['label'] as Map<String, dynamic>);

Map<String, dynamic> _$BilibiliDynamicDetailItemModuleAuthorVipToJson(
        BilibiliDynamicDetailItemModuleAuthorVip instance) =>
    <String, dynamic>{
      'avatar_subscript': instance.avatar_subscript,
      'avatar_subscript_url': instance.avatar_subscript_url,
      'due_date': instance.due_date,
      'nickname_color': instance.nickname_color,
      'status': instance.status,
      'theme_type': instance.theme_type,
      'type': instance.type,
      'label': instance.label,
    };

BilibiliDynamicDetailItemModuleAuthorVipLabel
    _$BilibiliDynamicDetailItemModuleAuthorVipLabelFromJson(
            Map<String, dynamic> json) =>
        BilibiliDynamicDetailItemModuleAuthorVipLabel()
          ..bg_color = json['bg_color'] as String
          ..bg_style = (json['bg_style'] as num).toInt()
          ..border_color = json['border_color'] as String?
          ..img_label_uri_hans = json['img_label_uri_hans'] as String
          ..img_label_uri_hant = json['img_label_uri_hant'] as String
          ..img_label_uri_hans_static =
              json['img_label_uri_hans_static'] as String
          ..img_label_uri_hant_static =
              json['img_label_uri_hant_static'] as String
          ..label_theme = json['label_theme'] as String
          ..path = json['path'] as String?
          ..text = json['text'] as String
          ..text_color = (json['text_color'] as num).toInt()
          ..use_img_label = json['use_img_label'] as bool;

Map<String, dynamic> _$BilibiliDynamicDetailItemModuleAuthorVipLabelToJson(
        BilibiliDynamicDetailItemModuleAuthorVipLabel instance) =>
    <String, dynamic>{
      'bg_color': instance.bg_color,
      'bg_style': instance.bg_style,
      'border_color': instance.border_color,
      'img_label_uri_hans': instance.img_label_uri_hans,
      'img_label_uri_hant': instance.img_label_uri_hant,
      'img_label_uri_hans_static': instance.img_label_uri_hans_static,
      'img_label_uri_hant_static': instance.img_label_uri_hant_static,
      'label_theme': instance.label_theme,
      'path': instance.path,
      'text': instance.text,
      'text_color': instance.text_color,
      'use_img_label': instance.use_img_label,
    };

BilibiliDynamicDetailItemModuleAuthorDecorate
    _$BilibiliDynamicDetailItemModuleAuthorDecorateFromJson(
            Map<String, dynamic> json) =>
        BilibiliDynamicDetailItemModuleAuthorDecorate()
          ..card_url = json['card_url'] as String
          ..id = (json['id'] as num).toInt()
          ..jump_url = json['jump_url'] as String
          ..name = json['name'] as String
          ..type = (json['type'] as num).toInt()
          ..fan = BilibiliDynamicDetailItemModuleAuthorDecorateFan.fromJson(
              json['fan'] as Map<String, dynamic>);

Map<String, dynamic> _$BilibiliDynamicDetailItemModuleAuthorDecorateToJson(
        BilibiliDynamicDetailItemModuleAuthorDecorate instance) =>
    <String, dynamic>{
      'card_url': instance.card_url,
      'id': instance.id,
      'jump_url': instance.jump_url,
      'name': instance.name,
      'type': instance.type,
      'fan': instance.fan,
    };

BilibiliDynamicDetailItemModuleAuthorDecorateFan
    _$BilibiliDynamicDetailItemModuleAuthorDecorateFanFromJson(
            Map<String, dynamic> json) =>
        BilibiliDynamicDetailItemModuleAuthorDecorateFan()
          ..color = json['color'] as String
          ..is_fan = json['is_fan'] as bool
          ..num_str = json['num_str'] as String
          ..number = (json['number'] as num).toInt();

Map<String, dynamic> _$BilibiliDynamicDetailItemModuleAuthorDecorateFanToJson(
        BilibiliDynamicDetailItemModuleAuthorDecorateFan instance) =>
    <String, dynamic>{
      'color': instance.color,
      'is_fan': instance.is_fan,
      'num_str': instance.num_str,
      'number': instance.number,
    };
