

import 'package:json_annotation/json_annotation.dart';

part 'SubscribeChannelResult.g.dart';

@JsonSerializable()
class SubscribeChannelResult{
    String result = "";
    @JsonKey(name: "channel_list")
    List<SubscribeChannel> channelList = [];
    String reason = "";

    SubscribeChannelResult();

    factory SubscribeChannelResult.fromJson(Map<String, dynamic> json) => _$SubscribeChannelResultFromJson(json);
}

@JsonSerializable()
class SubscribeChannel{
  @JsonKey(name: "_id")
  String id = "";
  String host = "";
  String description = "";
  String source = "";
  String link = "";
  String type = "";
  String identification = "";
  String date = "";
  bool subscribe = false;

  SubscribeChannel();

  factory SubscribeChannel.fromJson(Map<String, dynamic> json) => _$SubscribeChannelFromJson(json);
}