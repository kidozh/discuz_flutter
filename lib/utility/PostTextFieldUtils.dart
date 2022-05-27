

import 'dart:convert';
import 'dart:developer';
import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:discuz_flutter/JsonResult/SmileyResult.dart';
import 'package:discuz_flutter/entity/Smiley.dart';
import 'package:discuz_flutter/widget/PostTextField.dart';
import 'package:flutter/widgets.dart';

import '../generated/l10n.dart';

class PostTextFieldUtils{

  static String getPostMessage(String message){
    // filter smiley tag first [smiley].*?[/smiley]
    //String replaceRegexString = SmileyText.smileyStartFlag.replaceAll("", replace)+"(.*?)"+SmileyText.smileyEndFlag;
    RegExp replaceRegex = RegExp(r"\[smiley\](.*?)\[/smiley\]",multiLine: true);
    if(replaceRegex.hasMatch(message)){
      // contain
      log("contains regex ${message}");
      String replacementString = message;
      for(var matchCase in replaceRegex.allMatches(message)){
        if(matchCase.groupCount == 1){
          String actualString = matchCase.group(0)!;
          String smileyJsonString = matchCase.group(1)!;
          // parse json to obj
          Smiley smiley = Smiley.fromJson(jsonDecode(smileyJsonString));
          String smileyCode = smiley.code.replaceAll(r"\", "").replaceAll("/", "");
          replacementString = replacementString.replaceAll(actualString, smileyCode);
        }
        
      }
      message = replacementString;
    }
    return message;
  }

  static Future<String> getDeviceName(BuildContext context) async{
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if(Platform.isAndroid){
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.model == null? "": androidInfo.model!;
    }
    else if(Platform.isIOS){
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.name== null? "": iosInfo.name!;
    }
    else if(Platform.isWindows){
      WindowsDeviceInfo windowsDeviceInfo = await deviceInfo.windowsInfo;
      return S.of(context).windowsDeviceName(windowsDeviceInfo.computerName);
    }
    else if(Platform.isLinux){
      LinuxDeviceInfo linuxDeviceInfo = await deviceInfo.linuxInfo;
      return S.of(context).linuxDeviceName(linuxDeviceInfo.name);
    }
    else if(Platform.isMacOS){
      MacOsDeviceInfo macOsDeviceInfo = await deviceInfo.macOsInfo;
      return macOsDeviceInfo.model;
    }
    WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;

    return webBrowserInfo.userAgent == null? "":webBrowserInfo.userAgent!;
  }

  static const String USE_DEVICE_SIGNATURE = "USE_DEVICE_SIGNATURE";
  static const String NO_SIGNATURE = "";

}