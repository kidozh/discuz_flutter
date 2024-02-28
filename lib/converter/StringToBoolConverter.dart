import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

class StringToBoolConverter implements JsonConverter<bool, String?> {
  const StringToBoolConverter();

  @override
  bool fromJson(String? json) {
    if(json == null || json.isEmpty || json == "0"){
      return false;
    }
    else{
      return true;
    }

  }

  @override
  String toJson(bool object) {
    if(object){
      return "1";
    }
    else{
      return "0";
    }
    //return json.encode(object);

  }
  
}