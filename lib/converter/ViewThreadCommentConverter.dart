import 'dart:convert';
import 'dart:developer';

import 'package:discuz_flutter/JsonResult/ViewThreadResult.dart';
import 'package:discuz_flutter/entity/Post.dart';
import 'package:json_annotation/json_annotation.dart';

class ViewThreadCommentConverter implements JsonConverter<Map<String, List<Comment>>, Object?> {
  const ViewThreadCommentConverter();

  @override
  Map<String, List<Comment>> fromJson(Object? json) {
    if(json is Map<String, dynamic>){
      Map<String, dynamic> commentMap = json;
      log("comment map ${commentMap.toString()}");
      Map<String, List<Comment>> returnedMap = {};
      for(var entry in commentMap.entries){
        if(entry.value!=null && entry.value is List<dynamic> ){
          log("Get ${entry.key} value ${entry.value.runtimeType} ${entry.value}");
          List<dynamic> commentDynamicList = entry.value;
          List<Comment> commentList = [];
          for(var commentDynamic in commentDynamicList){
            Comment comment = Comment.fromJson(commentDynamic);
            commentList.add(comment);
            log("Get comment dynamic ${commentDynamic} ${comment.author}");
          }
          returnedMap[entry.key] = commentList;

        }

      }
      log("Get returned map ${returnedMap}");
      return returnedMap;
    }
    return {};

  }

  @override
  Object? toJson(Map<String, List<Comment>> object) {
    return {};
  }


  
}