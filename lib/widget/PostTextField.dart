

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/JsonResult/SmileyResult.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PostTextField extends StatefulWidget{

  Discuz _discuz;
  TextEditingController _controller;
  FocusNode focusNode;

  PostTextField(this._discuz,this._controller,{required this.focusNode});



  @override
  PostTextFieldState createState() {
    return PostTextFieldState(this._discuz,this._controller,focusNode: focusNode);
  }
}

class PostTextFieldState extends State<PostTextField>{
  TextEditingController _controller;

  Discuz _discuz;
  FocusNode focusNode;

  PostTextFieldState(this._discuz, this._controller,{required this.focusNode});

  @override
  Widget build(BuildContext context) {
    return ExtendedTextField(
      controller: _controller,
      specialTextSpanBuilder: PostSpecialTextSpanBuilder(_discuz),
      selectionControls: MaterialTextSelectionControls(),
      focusNode: focusNode,
    );
  }



}

class SmileyText extends SpecialText{
  Discuz _discuz;
  static String smileyStartFlag = "[smiley]";
  static String smileyEndFlag = "[/smiley]";
  int start;
  
  SmileyText(this._discuz, TextStyle textStyle,{required this.start}) : super(SmileyText.smileyStartFlag, SmileyText.smileyEndFlag, textStyle);

  get  smiley => Smiley.fromJson(jsonDecode(getContent()));

  get smileyCode {
    Smiley smileyObj = smiley;
    return smileyObj.code.replaceAll(r"\:", ":").replaceAll(r"\{", "{").replaceAll(r"\}", "}");
  }
  
  @override
  InlineSpan finishText() {
    return ImageSpan(
        CachedNetworkImageProvider(_discuz.baseURL+"/static/image/smiley/"+smiley.relativePath),
        imageWidth: 16,
        imageHeight: 16,
        start: this.start,
        actualText: toString(),


    );
  }
  
  
}

class PostSpecialTextSpanBuilder extends SpecialTextSpanBuilder{
  Discuz _discuz;

  PostSpecialTextSpanBuilder(this._discuz);

  @override
  SpecialText? createSpecialText(String flag, {TextStyle? textStyle, SpecialTextGestureTapCallback? onTap, required int index}) {
    if(flag == ""){
      return null;
    }
    else{
      if(isStart(flag, SmileyText.smileyStartFlag)){
        return SmileyText(_discuz, textStyle!,start: index-(SmileyText.smileyStartFlag.length-1));
      }

    }

  }

  @override
  TextSpan build(String data, {TextStyle? textStyle, SpecialTextGestureTapCallback? onTap}) {
    if(kIsWeb){
      return TextSpan(text: data,style: textStyle);
    }
    return super.build(data, textStyle: textStyle, onTap: onTap);
  }

}



