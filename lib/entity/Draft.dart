
import 'package:hive/hive.dart';

import '../utility/ConstUtils.dart';
import 'Discuz.dart';

part 'Draft.g.dart';

@HiveType(typeId: ConstUtils.HIVE_TYPE_ID_DRAFT)
class Draft extends HiveObject{
  @HiveField(1)
  String text;
  @HiveField(6)
  int fid = 0;
  @HiveField(2)
  int replyPid = 0;
  @HiveField(3)
  DateTime insertTime = DateTime.now();
  @HiveField(4)
  DateTime updateTime;

  @HiveField(5)
  Discuz discuz;

  Draft(this.text, this.fid, this.replyPid, this.updateTime, this.discuz);
}