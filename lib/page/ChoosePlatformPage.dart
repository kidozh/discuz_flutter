import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

class ChoosePlatformPage extends StatefulWidget {
  @override
  _ChoosePlatformState createState() => _ChoosePlatformState();
}

class _ChoosePlatformState extends State<ChoosePlatformPage> {

  String _selectedPlatformName = "";

  @override
  Widget build(BuildContext context) {

    _selectedPlatformName = Provider.of<ThemeNotifierProvider>(context,listen: false).platformName;

    return PlatformScaffold(
      iosContentPadding: true,
      appBar: PlatformAppBar(
        title: Text(S.of(context).appearanceOptimizedPlatform),
      ),
      body: SettingsList(
        sections: [

          SettingsSection(tiles: [
            SettingsTile(
              title: Text(S.of(context).followSystem),
              trailing: trailingWidget(""),
              onPressed: (BuildContext context) {

                changePlatform("");
              },
            ),
            SettingsTile(
              title: Text(S.of(context).materialDesign),
              trailing: trailingWidget("android"),
              onPressed: (BuildContext context) {
                changePlatform("android");
              },
            ),
            SettingsTile(
              title: Text(S.of(context).ios),
              trailing: trailingWidget("ios"),
              onPressed: (BuildContext context) {
                changePlatform("ios");
              },
            ),
            // SettingsTile(
            //   title: S.of(context).fuchsia,
            //   trailing: trailingWidget("fuchsia"),
            //   onPressed: (BuildContext context) {
            //     changePlatform("fuchsia");
            //   },
            // ),
            
          ]),
        ],
      ),
    );
  }

  Widget trailingWidget(String platformName) {
    return ( _selectedPlatformName == platformName)
        ? Icon(PlatformIcons(context).checkMark, color: Theme.of(context).primaryColor)
        : Icon(null);
  }

  void changePlatform(String platformName) {
    setState(() {
      _selectedPlatformName = platformName;
    });
    print("change theme color to $platformName");

    Provider.of<ThemeNotifierProvider>(context,listen: false).setPlatformName(platformName);
    UserPreferencesUtils.putPlatformPreference(platformName);

    if(PlatformProvider.of(context)!=null){
      switch (platformName){
        case "":{
          PlatformProvider.of(context)!.changeToAutoDetectPlatform();
          break;
        }
        case "ios":{
          PlatformProvider.of(context)!.changeToCupertinoPlatform();
          break;
        }
        case "android":{
          PlatformProvider.of(context)!.changeToMaterialPlatform();
          break;
        }
      }
    }
    VibrationUtils.vibrateSuccessfullyIfPossible();
  }
}