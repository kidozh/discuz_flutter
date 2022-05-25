
import 'package:hive/hive.dart';

import '../utility/ConstUtils.dart';

part 'Discuz.g.dart';

@HiveType(typeId: ConstUtils.HIVE_TYPE_ID_DISCUZ)
class Discuz extends HiveObject {
  @HiveField(1)
  String discuzVersion = "";
  @HiveField(2)
  String charset="utf-8";
  @HiveField(3)
  int apiVersion = 4;
  @HiveField(4)
  String pluginVersion = "";
  @HiveField(5)
  String regname = "";
  @HiveField(6)
  bool qqconnect = false;
  @HiveField(7)
  String wsqqqconnect = "1";
  @HiveField(8)
  String wsqhideregister = "";
  @HiveField(9)
  String siteName = "";
  @HiveField(10)
  String siteId = "";
  @HiveField(11)
  String uCenterURL = "";
  @HiveField(12)
  String defaultFid = "";
  @HiveField(13)
  String baseURL = "";

  String getDiscuzAvatarURL(){
    return this.baseURL + "/static/image/common/logo.png";
  }



  Discuz(
      this.baseURL,
      this.discuzVersion,
      this.charset,
      this.apiVersion,
      this.pluginVersion,
      this.regname,
      this.qqconnect,
      this.wsqqqconnect,
      this.wsqhideregister,
      this.siteName,
      this.siteId,
      this.uCenterURL,
      this.defaultFid);


}