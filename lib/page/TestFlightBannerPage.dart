
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
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

    bool? enablePush = await UserPreferencesUtils.checkPushPreference();
    if(enablePush == null){
      // prompt push notification
      await showPlatformDialog(
          context: context,
          builder: (_) => PlatformAlertDialog(
            title: Text(S.of(context).pushNotificationEnable),
            content: Text(S.of(context).pushServiceEnableDescription),
            actions: [
              PlatformDialogAction(
                child: Text(S.of(context).ok),
                onPressed: () async {
                  VibrationUtils.vibrateWithClickIfPossible();
                  Provider.of<UserPreferenceNotifierProvider>(context,listen: false).allowPush = true;
                  await UserPreferencesUtils.putPushPreference(true);
                  EasyLoading.showSuccess(S.of(context).pushServiceOnDescription);
                  Navigator.of(context).pop();
                },
              ),
              PlatformDialogAction(
                child: Text(S.of(context).cancel),
                onPressed: (){
                  VibrationUtils.vibrateWithClickIfPossible();
                  Navigator.of(context).pop();
                },
              )
            ],
          )
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
              Text(S.of(context).welcomeTitle, style: Theme.of(context).textTheme.headline6!.copyWith(
                fontSize: 30
              ),),
              SizedBox(height: 6,),
              Text(S.of(context).welcomeSubtitle,style: Theme.of(context).textTheme.bodyText2!.copyWith(
                  fontSize: 18,

              ),textAlign: TextAlign.center,),
              SizedBox(height: 30,),
              Card(

                color: Colors.green,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0,horizontal: 4.0),
                  child: ListTile(
                    leading: Icon(PlatformIcons(context).checkMarkCircled,color: Colors.white, size: 40,),
                    // leading: CircleAvatar(
                    //   backgroundColor: Colors.white,
                    //   child: Icon(PlatformIcons(context).checkMarkCircled,color: Colors.green),
                    // ),
                    //title: Text(S.of(context).upgrade_notification_title, style: TextStyle(color: Colors.white),),
                    title: Text(S.of(context).upgrade_notification_subtitle, style: TextStyle(color: Colors.white)),
                    onTap: (){
                      VibrationUtils.vibrateWithClickIfPossible();
                      URLUtils.launchURL("https://discuzhub.kidozh.com/dev-blog/");
                    },
                  ),
                ),
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.redAccent,
                  child: Icon(CupertinoIcons.hand_raised_fill,color: Colors.white),
                ),
                title: Text(S.of(context).preventAbuseUser),
                subtitle: Text(S.of(context).preventAbuseUserDescription),
              ),
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
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.purple,
                  child: Icon(Icons.menu_open,color: Colors.white,),
                ),
                title: Text(S.of(context).openSoftwareTitle),
                subtitle: Text(S.of(context).openSoftwareSubtitle),
                onTap: (){
                  VibrationUtils.vibrateWithClickIfPossible();
                  URLUtils.launchURL("https://github.com/kidozh/discuz_flutter");
                },
              ),
              SizedBox(height: 24,),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(child: PlatformElevatedButton(
                      child: Text(S.of(context).continueToDo, style: TextStyle(color: Theme.of(context).primaryTextTheme.bodyText1?.color),),
                      onPressed: () async {
                    PackageInfo packageInfo = await PackageInfo.fromPlatform();
                    String version = packageInfo.version;
                    await UserPreferencesUtils.putAcceptVersionCodeFlag(version);
                    Navigator.pop(context);
                  },
                    color: Theme.of(context).primaryColor,


                  ))

                ],
              ),

            ],
          )
      )
    );
  }

}