
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../provider/UserPreferenceNotifierProvider.dart';

class TestFlightBannerPage extends StatelessWidget{

  @override
  Widget build(BuildContext context) {

    return PlatformScaffold(
        iosContentBottomPadding: true,
        iosContentPadding: true,
        body: TestFlightBannerContent()
    );
  }
}

class TestFlightBannerContent extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return TestFlightBannerContentState();
  }

}

class TestFlightBannerContentState extends State<TestFlightBannerContent>{

  @override
  void initState(){
    super.initState();
    _checkPushService(context);

  }

  Future<void> _checkPushService(BuildContext context) async{

    String signaturePreference =
    await UserPreferencesUtils.getSignaturePreference();
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
    await triggerNotification(context);

  }

  Future<void> triggerNotification(BuildContext context) async{
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
      providesAppNotificationSettings: true
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized || settings.authorizationStatus == AuthorizationStatus.provisional){
      Provider.of<UserPreferenceNotifierProvider>(context,listen: false).allowPush = true;
      await UserPreferencesUtils.putPushPreference(true);
    }
    else{
      EasyLoading.showInfo(S.of(context).pushNotificationPermissionNotAuthorized);
      Provider.of<UserPreferenceNotifierProvider>(context,listen: false).allowPush = false;
      await UserPreferencesUtils.putPushPreference(false);
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
              SizedBox(width: double.infinity,height: 64,),
              Container(
                width: 128,
                height: 128,
                child: CircleAvatar(

                  backgroundColor: Colors.blue,
                  child: Icon(Icons.view_in_ar, color: Colors.white, size: 80,),
                ),
              ),
              SizedBox(height: 16,),
              Text(S.of(context).welcomeTitle, style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontSize: 30
              ),),
              SizedBox(height: 6,),
              Text(S.of(context).welcomeSubtitle,style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontSize: 18,

              ),textAlign: TextAlign.center,),
              SizedBox(height: 30,),
              // Card(
              //
              //   color: Colors.indigo,
              //   child: Padding(
              //     padding: EdgeInsets.symmetric(vertical: 8.0,horizontal: 4.0),
              //     child: ListTile(
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
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.redAccent,
                  child: Icon(CupertinoIcons.hand_raised_fill,color: Colors.white),
                ),
                title: Text(S.of(context).preventAbuseUser),
                subtitle: Text(S.of(context).preventAbuseUserDescription),
              ),
              Divider(),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.lock_outline,color: Colors.white,),
                ),
                title: Text(S.of(context).privacyProtectTitle),
                subtitle: Text(S.of(context).privacyProtectSubtitle),
                onTap: (){
                  VibrationUtils.vibrateWithClickIfPossible();
                  URLUtils.launchURL("https://discuzhub.kidozh.com/privacy_policy/");
                },
              ),
              Divider(),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.amber,
                  child: Icon(Icons.query_stats,color: Colors.black,),
                ),
                title: Text(S.of(context).useGoogleAnalyticsTitle),
                subtitle: Text(S.of(context).useGoogleAnalyticsContent),
                onTap: (){
                  VibrationUtils.vibrateWithClickIfPossible();
                  URLUtils.launchURL("https://policies.google.com/privacy");
                },
              ),
              Divider(),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.indigo,
                  child: Icon(Icons.check_outlined,color: Colors.white,),
                ),
                title: Text(S.of(context).termsOfService),
                subtitle: Text(S.of(context).termsOfUseDescription),
                onTap: (){
                  VibrationUtils.vibrateWithClickIfPossible();
                  URLUtils.launchURL("https://discuzhub.kidozh.com/zh/term_of_use/");
                },
              ),
              //Divider(),
              // ListTile(
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
              SizedBox(height: 24,),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(child: PlatformElevatedButton(
                      child: Text(S.of(context).continueToDo, style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),),
                      onPressed: () async {
                    PackageInfo packageInfo = await PackageInfo.fromPlatform();
                    String version = packageInfo.version;
                    await UserPreferencesUtils.putAcceptVersionCodeFlag(version);
                    Navigator.pop(context);
                  },
                    color: Theme.of(context).colorScheme.primaryContainer,


                  ))

                ],
              ),

            ],
          )
      )
    );
  }

}