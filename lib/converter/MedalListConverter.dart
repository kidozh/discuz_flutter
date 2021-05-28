import 'dart:convert';
import 'dart:developer';

import 'package:discuz_flutter/JsonResult/UserProfileResult.dart';
import 'package:discuz_flutter/entity/Post.dart';
import 'package:json_annotation/json_annotation.dart';

class MedalListConverter implements JsonConverter<List<Medal>, Object?> {
  const MedalListConverter();

  @override
  List<Medal> fromJson(Object? json) {
    // TODO: implement fromJson
    // log("Get Medal json ${json.runtimeType} ${json.toString()}");
    if(json is List<dynamic>){
      List<dynamic> medalDynamicList = json;
      log("medal list ${medalDynamicList.toString()}");
      List<Medal> medalList = [];
      for(var medalDynamic in medalDynamicList){
        if(medalDynamic!=null){
          // log("Get ${entry.key} value ${entry.value.runtimeType} ${entry.value}");
          Medal medal = Medal.fromJson(medalDynamic);
          medalList.add(medal);
        }

      }
      return medalList;
    }
    return [];

  }

  @override
  Object? toJson(List<Medal> object) {
    // TODO: implement toJson
    return object;
  }



  
}