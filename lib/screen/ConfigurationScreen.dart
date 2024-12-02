import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/LoginPage.dart';
import 'package:discuz_flutter/page/ManageTrustHostPage.dart';
import 'package:discuz_flutter/page/SettingPage.dart';
import 'package:discuz_flutter/page/ViewHistoryPage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/NullDiscuzScreen.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

class ConfigurationScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // user interface
        ConfigurationUserStatefulWidget(),
        Card(
          child: ListTile(
            title: Text(S.of(context).viewHistory),
            leading: Icon(Icons.history),
            onTap: (){
              Discuz? discuz =
                  Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz;
              if(discuz != null){
                VibrationUtils.vibrateWithClickIfPossible();
                Navigator.push(
                    context,
                    platformPageRoute(
                      iosTitle: S.of(context).viewHistory,
                        context: context,
                        builder: (context) => ViewHistoryPage(discuz)));
              }
            },
          ),

        ),
        Card(
          child: ListTile(
            title: Text(S.of(context).trustHostTitle),
            leading: Icon(Icons.check_circle_outline),
            onTap: (){
              VibrationUtils.vibrateWithClickIfPossible();
              Navigator.push(context,platformPageRoute(context:context,builder: (context) => ManageTrustHostPage()));
            },
          ),

        ),
        Card(
          child: ListTile(
            title: Text(S.of(context).settingTitle),
            leading: Icon(PlatformIcons(context).settings),
            onTap: (){
              VibrationUtils.vibrateWithClickIfPossible();
              Discuz? discuz = Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz;
              if (discuz != null) {
                Navigator.push(context,
                    platformPageRoute(context:context,builder: (context) => SettingPage()));
              }
            },
          ),

        ),

      ],
    );
  }

}

class ConfigurationUserStatefulWidget extends StatefulWidget{
  @override
  ConfigurationUserState createState() {
    return ConfigurationUserState();
  }


}

class ConfigurationUserState extends State<ConfigurationUserStatefulWidget>{
  @override
  Widget build(BuildContext context) {


    return Consumer<DiscuzAndUserNotifier>(
      builder: (context, discuzAndUser, _){
        if(discuzAndUser.discuz == null){
          return NullDiscuzScreen();
        }
        else if(discuzAndUser.user == null){
          return Card(
            child: ListTile(
              title: Text(S.of(context).loginTitle),
              leading: Icon(Icons.login),
              onTap: (){
                VibrationUtils.vibrateWithClickIfPossible();
                Discuz? discuz =
                    Provider.of<DiscuzAndUserNotifier>(context, listen: false)
                        .discuz;
                if (discuz != null) {
                  Navigator.push(context, platformPageRoute(context:context,builder: (context) => LoginPage(discuz, null)));
                }
              },
            ),
          );
        }
        else{
          return Card(
            child: ListTile(
              title: Text(discuzAndUser.user!.username),
              subtitle: Text(S.of(context).tapToWipeAndRelogin),
              leading: CircleAvatar(
                child: CachedNetworkImage(
                  imageUrl:
                  URLUtils.getLargeAvatarURL(discuzAndUser.discuz!, discuzAndUser.user!.uid.toString()),
                  progressIndicatorBuilder:
                      (context, url, downloadProgress) =>
                      CircularProgressIndicator(
                          value: downloadProgress.progress),
                  errorWidget: (context, url, error) => Container(
                    width: 100.0,
                    height: 100.0,
                    child: CircleAvatar(
                      backgroundColor:
                      CustomizeColor.getColorBackgroundById(discuzAndUser.user!.uid),
                      child: Text(
                        discuzAndUser.user!.username
                            .length !=
                            0
                            ? discuzAndUser.user!.username[0]
                            .toUpperCase()
                            : S.of(context).anonymous,
                        style: TextStyle(
                            color: Colors.white, fontSize: 45),
                      ),
                    ),
                  ),
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
              onTap: () async{
                VibrationUtils.vibrateWithClickIfPossible();
                // wipe out first
                if(discuzAndUser.user != null){
                  var _userDao = await AppDatabase.getUserDao();
                  await _userDao.deleteUser(discuzAndUser.user!);
                  Provider.of<DiscuzAndUserNotifier>(context, listen: false).setUser(null);
                }
                await Navigator.push(context, platformPageRoute(context:context,builder: (context) => LoginPage(discuzAndUser.discuz!, null)));
              },
            ),

          );

        }
      },
    );
  }

  @override
  void setState(fn) {
    if(this.mounted) {
      super.setState(fn);
    }
  }

}
