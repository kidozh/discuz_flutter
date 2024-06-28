// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ThreadSlideShowResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThreadSlideShowResult _$ThreadSlideShowResultFromJson(
        Map<String, dynamic> json) =>
    ThreadSlideShowResult()
      ..result = json['result'] as String
      ..slideshow_list = (json['channel_list'] as List<dynamic>)
          .map((e) => SlideShow.fromJson(e as Map<String, dynamic>))
          .toList()
      ..reason = json['reason'] as String;

Map<String, dynamic> _$ThreadSlideShowResultToJson(
        ThreadSlideShowResult instance) =>
    <String, dynamic>{
      'result': instance.result,
      'channel_list': instance.slideshow_list,
      'reason': instance.reason,
    };

SlideShow _$SlideShowFromJson(Map<String, dynamic> json) => SlideShow()
  ..id = json['_id'] as String
  ..image_src = json['image_src'] as String
  ..title = json['title'] as String
  ..forum = json['forum'] as String
  ..category = json['category'] as String
  ..author = json['author'] as String
  ..tid = (json['tid'] as num).toInt()
  ..identification = json['identification'] as String
  ..discuz_site_host = json['discuz_site_host'] as String
  ..date = json['date'] as String;

Map<String, dynamic> _$SlideShowToJson(SlideShow instance) => <String, dynamic>{
      '_id': instance.id,
      'image_src': instance.image_src,
      'title': instance.title,
      'forum': instance.forum,
      'category': instance.category,
      'author': instance.author,
      'tid': instance.tid,
      'identification': instance.identification,
      'discuz_site_host': instance.discuz_site_host,
      'date': instance.date,
    };
