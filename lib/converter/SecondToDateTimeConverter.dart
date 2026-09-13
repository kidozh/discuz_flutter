import 'package:json_annotation/json_annotation.dart';

class SecondToDateTimeConverter implements JsonConverter<DateTime, Object?> {
  const SecondToDateTimeConverter();
  @override
  DateTime fromJson(Object? json) {
    final seconds = json is num ? json : num.tryParse(json?.toString() ?? '');
    if (seconds == null || !seconds.isFinite || seconds.abs() > 8640000000000) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.fromMillisecondsSinceEpoch((seconds * 1000).toInt());
  }

  @override
  String toJson(DateTime object) =>
      (object.millisecondsSinceEpoch ~/ 1000).toString();
}
