
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class TestFlightBannerPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
        iosContentBottomPadding: true,
        iosContentPadding: true,
        appBar: PlatformAppBar(
          title: Text(S.of(context).testVersionNotificationTitle),
        ),
        body: TestFlightBannerContent()
    );
  }

}

class TestFlightBannerContent extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: double.infinity,height: 24,),
              Container(
                width: 128,
                height: 128,
                child: CircleAvatar(

                  backgroundColor: Colors.blue,
                  child: Icon(Icons.view_in_ar, color: Colors.white, size: 80,),
                ),
              ),
              SizedBox(height: 16,),
              Text(S.of(context).testVersion, style: Theme.of(context).textTheme.headline6!.copyWith(
                fontSize: 30
              ),),
              SizedBox(height: 6,),
              Text(S.of(context).testVersionDescription,style: Theme.of(context).textTheme.bodyText2!.copyWith(
                  fontSize: 18,

              ),textAlign: TextAlign.center,),
              SizedBox(height: 30,),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.redAccent,
                  child: Icon(Icons.bug_report,color: Colors.white),
                ),
                title: Text(S.of(context).bugTestTitle),
                subtitle: Text(S.of(context).bugTestSubtitle),
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.lock_outline,color: Colors.white,),
                ),
                title: Text(S.of(context).privacyProtectTitle),
                subtitle: Text(S.of(context).privacyProtectSubtitle),
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.indigo,
                  child: Icon(Icons.settings_backup_restore_rounded,color: Colors.white,),
                ),
                title: Text(S.of(context).dataBackupInTestTitle),
                subtitle: Text(S.of(context).dataBackupInTestSubtitle),
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.purple,
                  child: Icon(Icons.menu_open,color: Colors.white,),
                ),
                title: Text(S.of(context).openSoftwareTitle),
                subtitle: Text(S.of(context).openSoftwareSubtitle),
              ),
              SizedBox(height: 24,),
              CupertinoButton.filled(child: Text(S.of(context).continueToTest), onPressed: () async {
                await UserPreferencesUtils.putTestFlightNotificationFlag(1);
                Navigator.pop(context);
              })
            ],
          )
      )
    );
  }

}