import 'package:json_annotation/json_annotation.dart';

part 'BilibiliDynamicDetailResult.g.dart';

@JsonSerializable(explicitToJson: true)
class BilibiliDynamicDetailResult {
  int code;
  String message;
  int ttl;
  BiliData data;

  BilibiliDynamicDetailResult({
    this.code = 0,
    this.message = '',
    this.ttl = 0,
    BiliData? data,
  }) : data = data ?? BiliData();

  factory BilibiliDynamicDetailResult.fromJson(Map<String, dynamic> json) =>
      _$BilibiliDynamicDetailResultFromJson(json);

  Map<String, dynamic> toJson() => _$BilibiliDynamicDetailResultToJson(this);
}

@JsonSerializable(explicitToJson: true)
class BiliData {
  BiliItem item;

  BiliData({BiliItem? item}) : item = item ?? BiliItem();

  factory BiliData.fromJson(Map<String, dynamic> json) =>
      _$BiliDataFromJson(json);

  Map<String, dynamic> toJson() => _$BiliDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class BiliItem {
  @JsonKey(name: 'id_str')
  String idStr;
  Modules modules;
  String type;
  bool visible;

  BiliItem({
    this.idStr = '',
    Modules? modules,
    this.type = '',
    this.visible = false,
  }) : modules = modules ?? Modules();

  factory BiliItem.fromJson(Map<String, dynamic> json) =>
      _$BiliItemFromJson(json);

  Map<String, dynamic> toJson() => _$BiliItemToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Modules {
  @JsonKey(name: 'module_author')
  ModuleAuthor moduleAuthor;
  @JsonKey(name: 'module_dynamic')
  ModuleDynamic moduleDynamic;
  @JsonKey(name: 'module_stat')
  ModuleStat moduleStat;
  @JsonKey(name: 'module_more')
  Map<String, dynamic> moduleMore;

  Modules({
    ModuleAuthor? moduleAuthor,
    ModuleDynamic? moduleDynamic,
    ModuleStat? moduleStat,
    Map<String, dynamic>? moduleMore,
  })  : moduleAuthor = moduleAuthor ?? ModuleAuthor(),
        moduleDynamic = moduleDynamic ?? ModuleDynamic(),
        moduleStat = moduleStat ?? ModuleStat(),
        moduleMore = moduleMore ?? {};

  factory Modules.fromJson(Map<String, dynamic> json) =>
      _$ModulesFromJson(json);

  Map<String, dynamic> toJson() => _$ModulesToJson(this);
}

@JsonSerializable()
class ModuleAuthor {
  String name;
  int mid;
  String face;
  @JsonKey(name: 'jump_url')
  String jumpUrl;
  @JsonKey(name: 'pub_time')
  String pubTime;
  @JsonKey(name: 'pub_ts')
  int pubTs;
  VipInfo vip;

  ModuleAuthor({
    this.name = '',
    this.mid = 0,
    this.face = '',
    this.jumpUrl = '',
    this.pubTime = '',
    this.pubTs = 0,
    VipInfo? vip,
  }) : vip = vip ?? VipInfo();

  factory ModuleAuthor.fromJson(Map<String, dynamic> json) =>
      _$ModuleAuthorFromJson(json);

  Map<String, dynamic> toJson() => _$ModuleAuthorToJson(this);
}

@JsonSerializable()
class VipInfo {
  int status;
  int type;
  @JsonKey(name: 'theme_type')
  int themeType;

  VipInfo({
    this.status = 0,
    this.type = 0,
    this.themeType = 0,
  });

  factory VipInfo.fromJson(Map<String, dynamic> json) =>
      _$VipInfoFromJson(json);

  Map<String, dynamic> toJson() => _$VipInfoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ModuleDynamic {
  ModuleDesc desc;
  Major major;

  ModuleDynamic({
    ModuleDesc? desc,
    Major? major,
  })  : desc = desc ?? ModuleDesc(),
        major = major ?? Major();

  factory ModuleDynamic.fromJson(Map<String, dynamic> json) =>
      _$ModuleDynamicFromJson(json);

  Map<String, dynamic> toJson() => _$ModuleDynamicToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ModuleDesc {
  String text;
  @JsonKey(name: 'rich_text_nodes')
  List<RichTextNode> richTextNodes;

  ModuleDesc({
    this.text = '',
    List<RichTextNode>? richTextNodes,
  }) : richTextNodes = richTextNodes ?? [];

  String get displayText =>
      text.isNotEmpty
          ? text
          : richTextNodes.map((e) => e.text.isNotEmpty ? e.text : e.origText).join();

  factory ModuleDesc.fromJson(Map<String, dynamic> json) =>
      _$ModuleDescFromJson(json);

  Map<String, dynamic> toJson() => _$ModuleDescToJson(this);
}

@JsonSerializable()
class RichTextNode {
  String type;
  String text;
  @JsonKey(name: 'orig_text')
  String origText;

  RichTextNode({
    this.type = '',
    this.text = '',
    this.origText = '',
  });

  factory RichTextNode.fromJson(Map<String, dynamic> json) =>
      _$RichTextNodeFromJson(json);

  Map<String, dynamic> toJson() => _$RichTextNodeToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Major {
  String type;
  Draw draw;

  Major({
    this.type = '',
    Draw? draw,
  }) : draw = draw ?? Draw();

  factory Major.fromJson(Map<String, dynamic> json) => _$MajorFromJson(json);

  Map<String, dynamic> toJson() => _$MajorToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Draw {
  int id;
  List<DrawItem> items;

  Draw({
    this.id = 0,
    List<DrawItem>? items,
  }) : items = items ?? [];

  factory Draw.fromJson(Map<String, dynamic> json) => _$DrawFromJson(json);

  Map<String, dynamic> toJson() => _$DrawToJson(this);
}

@JsonSerializable()
class DrawItem {
  String src;
  int width;
  int height;
  double size;

  DrawItem({
    this.src = '',
    this.width = 0,
    this.height = 0,
    this.size = 0.0,
  });

  factory DrawItem.fromJson(Map<String, dynamic> json) =>
      _$DrawItemFromJson(json);

  Map<String, dynamic> toJson() => _$DrawItemToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ModuleStat {
  StatField like;
  StatField forward;
  StatField comment;

  ModuleStat({
    StatField? like,
    StatField? forward,
    StatField? comment,
  })  : like = like ?? StatField(),
        forward = forward ?? StatField(),
        comment = comment ?? StatField();

  factory ModuleStat.fromJson(Map<String, dynamic> json) =>
      _$ModuleStatFromJson(json);

  Map<String, dynamic> toJson() => _$ModuleStatToJson(this);
}

@JsonSerializable()
class StatField {
  int count;
  bool forbidden;
  bool status;

  StatField({
    this.count = 0,
    this.forbidden = false,
    this.status = false,
  });

  factory StatField.fromJson(Map<String, dynamic> json) =>
      _$StatFieldFromJson(json);

  Map<String, dynamic> toJson() => _$StatFieldToJson(this);
}
