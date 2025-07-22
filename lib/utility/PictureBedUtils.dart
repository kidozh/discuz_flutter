import 'package:shared_preferences/shared_preferences.dart';

enum ChevertoPictureBed{
  imgloc,
  imgbb
}

class PictureBedUtils{

  static String _IMGBB_KEY = "IMGBB";
  static String _IMGLOC_KEY = "IMGLOC";
  static String _TERM_OF_USE_ACCEPTED = "TERM_OF_USE_ACCEPTED";
  static String _TOKEN = "USER_TOKEN";

  static String IMGBB_TERM_OF_USE_ACCEPTED = "${_IMGBB_KEY}_${_TERM_OF_USE_ACCEPTED}";
  static String IMGLOC_TERM_OF_USE_ACCEPTED = "${_IMGLOC_KEY}_${_TERM_OF_USE_ACCEPTED}";

  static String IMGBB_TOKEN = "${_IMGBB_KEY}_${_TOKEN}";
  static String IMGLOC_TOKEN = "${_IMGLOC_KEY}_${_TOKEN}";

  static String IMGBB_API_UPLOAD_BASE_URL = "https://api.imgbb.com/1/";
  static String IMGLOC_API_UPLOAD_BASE_URL = "https://imgloc.com/api/1/";

  static Future<bool> isImgbbTermAccepted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var isSMMSTermAccepted =  prefs.getBool(IMGBB_TERM_OF_USE_ACCEPTED);
    return isSMMSTermAccepted == null? false: isSMMSTermAccepted;
  }

  static Future<void> setImgbbTermAccepted(bool value) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(IMGBB_TERM_OF_USE_ACCEPTED, value);
  }

  static Future<bool> isImglocTermAccepted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var isSMMSTermAccepted =  prefs.getBool(IMGLOC_TERM_OF_USE_ACCEPTED);
    return isSMMSTermAccepted == null? false: isSMMSTermAccepted;
  }

  static Future<void> setImglocTermAccepted(bool value) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(IMGLOC_TERM_OF_USE_ACCEPTED, value);
  }

  static String _getChevertoApiTokenKey(ChevertoPictureBed chevertoPictureBed){
    String prefKey = "";
    switch (chevertoPictureBed){

      case ChevertoPictureBed.imgbb:
        prefKey = IMGBB_TOKEN;
        break;
      case ChevertoPictureBed.imgloc:
        prefKey = IMGLOC_TOKEN;
        break;
    }
    return prefKey;
  }

  static Future<String> getChevertoApiToken(ChevertoPictureBed chevertoPictureBed) async {
    String prefKey = _getChevertoApiTokenKey(chevertoPictureBed);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token =  prefs.getString(prefKey);
    return token == null? "": token;
  }

  static Future<void> setChevertoApiToken(ChevertoPictureBed chevertoPictureBed, String token) async{
    String prefKey = _getChevertoApiTokenKey(chevertoPictureBed);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefKey, token);
  }

}