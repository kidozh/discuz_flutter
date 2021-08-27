

import 'dart:developer';
import 'dart:ui';

import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesUtils{
  static final String recordHistoryKey = "recordHistoryKey";

  static Future<void> putRecordHistoryEnabled(bool value) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(recordHistoryKey, value);
  }

  static Future<bool> getRecordHistoryEnabled() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var boolValue =  prefs.getBool(recordHistoryKey);
    return boolValue == null ? false : boolValue;
  }

  static String getForumDisplayRewriteRuleName(Discuz discuz){
    return "ForumDisplay${discuz.baseURL}";
  }

  static String getViewThreadRewriteRuleName(Discuz discuz){
    return "ViewThread${discuz.baseURL}";
  }

  static Future<void> putForumDisplayRule(Discuz discuz, String rewriteRule) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(getForumDisplayRewriteRuleName(discuz), rewriteRule);
  }

  static Future<String> getForumDisplayRule(Discuz discuz) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var rewriteRule =  prefs.getString(getForumDisplayRewriteRuleName(discuz));
    return rewriteRule == null ? "" : rewriteRule;
  }

  static Future<void> putViewThreadRule(Discuz discuz, String rewriteRule) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(getViewThreadRewriteRuleName(discuz), rewriteRule);
  }

  static Future<String> getViewThreadRule(Discuz discuz) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var rewriteRule =  prefs.getString(getViewThreadRewriteRuleName(discuz));
    return rewriteRule == null ? "" : rewriteRule;
  }

  // the example could be f{fid}-{page}
  static Future<String?> findFidInURL(Discuz discuz,String url) async{
    // transfer rewrite url to regex
    String rewriteUrl = await getForumDisplayRule(discuz);
    if(rewriteUrl.isEmpty){
      return null;
    }
    rewriteUrl = rewriteUrl.replaceAll("{fid}", "(?<fid>[0-9]+)");
    rewriteUrl = rewriteUrl.replaceAll("{page}", "(?<page>[0-9]+)");
    log("rewrite url ${rewriteUrl}");
    RegExp regExp = new RegExp(rewriteUrl);
    RegExpMatch? regExpMatch = regExp.firstMatch(url);
    if(regExpMatch == null){
      return null;
    }
    else{
      try{
        return regExpMatch.namedGroup("fid");
      }
      catch(e){
        return null;
      }

    }

  }

  // the example could be t{tid}-{page}-{prevpage}
  static Future<String?> findTidInURL(Discuz discuz,String url) async{
    // transfer rewrite url to regex
    String rewriteUrl = await getViewThreadRule(discuz);
    if(rewriteUrl.isEmpty){
      return null;
    }
    rewriteUrl = rewriteUrl.replaceAll("{tid}", "(?<tid>[0-9]+)");
    rewriteUrl = rewriteUrl.replaceAll("{page}", "(?<page>[0-9]+)");
    rewriteUrl = rewriteUrl.replaceAll("{prevpage}", "(?<prevpage>[0-9]+)");
    log("rewrite url ${rewriteUrl}");
    RegExp regExp = new RegExp(rewriteUrl);
    RegExpMatch? regExpMatch = regExp.firstMatch(url);
    log(rewriteUrl);
    if(regExpMatch == null){
      return null;
    }
    else{
      try{
        return regExpMatch.namedGroup("tid");
      }
      catch(e){
        return null;
      }

    }

  }

  static final String themeColorKey = "themeColorKey";

  static Future<void> putThemeColor(String themeColor) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(themeColorKey, themeColor);
  }

  static Future<String> getThemeColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var boolValue =  prefs.getString(themeColorKey);
    return boolValue == null ? "" : boolValue;
  }

  static final String platformPreferenceKey = "platformPreferenceKey";

  static Future<void> putPlatformPreference(String platformName) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(platformPreferenceKey, platformName);
  }

  static Future<String> getPlatformPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var platformName =  prefs.getString(platformPreferenceKey);
    return platformName == null ? "" : platformName;
  }

  static final String typesettingScalePreferenceKey = "typesettingScalePreferenceKey";

  static Future<void> putTypesettingScalePreference(double scale) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(typesettingScalePreferenceKey, scale);
  }

  static Future<double> getTypesettingScalePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var scale =  prefs.getDouble(typesettingScalePreferenceKey);
    return scale == null ? 1.0 : scale;
  }

  static final String interfaceBrightnessPreferenceKey = "interfaceBrightnessPreferenceKey";

  static Future<void> putInterfaceBrightnessPreference(String brightness) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(interfaceBrightnessPreferenceKey, brightness);
  }

  static Future<String?> getInterfaceBrightnessStringPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var brightness =  prefs.getString(interfaceBrightnessPreferenceKey);
    return brightness;
  }

  static Future<Brightness?> getInterfaceBrightnessPreference() async {
    String? brightnessString = await getInterfaceBrightnessStringPreference();
    if(brightnessString == null){
      return null;
    }
    else if(brightnessString == "light"){
      return Brightness.light;
    }
    else if(brightnessString == "dark"){
      return Brightness.dark;
    }
    else{
      return null;
    }

  }

  static final String disableFontCustomizationKey = "disableFontCustomizatioKey";

  static Future<void> putDisableFontCustomizationPreference(bool value) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(disableFontCustomizationKey, value);
  }

  static Future<bool> getDisableFontCustomizationPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var boolValue =  prefs.getBool(disableFontCustomizationKey);
    return boolValue == null ? false : boolValue;
  }

  static final String testFlightNotificationFlag = "testFlightNotificationFlag";

  static Future<void> putTestFlightNotificationFlag(int value) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(testFlightNotificationFlag, value);
  }

  static Future<int> getTestFlightNotificationFlag() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var intValue =  prefs.getInt(testFlightNotificationFlag);
    return intValue == null ? 0 : intValue;
  }


}