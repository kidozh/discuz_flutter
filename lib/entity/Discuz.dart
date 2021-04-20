import 'package:floor/floor.dart';

@entity
class Discuz {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  String discuzVersion = "";
  String charset="utf-8";
  int apiVersion = 4;
  String pluginVersion = "";
  String regname = "";
  bool qqconnect = false;
  String wsqqqconnect = "1";
  String wsqhideregister = "";
  String siteName = "";
  String siteId = "";
  String uCenterURL = "";
  String defaultFid = "";
  String baseURL = "";

  String getDiscuzAvatarURL(){
    return this.baseURL + "/static/image/common/logo.png";
  }



  Discuz(
      this.id,
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