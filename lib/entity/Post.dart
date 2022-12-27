import 'package:discuz_flutter/converter/AttachmentConverter.dart';
import 'package:discuz_flutter/converter/SecondToDateTimeConverter.dart';
import 'package:discuz_flutter/converter/StringToBoolConverter.dart';
import 'package:discuz_flutter/converter/StringToIntConverter.dart';
import 'package:json_annotation/json_annotation.dart';

import 'Discuz.dart';

part 'Post.g.dart';

@JsonSerializable()
class Post{
  @StringToIntConverter()
  int pid = 0;
  @StringToIntConverter()
  int tid = 0;
  @StringToBoolConverter()
  bool first = false;
  @StringToBoolConverter()
  bool anonymous = false;

  @JsonKey(defaultValue: "")
  String author = "";
  @JsonKey(defaultValue: "")
  String dateline = "";
  @JsonKey(defaultValue: "")
  String message = "";

  @JsonKey(defaultValue: "")
  String ipLocation = "";

  @JsonKey(name:"authorid")
  @StringToIntConverter()
  int authorId = 0;
  @StringToIntConverter()
  int attachment = 0;
  @StringToIntConverter()
  int status = 0,replycredit = 0, number = 0, position = 0;
  @JsonKey(name:"adminid",ignore: true, required: false)
  // @StringToIntConverter()
  String adminId = "0";
  @JsonKey(name:"groupid")
  @StringToIntConverter()
  int groupId = 0;
  @JsonKey(name:"memberstatus")
  @StringToIntConverter()
  int memberStatus = 0;
  @JsonKey(name: "dbdateline",defaultValue: null)
  @SecondToDateTimeConverter()
  DateTime publishAt = DateTime.now();

  @JsonKey(name: "attachlist",defaultValue: [])
  List<String> attachmentIdList = [];

  @JsonKey(name: "imagelist",defaultValue: [])
  List<String> imageIdList = [];

  @JsonKey(name:"groupiconid",defaultValue: "0")
  String groupIconId = "0";

  @JsonKey(name:"attachments", required: false)
  @AttachmentConverter()
  Map<String, Attachment> attachmentMapper  = {};

  List<Attachment> getAttachmentList(){
    List<Attachment> attachmentList = [];
    for(var entry in attachmentMapper.entries){
      attachmentList.add(entry.value);
    }
    return attachmentList;
  }


  Post();
  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
  Map<String, dynamic> toJson() => _$PostToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

@JsonSerializable(ignoreUnannotated: true)
@StringToIntConverter()
class Attachment{
  @StringToIntConverter()
  int aid=0, tid=0, pid=0, uid=0;
  @JsonKey(defaultValue: "")
  String dateline = "", filename = "";
  @StringToIntConverter()
  @JsonKey(name:"filesize",defaultValue: 0)
  int fileSize = 0;
  @StringToBoolConverter()
  bool remote = false, thumb = false, payed = false;
  // @JsonKey(defaultValue: "")
  // String description = "";
  @StringToIntConverter()
  @JsonKey(name:"readperm")
  int readPerm = 0;
  // @StringToIntConverter()
  // @JsonKey(name:"picid",defaultValue: 0)
  // int picId = 0;
  @JsonKey(name:"aidencode",defaultValue: "")
  String aidEncode = "";
  @JsonKey(defaultValue: "")
  String url = "";
  @StringToIntConverter()
  @JsonKey(name:"downloads",defaultValue: 0)
  int downloads = 0;
  @JsonKey(name: "dbdateline")
  @SecondToDateTimeConverter()
  DateTime updateAt = DateTime.now();
  @JsonKey(name: "attachsize",defaultValue: "")
  String attachmentSizeString = "";
  @JsonKey(name: "attachment",defaultValue: "")
  String attachmentPathName = "";
  @JsonKey(defaultValue: "")
  String ext = "";


  // @JsonKey(name:"imgalt", defaultValue: "")
  // String? imageAlt = "";

  Attachment();
  factory Attachment.fromJson(Map<String, dynamic> json) => _$AttachmentFromJson(json);
  Map<String, dynamic> toJson() => _$AttachmentToJson(this);

  String getAttachmentRealUrl(Discuz discuz){
    if(url.startsWith("http") || url.startsWith("http")){
      return url + attachmentPathName;
    }
    else{
      return discuz.baseURL.toString() + "/" + url + attachmentPathName;
    }

  }
}