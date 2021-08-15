

import 'package:discuz_flutter/utility/HiveUtils.dart';
import 'package:hive/hive.dart';

@HiveType(typeId: HiveAdapterTypeIds.discuz)
class Discuz{

  @HiveField(0)
  String discuzVersion = "";
  @HiveField(1)
  String charset="utf-8";
  @HiveField(2)
  int apiVersion = 4;
  @HiveField(3)
  String pluginVersion = "";
  @HiveField(4)
  String regname = "";
  @HiveField(5)
  bool qqconnect = false;
  @HiveField(6)
  String wsqqqconnect = "1";
  @HiveField(7)
  String wsqhideregister = "";
  @HiveField(8)
  String siteName = "";
  @HiveField(9)
  String siteId = "";
  @HiveField(10)
  String uCenterURL = "";
  @HiveField(11)
  String defaultFid = "";
  @HiveField(12)
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