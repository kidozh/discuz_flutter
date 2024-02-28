import 'package:json_annotation/json_annotation.dart';
import 'package:discuz_flutter/JsonResult/ErrorResult.dart';

part 'BaseResult.g.dart';

@JsonSerializable(explicitToJson: true)
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

    String? getErrorString(){
        if(error!=null){
            return error!;
        }
        else if(errorResult!=null){
            return "${errorResult!.content} (${errorResult!.key})";
        }
        else{
            return null;
        }
    }


}