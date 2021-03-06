import 'package:discuz_flutter/converter/SecondToDateTimeConverter.dart';
import 'package:discuz_flutter/converter/StringToBoolConverter.dart';
import 'package:discuz_flutter/converter/StringToIntConverter.dart';
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

  String views = "", replies = "";
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

  HotThread();



  factory HotThread.fromJson(Map<String, dynamic> json) => _$HotThreadFromJson(json);
  Map<String, dynamic> toJson() => _$HotThreadToJson(this);

}