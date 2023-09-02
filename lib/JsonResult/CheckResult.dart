import 'dart:core';

import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:json_annotation/json_annotation.dart';

// Example from keylol
// {"discuzversion":"X3.2","charset":"utf-8","version":"4","pluginversion":"1.4.8","regname":"register","qqconnect":"1",
// "wsqqqconnect":"1","wsqhideregister":"0","sitename":"\u5176\u4e50 Keylol","mysiteid":"8591285",
// "ucenterurl":"https:\/\/keylol.com\/uc_server","defaultfid":"161","totalposts":13701348,"totalmembers":1484286,"testcookie":null}

part 'CheckResult.g.dart';

@JsonSerializable()
class CheckResult {
  @JsonKey(name: 'discuzversion')
  String discuzVersion = "";
  String charset="utf-8";
  @JsonKey(name: 'version',defaultValue: "4")
  String apiVersion = "";
  int getApiVersion(){
    return int.parse(apiVersion);
  }
  @JsonKey(name: 'pluginversion')
  String pluginVersion = "";
  String regname = "";
  String qqconnect = "";
  bool qqEnabled(){
    return qqconnect == "1";
  }
  String wsqqqconnect = "1";
  String wsqhideregister = "";
  @JsonKey(name: 'sitename')
  String siteName = "";
  @JsonKey(name: 'mysiteid')
  String siteId = "";
  @JsonKey(name: 'ucenterurl')
  String uCenterURL = "";
  @JsonKey(name: 'defaultfid', defaultValue: "0")
  String defaultFid = "";
  // @JsonKey(name: 'totalposts', ignore: true)
  // int totalPosts = 0;
  // @JsonKey(name: 'totalmembers')
  // int totalMembers = 0;
  @JsonKey(defaultValue: "")
  String? testcookie = "";


  CheckResult(
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
      this.defaultFid,
      // this.totalPosts,
      // this.totalMembers
    );

  factory CheckResult.fromJson(Map<String, dynamic> json) => _$CheckResultFromJson(json);
  Map<String, dynamic> toJson() => _$CheckResultToJson(this);

  Discuz toDiscuz(String baseURL){
    return Discuz(baseURL,discuzVersion, charset, getApiVersion(),
        pluginVersion, regname, qqEnabled(),
        wsqqqconnect, wsqhideregister, siteName,
        siteId, uCenterURL, defaultFid);
  }
}