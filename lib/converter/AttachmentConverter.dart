import 'dart:developer';

import 'package:discuz_flutter/entity/Post.dart';
import 'package:json_annotation/json_annotation.dart';

class AttachmentConverter implements JsonConverter<Map<String,Attachment>, Object?> {
  const AttachmentConverter();

  @override
  Map<String, Attachment> fromJson(Object? json) {
    // TODO: implement fromJson
    // log("Get attachment json ${json.runtimeType} ${json.toString()}");
    if(json is Map<String, dynamic>){
      Map<String, dynamic> attachmentMap = json;
      log("attach map ${attachmentMap.toString()}");
      Map<String, Attachment> returnedMap = {};
      for(var entry in attachmentMap.entries){
        if(entry.value!=null){
          // log("Get ${entry.key} value ${entry.value.runtimeType} ${entry.value}");
          try{
            Attachment attachment = Attachment.fromJson(entry.value);
            returnedMap[entry.key] = attachment;
          }
          catch(e){
            log("parse attachment error ${e}");
          }

        }

      }
      return returnedMap;
    }
    return {};

  }

  @override
  Map<String, Attachment> toJson(Map<String, Attachment> object) {
    return object;
  }

  
}