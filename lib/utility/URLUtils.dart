
import 'package:discuz_flutter/entity/Discuz.dart';

class URLUtils{
  static String getAvatarURL(Discuz discuz, String uid){
    return "${discuz.uCenterURL}/avatar.php?uid=${uid}";
  }
}