
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

class ChooseThemeColorPage extends StatefulWidget {
  @override
  _ChooseThemeColorState createState() => _ChooseThemeColorState();
}

class _ChooseThemeColorState extends State<ChooseThemeColorPage> {

  DynamicSchemeVariant dynamicSchemeVariant = DynamicSchemeVariant.fidelity;
  FlexScheme _selectedThemeColor = FlexScheme.blue;
  String _selectedBrightnessName = "";

  Widget getLeadingCircleWidget(BuildContext context, Color color){
    return Container(

      width: 12,
      height: 12,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: color
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    //_selectedColorName = Provider.of<ThemeNotifierProvider>(context,listen: false).themeColorName;

    _selectedThemeColor = Provider.of<ThemeNotifierProvider>(context,listen: false).themeColor;
    final ThemeMode themeMode;
    final ValueChanged<ThemeMode> onThemeModeChanged;
    final bool useMaterial3;
    final ValueChanged<bool> onUseMaterial3Changed;
    //final FlexSchemeData flexSchemeData = FlexSchemeData();

    final ThemeData theme = Theme.of(context);
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
      iosContentPadding: true,
      appBar: PlatformAppBar(
        //title: Text(S.of(context).chooseThemeTitle),
        title: Text(_selectedThemeColor.name.toUpperCase()),

      ),
      body: SettingsList(
        sections: [
          CustomSettingsSection(
              child: Container(
                padding: EdgeInsets.all(4.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  //primary: true,
                  children: <Widget>[
                    // A 3-way theme mode toggle switch that shows the color scheme.
                    FlexThemeModeSwitch(
                      themeMode: ThemeMode.system,
                      title: Text(S.of(context).interfaceBrightness, style: TextStyle(fontSize: 16),),
                      labelLight: S.of(context).brightnessLight.toUpperCase(),
                      labelDark: S.of(context).brightnessDark.toUpperCase(),
                      labelSystem: S.of(context).followSystem.toUpperCase(),
                      onThemeModeChanged: (themeMode){
                        // not mention
                        switch (themeMode){
                          case ThemeMode.light:
                            changePlatform("light");
                            break;
                          case ThemeMode.dark:
                            changePlatform("dark");
                            break;
                          case ThemeMode.system:
                            changePlatform("");
                            break;
                        }

                      },
                      flexSchemeData: _selectedThemeColor.data,
                      buttonOrder: FlexThemeModeButtonOrder.lightSystemDark,
                    ),
                    // Show theme name and description.
                    // ListTile(
                    //   contentPadding: EdgeInsets.zero,
                    //   title: Text('${_selectedThemeColor.data.name} theme'),
                    //   subtitle: Text(_selectedThemeColor.data.description),
                    // ),

                    GridView.count(
                        primary: false,
                        crossAxisCount: 5,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 5,
                        crossAxisSpacing: 5,
                        children: FlexScheme.values.map((flexScheme){
                          return FlexSchemeCard(
                              flexScheme,
                              (){
                                changeColor(flexScheme);
                                VibrationUtils.vibrateWithClickIfPossible();
                              }
                          );
                        }).toList(),
                    ),
                  ],
                ),
              ),
          ),
        ],
      ),
    );
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

  void changeColor(FlexScheme colorValue) {
    setState(() {
      _selectedThemeColor = colorValue;
    });
    print("change theme color to $colorValue");

    Provider.of<ThemeNotifierProvider>(context,listen: false).setTheme(colorValue);
    List<FlexScheme> flexSchemeList = FlexScheme.values;
    UserPreferencesUtils.putThemeColor(flexSchemeList.indexOf(colorValue));
    VibrationUtils.vibrateSuccessfullyIfPossible();

    CustomizeColor.updateAndroidNavigationbar(context);

  }
}

class FlexSchemeCard extends StatelessWidget{

  FlexScheme flexScheme;
  GestureTapCallback gestureTapCallback;
  FlexSchemeCard(this.flexScheme, this.gestureTapCallback);

  @override
  Widget build(BuildContext context) {
    FlexSchemeColor flexSchemeColor = flexScheme.data.light;
    if(Theme.of(context).brightness == Brightness.dark){
      flexSchemeColor = flexScheme.data.dark;
    }
    
    return Consumer<ThemeNotifierProvider>(builder: (context, theme, child){
        bool isSelected = theme.themeColor == flexScheme;
        return InkWell(
          onTap: (){
            gestureTapCallback();
          },
          child: Container(
            margin: EdgeInsets.all(0.0),
            padding: EdgeInsets.all(4.0),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: isSelected? Border.all(color: flexSchemeColor.primary, width: 2):null,
            ),
            child: Container(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: GridView.count(
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                children: [
                  SizedBox(
                    child: Container(
                      color: flexSchemeColor.primary,
                    ),
                  ),
                  SizedBox(
                    child: Container(
                      color: flexSchemeColor.secondary,
                    ),
                  ),
                  SizedBox(

                    child: Container(
                      color: flexSchemeColor.appBarColor,
                    ),
                  ),
                  SizedBox(

                    child: Container(
                      color: flexSchemeColor.primaryContainer,
                    ),
                  ),
                ],
              ),
            ),

          ),
        );
    });
  }
}