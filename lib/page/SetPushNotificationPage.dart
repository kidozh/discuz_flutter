import 'dart:ffi';
import 'dart:io';

import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/utility/ConstUtils.dart';
import 'package:discuz_flutter/utility/PostTextFieldUtils.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class SetPushNotificationPage extends StatefulWidget {
  @override
  _SetPushNotificationState createState() => _SetPushNotificationState();
}

class _SetPushNotificationState extends State<SetPushNotificationPage> {
  bool allowPush = false;
  String deviceName = "";
  String packageId = "";
  String channel = "";
  String token = "";

  @override
  void initState(){
    _loadDeviceInformation();
  }

  void _loadDeviceInformation() async{
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    deviceName = await PostTextFieldUtils.getDeviceName(context);
    // firebase
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? fetchedToken = await messaging.getToken();

    setState((){
      deviceName = deviceName;
      packageId = packageInfo.packageName;
      channel = S.of(context).pushChannelFirebase;
      if(fetchedToken!= null){
        token = fetchedToken;
      }
    });


  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      iosContentPadding: true,
      appBar: PlatformAppBar(
        title: Text(S.of(context).pushNotification),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(tiles: [
            SettingsTile.switchTile(
              title: Text(S.of(context).pushNotificationEnable),
              description: Text(S.of(context).pushNotificationDescription),
              initialValue: allowPush,
              onToggle: (value) {
                VibrationUtils.vibrateWithClickIfPossible();
                // need to popup a dialog
                if (value) {
                  // popup dialog
                  _triggerDialog(context);
                } else {
                  setState(() {
                    allowPush = false;
                  });
                }
              },
            )
          ]),
          SettingsSection(
              title: Text(S.of(context).pushInformation),
              tiles: [
                SettingsTile(
                  title: Text(S.of(context).pushDevice),
                  value: Text(deviceName),
                ),
                SettingsTile(title: Text(S.of(context).pushPackageId),
                  value: Text(packageId),
                ),
                SettingsTile(
                  title: Text(S.of(context).pushChannel),
                  value: Text(S.of(context).pushChannelFirebase),
                ),
                SettingsTile(title: Text(S.of(context).pushToken),
                  description: Text(token),
                ),
              ]
          ),
          SettingsSection(title: Text(S.of(context).legalInformation), tiles: [
            SettingsTile.navigation(
              title: Text(S.of(context).termsOfService),
              leading: Icon(PlatformIcons(context).tagOutline),
              onPressed: (_) {
                VibrationUtils.vibrateWithClickIfPossible();
                _launchURL("https://discuzhub.kidozh.com/term_of_use/");
              },
            ),
            SettingsTile.navigation(
              title: Text(S.of(context).privacyPolicy),
              leading: Icon(PlatformIcons(context).tagOutline),
              onPressed: (_) {
                VibrationUtils.vibrateWithClickIfPossible();
                _launchURL("https://discuzhub.kidozh.com/privacy_policy/");
              },
            ),
            SettingsTile.navigation(
              title: Text(S.of(context).authorizedSite),
              leading: Icon(PlatformIcons(context).checkMarkCircled),
              onPressed: (_) {
                VibrationUtils.vibrateWithClickIfPossible();
                _launchURL("https://discuzhub.kidozh.com/open_source_licence/");
              },
            ),
          ])
        ],
      ),
    );
  }

  void _triggerDialog(BuildContext context) {
    showPlatformDialog(
        context: context,
        builder: (context) => PlatformAlertDialog(
              title: Text(S.of(context).pushNotificationEnable),
              content: Text(S.of(context).pushNotificationSubmittedContent),
              actions: [
                PlatformDialogAction(
                  child: Text(S.of(context).ok),
                  onPressed: () async {
                    FirebaseMessaging messaging = FirebaseMessaging.instance;
                    NotificationSettings settings = await messaging.requestPermission(
                      alert: true,
                      announcement: false,
                      badge: true,
                      carPlay: false,
                      criticalAlert: false,
                      provisional: false,
                      sound: true,
                    );

                    if (settings.authorizationStatus == AuthorizationStatus.authorized || settings.authorizationStatus == AuthorizationStatus.provisional){
                      setState(() {
                        allowPush = true;
                      });
                    }
                    else{
                      EasyLoading.showInfo(S.of(context).pushNotificationPermissionNotAuthorized);
                    }
                    Navigator.of(context).pop();

                  },
                ),
                PlatformDialogAction(
                  child: Text(S.of(context).cancel),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ));
  }

  void _launchURL(String url) async => await canLaunchUrl(Uri.parse(url))
      ? await launchUrl(Uri.parse(url))
      : throw 'Could not launch $url';
}
