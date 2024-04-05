
import 'package:json_annotation/json_annotation.dart';

class ThreadTypeConverter implements JsonConverter<Map<String,String>, Object?> {
  const ThreadTypeConverter();

  @override
  Map<String,String> fromJson(Object? json) {
    if(json is Map<String, dynamic>){
      Map<String, String> stringMap = {};

      for(String key in json.keys){
        stringMap[key] = json[key].toString();
      }
      return stringMap;

    }

    return {};

  }

  @override
  Object toJson(Map<String,String> object) {
    return object.toString();
  }

  
}