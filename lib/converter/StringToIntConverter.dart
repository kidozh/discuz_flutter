import 'package:json_annotation/json_annotation.dart';

class StringToIntConverter implements JsonConverter<int, String?> {
  const StringToIntConverter();

  @override
  int fromJson(String? json) {
    if(json == null){
      return 0;
    }
    else{
      int? value = int.tryParse(json);
      if(value!= null){
        return value;
      }
      else{
        return 0;
      }

    }


  }

  @override
  String toJson(int object) {
    return object.toString();

  }
  
}