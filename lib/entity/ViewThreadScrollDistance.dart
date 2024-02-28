

import 'package:hive/hive.dart';

import '../utility/ConstUtils.dart';
import 'Discuz.dart';

part 'ViewThreadScrollDistance.g.dart';

@HiveType(typeId: ConstUtils.HIVE_TYPE_VIEWTHREAD_SCROLL_DISTANCE)
class ViewThreadScrollDistance extends HiveObject{
  @HiveField(0)
  int tid;
  @HiveField(1)
  double offset;
  @HiveField(2)
  DateTime updateTime = DateTime.now();
  @HiveField(3)
  bool isAscend;

  @HiveField(4)
  Discuz discuz;

  ViewThreadScrollDistance(this.tid, this.offset, this.discuz, this.updateTime, this.isAscend);
}