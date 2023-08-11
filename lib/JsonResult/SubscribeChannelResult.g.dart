// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'SubscribeChannelResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscribeChannelResult _$SubscribeChannelResultFromJson(
        Map<String, dynamic> json) =>
    SubscribeChannelResult()
      ..result = json['result'] as String
      ..channelList = (json['channel_list'] as List<dynamic>)
          .map((e) => SubscribeChannel.fromJson(e as Map<String, dynamic>))
          .toList()
      ..reason = json['reason'] as String;

Map<String, dynamic> _$SubscribeChannelResultToJson(
        SubscribeChannelResult instance) =>
    <String, dynamic>{
      'result': instance.result,
      'channel_list': instance.channelList,
      'reason': instance.reason,
    };

SubscribeChannel _$SubscribeChannelFromJson(Map<String, dynamic> json) =>
    SubscribeChannel()
      ..id = json['_id'] as String
      ..host = json['host'] as String
      ..description = json['description'] as String
      ..source = json['source'] as String
      ..link = json['link'] as String
      ..type = json['type'] as String
      ..identification = json['identification'] as String
      ..date = json['date'] as String
      ..note = json['note'] as String
      ..subscribe = json['subscribe'] as bool;

Map<String, dynamic> _$SubscribeChannelToJson(SubscribeChannel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'host': instance.host,
      'description': instance.description,
      'source': instance.source,
      'link': instance.link,
      'type': instance.type,
      'identification': instance.identification,
      'date': instance.date,
      'note': instance.note,
      'subscribe': instance.subscribe,
    };
