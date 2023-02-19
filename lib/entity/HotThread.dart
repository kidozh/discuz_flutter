import 'package:discuz_flutter/converter/SecondToDateTimeConverter.dart';
import 'package:discuz_flutter/converter/StringToBoolConverter.dart';
import 'package:discuz_flutter/converter/StringToIntConverter.dart';
import 'package:discuz_flutter/entity/ForumThread.dart';
import 'package:json_annotation/json_annotation.dart';

part 'HotThread.g.dart';

@JsonSerializable(disallowUnrecognizedKeys: false)
class HotThread{
  @StringToIntConverter()
  int tid = 0, fid = 0, posttableid = 0, typeid = 0, sortid = 0, price = 0;

  @JsonKey(name: "readperm")
  @StringToIntConverter()
  int readPerm = 0;
  String author = "";

  @JsonKey(name: "authorid")
  @StringToIntConverter()
  int authorId = 0;

  String subject = "", dateline = "";
  @JsonKey(name: "lastpost")
  String lastPostTime = "";

  @JsonKey(name: "lastposter")
  String lastPoster = "";

  String views = "";
  @StringToIntConverter()
  @JsonKey(defaultValue: 0)
  int replies = 0;
  @JsonKey(name: "displayorder")
  @StringToIntConverter()
  int displayOrder = 0;
  String highlight = "";
  @StringToBoolConverter()
  bool digest = false;
  @JsonKey(name: "typehtml",defaultValue: "")
  String typeHtml = "";
  @JsonKey(name: "typename",defaultValue: "")
  String typeName = "";
  @JsonKey(name: "dbdateline")
  @SecondToDateTimeConverter()
  DateTime publishAt = DateTime.now();
  @JsonKey(name: "dblastpost")
  @SecondToDateTimeConverter()
  DateTime lastPostAt = DateTime.now();

  @JsonKey(defaultValue: "")
  String message = "";

  @JsonKey(name: "attachmentImageNumber", defaultValue: 0)
  @StringToIntConverter()
  int attachmentImageNumber = 0;

  @JsonKey(defaultValue: [])

  List<AttachmentPreview> attachmentImagePreviewList = [];

  HotThread();

  factory HotThread.fromJson(Map<String, dynamic> json) => _$HotThreadFromJson(json);
  Map<String, dynamic> toJson() => _$HotThreadToJson(this);

  ForumThread toForumThread(){
    print(toJson());
    return ForumThread.fromJson(toJson());
  }

}