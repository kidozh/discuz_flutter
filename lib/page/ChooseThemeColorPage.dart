import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

class ChooseThemeColorPage extends StatefulWidget {
  @override
  _ChooseThemeColorState createState() => _ChooseThemeColorState();
}

class _ChooseThemeColorState extends State<ChooseThemeColorPage> {

  int _selectedColorValue = Colors.blue.value;

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

    _selectedColorValue = Provider.of<ThemeNotifierProvider>(context,listen: false).themeColor.value;

    return PlatformScaffold(
      iosContentPadding: true,
      appBar: PlatformAppBar(
        title: Text(S.of(context).chooseThemeTitle),

      ),
      body: SettingsList(
        sections: [
          CustomSettingsSection(
              child: ColorPicker(
                color: Color(_selectedColorValue),
                onColorChanged: (Color color) {
                  setState(() {
                    _selectedColorValue = color.value;
                  });

                  changeColor(color.value);

                },
                // heading: Text(
                //   S.of(context).selectColorTitle,
                //   style: Theme.of(context).textTheme.headlineSmall,
                // ),
                subheading: Text(
                  S.of(context).selectColorShadeTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                wheelSubheading: Text(
                  S.of(context).selectColorAndShadeTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                showMaterialName: true,
                showColorName: true,
                showColorCode: true,
                copyPasteBehavior: const ColorPickerCopyPasteBehavior(
                  longPressMenu: true,
                ),
                materialNameTextStyle: Theme.of(context).textTheme.bodySmall,
                colorNameTextStyle: Theme.of(context).textTheme.bodySmall,
                colorCodeTextStyle: Theme.of(context).textTheme.bodySmall,
                pickersEnabled: const <ColorPickerType, bool>{
                  ColorPickerType.both: true,
                  ColorPickerType.primary: false,
                  ColorPickerType.accent: false,
                  ColorPickerType.bw: false,
                  ColorPickerType.custom: true,
                  ColorPickerType.wheel: true,
                },
                pickerTypeLabels: <ColorPickerType, String>{
                  ColorPickerType.primary: S.of(context).primaryColorPickerType,
                  ColorPickerType.accent: S.of(context).accentColorPickerType,
                  ColorPickerType.wheel: S.of(context).wheelColorPickerType,
                  ColorPickerType.bw: S.of(context).blackAndWhiteColorPickerType,
                  ColorPickerType.both: S.of(context).bothColorPickerType
                },
                selectedColorIcon: AppPlatformIcons(context).check,

              ),
          ),
        ],
      ),
    );
  }

  // Widget trailingWidget(String colorName) {
  //   return ( _selectedColorName == colorName)
  //       ? Icon(PlatformIcons(context).checkMark, color: Theme.of(context).colorScheme.primary)
  //       : Icon(null);
  // }

  void changeColor(int colorValue) {
    setState(() {
      _selectedColorValue = colorValue;
    });
    print("change theme color to $colorValue");

    Provider.of<ThemeNotifierProvider>(context,listen: false).setTheme(colorValue);
    UserPreferencesUtils.putThemeColor(colorValue);
    VibrationUtils.vibrateSuccessfullyIfPossible();
  }
}