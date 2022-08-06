
import 'dart:developer';
import 'dart:io';

import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/PostTextFieldUtils.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

import '../provider/UserPreferenceNotifierProvider.dart';
import '../utility/AppPlatformIcons.dart';

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
    String? fetchedToken = null;
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    if (Platform.isIOS){
      fetchedToken = await messaging.getAPNSToken();

      log("Get APNS ${fetchedToken}");
    }
    else{
      // firebase


      try{
        fetchedToken = await messaging.getToken();
      }
      catch(e){
        fetchedToken = null;
      }
    }



    setState((){
      deviceName = deviceName;
      packageId = packageInfo.packageName;
      if(Platform.isIOS){
        channel = S.of(context).pushChannelAPNs;
      }
      else{
        channel = S.of(context).pushChannelFirebase;
      }

      if(fetchedToken!= null){
        token = fetchedToken;
      }
      else{
        token = "";
      }
    });
    // allowPush
    bool _allowPush = await UserPreferencesUtils.getPushPreference();
    setState((){
      allowPush = _allowPush;
    });
    Provider.of<UserPreferenceNotifierProvider>(context,listen: false).allowPush = _allowPush;


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
          if(token == "")
            SettingsSection(tiles: [
              SettingsTile(
                title: Text(S.of(context).pushDeviceNotSupported),
                description: Text(S.of(context).pushDeviceNotSupportedDescription),
                leading: Icon(PlatformIcons(context).removeCircledSolid),
              )
            ],
            ),
          if(token != "")
          SettingsSection(tiles: [
            SettingsTile.switchTile(
              title: Text(S.of(context).pushNotificationEnable),
              description: Text(S.of(context).pushNotificationDescription),
              initialValue: allowPush,
              activeSwitchColor: Theme.of(context).primaryColor,
              onToggle: (value) async {
                VibrationUtils.vibrateWithClickIfPossible();
                // need to popup a dialog
                if (value) {
                  // popup dialog
                  _triggerDialog(context);
                } else {
                  setState(() {
                    allowPush = false;
                  });
                  Provider.of<UserPreferenceNotifierProvider>(context,listen: false).allowPush = value;
                  await UserPreferencesUtils.putPushPreference(false);

                }
              },
            )
          ]),
          if(token != "")
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
                SettingsTile(title: Text(channel),
                  description: Text(token),
                ),
              ]
          ),
          SettingsSection(title: Text(S.of(context).legalInformation), tiles: [
            SettingsTile.navigation(
              title: Text(S.of(context).termsOfService),
              leading: Icon(AppPlatformIcons(context).termsOfServiceOutlined),
              onPressed: (_) {
                VibrationUtils.vibrateWithClickIfPossible();
                URLUtils.launchURL("https://discuzhub.kidozh.com/term_of_use/");
              },
            ),
            SettingsTile.navigation(
              title: Text(S.of(context).privacyPolicy),
              leading: Icon(AppPlatformIcons(context).privacyPolicyOutlined),
              onPressed: (_) {
                VibrationUtils.vibrateWithClickIfPossible();
                URLUtils.launchURL("https://discuzhub.kidozh.com/privacy_policy/");
              },
            ),

          ]),
          SettingsSection(title: Text(S.of(context).pushHelpPages),tiles:[
            SettingsTile.navigation(
              title: Text(S.of(context).workProcedure),
              leading: Icon(PlatformIcons(context).helpOutline),
              onPressed: (_) {
                VibrationUtils.vibrateWithClickIfPossible();
                URLUtils.launchURL("https://discuzhub.kidozh.com/dev-blog/how-push-service-works/");
              },
            ),
            SettingsTile.navigation(
              title: Text(S.of(context).authorizedSite),
              leading: Icon(PlatformIcons(context).checkMarkCircledOutline),
              onPressed: (_) {
                VibrationUtils.vibrateWithClickIfPossible();
                URLUtils.launchURL("https://discuzhub.kidozh.com/dev-blog/verified-discuz-site/");
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
                    VibrationUtils.vibrateWithClickIfPossible();
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
                      Provider.of<UserPreferenceNotifierProvider>(context,listen: false).allowPush = true;
                      await UserPreferencesUtils.putPushPreference(true);
                    }
                    else{
                      EasyLoading.showInfo(S.of(context).pushNotificationPermissionNotAuthorized);
                      Provider.of<UserPreferenceNotifierProvider>(context,listen: false).allowPush = false;
                      await UserPreferencesUtils.putPushPreference(false);
                    }
                    Navigator.of(context).pop();

                  },
                ),
                PlatformDialogAction(
                  child: Text(S.of(context).cancel),
                  onPressed: () {
                    VibrationUtils.vibrateWithClickIfPossible();
                    Navigator.of(context).pop();
                  },
                )
              ],
            ));
  }
}
