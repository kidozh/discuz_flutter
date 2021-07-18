

import 'dart:developer';

import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RewriteRuleUtils{
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

  static String getUserProfileRewriteRuleName(Discuz discuz){
    return "ViewThread${discuz.baseURL}";
  }

  static Future<void> putUserProfileRule(Discuz discuz, String rewriteRule) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(getUserProfileRewriteRuleName(discuz), rewriteRule);
  }

  static Future<String> getUserProfileRule(Discuz discuz) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var rewriteRule =  prefs.getString(getUserProfileRewriteRuleName(discuz));
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
    String rewriteUrl = await getUserProfileRule(discuz);
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

  // the example could be space-{user}-{value}.html
  static Future<String?> findUidInURL(Discuz discuz,String url) async{
    // transfer rewrite url to regex
    String rewriteUrl = await getViewThreadRule(discuz);
    if(rewriteUrl.isEmpty){
      return null;
    }
    rewriteUrl = rewriteUrl.replaceAll("{user}", "(?<user>.+)");
    rewriteUrl = rewriteUrl.replaceAll("{value}", "(?<value>[0-9]+)");
    log("rewrite url ${rewriteUrl}");
    RegExp regExp = new RegExp(rewriteUrl);
    RegExpMatch? regExpMatch = regExp.firstMatch(url);
    log(rewriteUrl);
    if(regExpMatch == null){
      return null;
    }
    else{
      try{
        return regExpMatch.namedGroup("value");
      }
      catch(e){
        return null;
      }

    }

  }


}