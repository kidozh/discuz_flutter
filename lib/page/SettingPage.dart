import 'dart:io';

import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/ChooseDynamicSchemeVariantPage.dart';
import 'package:discuz_flutter/page/ChooseInterfaceBrightnessPage.dart';
import 'package:discuz_flutter/page/ChoosePlatformPage.dart';
import 'package:discuz_flutter/page/ChooseTypography.dart';
import 'package:discuz_flutter/page/DiscuzAuthenticationPage.dart';
import 'package:discuz_flutter/page/SelectSignatureStylePage.dart';
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/provider/TypeSettingNotifierProvider.dart';
import 'package:discuz_flutter/provider/UserPreferenceNotifierProvider.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
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

  bool useMaterial3 = true;
  bool hapticFeedback = true;

  String packageVersion = "";
  String packageBuildNumber = "";

  _loadPackageInfo() async{
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState((){
      packageVersion = packageInfo.version;
      packageBuildNumber = packageInfo.buildNumber;
    });

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPreference();
    _loadPackageInfo();
  }

  void getPreference() async {
    recordHistory = await UserPreferencesUtils.getRecordHistoryEnabled();
    hapticFeedback = await UserPreferencesUtils.getHapticFeedbackPreference();
    setState(() {
      recordHistory = recordHistory;
      hapticFeedback = hapticFeedback;
    });


  }

  @override
  Widget build(BuildContext context) {
    useMaterial3 = Provider.of<ThemeNotifierProvider>(context,listen: false).useMaterial3;
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
                title: Text(S.of(context).securityTitle),
                tiles: [
                  SettingsTile.navigation(
                    title: Text(S.of(context).discuzAuthenticationTitle),
                    leading: Icon(AppPlatformIcons(context).authenticationSecureOutline),

                    onPressed: (context){
                      VibrationUtils.vibrateWithClickIfPossible();
                      Navigator.of(context).push(platformPageRoute(
                        builder: (_) => DiscuzAuthenticationPage(),
                        context: context,
                      ));
                    },
                  )
                ],
            ),

            SettingsSection(
              title: Text(S.of(context).common),
              tiles: [
                SettingsTile.switchTile(
                  title: Text(S.of(context).recordHistoryTitle),
                  leading: Icon(AppPlatformIcons(context).historyOutlined),
                  activeSwitchColor: Theme.of(context).colorScheme.primary,
                  onToggle: (bool value) {
                    VibrationUtils.vibrateWithSwitchIfPossible();
                    print("set record history ${value} ");
                    UserPreferencesUtils.putRecordHistoryEnabled(value);
                    setState(() {
                      recordHistory = value;
                    });
                  }, initialValue: recordHistory,
                ),
                // SettingsTile.navigation(
                //   title: Text(S.of(context).pushNotification),
                //   leading: Icon(AppPlatformIcons(context).pushServiceOutlined),
                //   value: Consumer<UserPreferenceNotifierProvider>(
                //     builder: (context, userPreference, child){
                //       if(userPreference.allowPush){
                //         return Text(S.of(context).pushNotificationOn);
                //       }
                //       else{
                //         return Text(S.of(context).pushNotificationOff);
                //       }
                //     },
                //   ),
                //   onPressed: (context){
                //     VibrationUtils.vibrateWithClickIfPossible();
                //     Navigator.of(context).push(platformPageRoute(
                //       builder: (_) => SetPushNotificationPage(),
                //       context: context,
                //     ));
                //   },
                // )
              ],
            ),
            SettingsSection(
              title: Text(S.of(context).displaySettingTitle),
              tiles: [
                SettingsTile.navigation(
                  title: Text(S.of(context).chooseThemeTitle),
                  value: Text(themeEntity.themeColorName),
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
                  title: Text(S.of(context).dynamicSchemeVariant),
                  value: Text(themeEntity.getDynamicSchemeVariantName(context)),
                  leading: Icon(AppPlatformIcons(context).dynamicSchemeVariantOutlined),
                  onPressed: (context) {
                    VibrationUtils.vibrateWithClickIfPossible();
                    Navigator.of(context).push(platformPageRoute(
                      builder: (_) => ChooseDynamicSchemeVariantPage(),
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
                SettingsTile.navigation(
                  title: Text(S.of(context).interfaceBrightness),
                  //description: Text(S.of(context).brightnessManualChangeDisabled),
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
                SettingsTile.switchTile(
                  title: Text(S.of(context).useMaterial3Title),
                  leading: Icon(AppPlatformIcons(context).material3Outlined),
                  activeSwitchColor: Theme.of(context).colorScheme.primary,
                  onToggle: (bool value) {
                    VibrationUtils.vibrateWithSwitchIfPossible();
                    UserPreferencesUtils.putMaterial3PropertyPreference(value);
                    Provider.of<ThemeNotifierProvider>(context,listen: false).setMaterial3(value);
                    setState((){
                      useMaterial3 = value;
                    });
                  }, initialValue: useMaterial3,
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
              title: Text(S.of(context).feedbackTitle),
                tiles: [
                  SettingsTile.switchTile(
                    title: Text(S.of(context).hapticFeedbackTitle),
                    leading: Icon(AppPlatformIcons(context).hapticFeedbackOutlined),
                    activeSwitchColor: Theme.of(context).colorScheme.primary,
                    initialValue: hapticFeedback,
                    onToggle: (bool value) async{
                      if(value){
                        VibrationUtils.vibrateWithClickIfPossible();
                      }
                      UserPreferencesUtils.putHapticFeedbackPreference(value);
                      setState(() {
                        hapticFeedback = value;
                      });

                    },

                  )
                ]
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
                      else if(userPreference.signature == PostTextFieldUtils.USE_APP_SIGNATURE){
                        return Text(S.of(context).signatureWithDisFly);
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
                // SettingsTile.navigation(
                //   title: Text(S.of(context).pictureBedTitle),
                //   leading: Icon(AppPlatformIcons(context).pictureBedOutlined),
                //   onPressed: (_) {
                //     VibrationUtils.vibrateWithClickIfPossible();
                //     Navigator.of(context).push(platformPageRoute(
                //       builder: (_) => ConfigurePictureBedPage(),
                //       context: context,
                //     ));
                //   },
                // ),
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
                // SettingsTile.navigation(
                //   title: Text(S.of(context).dhPushServiceTitle),
                //   leading: Icon(AppPlatformIcons(context).pushServiceOutlined),
                //
                //   onPressed: (_) {
                //     VibrationUtils.vibrateWithClickIfPossible();
                //     _launchURL("https:/dhp.kidozh.com");
                //   },
                // ),
                SettingsTile.navigation(
                  title: Text(S.of(context).openSoftwareTitle),
                  leading: Icon(PlatformIcons(context).bookmark),

                  onPressed: (_) {
                    VibrationUtils.vibrateWithClickIfPossible();
                    showLicensePage(
                        context: context,
                        applicationName: S.of(context).appName,
                        applicationIcon: Image(
                          image: AssetImage("assets/images/icon-large.png",),
                          width: 64,
                        ),
                        applicationVersion: packageVersion
                    );
                  },
                ),
              ],
            ),
            CustomSettingsSection(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 22, bottom: 8),
                    child: Image(
                        image: AssetImage("assets/images/icon-large.png",),
                        width: 64,
                    ),
                  ),
                  Text(
                    S.of(context).buildVersionDescription(packageVersion, packageBuildNumber),
                    style: TextStyle(color: Theme.of(context).disabledColor),
                  ),
                  SizedBox(height: 32,)
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
      await canLaunchUrl(Uri.parse(url)) ? await launchUrl(Uri.parse(url), mode: Platform.isIOS? LaunchMode.inAppWebView: LaunchMode.externalApplication) : throw 'Could not launch $url';
}
