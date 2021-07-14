import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/ChoosePlatformPage.dart';
import 'package:discuz_flutter/page/ChooseTypeSettingScalePage.dart';
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/provider/TypeSettingNotifierProvider.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';

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
      body: buildSettingsList(),
    );
  }

  Widget buildSettingsList() {

    double scale = Provider.of<TypeSettingNotifierProvider>(context,listen: false).scalingParameter;

    return Consumer<ThemeNotifierProvider>(builder: (context, themeEntity, _) {

      return Consumer<TypeSettingNotifierProvider>(builder: (context, typeSetting, _) {
        return SettingsList(
          sections: [
            SettingsSection(
              title: S.of(context).common,
              tiles: [
                SettingsTile.switchTile(
                  title: S.of(context).recordHistoryTitle,
                  subtitle: recordHistory
                      ? S.of(context).recordHistoryOnDescription
                      : S.of(context).recordHistoryOffDescription,
                  leading: Icon(Icons.history),
                  switchValue: recordHistory,
                  onToggle: (bool value) {
                    print("set record history ${value} ");
                    UserPreferencesUtils.putRecordHistoryEnabled(value);
                    setState(() {
                      recordHistory = value;
                    });
                  },
                ),
              ],
            ),
            SettingsSection(
              title: S.of(context).displaySettingTitle,
              tiles: [
                SettingsTile(
                  title: S.of(context).chooseThemeTitle,
                  subtitle: themeEntity.getColorName(context),
                  leading: Icon(Icons.color_lens_outlined),
                  onPressed: (context) {
                    Navigator.of(context).push(platformPageRoute(
                      builder: (_) => ChooseThemeColorPage(),
                      context: context,
                    ));
                  },
                ),
                SettingsTile(
                  title: S.of(context).appearanceOptimizedPlatform,
                  subtitle: themeEntity.getPlatformLocaleName(context),
                  leading: Icon(PlatformIcons(context).home),
                  onPressed: (context) {
                    Navigator.of(context).push(platformPageRoute(
                      builder: (_) => ChoosePlatformPage(),
                      context: context,
                    ));
                  },
                ),
                SettingsTile(
                  title: S.of(context).fontSizeScaleParameter,
                  subtitle: S.of(context).fontSizeScaleParameterUnit(typeSetting.scalingParameter.toStringAsFixed(3)),
                  leading: Icon(Icons.format_size),
                  onPressed: (context) {
                    Navigator.of(context).push(platformPageRoute(
                      builder: (_) => ChooseTypeSettingScalePage(),
                      context: context,
                    ));
                  },
                )


              ],
            ),


            // SettingsSection(
            //   title: 'Account',
            //   tiles: [
            //     SettingsTile(title: 'Phone number', leading: Icon(Icons.phone)),
            //     SettingsTile(title: 'Email', leading: Icon(Icons.email)),
            //     SettingsTile(title: 'Sign out', leading: Icon(Icons.exit_to_app)),
            //   ],
            // ),
            // SettingsSection(
            //   title: 'Security',
            //   tiles: [
            //     SettingsTile.switchTile(
            //       title: 'Lock app in background',
            //       leading: Icon(Icons.phonelink_lock),
            //       switchValue: lockInBackground,
            //       onToggle: (bool value) {
            //         setState(() {
            //           lockInBackground = value;
            //           notificationsEnabled = value;
            //         });
            //       },
            //     ),
            //   ],
            // ),
            SettingsSection(
              title: S.of(context).legalInformation,
              tiles: [
                SettingsTile(
                  title: S.of(context).termsOfService,
                  leading: Icon(Icons.description),
                  onPressed: (_) {
                    _launchURL("https://discuzhub.kidozh.com/term_of_use/");
                  },
                ),
                SettingsTile(
                  title: S.of(context).privacyPolicy,
                  leading: Icon(Icons.privacy_tip),
                  onPressed: (_) {
                    _launchURL("https://discuzhub.kidozh.com/privacy_policy/");
                  },
                ),
                SettingsTile(
                  title: S.of(context).openSourceLicence,
                  leading: Icon(Icons.collections_bookmark),
                  onPressed: (_) {
                    _launchURL(
                        "https://discuzhub.kidozh.com/open_source_licence/");
                  },
                ),
              ],
            ),
            CustomSection(
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
      await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
}
