import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

class SecondToDateTimeConverter implements JsonConverter<DateTime, String> {
  const SecondToDateTimeConverter();

  @override
  DateTime fromJson(String json) {
    return DateTime.fromMillisecondsSinceEpoch(int.parse(json) * 1000);

  }

  @override
  String toJson(DateTime object) {
    return json.encode(object);

  }
  
}