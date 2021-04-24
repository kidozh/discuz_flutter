import 'package:json_annotation/json_annotation.dart';

class StringToIntConverter implements JsonConverter<int, String?> {
  const StringToIntConverter();

  @override
  int fromJson(String? json) {
    if(json == null){
      return 0;
    }
    else{
      return int.parse(json);
    }


  }

  @override
  String toJson(int object) {
    return object.toString();

  }
  
}