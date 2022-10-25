

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/Smiley.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PostTextField extends StatefulWidget{

  Discuz _discuz;
  TextEditingController _controller;
  FocusNode focusNode;
  bool? expanded;

  PostTextField(this._discuz,this._controller,{required this.focusNode, this.expanded});



  @override
  PostTextFieldState createState() {
    return PostTextFieldState(this._discuz,this._controller,focusNode: focusNode, expanded: this.expanded);
  }
}

class PostTextFieldState extends State<PostTextField>{
  TextEditingController _controller;

  Discuz _discuz;
  FocusNode focusNode;
  bool? expanded;

  PostTextFieldState(this._discuz, this._controller,{required this.focusNode, this.expanded});

  @override
  Widget build(BuildContext context) {
    return ExtendedTextField(
      controller: _controller,
      specialTextSpanBuilder: PostSpecialTextSpanBuilder(_discuz),
      selectionControls: MaterialTextSelectionControls(),
      focusNode: focusNode,
      minLines: expanded  == null? 1: null,
      maxLines: expanded  == null?3:null,
      expands: expanded == null? false: true,
      decoration: InputDecoration(
        hintText: S.of(context).sendReplyHint,
      ),

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
        imageWidth: 20,
        imageHeight: 20,
        start: this.start,
        actualText: toString(),
    );
  }
  
  
}


class AttachImageText extends SpecialText{
  Discuz _discuz;
  static String attachStartFlag = "[attachimg]";
  static String attachEndFlag = "[/attachimg]";
  int start;

  AttachImageText(this._discuz, TextStyle textStyle,{required this.start}) : super(AttachImageText.attachStartFlag, AttachImageText.attachEndFlag, textStyle);


  get aid => getContent();


  @override
  InlineSpan finishText() {
    return BackgroundTextSpan(
      text: " 📃 ${aid} ",
      background: Paint()..color = Colors.blue.withOpacity(0.15),
      actualText: toString(),
      start: start,
      style: TextStyle(color: Colors.blue),

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
      if(isStart(flag, AttachImageText.attachStartFlag)){
        return AttachImageText(_discuz, textStyle!,start: index-(AttachImageText.attachStartFlag.length-1));
      }
      else if(isStart(flag, SmileyText.smileyStartFlag)){
        return SmileyText(_discuz, textStyle!,start: index-(SmileyText.smileyStartFlag.length-1));
      }
      else{
        return null;
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



