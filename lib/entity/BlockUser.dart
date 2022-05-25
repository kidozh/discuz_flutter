

import 'package:hive/hive.dart';

import '../utility/ConstUtils.dart';
import 'Discuz.dart';

part 'BlockUser.g.dart';

@HiveType(typeId: ConstUtils.HIVE_TYPE_ID_BLOCK_USER)
class BlockUser extends HiveObject{
  @HiveField(1)
  int uid;
  @HiveField(2)
  String name;
  @HiveField(3)
  DateTime insertTime = DateTime.now();
  @HiveField(4)
  DateTime updateTime;

  @HiveField(5)
  Discuz discuz;

  BlockUser(this.uid, this.name, this.updateTime, this.discuz);
}