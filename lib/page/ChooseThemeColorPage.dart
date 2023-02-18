import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

class ChooseThemeColorPage extends StatefulWidget {
  @override
  _ChooseThemeColorState createState() => _ChooseThemeColorState();
}

class _ChooseThemeColorState extends State<ChooseThemeColorPage> {

  String _selectedColorName = "";

  @override
  Widget build(BuildContext context) {

    _selectedColorName = Provider.of<ThemeNotifierProvider>(context,listen: false).themeColorName;

    return PlatformScaffold(
      iosContentPadding: true,
      appBar: PlatformAppBar(
        title: Text(S.of(context).chooseThemeTitle),
      ),
      body: SettingsList(
        sections: [
          // CustomSettingsSection(child: Column(
          //   children: [
          //     Padding(
          //       padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16.0),
          //       child: Text(S.of(context).iosColorSchemeSuggestions, style: Theme.of(context).textTheme.bodyText2),
          //
          //     )
          //
          //   ],
          // )),
          SettingsSection(tiles: [
            SettingsTile(
              title: Text(S.of(context).colorAmber),
              trailing: trailingWidget("amber"),
              onPressed: (BuildContext context) {
                changeColor("amber");
              },
            ),
            SettingsTile(
              title: Text(S.of(context).colorGrey),
              trailing: trailingWidget("grey"),
              onPressed: (BuildContext context) {
                changeColor("grey");
              },
            ),
            SettingsTile(
              title: Text(S.of(context).colorBlue),
              trailing: trailingWidget("blue"),
              onPressed: (BuildContext context) {
                changeColor("blue");
              },
            ),
            SettingsTile(
              title: Text(S.of(context).colorCyan),
              trailing: trailingWidget("cyan"),
              onPressed: (BuildContext context) {
                changeColor("cyan");
              },
            ),
            SettingsTile(
              title: Text(S.of(context).colorDeepPurple),
              trailing: trailingWidget("deepPurple"),
              onPressed: (BuildContext context) {
                changeColor("deepPurple");
              },
            ),
            SettingsTile(
              title: Text(S.of(context).colorDeepOrange),
              trailing: trailingWidget("deepOrange"),
              onPressed: (BuildContext context) {
                changeColor("deepOrange");
              },
            ),
            SettingsTile(
              title: Text(S.of(context).colorYellow),
              trailing: trailingWidget("yellow"),
              onPressed: (BuildContext context) {
                changeColor("yellow");
              },
            ),
            SettingsTile(
              title: Text(S.of(context).colorLime),
              trailing: trailingWidget("lime"),
              onPressed: (BuildContext context) {
                changeColor("lime");
              },
            ),
            SettingsTile(
              title: Text(S.of(context).colorGreen),
              trailing: trailingWidget("green"),
              onPressed: (BuildContext context) {
                changeColor("green");
              },
            ),
            SettingsTile(
              title: Text(S.of(context).colorIndigo),
              trailing: trailingWidget("indigo"),
              onPressed: (BuildContext context) {
                changeColor("indigo");
              },
            ),
            SettingsTile(
              title: Text(S.of(context).colorOrange),
              trailing: trailingWidget("orange"),
              onPressed: (BuildContext context) {
                changeColor("orange");
              },
            ),
            SettingsTile(
              title: Text(S.of(context).colorPurple),
              trailing: trailingWidget("purple"),
              onPressed: (BuildContext context) {
                changeColor("purple");
              },
            ),
            SettingsTile(
              title: Text(S.of(context).colorPink),
              trailing: trailingWidget("pink"),
              onPressed: (BuildContext context) {
                changeColor("pink");
              },
            ),
            SettingsTile(
              title: Text(S.of(context).colorRed),
              trailing: trailingWidget("red"),
              onPressed: (BuildContext context) {
                changeColor("red");
              },
            ),
            SettingsTile(
              title: Text(S.of(context).colorTeal),
              trailing: trailingWidget("teal"),
              onPressed: (BuildContext context) {
                changeColor("teal");
              },
            ),
            SettingsTile(
              title: Text(S.of(context).colorBrown),
              trailing: trailingWidget("brown"),
              onPressed: (BuildContext context) {
                changeColor("brown");
              },
            ),
            SettingsTile(
              title: Text(S.of(context).colorLightBlue),
              trailing: trailingWidget("lightBlue"),
              onPressed: (BuildContext context) {
                changeColor("lightBlue");
              },
            ),
            SettingsTile(
              title: Text(S.of(context).colorBlueGrey),
              trailing: trailingWidget("blueGrey"),
              onPressed: (BuildContext context) {
                changeColor("blueGrey");
              },
            ),
            SettingsTile(
              title: Text(S.of(context).colorLightGreen),
              trailing: trailingWidget("lightGreen"),
              onPressed: (BuildContext context) {
                changeColor("lightGreen");
              },
            ),
          ]),
        ],
      ),
    );
  }

  Widget trailingWidget(String colorName) {
    return ( _selectedColorName == colorName)
        ? Icon(PlatformIcons(context).checkMark, color: Theme.of(context).colorScheme.primary)
        : Icon(null);
  }

  void changeColor(String colorName) {
    setState(() {
      _selectedColorName = colorName;
    });
    print("change theme color to $colorName");

    Provider.of<ThemeNotifierProvider>(context,listen: false).setTheme(colorName);
    UserPreferencesUtils.putThemeColor(colorName);
    VibrationUtils.vibrateSuccessfullyIfPossible();
  }
}