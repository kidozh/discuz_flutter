// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PushTokenListResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushTokenListResult _$PushTokenListResultFromJson(Map<String, dynamic> json) =>
    PushTokenListResult()
      ..result = json['result'] as String
      ..maxToken = (json['maxToken'] as num).toInt()
      ..formhash = json['formhash'] as String
      ..list = (json['list'] as List<dynamic>)
          .map((e) => PushToken.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$PushTokenListResultToJson(
        PushTokenListResult instance) =>
    <String, dynamic>{
      'result': instance.result,
      'maxToken': instance.maxToken,
      'formhash': instance.formhash,
      'list': instance.list,
    };

PushToken _$PushTokenFromJson(Map<String, dynamic> json) => PushToken()
  ..id = const StringToIntConverter().fromJson(json['id'] as String?)
  ..uid = const StringToIntConverter().fromJson(json['uid'] as String?)
  ..username = json['username'] as String
  ..token = json['token'] as String
  ..allowPush =
      const StringToBoolConverter().fromJson(json['allowPush'] as String?)
  ..deviceName = json['deviceName'] as String
  ..updateAt =
      const SecondToDateTimeConverter().fromJson(json['updateAt'] as String?)
  ..channel = json['channel'] as String;

Map<String, dynamic> _$PushTokenToJson(PushToken instance) => <String, dynamic>{
      'id': const StringToIntConverter().toJson(instance.id),
      'uid': const StringToIntConverter().toJson(instance.uid),
      'username': instance.username,
      'token': instance.token,
      'allowPush': const StringToBoolConverter().toJson(instance.allowPush),
      'deviceName': instance.deviceName,
      'updateAt': const SecondToDateTimeConverter().toJson(instance.updateAt),
      'channel': instance.channel,
    };

PostTokenResult _$PostTokenResultFromJson(Map<String, dynamic> json) =>
    PostTokenResult()
      ..result = json['result'] as String
      ..formhash = json['formhash'] as String;

Map<String, dynamic> _$PostTokenResultToJson(PostTokenResult instance) =>
    <String, dynamic>{
      'result': instance.result,
      'formhash': instance.formhash,
    };
