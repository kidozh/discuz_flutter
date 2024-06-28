

import 'dart:developer';

import 'package:discuz_flutter/entity/NewThread.dart';
import 'package:json_annotation/json_annotation.dart';

class NewThreadListConverter implements JsonConverter<List<NewThread>, Object?> {
  const NewThreadListConverter();

  @override
  List<NewThread> fromJson(Object? json) {
    List<NewThread> newThreadList = [];
    if(json is List<dynamic>){
      List<dynamic> newThreadDynamicList = json;
      log("new Thread list ${newThreadDynamicList.toString()}");

      for(var newThreadDynamic in newThreadDynamicList){
        if(newThreadDynamic!=null){
          // log("Get ${entry.key} value ${entry.value.runtimeType} ${entry.value}");
          try{
            NewThread newThread = NewThread.fromJson(newThreadDynamic);
            newThreadList.add(newThread);
          }
          catch (e){
            log("error in parse new thread ${e}");
          }

        }

      }
    }
    return newThreadList;
  }

  @override
  Object? toJson(List<NewThread> object) {
    return object;
  }
}