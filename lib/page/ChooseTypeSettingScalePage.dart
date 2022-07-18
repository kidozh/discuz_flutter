import 'dart:math';

import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/Post.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/TypeSettingNotifierProvider.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/PostWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

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
    mockedPost.message = getRandomString(400);
    mockedPost.author = getRandomString(10);
    return mockedPost;
  }

  bool ignoreCustomFontStyle = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPreference();
  }

  void getPreference() async {
    bool ignoreCustomFontStyleSetting = await UserPreferencesUtils.getDisableFontCustomizationPreference();
    setState(() {
      ignoreCustomFontStyle = ignoreCustomFontStyleSetting;
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
                  description: ignoreCustomFontStyle
                      ? Text(S.of(context).disableFontCustomizationTitle)
                      : null,
                  leading: Icon(PlatformIcons(context).edit),
                  activeSwitchColor: Theme.of(context).primaryColor,
                  //switchValue: ignoreCustomFontStyle,
                  onToggle: (bool value) {
                    VibrationUtils.vibrateWithSwitchIfPossible();
                    print("set record history ${value} ");
                    UserPreferencesUtils.putDisableFontCustomizationPreference(value);
                    setState(() {
                      ignoreCustomFontStyle = value;
                    });
                  }, initialValue: ignoreCustomFontStyle,
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
                        Icons.format_size,
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
                  child: PlatformSlider(
                    activeColor: Theme.of(context).primaryColor,
                    value: _scalingParamter,
                    min: 1.0,
                    max: 3.0,
                    onChanged: (value) {
                      changeScale(value);
                    },
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
                    PostWidget(mockedDiscuz, generateMockedPost(), _rnd.nextInt(1000),""),
                    PostWidget(mockedDiscuz, generateMockedPost(), _rnd.nextInt(1000),""),
                    PostWidget(mockedDiscuz, generateMockedPost(), _rnd.nextInt(1000),"")
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
}
