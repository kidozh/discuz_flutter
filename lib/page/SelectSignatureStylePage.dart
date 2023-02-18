

import 'dart:developer';

import 'package:discuz_flutter/utility/PostTextFieldUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

import '../generated/l10n.dart';
import '../provider/UserPreferenceNotifierProvider.dart';
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
    // update provider
    Provider.of<UserPreferenceNotifierProvider>(context,listen: false).signature = signature;
    log("New signature ${signature}");
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
      iosContentPadding: true,
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

                  SettingsTile.navigation(
                    title: Text(S.of(context).noSignature),
                    trailing: signature == PostTextFieldUtils.NO_SIGNATURE ?Icon(PlatformIcons(context).checkMark, color: Theme.of(context).colorScheme.primary,): Icon(null),
                    onPressed: (BuildContext context){
                      VibrationUtils.vibrateWithClickIfPossible();
                      setSignature(PostTextFieldUtils.NO_SIGNATURE);
                    },
                  ),
                  SettingsTile.navigation(
                    title: Text(S.of(context).deviceNameSignature+" (${deviceSignature})"),
                    //value: Text(deviceSignature),
                    trailing: signature == PostTextFieldUtils.USE_DEVICE_SIGNATURE?Icon(PlatformIcons(context).checkMark, color: Theme.of(context).colorScheme.primary):Icon(null),
                    onPressed: (BuildContext context){
                      VibrationUtils.vibrateWithClickIfPossible();
                      setSignature(PostTextFieldUtils.USE_DEVICE_SIGNATURE);
                    },
                  ),
                  SettingsTile.navigation(
                    title: Text(S.of(context).customSignature),
                    trailing: (signature != PostTextFieldUtils.NO_SIGNATURE && signature != PostTextFieldUtils.USE_DEVICE_SIGNATURE)?
                    Icon(PlatformIcons(context).checkMark, color: Theme.of(context).colorScheme.primary):
                    Icon(null),
                    onPressed: (BuildContext context){
                      VibrationUtils.vibrateWithClickIfPossible();
                      setSignature(" ");
                    },
                  ),


                ],

              ),
              if(signature!= PostTextFieldUtils.NO_SIGNATURE && signature!= PostTextFieldUtils.USE_DEVICE_SIGNATURE)
                CustomSettingsSection(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
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
                    )

                ),
            ],
          ),
        ],
      ),
    );


  }


}