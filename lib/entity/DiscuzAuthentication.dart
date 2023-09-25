

import 'package:hive/hive.dart';

import '../utility/ConstUtils.dart';


part 'DiscuzAuthentication.g.dart';

@HiveType(typeId: ConstUtils.HIVE_TYPE_ID_DISCUZ_AUTHENTICATION)
class DiscuzAuthentication extends HiveObject{
  @HiveField(1)
  String account = "";

  @HiveField(2)
  String password = "";

  @HiveField(3)
  String discuz_host = "";

  @HiveField(4)
  DateTime updateTime = DateTime.now();

  @HiveField(5)
  String note = "";
}