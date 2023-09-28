import 'package:discuz_flutter/converter/SecondToDateTimeConverter.dart';
import 'package:discuz_flutter/converter/StringToIntConverter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ForumThread.g.dart';

@JsonSerializable(disallowUnrecognizedKeys: false)
class ForumThread{

  String tid = "0";
  int getTid(){
    return int.parse(tid);
  }

  @JsonKey(name:"typeid", defaultValue: "0")
  String typeId = "0";

  int getTypeId(){
    return int.parse(typeId);
  }

  @JsonKey(name: "price",defaultValue: "0")
  String price = "0";
  int getPrice(){
    return int.parse(price);
  }

  @JsonKey(name:"readperm")
  @StringToIntConverter()
  int readPerm = 0;
  @JsonKey(defaultValue: "")
  String author = "";
  @JsonKey(name:"authorid")
  String authorId = "0";
  int getAuthorId(){
    return int.parse(authorId);
  }
  @JsonKey(defaultValue: "")
  String subject = "";
  @JsonKey(defaultValue: "")
  String dateline = "";
  @JsonKey(defaultValue: "")
  String lastpost = "";
  @JsonKey(name: "lastposter",defaultValue: "")
  String lastposter = "";
  @JsonKey(defaultValue: "")
  String views = "";
  @StringToIntConverter()
  @JsonKey(defaultValue: 0)
  int replies = 0;
  @JsonKey(name: "displayorder", defaultValue: "0")
  String displayOrder = "0";
  int getDisplayOrder(){
    return int.parse(displayOrder);
  }
  @JsonKey(defaultValue: "0")
  String digest = "0";
  @JsonKey(defaultValue: "0")
  String special = "0";
  @JsonKey(defaultValue: "0")
  String attachment = "0";
  @JsonKey(name: "replycredit", defaultValue: "0")
  String replyCredit = "0";
  @JsonKey(name: "dbdateline")
  @SecondToDateTimeConverter()
  DateTime dbdatelineMinutes = DateTime.now();

  @JsonKey(name:"dblastpost")
  String dblastpostMinutes = "0";
  DateTime getUpdatedTime(){
    return DateTime.fromMillisecondsSinceEpoch(int.parse(dblastpostMinutes) * 1000);
  }

  @JsonKey(required: false, defaultValue: [])
  List<ShortReply> reply = [];
  // extra information
  @JsonKey(defaultValue: "")
  String message = "";

  @JsonKey(name: "attachmentImageNumber", defaultValue: 0)
  @StringToIntConverter()
  int attachmentImageNumber = 0;

  @JsonKey(defaultValue: [])
  List<AttachmentPreview> attachmentImagePreviewList = [];

  ForumThread();



  factory ForumThread.fromJson(Map<String, dynamic> json) => _$ForumThreadFromJson(json);
  Map<String, dynamic> toJson() => _$ForumThreadToJson(this);

  @override
  String toString() {
    // TODO: implement toString
    return "ForumThread ${author} in ${tid}";
  }

  @JsonKey(name: "typename", required: false, defaultValue: "")
  String typeName = "";
}

@JsonSerializable(disallowUnrecognizedKeys: false)
class ShortReply{
  String pid = "0";
  String author = "";
  @JsonKey(name: "authorid")
  String authorId = "0";
  String message = "";
  @JsonKey(defaultValue: "")
  String avatar = "";

  ShortReply();
  factory ShortReply.fromJson(Map<String, dynamic> json) => _$ShortReplyFromJson(json);
  Map<String, dynamic> toJson() => _$ShortReplyToJson(this);

}

@JsonSerializable(ignoreUnannotated: true)
class AttachmentPreview{
  @StringToIntConverter()
  int aid=0, tid=0, pid=0, uid=0;
  @JsonKey(defaultValue: "")
  String dateline = "", filename = "", attachment="";
  @StringToIntConverter()
  @JsonKey(name:"filesize",defaultValue: 0)
  int fileSize = 0;
  @JsonKey(defaultValue: "")
  String description = "";
  @StringToIntConverter()
  @JsonKey(name:"readperm", defaultValue: 0)
  int readPerm = 0;
  @StringToIntConverter()
  @JsonKey(defaultValue: 0)
  int width = 0, height=0;

  AttachmentPreview();
  factory AttachmentPreview.fromJson(dynamic json){
    if(json is Map<String, dynamic>){
      return _$AttachmentPreviewFromJson(json);
    }
    else if(json is AttachmentPreview){
      return json;
    }
    return AttachmentPreview();
  }
  //factory AttachmentPreview.fromJson(Map<String, dynamic> json) => _$AttachmentPreviewFromJson(json);
  Map<String, dynamic> toJson() => _$AttachmentPreviewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}