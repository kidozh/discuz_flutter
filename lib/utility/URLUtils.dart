
import 'dart:io';

import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:url_launcher/url_launcher.dart';

class URLUtils{
  static String getAvatarURL(Discuz discuz, String uid){
    return "${discuz.uCenterURL}/avatar.php?uid=${uid}&size=big";
  }

  static String getLargeAvatarURL(Discuz discuz, String uid){
    return "${discuz.uCenterURL}/avatar.php?uid=${uid}&size=middle";
  }

  static String getSmallAvatarURL(Discuz discuz, String uid){
    return "${discuz.uCenterURL}/avatar.php?uid=${uid}&size=small";
  }

  static String getAttachmentURLWithAidEncode(Discuz discuz, String aid){
    return "${discuz.baseURL}/forum.php?mod=attachment&aid=${aid}";
  }

  static String getViewThreadURL(Discuz discuz, int tid){
    return "${discuz.baseURL}/forum.php?mod=viewthread&tid=${tid}";
  }

  static String getForumDisplayURL(Discuz discuz, int fid){
    return "${discuz.baseURL}/forum.php?mod=forumdisplay&fid=${fid}";
  }

  static Future<void> launchURL(String url) async => await canLaunchUrl(Uri.parse(url))
      ? await launchUrl(Uri.parse(url), mode: Platform.isIOS? LaunchMode.inAppWebView: LaunchMode.externalApplication)
      : throw 'Could not launch $url';
}