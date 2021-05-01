
import 'package:discuz_flutter/entity/Discuz.dart';

class URLUtils{
  static String getAvatarURL(Discuz discuz, String uid){
    return "${discuz.uCenterURL}/avatar.php?uid=${uid}&size=large";
  }

  static String getAttachmentURLWithAidEncode(Discuz discuz, String aid){
    return "${discuz.baseURL}/forum.php?mod=attachment&aid=${aid}";
  }
}