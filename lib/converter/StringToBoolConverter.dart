import 'package:json_annotation/json_annotation.dart';

class StringToBoolConverter implements JsonConverter<bool, Object?> {
  const StringToBoolConverter();
  @override
  bool fromJson(Object? json) {
    if (json is bool) return json;
    if (json is num) return json != 0;
    if (json is String) {
      return json.isNotEmpty && json != '0' && json.toLowerCase() != 'false';
    }
    return false;
  }

  @override
  String toJson(bool object) => object ? '1' : '0';
}
