

import 'dart:convert';
import 'dart:developer';

import 'package:discuz_flutter/JsonResult/SmileyResult.dart';
import 'package:discuz_flutter/entity/Smiley.dart';
import 'package:discuz_flutter/widget/PostTextField.dart';

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

}