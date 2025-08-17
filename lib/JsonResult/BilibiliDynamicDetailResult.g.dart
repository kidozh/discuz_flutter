// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'BilibiliDynamicDetailResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BilibiliDynamicDetailResult _$BilibiliDynamicDetailResultFromJson(
        Map<String, dynamic> json) =>
    BilibiliDynamicDetailResult(
      code: (json['code'] as num?)?.toInt() ?? 0,
      message: json['message'] as String? ?? '',
      ttl: (json['ttl'] as num?)?.toInt() ?? 0,
      data: json['data'] == null
          ? null
          : BiliData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BilibiliDynamicDetailResultToJson(
        BilibiliDynamicDetailResult instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'ttl': instance.ttl,
      'data': instance.data.toJson(),
    };

BiliData _$BiliDataFromJson(Map<String, dynamic> json) => BiliData(
      item: json['item'] == null
          ? null
          : BiliItem.fromJson(json['item'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BiliDataToJson(BiliData instance) => <String, dynamic>{
      'item': instance.item.toJson(),
    };

BiliItem _$BiliItemFromJson(Map<String, dynamic> json) => BiliItem(
      idStr: json['id_str'] as String? ?? '',
      modules: json['modules'] == null
          ? null
          : Modules.fromJson(json['modules'] as Map<String, dynamic>),
      type: json['type'] as String? ?? '',
      visible: json['visible'] as bool? ?? false,
    );

Map<String, dynamic> _$BiliItemToJson(BiliItem instance) => <String, dynamic>{
      'id_str': instance.idStr,
      'modules': instance.modules.toJson(),
      'type': instance.type,
      'visible': instance.visible,
    };

Modules _$ModulesFromJson(Map<String, dynamic> json) => Modules(
      moduleAuthor: json['module_author'] == null
          ? null
          : ModuleAuthor.fromJson(
              json['module_author'] as Map<String, dynamic>),
      moduleDynamic: json['module_dynamic'] == null
          ? null
          : ModuleDynamic.fromJson(
              json['module_dynamic'] as Map<String, dynamic>),
      moduleStat: json['module_stat'] == null
          ? null
          : ModuleStat.fromJson(json['module_stat'] as Map<String, dynamic>),
      moduleMore: json['module_more'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ModulesToJson(Modules instance) => <String, dynamic>{
      'module_author': instance.moduleAuthor.toJson(),
      'module_dynamic': instance.moduleDynamic.toJson(),
      'module_stat': instance.moduleStat.toJson(),
      'module_more': instance.moduleMore,
    };

ModuleAuthor _$ModuleAuthorFromJson(Map<String, dynamic> json) => ModuleAuthor(
      name: json['name'] as String? ?? '',
      mid: (json['mid'] as num?)?.toInt() ?? 0,
      face: json['face'] as String? ?? '',
      jumpUrl: json['jump_url'] as String? ?? '',
      pubTime: json['pub_time'] as String? ?? '',
      pubTs: (json['pub_ts'] as num?)?.toInt() ?? 0,
      vip: json['vip'] == null
          ? null
          : VipInfo.fromJson(json['vip'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ModuleAuthorToJson(ModuleAuthor instance) =>
    <String, dynamic>{
      'name': instance.name,
      'mid': instance.mid,
      'face': instance.face,
      'jump_url': instance.jumpUrl,
      'pub_time': instance.pubTime,
      'pub_ts': instance.pubTs,
      'vip': instance.vip,
    };

VipInfo _$VipInfoFromJson(Map<String, dynamic> json) => VipInfo(
      status: (json['status'] as num?)?.toInt() ?? 0,
      type: (json['type'] as num?)?.toInt() ?? 0,
      themeType: (json['theme_type'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$VipInfoToJson(VipInfo instance) => <String, dynamic>{
      'status': instance.status,
      'type': instance.type,
      'theme_type': instance.themeType,
    };

ModuleDynamic _$ModuleDynamicFromJson(Map<String, dynamic> json) =>
    ModuleDynamic(
      desc: json['desc'] == null
          ? null
          : ModuleDesc.fromJson(json['desc'] as Map<String, dynamic>),
      major: json['major'] == null
          ? null
          : Major.fromJson(json['major'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ModuleDynamicToJson(ModuleDynamic instance) =>
    <String, dynamic>{
      'desc': instance.desc.toJson(),
      'major': instance.major.toJson(),
    };

ModuleDesc _$ModuleDescFromJson(Map<String, dynamic> json) => ModuleDesc(
      text: json['text'] as String? ?? '',
      richTextNodes: (json['rich_text_nodes'] as List<dynamic>?)
          ?.map((e) => RichTextNode.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ModuleDescToJson(ModuleDesc instance) =>
    <String, dynamic>{
      'text': instance.text,
      'rich_text_nodes': instance.richTextNodes.map((e) => e.toJson()).toList(),
    };

RichTextNode _$RichTextNodeFromJson(Map<String, dynamic> json) => RichTextNode(
      type: json['type'] as String? ?? '',
      text: json['text'] as String? ?? '',
      origText: json['orig_text'] as String? ?? '',
    );

Map<String, dynamic> _$RichTextNodeToJson(RichTextNode instance) =>
    <String, dynamic>{
      'type': instance.type,
      'text': instance.text,
      'orig_text': instance.origText,
    };

Major _$MajorFromJson(Map<String, dynamic> json) => Major(
      type: json['type'] as String? ?? '',
      draw: json['draw'] == null
          ? null
          : Draw.fromJson(json['draw'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MajorToJson(Major instance) => <String, dynamic>{
      'type': instance.type,
      'draw': instance.draw.toJson(),
    };

Draw _$DrawFromJson(Map<String, dynamic> json) => Draw(
      id: (json['id'] as num?)?.toInt() ?? 0,
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => DrawItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DrawToJson(Draw instance) => <String, dynamic>{
      'id': instance.id,
      'items': instance.items.map((e) => e.toJson()).toList(),
    };

DrawItem _$DrawItemFromJson(Map<String, dynamic> json) => DrawItem(
      src: json['src'] as String? ?? '',
      width: (json['width'] as num?)?.toInt() ?? 0,
      height: (json['height'] as num?)?.toInt() ?? 0,
      size: (json['size'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$DrawItemToJson(DrawItem instance) => <String, dynamic>{
      'src': instance.src,
      'width': instance.width,
      'height': instance.height,
      'size': instance.size,
    };

ModuleStat _$ModuleStatFromJson(Map<String, dynamic> json) => ModuleStat(
      like: json['like'] == null
          ? null
          : StatField.fromJson(json['like'] as Map<String, dynamic>),
      forward: json['forward'] == null
          ? null
          : StatField.fromJson(json['forward'] as Map<String, dynamic>),
      comment: json['comment'] == null
          ? null
          : StatField.fromJson(json['comment'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ModuleStatToJson(ModuleStat instance) =>
    <String, dynamic>{
      'like': instance.like.toJson(),
      'forward': instance.forward.toJson(),
      'comment': instance.comment.toJson(),
    };

StatField _$StatFieldFromJson(Map<String, dynamic> json) => StatField(
      count: (json['count'] as num?)?.toInt() ?? 0,
      forbidden: json['forbidden'] as bool? ?? false,
      status: json['status'] as bool? ?? false,
    );

Map<String, dynamic> _$StatFieldToJson(StatField instance) => <String, dynamic>{
      'count': instance.count,
      'forbidden': instance.forbidden,
      'status': instance.status,
    };
