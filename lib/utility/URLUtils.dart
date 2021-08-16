
import 'package:discuz_flutter/entity/Discuz.dart';

class URLUtils{
  static String getAvatarURL(Discuz discuz, String uid){
    return "${discuz.uCenterURL}/avatar.php?uid=${uid}&size=large";
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
}