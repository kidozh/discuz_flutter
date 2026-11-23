import 'package:hive_ce/hive.dart';

import '../utility/ConstUtils.dart';
import 'Discuz.dart';

part 'Draft.g.dart';

@HiveType(typeId: ConstUtils.HIVE_TYPE_ID_DRAFT)
class Draft extends HiveObject {
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
  @HiveField(8, defaultValue: '')
  String pollJson = '';

  @HiveField(9, defaultValue: <String, String>{})
  Map<String, String> attachmentNames = {};

  @HiveField(10, defaultValue: '')
  String specialThreadJson = '';

  @HiveField(11, defaultValue: 0)
  int uid = 0;
  @HiveField(12, defaultValue: '')
  String pendingAttachmentsJson = '';

  @HiveField(13, defaultValue: '')
  String replyRewardJson = '';

  @HiveField(14, defaultValue: '')
  String classifiedJson = '';

  @HiveField(15, defaultValue: '')
  String rushJson = '';

  @HiveField(16, defaultValue: '')
  String extraThreadOptionsJson = '';

  @HiveField(7)
  String typeid;

  Draft(
    this.title,
    this.text,
    this.fid,
    this.typeid,
    this.updateTime,
    this.discuz,
  );
}
