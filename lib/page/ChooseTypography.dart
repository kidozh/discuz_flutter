import 'dart:math';

import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/Post.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/TypeSettingNotifierProvider.dart';
import 'package:discuz_flutter/utility/PostTextFieldUtils.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/PostWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

import '../utility/AppPlatformIcons.dart';

class ChooseTypeSettingScalePage extends StatefulWidget {
  @override
  _ChooseTypeSettingScaleState createState() => _ChooseTypeSettingScaleState();
}

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

class _ChooseTypeSettingScaleState extends State<ChooseTypeSettingScalePage> {
  double _scalingParamter = 1.0;


  Post generateMockedPost(){
    Post mockedPost = Post();
    mockedPost.authorId = _rnd.nextInt(100);
    mockedPost.position = _rnd.nextInt(400);
    mockedPost.message = PostTextFieldUtils.EXAMPLE_HTML_LONG_DATA;
    mockedPost.author = getRandomString(10);
    DateTime today = DateTime.now();
    DateTime randomTimeAgo = today.subtract(Duration(minutes: _rnd.nextInt(500)));
    mockedPost.publishAt = randomTimeAgo;
    return mockedPost;
  }

  bool ignoreCustomFontStyle = false;
  bool _useThinFont = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPreference();
  }

  void getPreference() async {
    bool ignoreCustomFontStyleSetting = await UserPreferencesUtils.getDisableFontCustomizationPreference();
    bool useThinFont = await UserPreferencesUtils.getUseThinFontPreference();
    setState(() {
      ignoreCustomFontStyle = ignoreCustomFontStyleSetting;
      _useThinFont = useThinFont;
    });
  }



  @override
  Widget build(BuildContext context) {
    _scalingParamter =
        Provider.of<TypeSettingNotifierProvider>(context, listen: false)
            .scalingParameter;
    Discuz mockedDiscuz = Discuz(
        "https://bbs.nwpu.edu.cn",
        "4",
        "utf8",
        4,
        "X1.8",
        "register",
        false,
        "false",
        "false",
        "MOCK",
        "452",
        "uCenterURL",
        "1");


    return PlatformScaffold(
      iosContentPadding: true,
      appBar: PlatformAppBar(
        title: Text(S.of(context).typeSetting),
      ),
      body: Consumer<TypeSettingNotifierProvider>(
          builder: (context, typesetting, _) {
        return SettingsList(
          sections: [
            SettingsSection(
              tiles: [
                SettingsTile.switchTile(
                  title: Text(S.of(context).disableFontCustomization),
                  // description: ignoreCustomFontStyle
                  //     ? Text(S.of(context).disableFontCustomizationTitle)
                  //     : null,
                  activeSwitchColor: Theme.of(context).colorScheme.primary,
                  leading: Icon(PlatformIcons(context).edit),
                  onToggle: (bool value) {
                    VibrationUtils.vibrateWithSwitchIfPossible();
                    print("set disable font customisation ${value} ");
                    UserPreferencesUtils.putDisableFontCustomizationPreference(value);
                    setState(() {
                      ignoreCustomFontStyle = value;
                    });
                  }, initialValue: ignoreCustomFontStyle,
                ),
                SettingsTile.switchTile(
                  title: Text(S.of(context).useThinFont),
                  activeSwitchColor: Theme.of(context).colorScheme.primary,
                  leading: Icon(AppPlatformIcons(context).fontWeightOutline),
                  onToggle: (bool value) {
                    VibrationUtils.vibrateWithSwitchIfPossible();
                    UserPreferencesUtils.putUseThinFontPreference(value);
                    Provider.of<TypeSettingNotifierProvider>(context, listen: false).useThinFontWeight = value;
                    setState(() {
                      _useThinFont = value;
                    });
                  }, initialValue: _useThinFont,
                ),
                SettingsTile.navigation(
                  title: Text(S.of(context).chooseTypographyTheme),
                  leading: Icon(AppPlatformIcons(context).typographyOutline),
                  value: Text(typesetting.getTypographyThemeName(context)),
                  onPressed: (context) {
                    VibrationUtils.vibrateWithSwitchIfPossible();
                    // trigger a
                    triggerTypographySelection();
                  }
                ),
              ],
            ),
            CustomSettingsSection(
                child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  height: 16.0,
                ),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Icon(
                        AppPlatformIcons(context).formatSizeSolid,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.grey.shade600
                            : Colors.white,
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                            left: isCupertino(context) ? 0.0 : 16.0),
                        child: Text(
                          S.of(context).fontSizeScaleParameter,
                          style: TextStyle(fontSize: 16),
                        )),
                    Expanded(
                      child: Container(),
                      flex: 1,
                    ),
                    //Expanded(child: Spacer()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                          S.of(context).fontSizeScaleParameterUnit(
                              _scalingParamter.toStringAsFixed(3)),
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey.shade600)),
                    )
                  ],
                ),
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: PlatformSlider(
                      activeColor: Theme.of(context).colorScheme.primary,
                      value: _scalingParamter,
                      min: 1.0,
                      max: 3.0,
                      onChanged: (value) {
                        changeScale(value);
                      },
                    ),
                  ),
                )
              ],
            )),
            CustomSettingsSection(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    PostWidget(mockedDiscuz, generateMockedPost(), _rnd.nextInt(1000),""),
                    PostWidget(mockedDiscuz, generateMockedPost(), _rnd.nextInt(1000),""),
                  ],
                ),
              ),
            )
          ],
        );
      }),
    );
  }

  void changeScale(double value) {
    setState(() {
      _scalingParamter = value.toDouble();
    });
    UserPreferencesUtils.putTypesettingScalePreference(_scalingParamter);
    Provider.of<TypeSettingNotifierProvider>(context, listen: false)
        .setScalingParameter(_scalingParamter);
  }

  void triggerTypographySelection(){
    List<String> typographyThemeList = TypeSettingNotifierProvider.getTypographyThemeNameList(context);
    
    showCupertinoModalPopup(
        context: context, builder: (context) => Container(
      height: 216,
      padding: EdgeInsets.only(top: 6.0),
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      color: Theme.of(context).colorScheme.background,
      child: SafeArea(
        child: CupertinoPicker(
            itemExtent: 32,
            useMagnifier: true,
            magnification: 1.22,
            squeeze: 1.2,
            onSelectedItemChanged: (position){
              VibrationUtils.vibrateWithClickIfPossible();
              List<String> typographyList = TypeSettingNotifierProvider.typographyList;
              if(position < typographyList.length){
                UserPreferencesUtils.putTypographyThemePreference(typographyList[position]);
                Provider.of<TypeSettingNotifierProvider>(context, listen: false).typographyTheme = typographyList[position];
              }
              
            },
            children: List<Widget>.generate(
              typographyThemeList.length, (index) => Center(
                child: Text("${typographyThemeList[index]}")
            ),
            )
        ),
      ),
    )
    );
  }
}
