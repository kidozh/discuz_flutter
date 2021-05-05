import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

class StringToBoolConverter implements JsonConverter<bool, String?> {
  const StringToBoolConverter();

  @override
  bool fromJson(String? json) {
    if(json == null || json == "0"){
      return false;
    }
    else{
      return true;
    }

  }

  @override
  String toJson(bool object) {
    return json.encode(object);

  }
  
}