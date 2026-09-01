import 'dart:async';

import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../provider/UserPreferenceNotifierProvider.dart';

class TestFlightBannerPage extends StatefulWidget {
  final String? version;

  const TestFlightBannerPage({this.version, super.key});

  @override
  State<TestFlightBannerPage> createState() => _TestFlightBannerPageState();
}

class _TestFlightBannerPageState extends State<TestFlightBannerPage> {
  String? _version;

  @override
  void initState() {
    super.initState();
    _version = widget.version;
    if (_version == null) unawaited(_loadVersion());
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _version = packageInfo.version);
  }

  String _pageTitle(BuildContext context) => _version == null
      ? S.of(context).welcomeTitle
      : S.of(context).welcomeVersionTitle(_version!);

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
        iosContentBottomPadding: true,
        iosContentPadding: true,
        appBar: PlatformAppBar(
          title: Text(_pageTitle(context)),
        ),
        body: TestFlightBannerContent(version: _version));
  }
}

class TestFlightBannerContent extends StatefulWidget {
  final String? version;

  const TestFlightBannerContent({required this.version, super.key});

  @override
  State<TestFlightBannerContent> createState() =>
      TestFlightBannerContentState();
}

class TestFlightBannerContentState extends State<TestFlightBannerContent> {
  static const _featureContentPadding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 12);

  String _pageTitle(BuildContext context) => widget.version == null
      ? S.of(context).welcomeTitle
      : S.of(context).welcomeVersionTitle(widget.version!);

  Widget _featureLeading({
    required Color backgroundColor,
    required IconData icon,
    required Color foregroundColor,
  }) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: backgroundColor,
      child: Icon(icon, color: foregroundColor, size: 17),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkPushService();
    });
  }

  Future<void> _checkPushService() async {
    // if(signaturePreference != PostTextFieldUtils.USE_APP_SIGNATURE){
    //   // prompt push notification
    //   await showPlatformDialog(
    //       context: context,
    //       builder: (_) => PlatformAlertDialog(
    //         title: Text(S.of(context).signatureSupportUS),
    //         content: Text(S.of(context).signatureWithDisFlyDescription),
    //         actions: [
    //           PlatformDialogAction(
    //             child: Text(S.of(context).ok),
    //             onPressed: () async {
    //               VibrationUtils.vibrateWithClickIfPossible();
    //               UserPreferencesUtils.putSignaturePreference(PostTextFieldUtils.USE_APP_SIGNATURE);
    //               // update provider
    //               Provider.of<UserPreferenceNotifierProvider>(context,listen: false).signature = PostTextFieldUtils.USE_APP_SIGNATURE;
    //               Navigator.of(context).pop();
    //               EasyLoading.showInfo(S.of(context).acknowledgeAppSignatureAndAdDiminish);
    //             },
    //           ),
    //           PlatformDialogAction(
    //             child: Text(S.of(context).cancel),
    //             onPressed: (){
    //               VibrationUtils.vibrateWithClickIfPossible();
    //               Navigator.of(context).pop();
    //             },
    //           )
    //         ],
    //       )
    //   );
    // }

    // check with push service
    if (mounted) await triggerNotification();
  }

  Future<void> triggerNotification() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
        providesAppNotificationSettings: true);
    if (!mounted) return;

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      Provider.of<UserPreferenceNotifierProvider>(context, listen: false)
          .allowPush = true;
      await UserPreferencesUtils.putPushPreference(true);
    } else {
      Provider.of<UserPreferenceNotifierProvider>(context, listen: false)
          .allowPush = false;
      await UserPreferencesUtils.putPushPreference(false);
      if (!mounted) return;
      await showPlatformAlert(
        context: context,
        title: _pageTitle(context),
        message: S.of(context).pushNotificationPermissionNotAuthorized,
        actions: [
          PlatformAlertAction(
            label: S.of(context).ok,
            isDefaultAction: true,
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 64,
                ),
                PlatformLiquidGlassAvatar(
                  size: 128,
                  child: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(
                      PlatformIcons(context).cube,
                      color: Colors.white,
                      size: 72,
                    ),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  _pageTitle(context),
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontSize: 30),
                ),
                SizedBox(
                  height: 6,
                ),
                Text(
                  S.of(context).welcomeSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 18,
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 30,
                ),
                // PlatformCard(
                //
                //   color: Colors.indigo,
                //   child: Padding(
                //     padding: EdgeInsets.symmetric(vertical: 8.0,horizontal: 4.0),
                //     child: PlatformListTile(
                //       leading: Icon(Icons.stop_circle_rounded,color: Colors.white, size: 40,),
                //       // leading: CircleAvatar(
                //       //   backgroundColor: Colors.white,
                //       //   child: Icon(PlatformIcons(context).checkMarkCircled,color: Colors.green),
                //       // ),
                //       title: Text(S.of(context).upgrade_notification_title,
                //         style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                //       ),
                //       subtitle: Text(S.of(context).upgrade_notification_subtitle,
                //           style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal)
                //       ),
                //       onTap: (){
                //         VibrationUtils.vibrateWithClickIfPossible();
                //         Discuz? discuz =
                //             Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz;
                //         bool allowPush =
                //             Provider.of<UserPreferenceNotifierProvider>(context, listen: false).allowPush;
                //         if(discuz != null){
                //           if(allowPush){
                //             Navigator.push(context,platformPageRoute(context:context,builder: (context) => SubscribeChannelPage()));
                //           }
                //           else{
                //             EasyLoading.showError(S.of(context).pushServiceOff);
                //           }
                //         }
                //         else{
                //           EasyLoading.showError(S.of(context).noDiscuzNotFound);
                //         }
                //       },
                //     ),
                //   ),
                // ),
                PlatformListTile(
                  leading: _featureLeading(
                    backgroundColor: Colors.redAccent,
                    icon: CupertinoIcons.hand_raised_fill,
                    foregroundColor: Colors.white,
                  ),
                  title: Text(S.of(context).preventAbuseUser),
                  subtitle: Text(
                    S.of(context).preventAbuseUserDescription,
                    softWrap: true,
                  ),
                  isThreeLine: true,
                  contentPadding: _featureContentPadding,
                ),
                PlatformListTile(
                  leading: _featureLeading(
                    backgroundColor: Colors.green,
                    icon: PlatformIcons(context).secure,
                    foregroundColor: Colors.white,
                  ),
                  title: Text(S.of(context).privacyProtectTitle),
                  subtitle: Text(
                    S.of(context).privacyProtectSubtitle,
                    softWrap: true,
                  ),
                  isThreeLine: true,
                  contentPadding: _featureContentPadding,
                  onTap: () {
                    VibrationUtils.vibrateWithClickIfPossible();
                    URLUtils.launchURL(
                        "https://discuzhub.kidozh.com/privacy_policy/");
                  },
                ),
                PlatformListTile(
                  leading: _featureLeading(
                    backgroundColor: Colors.amber,
                    icon: PlatformIcons(context).chart,
                    foregroundColor: Colors.black,
                  ),
                  title: Text(S.of(context).useGoogleAnalyticsTitle),
                  subtitle: Text(
                    S.of(context).useGoogleAnalyticsContent,
                    softWrap: true,
                  ),
                  isThreeLine: true,
                  contentPadding: _featureContentPadding,
                  onTap: () {
                    VibrationUtils.vibrateWithClickIfPossible();
                    URLUtils.launchURL("https://policies.google.com/privacy");
                  },
                ),
                PlatformListTile(
                  leading: _featureLeading(
                    backgroundColor: Colors.indigo,
                    icon: PlatformIcons(context).checkMark,
                    foregroundColor: Colors.white,
                  ),
                  title: Text(S.of(context).termsOfService),
                  subtitle: Text(
                    S.of(context).termsOfUseDescription,
                    softWrap: true,
                  ),
                  isThreeLine: true,
                  contentPadding: _featureContentPadding,
                  onTap: () {
                    VibrationUtils.vibrateWithClickIfPossible();
                    URLUtils.launchURL(
                        "https://discuzhub.kidozh.com/zh/term_of_use/");
                  },
                ),
                //Divider(),
                // PlatformListTile(
                //   leading: CircleAvatar(
                //     backgroundColor: Colors.purple,
                //     child: Icon(Icons.menu_open,color: Colors.white,),
                //   ),
                //   title: Text(S.of(context).openSoftwareTitle),
                //   subtitle: Text(S.of(context).openSoftwareSubtitle),
                //   onTap: (){
                //     VibrationUtils.vibrateWithClickIfPossible();
                //     URLUtils.launchURL("https://github.com/kidozh/discuz_flutter");
                //   },
                // ),
                SizedBox(
                  height: 24,
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                        child: PlatformElevatedButton(
                      onPressed: () async {
                        final version = widget.version ??
                            (await PackageInfo.fromPlatform()).version;
                        await UserPreferencesUtils.putAcceptVersionCodeFlag(
                            version);
                        if (context.mounted) Navigator.pop(context);
                      },
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        S.of(context).continueToDo,
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer),
                      ),
                    ))
                  ],
                ),
              ],
            )));
  }
}
