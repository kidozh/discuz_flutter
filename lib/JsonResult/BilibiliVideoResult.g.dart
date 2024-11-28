// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'BilibiliVideoResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BilibiliVideoResult _$BilibiliVideoResultFromJson(Map<String, dynamic> json) =>
    BilibiliVideoResult()
      ..code = (json['code'] as num).toInt()
      ..message = json['message'] as String
      ..ttl = (json['ttl'] as num).toInt()
      ..data = BilibiliVideoData.fromJson(json['data'] as Map<String, dynamic>);

Map<String, dynamic> _$BilibiliVideoResultToJson(
        BilibiliVideoResult instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'ttl': instance.ttl,
      'data': instance.data,
    };

BilibiliVideoData _$BilibiliVideoDataFromJson(Map<String, dynamic> json) =>
    BilibiliVideoData()
      ..viewData =
          BilibiliVideoViewData.fromJson(json['View'] as Map<String, dynamic>);

Map<String, dynamic> _$BilibiliVideoDataToJson(BilibiliVideoData instance) =>
    <String, dynamic>{
      'View': instance.viewData,
    };

BilibiliVideoViewData _$BilibiliVideoViewDataFromJson(
        Map<String, dynamic> json) =>
    BilibiliVideoViewData()
      ..bvid = json['bvid'] as String
      ..aid = (json['aid'] as num).toInt()
      ..videos = (json['videos'] as num).toInt()
      ..tid = (json['tid'] as num).toInt()
      ..tname = json['tname'] as String
      ..copyright = (json['copyright'] as num).toInt()
      ..pic = json['pic'] as String
      ..title = json['title'] as String
      ..pubdate = (json['pubdate'] as num).toInt()
      ..ctime = (json['ctime'] as num).toInt()
      ..desc = json['desc'] as String
      ..state = (json['state'] as num).toInt()
      ..duration = (json['duration'] as num).toInt()
      ..owner = BilibiliVideoViewDataOwner.fromJson(
          json['owner'] as Map<String, dynamic>);

Map<String, dynamic> _$BilibiliVideoViewDataToJson(
        BilibiliVideoViewData instance) =>
    <String, dynamic>{
      'bvid': instance.bvid,
      'aid': instance.aid,
      'videos': instance.videos,
      'tid': instance.tid,
      'tname': instance.tname,
      'copyright': instance.copyright,
      'pic': instance.pic,
      'title': instance.title,
      'pubdate': instance.pubdate,
      'ctime': instance.ctime,
      'desc': instance.desc,
      'state': instance.state,
      'duration': instance.duration,
      'owner': instance.owner,
    };

BilibiliVideoViewDataOwner _$BilibiliVideoViewDataOwnerFromJson(
        Map<String, dynamic> json) =>
    BilibiliVideoViewDataOwner()
      ..mid = (json['mid'] as num).toInt()
      ..name = json['name'] as String
      ..face = json['face'] as String;

Map<String, dynamic> _$BilibiliVideoViewDataOwnerToJson(
        BilibiliVideoViewDataOwner instance) =>
    <String, dynamic>{
      'mid': instance.mid,
      'name': instance.name,
      'face': instance.face,
    };
