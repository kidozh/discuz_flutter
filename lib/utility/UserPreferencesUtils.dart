

import 'dart:developer';

import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../entity/User.dart';
import 'PostTextFieldUtils.dart';

class UserPreferencesUtils{
  static final String recordHistoryKey = "recordHistoryKey";

  static Future<void> putRecordHistoryEnabled(bool value) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(recordHistoryKey, value);
  }

  static Future<bool> getRecordHistoryEnabled() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var boolValue =  prefs.getBool(recordHistoryKey);
    return boolValue == null ? true : boolValue;
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

  static final String themeColorKey = "themeColorValueKeyV1";

  static Future<void> putThemeColor(int themeColorValue) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(themeColorKey, themeColorValue);
  }

  static List<FlexScheme> getAvailableThemes(){
    List<FlexScheme> availableThemes = [];
    for (var value in FlexScheme.values){
      if(value != FlexScheme.custom){
        availableThemes.add(value);
      }
    }
    return availableThemes;

  }



  static Future<FlexScheme> getThemeColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<FlexScheme> availableThemes = getAvailableThemes();
    var colorIndex =  prefs.getInt(themeColorKey);
    return colorIndex == null ? FlexScheme.blueWhale : availableThemes[colorIndex];
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
    return scale == null ? 1.2 : scale;
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
    return boolValue == null ? true : boolValue;
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

  static final String acceptVersionCodeFlag = "acceptVersionCodeFlag";

  static Future<void> putAcceptVersionCodeFlag(String value) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(acceptVersionCodeFlag, value);
  }

  static Future<String> getAcceptVersionCodeFlag() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var value =  prefs.getString(acceptVersionCodeFlag);
    return value == null ? "" : value;
  }

  static final String useMaterial3PreferenceKey = "useMaterial3PreferenceKey";

  static Future<bool> getMaterial3PropertyPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var useMaterial3 =  prefs.getBool(useMaterial3PreferenceKey);
    return useMaterial3 == null? true: useMaterial3;
  }

  static Future<void> putMaterial3PropertyPreference(bool value) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(useMaterial3PreferenceKey, value);
  }

  static final String signaturePreferenceKey = "signaturePreferenceKey";

  static Future<String> getSignaturePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var signaturePreference =  prefs.getString(signaturePreferenceKey);
    return signaturePreference == null? PostTextFieldUtils.USE_APP_SIGNATURE: signaturePreference;
  }

  static Future<void> putSignaturePreference(String value) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(signaturePreferenceKey, value);
  }



  static Future<String> getDiscuzForumFids(Discuz discuz) async {
    String discuzForumFidsKey = "discuz_forums_${discuz.baseURL}";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var signaturePreference =  prefs.getString(discuzForumFidsKey);
    return signaturePreference == null? "": signaturePreference;
  }

  static Future<void> putDiscuzForumFids(Discuz discuz,String value) async{
    String discuzForumFidsKey = "discuz_forums_${discuz.baseURL}";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(discuzForumFidsKey, value);
  }

  static final String pushPreferenceKey = "pushPreferenceKey";

  static Future<bool> getPushPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var pushPreference =  prefs.getBool(pushPreferenceKey);
    return pushPreference == null? false: pushPreference;
  }

  static Future<bool?> checkPushPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var pushPreference =  prefs.getBool(pushPreferenceKey);
    return pushPreference;
  }

  static Future<void> putPushPreference(bool value) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(pushPreferenceKey, value);
  }

  static final String firstShowDiscuzKey = "firstShowDiscuzKey";

  static Future<String?> getFirstShowDiscuzPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var pushPreference =  prefs.getString(firstShowDiscuzKey);
    return pushPreference;
  }

  static Future<void> putFirstShowDiscuzPreference(String value) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(firstShowDiscuzKey, value);
  }

  static Future<String> getDiscuzGroupNameById(Discuz discuz, int groupId) async {
    String discuzForumFidsKey = "discuz_groupName_${discuz.baseURL}_${groupId}";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var signaturePreference =  prefs.getString(discuzForumFidsKey);
    return signaturePreference == null? "": signaturePreference;
  }

  static Future<void> putDiscuzGroupNameById(Discuz discuz, int groupId, String value) async{
    String discuzForumFidsKey = "discuz_groupName_${discuz.baseURL}_${groupId}";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(discuzForumFidsKey, value);
  }

  static Future<int> getDiscuzGroupStarById(Discuz discuz, int groupId) async {
    String discuzForumFidsKey = "discuz_groupStar_${discuz.baseURL}_${groupId}";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var signaturePreference =  prefs.getInt(discuzForumFidsKey);
    return signaturePreference == null? 0: signaturePreference;
  }

  static Future<void> putDiscuzGroupStarById(Discuz discuz, int groupId, int value) async{
    String discuzForumFidsKey = "discuz_groupStar_${discuz.baseURL}_${groupId}";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(discuzForumFidsKey, value);
  }

  static Future<int> getLastMobileSign(Discuz discuz, int uid) async {
    String discuzForumFidsKey = "discuz_last_signed_in_${discuz.baseURL}_${uid}";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var signaturePreference =  prefs.getInt(discuzForumFidsKey);
    return signaturePreference == null? 0: signaturePreference;
  }

  static Future<void> _putLastMobileSign(Discuz discuz, int uid, int value) async{
    String discuzForumFidsKey = "discuz_last_signed_in_${discuz.baseURL}_${uid}";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(discuzForumFidsKey, value);
  }

  static bool isTheSameDay(DateTime a, DateTime b){
    final dateFormat = DateFormat("yyyy-MM-dd");
    final date1 = dateFormat.format(a);
    final date2 = dateFormat.format(b);
    return date1 == date2;
  }

  static Future<bool> shouldMobileSign(Discuz discuz, int uid) async{
    int lastMobileSignTimestampSecond = await getLastMobileSign(discuz, uid);
    DateTime lastSignDate = DateTime.fromMillisecondsSinceEpoch(lastMobileSignTimestampSecond * 1000);
    DateTime now = DateTime.now();

    if (!isTheSameDay(lastSignDate, now)){
      // if not in the same day, a mobile sign is neccessary
      return true;
    }
    else{
      return false;
    }
  }

  static Future<void> putLastMobileSignRecord(Discuz discuz, int uid) async{
    int nowTimestampSecond = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await _putLastMobileSign(discuz, uid, nowTimestampSecond);
  }

  static final String hapticFeedbackPreferenceKey = "hapticFeedbackPreferenceKey";

  static Future<bool> getHapticFeedbackPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var enableHapticFeedback =  prefs.getBool(hapticFeedbackPreferenceKey);
    return enableHapticFeedback == null? true: enableHapticFeedback;
  }

  static Future<void> putHapticFeedbackPreference(bool value) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(hapticFeedbackPreferenceKey, value);
  }

  static final String subscribedChannelPreferenceKey = "subscribedChannelPreferenceKey";

  static Future<List<String>> getSubscribedChannelList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var subscribedChannel =  prefs.getStringList(subscribedChannelPreferenceKey);
    return subscribedChannel == null? []: subscribedChannel;
  }

  static Future<void> putSubscribedChannelList(List<String> subscribedChannelList) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(subscribedChannelPreferenceKey, subscribedChannelList);
  }

  static final String lastSubscribedTimestampPreferenceKey = "lastSubscribedTimestampPreferenceKey";

  static Future<int> getLastPushSecond() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var signaturePreference =  prefs.getInt(lastSubscribedTimestampPreferenceKey);
    return signaturePreference == null? 0: signaturePreference;
  }

  static Future<void> _putLastPushSecond(int value) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(lastSubscribedTimestampPreferenceKey, value);
  }

  static Future<bool> shouldSendTokenToDHPushServer() async{
    int lastMobileSignTimestampSecond = await getLastPushSecond();
    DateTime lastPushDate = DateTime.fromMillisecondsSinceEpoch(lastMobileSignTimestampSecond * 1000);
    DateTime now = DateTime.now();
    // since last two days?
    if (now.difference(lastPushDate).inHours > 12){
      // if not in the same day, a mobile sign is neccessary
      return true;
    }
    else{
      return false;
    }
  }

  static Future<void> putLastPushSecond() async{
    int nowTimestampSecond = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await _putLastPushSecond(nowTimestampSecond);
  }

  static Future<bool> shouldRememberDiscuzPassword(Discuz discuz) async {
    String discuzForumFidsKey = "discuz_password_remember_${discuz.baseURL}";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var signaturePreference =  prefs.getBool(discuzForumFidsKey);
    return signaturePreference == null? false : signaturePreference;
  }

  static Future<void> putShouldRememberDiscuzPassword(Discuz discuz, bool value) async{
    String discuzForumFidsKey = "discuz_password_remember_${discuz.baseURL}";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(discuzForumFidsKey, value);
  }

  static final String typographyThemePreferenceKey = "typographyThemePreferenceKey";

  static Future<void> putTypographyThemePreference(String typography) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(typographyThemePreferenceKey, typography);
  }

  static Future<String?> getTypographyThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var brightness =  prefs.getString(typographyThemePreferenceKey);
    return brightness;
  }

  static final String useThinFontPreferenceKey = "useThinFontPreferenceKey";

  static Future<void> putUseThinFontPreference(bool value) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(useThinFontPreferenceKey, value);
  }

  static Future<bool> getUseThinFontPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? value =  prefs.getBool(useThinFontPreferenceKey);
    return value == null? false: value;
  }

  static final String useCompactParagraphPreferenceKey = "useCompactParagraphPreferenceKey";

  static Future<void> putUseCompactParagraphPreference(bool value) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(useCompactParagraphPreferenceKey, value);
  }

  static Future<bool> getUseCompactParagraphPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? value =  prefs.getBool(useCompactParagraphPreferenceKey);
    return value == null? true: value;
  }

  static Future<String> getDiscuzSmileyCacheJson(Discuz discuz) async {
    String discuzSmileyCacheJsonKey = "discuz_simley_caches_${discuz.baseURL}";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var string =  prefs.getString(discuzSmileyCacheJsonKey);
    return string == null? "": string;
  }

  static Future<void> putDiscuzSmileyCacheJson(Discuz discuz,String value) async{
    String discuzSmileyCacheJsonKey = "discuz_simley_caches_${discuz.baseURL}";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(discuzSmileyCacheJsonKey, value);
  }


  static final String interfaceDynamicSchemeVariantPreferenceKey = "interfaceDynamicSchemeVariantPreferenceKey";
  static Future<void> putInterfaceDynamicSchemeVariantPreference(DynamicSchemeVariant dynamicVariant) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String dynamicVariantString = "totalSpot";
    switch (dynamicVariant){
      case DynamicSchemeVariant.tonalSpot:{
        dynamicVariantString = "totalSpot";
        break;
      }

      case DynamicSchemeVariant.fidelity:{
        dynamicVariantString = "fidelity";
        break;
      }
      case DynamicSchemeVariant.monochrome:{
        dynamicVariantString = "monochrome";
        break;
      }
      case DynamicSchemeVariant.neutral:{
        dynamicVariantString = "neutral";
        break;
      }
      case DynamicSchemeVariant.vibrant:{
        dynamicVariantString = "vibrant";
        break;
      }
      case DynamicSchemeVariant.expressive:{
        dynamicVariantString = "expressive";
        break;
      }
      case DynamicSchemeVariant.content:{
        dynamicVariantString = "content";
        break;
      }
      case DynamicSchemeVariant.rainbow:{
        dynamicVariantString = "rainbow";
        break;
      }
      case DynamicSchemeVariant.fruitSalad:{
        dynamicVariantString = "fruitSalad";
        break;
      }
    }
    await prefs.setString(interfaceDynamicSchemeVariantPreferenceKey, dynamicVariantString);
  }

  static Future<String?> getInterfaceDynamicSchemeVariantStringPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var brightness =  prefs.getString(interfaceDynamicSchemeVariantPreferenceKey);
    return brightness;
  }

  static Future<DynamicSchemeVariant> getInterfaceDynamicSchemeVariantPreference() async {
    String? dynamicVariantString = await getInterfaceDynamicSchemeVariantStringPreference();
    switch (dynamicVariantString){
      case "tonalSpot": return DynamicSchemeVariant.tonalSpot;
      case "fidelity": return DynamicSchemeVariant.fidelity;
      case "monochrome" : return DynamicSchemeVariant.monochrome;
      case "neutral" : return DynamicSchemeVariant.neutral;
      case "vibrant" : return DynamicSchemeVariant.vibrant;
      case "expressive" : return DynamicSchemeVariant.expressive;
      case "content" : return DynamicSchemeVariant.content;
      case "rainbow" : return DynamicSchemeVariant.rainbow;
      case "fruitSalad" : return DynamicSchemeVariant.fruitSalad;
      default:
        return DynamicSchemeVariant.tonalSpot;
    }
  }

  static Future<String> getDiscuzPortalResultCacheJson(Discuz discuz) async {
    String discuzSmileyCacheJsonKey = "discuz_portal_caches_${discuz.baseURL}";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var string =  prefs.getString(discuzSmileyCacheJsonKey);
    return string == null? "": string;
  }

  static Future<void> putDiscuzPortalResultCacheJson(Discuz discuz,String value) async{
    String discuzSmileyCacheJsonKey = "discuz_portal_caches_${discuz.baseURL}";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(discuzSmileyCacheJsonKey, value);
  }

  static Future<int> getLastReportAnalyticsTime() async {
    String discuzForumFidsKey = "discuz_last_report_in_analytics";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var signaturePreference =  prefs.getInt(discuzForumFidsKey);
    return signaturePreference == null? 0: signaturePreference;
  }

  static Future<void> _putLastReportAnalyticsTime(int value) async{
    String discuzForumFidsKey = "discuz_last_report_in_analytics";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(discuzForumFidsKey, value);
  }

  static Future<void> putLastReportAnalyticsTime() async{
    int nowTimestampSecond = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    _putLastReportAnalyticsTime(nowTimestampSecond);
  }

  static Future<bool> shouldReportAnalytics() async{
    int lastMobileSignTimestampSecond = await getLastReportAnalyticsTime();
    DateTime lastSignDate = DateTime.fromMillisecondsSinceEpoch(lastMobileSignTimestampSecond * 1000);
    DateTime now = DateTime.now();

    if (!isTheSameDay(lastSignDate, now)){
      // if not in the same day, a mobile sign is neccessary
      return true;
    }
    else{
      return false;
    }
  }

  static Future<String> getSupportDiscuzListResultCacheJson() async {
    String discuzSmileyCacheJsonKey = "discuz_support_list_caches";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var string =  prefs.getString(discuzSmileyCacheJsonKey);
    return string == null? "": string;
  }

  static Future<void> putSupportDiscuzListResultCacheJson(String value) async{
    String discuzSmileyCacheJsonKey = "discuz_support_list_caches";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(discuzSmileyCacheJsonKey, value);
  }

  static Future<String> getDiscuzPrivateMessageResultCacheJson(Discuz discuz, User user) async {
    String discuzSmileyCacheJsonKey = "discuz_private_message_caches_${discuz.baseURL}_${user.uid}";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var string =  prefs.getString(discuzSmileyCacheJsonKey);
    return string == null? "": string;
  }

  static Future<void> putDiscuzPrivateMessageResultCacheJson(Discuz discuz, User user,String value) async{
    String discuzSmileyCacheJsonKey = "discuz_private_message_caches_${discuz.baseURL}_${user.uid}";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(discuzSmileyCacheJsonKey, value);
  }

  static final String adExemptDiscuzHostPreferenceKey = "adExemptDiscuzHostPreferenceKey";

  static Future<void> putAdExemptDiscuzHostPreference(String value) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(adExemptDiscuzHostPreferenceKey, value);
  }

  static Future<String> getAdExemptDiscuzHostPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? value =  prefs.getString(adExemptDiscuzHostPreferenceKey);
    return value == null? "": value;
  }

  static Future<int> getLastRegisterSubscriptionTime() async {
    String discuzForumFidsKey = "dh_push_subscription_last_time";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var signaturePreference =  prefs.getInt(discuzForumFidsKey);
    return signaturePreference == null? 0: signaturePreference;
  }

  static Future<void> _putRegisterSubscriptionTime(int value) async{
    String discuzForumFidsKey = "dh_push_subscription_last_time";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(discuzForumFidsKey, value);
  }

  static Future<void> putRegisterSubscriptionTime() async{
    int nowTimestampSecond = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    _putRegisterSubscriptionTime(nowTimestampSecond);
  }

  static Future<bool> shouldRegisterSubscription() async{
    int lastMobileSignTimestampSecond = await getLastRegisterSubscriptionTime();
    DateTime lastSignDate = DateTime.fromMillisecondsSinceEpoch(lastMobileSignTimestampSecond * 1000);
    DateTime now = DateTime.now();

    if (!isTheSameDay(lastSignDate, now)){
      // if not in the same day, a mobile sign is neccessary
      return true;
    }
    else{
      return false;
    }
  }

}