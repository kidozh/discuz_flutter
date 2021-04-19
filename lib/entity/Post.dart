import 'package:discuz_flutter/converter/AttachmentConverter.dart';
import 'package:discuz_flutter/converter/SecondToDateTimeConverter.dart';
import 'package:discuz_flutter/converter/StringToBoolConverter.dart';
import 'package:discuz_flutter/converter/StringToIntConverter.dart';
import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

part 'Post.g.dart';

@JsonSerializable(disallowUnrecognizedKeys: false)
class Post{
  @StringToIntConverter()
  int pid = 0;
  @StringToIntConverter()
  int tid = 0;
  @StringToBoolConverter()
  bool first = false;
  @StringToBoolConverter()
  bool anonymous = false;


  String author = "";
  String dateline = "";
  String message = "";
  String username = "";
  @StringToIntConverter()
  @JsonKey(name:"authorid")
  int authorId = 0;
  @StringToIntConverter()
  int attachment = 0;
  @StringToIntConverter()
  int status = 0,replycredit = 0, number = 0, position = 0;
  @JsonKey(name:"adminid")
  @StringToIntConverter()
  int adminId = 0;
  @JsonKey(name:"groupid")
  @StringToIntConverter()
  int groupId = 0;
  @JsonKey(name:"memberstatus")
  @StringToIntConverter()
  int memberStatus = 0;
  @JsonKey(name: "dbdateline")
  @SecondToDateTimeConverter()
  DateTime publishAt = DateTime.now();

  @JsonKey(name: "attachlist",defaultValue: [])
  List<String> attachmentIdList = [];

  @JsonKey(name: "imagelist",defaultValue: [])
  List<String> imageIdList = [];

  @JsonKey(name:"groupiconid",defaultValue: "0")
  String groupIconId = "0";

  // @JsonKey(name:"attachments",defaultValue: {}, required: false)
  // @AttachmentConverter()
  // Map<String, Attachment> attachmentMapper  = {};


  Post();
  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
  Map<String, dynamic> toJson() => _$PostToJson(this);

  @override
  String toString() {
    // TODO: implement toString
    return "Pos";
  }
}

@JsonSerializable(ignoreUnannotated: true)
@StringToIntConverter()
class Attachment{
  @StringToIntConverter()
  int aid=0, tid=0, pid=0, uid=0;

  String? dateline = "", filename = "";
  @StringToIntConverter()
  @JsonKey(name:"filesize")
  int fileSize = 0;
  @StringToBoolConverter()
  bool remote = false, thumb = false, payed = false;
  @JsonKey(defaultValue: "")
  String description = "";
  @StringToIntConverter()
  @JsonKey(name:"readperm")
  int readPerm = 0;
  @StringToIntConverter()
  @JsonKey(name:"picid")
  int picId = 0;
  @JsonKey(name:"aidencode",defaultValue: "")
  String aidEncode = "";
  @StringToIntConverter()
  @JsonKey(name:"downloads")
  int downloads = 0;

  @JsonKey(name:"imgalt", defaultValue: "")
  String? imageAlt = "";

  Attachment();
  factory Attachment.fromJson(Map<String, dynamic> json) => _$AttachmentFromJson(json);
  Map<String, dynamic> toJson() => _$AttachmentToJson(this);
}