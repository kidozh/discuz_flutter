

import 'package:hive_ce/hive.dart';

import '../utility/ConstUtils.dart';
import 'Discuz.dart';

part 'ViewThreadCache.g.dart';

@HiveType(typeId: ConstUtils.HIVE_TYPE_VIEWTHREAD_CACHE)
class ViewThreadCache extends HiveObject{
  @HiveField(0)
  int tid;
  @HiveField(1)
  String json;
  @HiveField(2)
  DateTime updateTime = DateTime.now();
  @HiveField(3)
  int page;
  @HiveField(4)
  bool isAscend;

  @HiveField(5)
  Discuz discuz;

  ViewThreadCache(this.tid, this.json, this.discuz, this.updateTime, this.page, this.isAscend);
}