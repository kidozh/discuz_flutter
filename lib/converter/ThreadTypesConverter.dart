import 'package:json_annotation/json_annotation.dart';

import '../utility/discuz_json.dart';

class ThreadTypeConverter
    implements JsonConverter<Map<String, String>, Object?> {
  const ThreadTypeConverter();

  @override
  Map<String, String> fromJson(Object? json) =>
      discuzMap(json).map((id, name) => MapEntry(id, discuzString(name)));

  @override
  Object toJson(Map<String, String> object) => object;
}
