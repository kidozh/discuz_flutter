


import 'package:hive_ce/hive.dart';

import '../utility/ConstUtils.dart';
import 'Discuz.dart';

part 'ViewHistory.g.dart';

@HiveType(typeId: ConstUtils.HIVE_TYPE_ID_VIEW_HISTORY)
class ViewHistory extends HiveObject{
  @HiveField(0)
  String title;
  @HiveField(1)
  String subject;
  @HiveField(2)
  String description;
  @HiveField(3)
  String type;
  @HiveField(4)
  int identification;
  @HiveField(5)
  String author;
  @HiveField(6)
  int authorId;
  @HiveField(7)
  DateTime insertTime = DateTime.now();
  @HiveField(8)
  DateTime updateTime;

  @HiveField(9)
  Discuz discuz;

  ViewHistory(this.title, this.subject, this.description, this.type, this.identification,this.author, this.authorId, this.discuz, this.updateTime);
}