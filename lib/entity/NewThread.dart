import 'package:discuz_flutter/converter/SecondToDateTimeConverter.dart';
import 'package:discuz_flutter/converter/StringToBoolConverter.dart';
import 'package:discuz_flutter/converter/StringToIntConverter.dart';
import 'package:json_annotation/json_annotation.dart';

import 'ForumThread.dart';

part 'NewThread.g.dart';

@JsonSerializable()
class NewThread{
  @StringToIntConverter()
  int tid = 0;

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

  @StringToBoolConverter()
  bool digest = false;
  @StringToIntConverter()
  int attachment = 0;

  @JsonKey(name: "dbdateline")
  @SecondToDateTimeConverter()
  DateTime publishAt = DateTime.now();
  @JsonKey(name: "dblastpost")
  @SecondToDateTimeConverter()
  DateTime lastPostAt = DateTime.now();

  @JsonKey(name: "attachmentImageNumber", defaultValue: 0)
  @StringToIntConverter()
  int attachmentImageNumber = 0;

  @JsonKey(defaultValue: [])
  List<AttachmentPreview> attachmentImagePreviewList = [];

  NewThread();



  factory NewThread.fromJson(Map<String, dynamic> json) => _$NewThreadFromJson(json);
  Map<String, dynamic> toJson() => _$NewThreadToJson(this);

  ForumThread toForumThread(){

    return ForumThread.fromJson(toJson());
  }

}