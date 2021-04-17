import 'package:json_annotation/json_annotation.dart';
import 'package:discuz_flutter/JsonResult/ErrorResult.dart';

part 'BaseResult.g.dart';

@JsonSerializable()
class BaseResult{
    @JsonKey(name: "Version")
    String version = "";
    int getApiVersion(){
      return int.parse(version);
    }
    @JsonKey(name: "Charset")
    String charset = "";
    @JsonKey(name: "Message",required: false)
    ErrorResult? errorResult;
    @JsonKey(required: false)
    String? error;


}