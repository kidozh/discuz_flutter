

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/JsonResult/SmileyResult.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PostTextField extends StatefulWidget{

  Discuz _discuz;

  PostTextField(this._discuz);

  @override
  PostTextFieldState createState() {
    return PostTextFieldState(this._discuz);
  }
}

class PostTextFieldState extends State<PostTextField>{
  TextEditingController _controller = TextEditingController();

  Discuz _discuz;

  PostTextFieldState(this._discuz);

  @override
  Widget build(BuildContext context) {
    return ExtendedTextField(
      controller: _controller,
      
    );
  }

  void insertSmiley(Smiley smiley){

  }

}

class SmileyText extends SpecialText{
  Discuz _discuz;
  static String smileyStartFlag = "[smiley]";
  static String smileyEndFlag = "[/smiley]";
  
  SmileyText(this._discuz,TextStyle textStyle) : super(SmileyText.smileyStartFlag, SmileyText.smileyEndFlag, textStyle);

  get smiley => Smiley.fromJson(jsonDecode(getContent()));
  
  @override
  InlineSpan finishText() {

    return ImageSpan(
        CachedNetworkImageProvider(_discuz.baseURL+"/static/image/smiley/"+smiley.relativePath),
        imageWidth: 16,
        imageHeight: 16,
        actualText: smiley.code
    );
  }
  
  
}

class PostSpecialTextSpanBuilder extends SpecialTextSpanBuilder{
  Discuz _discuz;

  PostSpecialTextSpanBuilder(this._discuz);

  @override
  SpecialText? createSpecialText(String flag, {TextStyle? textStyle, SpecialTextGestureTapCallback? onTap, required int index}) {
    if(flag == null || flag == ""){
      return null;
    }
    else{
      if(isStart(flag, SmileyText.smileyStartFlag)){
        return SmileyText(_discuz, textStyle!);
      }

    }

  }

}