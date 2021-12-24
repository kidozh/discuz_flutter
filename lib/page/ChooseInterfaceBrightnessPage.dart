import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

class ChooseInterfaceBrightnessPage extends StatefulWidget {
  @override
  _ChooseInterfaceBrightnessState createState() => _ChooseInterfaceBrightnessState();
}

class _ChooseInterfaceBrightnessState extends State<ChooseInterfaceBrightnessPage> {

  String _selectedBrightnessName = "";



  @override
  Widget build(BuildContext context) {

    Brightness? _selectedBrightness = Provider.of<ThemeNotifierProvider>(context,listen: false).brightness;
    if(_selectedBrightness == null){
      _selectedBrightnessName = "";
    }
    else if(_selectedBrightness == Brightness.light){
      _selectedBrightnessName = "light";
    }
    else if(_selectedBrightness == Brightness.dark){
      _selectedBrightnessName = "dark";
    }
    else{
      _selectedBrightnessName = "";
    }




    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(S.of(context).interfaceBrightness),
      ),
      body: SettingsList(
        sections: [

          SettingsSection(tiles: [
            SettingsTile(
              title: S.of(context).followSystem,
              trailing: trailingWidget(""),
              onPressed: (BuildContext context) {

                changePlatform("");
              },
            ),
            SettingsTile(
              title: S.of(context).brightnessLight,
              trailing: trailingWidget("light"),
              onPressed: (BuildContext context) {
                changePlatform("light");
              },
            ),
            SettingsTile(
              title: S.of(context).brightnessDark,
              trailing: trailingWidget("dark"),
              onPressed: (BuildContext context) {
                changePlatform("dark");
              },
            ),
            
          ]),
          CustomSection(child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                child: Text(S.of(context).iosDarkModeDisabledText, style: Theme.of(context).textTheme.bodyText2),

              )

            ],
          ))
        ],
      ),
    );
  }

  Widget trailingWidget(String brightnessName) {
    return ( _selectedBrightnessName == brightnessName)
        ? Icon(PlatformIcons(context).checkMark, color: Theme.of(context).primaryColor)
        : Icon(null);
  }

  void changePlatform(String brightnessName) {
    setState(() {
      _selectedBrightnessName = brightnessName;
    });
    print("change brightness to $brightnessName");
    Brightness? brightness;
    if(brightnessName == ""){
      brightness = null;
    }
    else if(brightnessName == "light"){
      brightness = Brightness.light;
    }
    else if(brightnessName == "dark"){
      brightness = Brightness.dark;
    }
    else{
      brightness = null;
    }

    Provider.of<ThemeNotifierProvider>(context,listen: false).setBrightness(brightness);
    UserPreferencesUtils.putInterfaceBrightnessPreference(brightnessName);
    VibrationUtils.vibrateSuccessfullyIfPossible();
  }
}