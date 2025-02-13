
import 'package:discuz_flutter/utility/ConstUtils.dart';
import 'package:hive_ce/hive.dart';

part 'TrustHost.g.dart';

@HiveType(typeId: ConstUtils.HIVE_TYPE_ID_TRUST_HOST)
class TrustHost extends HiveObject{
  @HiveField(0)
  String host;
  @HiveField(1)
  DateTime trustAt = DateTime.now();

  TrustHost(this.host);
}