import 'package:json_annotation/json_annotation.dart';
import '../utility/discuz_json.dart';

class StringToIntConverter implements JsonConverter<int, Object?> {
  const StringToIntConverter();
  @override
  int fromJson(Object? json) => discuzInt(json);
  @override
  String toJson(int object) => object.toString();
}
