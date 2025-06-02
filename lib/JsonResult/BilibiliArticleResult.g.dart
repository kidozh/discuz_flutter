// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'BilibiliArticleResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BilibiliArticleResult _$BilibiliArticleResultFromJson(
        Map<String, dynamic> json) =>
    BilibiliArticleResult()
      ..code = (json['code'] as num).toInt()
      ..message = json['message'] as String
      ..ttl = (json['ttl'] as num).toInt()
      ..data =
          BilibiliArticleData.fromJson(json['data'] as Map<String, dynamic>);

Map<String, dynamic> _$BilibiliArticleResultToJson(
        BilibiliArticleResult instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'ttl': instance.ttl,
      'data': instance.data,
    };

BilibiliArticleData _$BilibiliArticleDataFromJson(Map<String, dynamic> json) =>
    BilibiliArticleData()
      ..like = (json['like'] as num).toInt()
      ..attention = json['attention'] as bool
      ..favorite = json['favorite'] as bool
      ..coin = (json['coin'] as num).toInt()
      ..banner_url = json['banner_url'] as String
      ..mid = (json['mid'] as num).toInt()
      ..author_name = json['author_name'] as String
      ..image_urls =
          (json['image_urls'] as List<dynamic>).map((e) => e as String).toList()
      ..origin_image_urls = (json['origin_image_urls'] as List<dynamic>)
          .map((e) => e as String)
          .toList()
      ..sharable = json['sharable'] as bool
      ..show_later_watch = json['show_later_watch'] as bool
      ..show_small_window = json['show_small_window'] as bool
      ..in_list = json['in_list'] as bool
      ..pre = (json['pre'] as num).toInt()
      ..next = (json['next'] as num).toInt()
      ..type = (json['type'] as num).toInt()
      ..share_channels = (json['share_channels'] as List<dynamic>)
          .map((e) =>
              BilibiliArticleShareChannel.fromJson(e as Map<String, dynamic>))
          .toList()
      ..viewData = BilibiliArticleStatsData.fromJson(
          json['View'] as Map<String, dynamic>);

Map<String, dynamic> _$BilibiliArticleDataToJson(
        BilibiliArticleData instance) =>
    <String, dynamic>{
      'like': instance.like,
      'attention': instance.attention,
      'favorite': instance.favorite,
      'coin': instance.coin,
      'banner_url': instance.banner_url,
      'mid': instance.mid,
      'author_name': instance.author_name,
      'image_urls': instance.image_urls,
      'origin_image_urls': instance.origin_image_urls,
      'sharable': instance.sharable,
      'show_later_watch': instance.show_later_watch,
      'show_small_window': instance.show_small_window,
      'in_list': instance.in_list,
      'pre': instance.pre,
      'next': instance.next,
      'type': instance.type,
      'share_channels': instance.share_channels,
      'View': instance.viewData,
    };

BilibiliArticleStatsData _$BilibiliArticleStatsDataFromJson(
        Map<String, dynamic> json) =>
    BilibiliArticleStatsData()
      ..view = (json['view'] as num).toInt()
      ..favorite = (json['favorite'] as num).toInt()
      ..like = (json['like'] as num).toInt()
      ..dislike = (json['dislike'] as num).toInt()
      ..reply = (json['reply'] as num).toInt()
      ..share = (json['share'] as num).toInt()
      ..coin = (json['coin'] as num).toInt()
      ..dynamic_num = (json['dynamic'] as num).toInt();

Map<String, dynamic> _$BilibiliArticleStatsDataToJson(
        BilibiliArticleStatsData instance) =>
    <String, dynamic>{
      'view': instance.view,
      'favorite': instance.favorite,
      'like': instance.like,
      'dislike': instance.dislike,
      'reply': instance.reply,
      'share': instance.share,
      'coin': instance.coin,
      'dynamic': instance.dynamic_num,
    };

BilibiliArticleShareChannel _$BilibiliArticleShareChannelFromJson(
        Map<String, dynamic> json) =>
    BilibiliArticleShareChannel()
      ..name = json['name'] as String
      ..picture = json['picture'] as String
      ..share_channel = json['share_channel'] as String;

Map<String, dynamic> _$BilibiliArticleShareChannelToJson(
        BilibiliArticleShareChannel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'picture': instance.picture,
      'share_channel': instance.share_channel,
    };
