
import 'package:discuz_flutter/converter/FloorDateTimeConverter.dart';
import 'package:floor/floor.dart';

@entity
@TypeConverters([FloorDateTimeConverter])
class TrustHost{
  @PrimaryKey(autoGenerate: true)
  final int? id;

  String host;
  DateTime trustAt = DateTime.now();

  TrustHost(this.id, this.host);
}