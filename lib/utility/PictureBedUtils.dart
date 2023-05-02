

import 'package:shared_preferences/shared_preferences.dart';

class PictureBedUtils{
  static String _SMMS_KEY = "SMMS";
  static String _TERM_OF_USE_ACCEPTED = "TERM_OF_USE_ACCEPTED";

  static String SMMS_TERM_OF_USE_ACCEPTED = "${_SMMS_KEY}_${_TERM_OF_USE_ACCEPTED}";

  static Future<bool> isSMMSTermAccepted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var isSMMSTermAccepted =  prefs.getBool(SMMS_TERM_OF_USE_ACCEPTED);
    return isSMMSTermAccepted == null? false: isSMMSTermAccepted;
  }

  static Future<void> setSMMSTermAccepted(bool value) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SMMS_TERM_OF_USE_ACCEPTED, value);
  }
}