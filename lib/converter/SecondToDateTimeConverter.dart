import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

class SecondToDateTimeConverter implements JsonConverter<DateTime, String?> {
  const SecondToDateTimeConverter();

  @override
  DateTime fromJson(String? json) {
    if(json != null){
      return DateTime.fromMillisecondsSinceEpoch(int.parse(json) * 1000);
    }
    else{
      return DateTime.now();
    }


  }

  @override
  String toJson(DateTime object) {
    return json.encode(object);

  }
  
}