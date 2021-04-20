import 'package:discuz_flutter/converter/SecondToDateTimeConverter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ForumThread.g.dart';

@JsonSerializable(disallowUnrecognizedKeys: false)
class ForumThread{

  String tid = "0";
  int getTid(){
    return int.parse(tid);
  }

  @JsonKey(name:"typeid")
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
  String readPerm = "0";
  String author = "";
  @JsonKey(name:"authorid")
  String authorId = "0";
  int getAuthorId(){
    return int.parse(authorId);
  }
  String subject = "";
  String dateline = "";
  String lastpost = "";
  @JsonKey(name: "lastposter",defaultValue: "")
  String lastposter = "";
  String views = "";
  String replies = "";
  @JsonKey(name: "displayorder")
  String displayOrder = "0";
  int getDisplayOrder(){
    return int.parse(displayOrder);
  }
  String digest = "0";
  String special = "0";
  String attachment = "0";
  @JsonKey(name: "replycredit")
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

  ForumThread();



  factory ForumThread.fromJson(Map<String, dynamic> json) => _$ForumThreadFromJson(json);
  Map<String, dynamic> toJson() => _$ForumThreadToJson(this);

  @override
  String toString() {
    // TODO: implement toString
    return "ForumThread ${author} in ${tid}";
  }
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