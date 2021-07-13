// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'FavoriteThreadResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FavoriteThreadResult _$FavoriteThreadResultFromJson(Map<String, dynamic> json) {
  return FavoriteThreadResult()
    ..version = json['Version'] as String
    ..charset = json['Charset'] as String
    ..errorResult = json['Message'] == null
        ? null
        : ErrorResult.fromJson(json['Message'] as Map<String, dynamic>)
    ..error = json['error'] as String?
    ..variables = FavoriteThreadVariables.fromJson(
        json['Variables'] as Map<String, dynamic>);
}

Map<String, dynamic> _$FavoriteThreadResultToJson(
        FavoriteThreadResult instance) =>
    <String, dynamic>{
      'Version': instance.version,
      'Charset': instance.charset,
      'Message': instance.errorResult,
      'error': instance.error,
      'Variables': instance.variables,
    };

FavoriteThreadVariables _$FavoriteThreadVariablesFromJson(
    Map<String, dynamic> json) {
  return FavoriteThreadVariables()
    ..cookiepre = json['cookiepre'] as String
    ..auth = json['auth'] as String?
    ..saltkey = json['saltkey'] as String
    ..member_username = json['member_username'] as String
    ..member_avatar = json['member_avatar'] as String
    ..member_uid =
        const StringToIntConverter().fromJson(json['member_uid'] as String?)
    ..groupId =
        const StringToIntConverter().fromJson(json['groupid'] as String?)
    ..readAccess =
        const StringToIntConverter().fromJson(json['readaccess'] as String?)
    ..formHash = json['formhash'] as String
    ..ismoderator = json['ismoderator'] as String?
    ..noticeCount = NoticeCount.fromJson(json['notice'] as Map<String, dynamic>)
    ..pmList = (json['list'] as List<dynamic>)
        .map((e) => FavoriteThread.fromJson(e as Map<String, dynamic>))
        .toList()
    ..count = const StringToIntConverter().fromJson(json['count'] as String?)
    ..perPage =
        const StringToIntConverter().fromJson(json['perpage'] as String?);
}

Map<String, dynamic> _$FavoriteThreadVariablesToJson(
        FavoriteThreadVariables instance) =>
    <String, dynamic>{
      'cookiepre': instance.cookiepre,
      'auth': instance.auth,
      'saltkey': instance.saltkey,
      'member_username': instance.member_username,
      'member_avatar': instance.member_avatar,
      'member_uid': const StringToIntConverter().toJson(instance.member_uid),
      'groupid': const StringToIntConverter().toJson(instance.groupId),
      'readaccess': const StringToIntConverter().toJson(instance.readAccess),
      'formhash': instance.formHash,
      'ismoderator': instance.ismoderator,
      'notice': instance.noticeCount,
      'list': instance.pmList,
      'count': const StringToIntConverter().toJson(instance.count),
      'perpage': const StringToIntConverter().toJson(instance.perPage),
    };

FavoriteThread _$FavoriteThreadFromJson(Map<String, dynamic> json) {
  return FavoriteThread()
    ..favId = const StringToIntConverter().fromJson(json['favid'] as String?)
    ..uid = const StringToIntConverter().fromJson(json['uid'] as String?)
    ..id = const StringToIntConverter().fromJson(json['id'] as String?)
    ..idType = json['idtype'] as String
    ..title = json['title'] as String
    ..description = json['description'] as String
    ..replies =
        const StringToIntConverter().fromJson(json['replies'] as String?)
    ..author = json['author'] as String
    ..publishAt =
        const SecondToDateTimeConverter().fromJson(json['dateline'] as String?);
}

Map<String, dynamic> _$FavoriteThreadToJson(FavoriteThread instance) =>
    <String, dynamic>{
      'favid': const StringToIntConverter().toJson(instance.favId),
      'uid': const StringToIntConverter().toJson(instance.uid),
      'id': const StringToIntConverter().toJson(instance.id),
      'idtype': instance.idType,
      'title': instance.title,
      'description': instance.description,
      'replies': const StringToIntConverter().toJson(instance.replies),
      'author': instance.author,
      'dateline': const SecondToDateTimeConverter().toJson(instance.publishAt),
    };
