import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/ChooseInterfaceBrightnessPage.dart';
import 'package:discuz_flutter/page/ChoosePlatformPage.dart';
import 'package:discuz_flutter/page/ChooseTypeSettingScalePage.dart';
import 'package:discuz_flutter/page/SelectSignatureStylePage.dart';
import 'package:discuz_flutter/page/SetPushNotificationPage.dart';
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/provider/TypeSettingNotifierProvider.dart';
import 'package:discuz_flutter/provider/UserPreferenceNotifierProvider.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utility/AppPlatformIcons.dart';
import '../utility/PostTextFieldUtils.dart';
import 'ChooseThemeColorPage.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool lockInBackground = true;
  bool notificationsEnabled = true;

  bool recordHistory = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPreference();
  }

  void getPreference() async {
    recordHistory = await UserPreferencesUtils.getRecordHistoryEnabled();
    setState(() {
      recordHistory = recordHistory;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(title: Text(S.of(context).settingTitle)),
      iosContentPadding: true,
      body: buildSettingsList(),
    );
  }

  Widget buildSettingsList() {

    return Consumer<ThemeNotifierProvider>(builder: (context, themeEntity, _) {

      return Consumer<TypeSettingNotifierProvider>(builder: (context, typeSetting, _) {
        return SettingsList(
          sections: [
            SettingsSection(
              title: Text(S.of(context).common),
              tiles: [
                SettingsTile.switchTile(
                  title: Text(S.of(context).recordHistoryTitle),
                  description: Text(recordHistory
                      ? S.of(context).recordHistoryOnDescription
                      : S.of(context).recordHistoryOffDescription),
                  leading: Icon(AppPlatformIcons(context).historyOutlined),
                  //switchValue: recordHistory,
                  activeSwitchColor: Theme.of(context).primaryColor,
                  onToggle: (bool value) {
                    VibrationUtils.vibrateWithSwitchIfPossible();
                    print("set record history ${value} ");
                    UserPreferencesUtils.putRecordHistoryEnabled(value);
                    setState(() {
                      recordHistory = value;
                    });
                  }, initialValue: recordHistory,
                ),
                SettingsTile.navigation(
                  title: Text(S.of(context).pushNotification),
                  leading: Icon(AppPlatformIcons(context).pushServiceOutlined),
                  value: Consumer<UserPreferenceNotifierProvider>(
                    builder: (context, userPreference, child){
                      if(userPreference.allowPush){
                        return Text(S.of(context).pushNotificationOn);
                      }
                      else{
                        return Text(S.of(context).pushNotificationOff);
                      }
                    },
                  ),
                  onPressed: (context){
                    VibrationUtils.vibrateWithClickIfPossible();
                    Navigator.of(context).push(platformPageRoute(
                      builder: (_) => SetPushNotificationPage(),
                      context: context,
                    ));
                  },
                )
              ],
            ),
            SettingsSection(
              title: Text(S.of(context).displaySettingTitle),
              tiles: [
                SettingsTile.navigation(
                  title: Text(S.of(context).chooseThemeTitle),
                  value: Text(themeEntity.getColorName(context)),
                  leading: Icon(AppPlatformIcons(context).appThemeOutlined),
                  onPressed: (context) {
                    VibrationUtils.vibrateWithClickIfPossible();
                    Navigator.of(context).push(platformPageRoute(
                      builder: (_) => ChooseThemeColorPage(),
                      context: context,
                    ));
                  },
                ),
                SettingsTile.navigation(
                  title: Text(S.of(context).appearanceOptimizedPlatform),
                  value: Text(themeEntity.getPlatformLocaleName(context)),
                  leading: Icon(AppPlatformIcons(context).appAppearanceOutlined),
                  onPressed: (context) {
                    VibrationUtils.vibrateWithClickIfPossible();
                    Navigator.of(context).push(platformPageRoute(
                      builder: (_) => ChoosePlatformPage(),
                      context: context,
                    ));
                  },
                ),
                SettingsTile.switchTile(
                  title: Text(S.of(context).useMaterial3Title),
                  description: themeEntity.useMaterial3
                      ? Text(S.of(context).useMaterial3YesSubtitle)
                      : Text(S.of(context).useMaterial3NoSubtitle),
                  leading: Icon(AppPlatformIcons(context).material3Outlined),
                  activeSwitchColor: Theme.of(context).primaryColor,
                  onToggle: (bool value) {
                    VibrationUtils.vibrateWithSwitchIfPossible();
                    UserPreferencesUtils.putMaterial3PropertyPreference(value);
                    Provider.of<ThemeNotifierProvider>(context,listen: false).setMaterial3(value);
                  }, initialValue: themeEntity.useMaterial3,
                ),
                SettingsTile.navigation(
                  title: Text(S.of(context).interfaceBrightness),
                  value: Text(themeEntity.getBrightnessName(context)),
                  leading: Icon(PlatformIcons(context).brightness),
                  onPressed: (context) {
                    VibrationUtils.vibrateWithClickIfPossible();
                    Navigator.of(context).push(platformPageRoute(
                      builder: (_) => ChooseInterfaceBrightnessPage(),
                      context: context,
                    ));
                  },
                ),
                SettingsTile.navigation(
                  title: Text(S.of(context).typeSetting),
                  value: Text(S.of(context).fontSizeScaleParameterUnit(typeSetting.scalingParameter.toStringAsFixed(3))),
                  leading: Icon(AppPlatformIcons(context).typeSettingOutlined),
                  onPressed: (context) {
                    VibrationUtils.vibrateWithClickIfPossible();
                    Navigator.of(context).push(platformPageRoute(
                      builder: (_) => ChooseTypeSettingScalePage(),
                      context: context,
                    ));
                  },
                )


              ],
            ),
            SettingsSection(
              title: Text(S.of(context).post),
              tiles: [
                SettingsTile.navigation(
                  title: Text(S.of(context).signatureStyle),
                  leading: Icon(AppPlatformIcons(context).signatureOutlined),
                  value: Consumer<UserPreferenceNotifierProvider>(
                    builder: (context, userPreference, child){
                      if(userPreference.signature == PostTextFieldUtils.NO_SIGNATURE){
                        return Text(S.of(context).noSignature);
                      }
                      else if(userPreference.signature == PostTextFieldUtils.USE_DEVICE_SIGNATURE){
                        return Text(S.of(context).deviceNameSignature);
                      }
                      else {
                        return Text(S.of(context).customSignature);
                      }
                    },
                  ),
                  onPressed: (context) {
                    VibrationUtils.vibrateWithClickIfPossible();
                    Navigator.of(context).push(platformPageRoute(
                      builder: (_) => SelectSignatureStylePage(),
                      context: context,
                    ));
                  },
                ),
              ],
            ),
            SettingsSection(
              title: Text(S.of(context).legalInformation),
              tiles: [
                SettingsTile.navigation(
                  title: Text(S.of(context).termsOfService),
                  leading: Icon(AppPlatformIcons(context).privacyPolicyOutlined),

                  onPressed: (_) {
                    VibrationUtils.vibrateWithClickIfPossible();
                    _launchURL("https://discuzhub.kidozh.com/term_of_use/");
                  },
                ),
                SettingsTile.navigation(
                  title: Text(S.of(context).privacyPolicy),
                  leading: Icon(AppPlatformIcons(context).termsOfServiceOutlined),

                  onPressed: (_) {
                    VibrationUtils.vibrateWithClickIfPossible();
                    _launchURL("https://discuzhub.kidozh.com/privacy_policy/");
                  },
                ),
              ],
            ),
            CustomSettingsSection(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 22, bottom: 8),
                    child: Icon(
                      Icons.flutter_dash_rounded,
                      size: 54,
                    ),
                  ),
                  Text(
                    S.of(context).buildDescription,
                    style: TextStyle(color: Color(0xFF777777)),
                  ),
                ],
              ),
            ),
          ],
        );
      });

    });
  }

  double paragraphFontSize = 12.0;

  void _launchURL(String url) async =>
      await canLaunchUrl(Uri.parse(url)) ? await launchUrl(Uri.parse(url)) : throw 'Could not launch $url';
}
