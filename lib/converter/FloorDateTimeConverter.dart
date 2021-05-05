

import 'package:floor/floor.dart';

class FloorDateTimeConverter extends TypeConverter<DateTime, int> {
  @override
  int encode(DateTime value) {
    return value.millisecondsSinceEpoch;
  }

  @override
  DateTime decode(int databaseValue) {
    return DateTime.fromMillisecondsSinceEpoch(databaseValue);
  }
}