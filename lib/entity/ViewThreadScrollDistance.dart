import 'package:hive_ce/hive.dart';

import '../utility/ConstUtils.dart';
import 'Discuz.dart';

part 'ViewThreadScrollDistance.g.dart';

@HiveType(typeId: ConstUtils.HIVE_TYPE_VIEWTHREAD_SCROLL_DISTANCE)
class ViewThreadScrollDistance extends HiveObject {
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

  @HiveField(5)
  final int? uid;
  @HiveField(6)
  final int? pid;
  @HiveField(7)
  final int? repliesAtRead;

  ViewThreadScrollDistance(
    this.tid,
    this.offset,
    this.discuz,
    this.updateTime,
    this.isAscend, {
    this.uid,
    this.pid,
    this.repliesAtRead,
  });

  bool hasUpdates(int replies) {
    final previous = repliesAtRead;
    return previous != null && replies > previous;
  }
}
