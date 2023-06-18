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

    _selectedColorName = Provider.of<ThemeNotifierProvider>(context,listen: false).themeColorName;

    return PlatformScaffold(
      iosContentPadding: true,
      appBar: PlatformAppBar(
        title: Text(S.of(context).chooseThemeTitle),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(tiles: [
            SettingsTile(
              title: Text(S.of(context).colorAmber),
              leading: getLeadingCircleWidget(context, Colors.amber),
              trailing: trailingWidget("amber"),
              onPressed: (BuildContext context) {
                changeColor("amber");
              },
            ),
            SettingsTile(
              title: Text(S.of(context).colorGrey),
              leading: getLeadingCircleWidget(context, Colors.grey),
              trailing: trailingWidget("grey"),
              onPressed: (BuildContext context) {
                changeColor("grey");
              },
            ),
            SettingsTile(
              title: Text(S.of(context).colorBlue),
              leading: getLeadingCircleWidget(context, Colors.blue),
              trailing: trailingWidget("blue"),
              onPressed: (BuildContext context) {
                changeColor("blue");
              },
            ),
            SettingsTile(
              title: Text(S.of(context).colorCyan),
              leading: getLeadingCircleWidget(context, Colors.cyan),
              trailing: trailingWidget("cyan"),
              onPressed: (BuildContext context) {
                changeColor("cyan");
              },
            ),
            SettingsTile(
              title: Text(S.of(context).colorDeepPurple),
              leading: getLeadingCircleWidget(context, Colors.deepPurple),
              trailing: trailingWidget("deepPurple"),
              onPressed: (BuildContext context) {
                changeColor("deepPurple");
              },
            ),
            SettingsTile(
              title: Text(S.of(context).colorDeepOrange),
              leading: getLeadingCircleWidget(context, Colors.deepOrange),
              trailing: trailingWidget("deepOrange"),
              onPressed: (BuildContext context) {
                changeColor("deepOrange");
              },
            ),
            SettingsTile(
              title: Text(S.of(context).colorYellow),
              leading: getLeadingCircleWidget(context, Colors.yellow),
              trailing: trailingWidget("yellow"),
              onPressed: (BuildContext context) {
                changeColor("yellow");
              },
            ),
            SettingsTile(
              title: Text(S.of(context).colorLime),
              leading: getLeadingCircleWidget(context, Colors.lime),
              trailing: trailingWidget("lime"),
              onPressed: (BuildContext context) {
                changeColor("lime");
              },
            ),
            SettingsTile(
              title: Text(S.of(context).colorGreen),
              leading: getLeadingCircleWidget(context, Colors.green),
              trailing: trailingWidget("green"),
              onPressed: (BuildContext context) {
                changeColor("green");
              },
            ),
            SettingsTile(
              title: Text(S.of(context).colorIndigo),
              leading: getLeadingCircleWidget(context, Colors.indigo),
              trailing: trailingWidget("indigo"),
              onPressed: (BuildContext context) {
                changeColor("indigo");
              },
            ),
            SettingsTile(
              title: Text(S.of(context).colorOrange),
              leading: getLeadingCircleWidget(context, Colors.orange),
              trailing: trailingWidget("orange"),
              onPressed: (BuildContext context) {
                changeColor("orange");
              },
            ),
            SettingsTile(
              title: Text(S.of(context).colorPurple),
              leading: getLeadingCircleWidget(context, Colors.purple),
              trailing: trailingWidget("purple"),
              onPressed: (BuildContext context) {
                changeColor("purple");
              },
            ),
            SettingsTile(
              title: Text(S.of(context).colorPink),
              leading: getLeadingCircleWidget(context, Colors.pink),
              trailing: trailingWidget("pink"),
              onPressed: (BuildContext context) {
                changeColor("pink");
              },
            ),
            SettingsTile(
              title: Text(S.of(context).colorRed),
              leading: getLeadingCircleWidget(context, Colors.red),
              trailing: trailingWidget("red"),
              onPressed: (BuildContext context) {
                changeColor("red");
              },
            ),
            SettingsTile(
              title: Text(S.of(context).colorTeal),
              leading: getLeadingCircleWidget(context, Colors.teal),
              trailing: trailingWidget("teal"),
              onPressed: (BuildContext context) {
                changeColor("teal");
              },
            ),
            SettingsTile(
              title: Text(S.of(context).colorBrown),
              leading: getLeadingCircleWidget(context, Colors.brown),
              trailing: trailingWidget("brown"),
              onPressed: (BuildContext context) {
                changeColor("brown");
              },
            ),
            SettingsTile(
              title: Text(S.of(context).colorLightBlue),
              leading: getLeadingCircleWidget(context, Colors.lightBlue),
              trailing: trailingWidget("lightBlue"),
              onPressed: (BuildContext context) {
                changeColor("lightBlue");
              },
            ),
            SettingsTile(
              title: Text(S.of(context).colorBlueGrey),
              leading: getLeadingCircleWidget(context, Colors.blueGrey),
              trailing: trailingWidget("blueGrey"),
              onPressed: (BuildContext context) {
                changeColor("blueGrey");
              },
            ),
            SettingsTile(
              title: Text(S.of(context).colorLightGreen),
              leading: getLeadingCircleWidget(context, Colors.lightGreen),
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