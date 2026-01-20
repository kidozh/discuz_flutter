

import 'package:hive_ce/hive.dart';

import '../utility/ConstUtils.dart';
import 'Discuz.dart';

part 'AiRule.g.dart';

@HiveType(typeId: ConstUtils.HIVE_TYPE_ID_AI_RULE)
class AiRule extends HiveObject{
  @HiveField(5)
  String name;
  @HiveField(1)
  String instruction;
  @HiveField(2)
  String prompt;
  @HiveField(3)
  DateTime insertTime = DateTime.now();
  @HiveField(4)
  DateTime updateTime;
  @HiveField(6)
  bool? isExample = false;


  AiRule(this.name, this.instruction, this.prompt, this.updateTime);
}