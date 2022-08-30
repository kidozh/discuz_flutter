
import 'package:hive/hive.dart';

import '../utility/ConstUtils.dart';
import 'Discuz.dart';

part 'Draft.g.dart';

@HiveType(typeId: ConstUtils.HIVE_TYPE_ID_DRAFT)
class Draft extends HiveObject{
  @HiveField(1)
  String title;
  @HiveField(2)
  String text;
  @HiveField(3)
  DateTime insertTime = DateTime.now();
  @HiveField(4)
  DateTime updateTime;

  @HiveField(5)
  Discuz discuz;
  @HiveField(6)
  int fid = 0;
  @HiveField(7)
  int typeid = 0;


  Draft(this.title, this.text, this.fid, this.typeid, this.updateTime, this.discuz);
}