

import 'dart:developer';

import 'package:discuz_flutter/screen/BlankScreen.dart';
import 'package:discuz_flutter/utility/PostTextFieldUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

import '../generated/l10n.dart';
import '../utility/UserPreferencesUtils.dart';

class SelectSignatureStylePage extends StatefulWidget{
  @override
  SelectSignatureStyleState createState() {
    return SelectSignatureStyleState();
  }

}

class SelectSignatureStyleState extends State<SelectSignatureStylePage>{

  String deviceSignature = "";
  String signature = "";
  TextEditingController controller = TextEditingController();

  void setSignature(String string){
    setState((){
      signature = string;
    });
    UserPreferencesUtils.putSignaturePreference(string);
  }

  void initState(){
    _loadDeviceName();
    super.initState();
  }

  void _loadDeviceName() async{

    String? _deviceSignature = await PostTextFieldUtils.getDeviceName(context);
    setState((){
      deviceSignature = _deviceSignature == null? "": _deviceSignature;
    });
    String? signatureInPreference = await UserPreferencesUtils.getSignaturePreference();
    if(signatureInPreference == null){
      setSignature(PostTextFieldUtils.NO_SIGNATURE);
    }
    else{
      setSignature(signatureInPreference);
      log("Get signature $signatureInPreference");
      if(signatureInPreference != PostTextFieldUtils.USE_DEVICE_SIGNATURE){
        controller.text= signatureInPreference;
      }
    }

  }

  @override
  Widget build(BuildContext context) {

    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(S.of(context).signatureStyle),
      ),
      body: Column(
        children: [
          SettingsList(
            shrinkWrap: true,
            sections: [
              SettingsSection(
                tiles: [

                  SettingsTile(
                    title: S.of(context).noSignature,
                    trailing: signature == PostTextFieldUtils.NO_SIGNATURE ?Icon(PlatformIcons(context).checkMark, color: Theme.of(context).primaryColor,): Icon(null),
                    onPressed: (BuildContext context){
                      VibrationUtils.vibrateWithClickIfPossible();
                      setSignature(PostTextFieldUtils.NO_SIGNATURE);
                    },
                  ),
                  SettingsTile(
                    title: S.of(context).deviceNameSignature,
                    subtitle: deviceSignature,
                    trailing: signature == PostTextFieldUtils.USE_DEVICE_SIGNATURE?Icon(PlatformIcons(context).checkMark, color: Theme.of(context).primaryColor):Icon(null),
                    onPressed: (BuildContext context){
                      VibrationUtils.vibrateWithClickIfPossible();
                      setSignature(PostTextFieldUtils.USE_DEVICE_SIGNATURE);
                    },
                  ),
                  SettingsTile(
                    title: S.of(context).customSignature,
                    trailing: (signature != PostTextFieldUtils.NO_SIGNATURE && signature != PostTextFieldUtils.USE_DEVICE_SIGNATURE)?
                    Icon(PlatformIcons(context).checkMark, color: Theme.of(context).primaryColor):
                    Icon(null),
                    onPressed: (BuildContext context){
                      VibrationUtils.vibrateWithClickIfPossible();
                      setSignature(" ");
                    },
                  ),

                ],

              )
            ],
          ),
          SizedBox(height: 8,),
          if(signature!= PostTextFieldUtils.NO_SIGNATURE && signature!= PostTextFieldUtils.USE_DEVICE_SIGNATURE)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: PlatformTextField(
              enabled: (signature!= PostTextFieldUtils.NO_SIGNATURE && signature!= PostTextFieldUtils.USE_DEVICE_SIGNATURE),
              hintText: S.of(context).signatureHint,
              onChanged: (String string){
                if(string != signature){
                  setSignature(string);
                }

              },
              controller: controller,

            ),
          ),

        ],
      ),
    );


  }


}