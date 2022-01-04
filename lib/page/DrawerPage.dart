import 'dart:developer';

import 'package:discuz_flutter/dao/UserDao.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/DBHelper.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/UserAvatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

import 'LoginPage.dart';
import 'ManageAccountPage.dart';
import 'ManageDiscuzPage.dart';
import 'ManageTrustHostPage.dart';
import 'SettingPage.dart';
import 'ViewHistoryPage.dart';

class DrawerPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return DrawerStatefulWidget();
  }

}

class DrawerStatefulWidget extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return DrawerState();
  }

}

class DrawerState extends State<DrawerStatefulWidget>{

  late UserDao _userDao;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initDb();
  }

  void _initDb() async {
    final db = await DBHelper.getAppDb();
    _userDao = db.userDao;
    //_discuzDao = db.discuzDao;
  }

  Widget _buildFunctionNavWidgetList() {
    return ListView(
      children: [
        ListTile(
          title: Text(S.of(context).loginTitle),
          subtitle: Text(S.of(context).loginSubtitle),
          leading: Icon(PlatformIcons(context).personAddSolid),
          onTap: () async {
            VibrationUtils.vibrateWithClickIfPossible();
            Discuz? discuz =
                Provider.of<DiscuzAndUserNotifier>(context, listen: false)
                    .discuz;
            if (discuz != null) {
              await Navigator.push(context, platformPageRoute(context:context,builder: (context) => LoginPage(discuz, null)));
            }
          },
        ),
        ListTile(
          title: Text(S.of(context).manageAccount),
          leading: Icon(PlatformIcons(context).groupSolid),
          onTap: () async {
            VibrationUtils.vibrateWithClickIfPossible();
            Discuz? discuz =
                Provider.of<DiscuzAndUserNotifier>(context, listen: false)
                    .discuz;
            if (discuz != null) {
              await Navigator.push(
                  context,
                  platformPageRoute(
                      context: context,
                      builder: (context) => ManageAccountPage(
                        discuz,
                      )));
            }
          },
        ),
        ListTile(
          title: Text(S.of(context).manageDiscuz),
          leading: Icon(PlatformIcons(context).folderSolid),
          onTap: () async {
            VibrationUtils.vibrateWithClickIfPossible();
            await Navigator.push(
                context,
                platformPageRoute(
                    context: context,
                    builder: (context) => ManageDiscuzPage()));
          },
        ),
        ListTile(
          title: Text(S.of(context).viewHistory),
          leading: Icon(PlatformIcons(context).timeSolid),
          onTap: () async {
            Discuz? discuz =
                Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz;
            if(discuz != null){
              VibrationUtils.vibrateWithClickIfPossible();
              await Navigator.push(
                  context,
                  platformPageRoute(
                      context: context,
                      builder: (context) => ViewHistoryPage(discuz)));
            }

          },
        ),
        ListTile(
          title: Text(S.of(context).trustHostTitle),
          leading: Icon(PlatformIcons(context).checkMarkCircledSolid),
          onTap: () async {
            VibrationUtils.vibrateWithClickIfPossible();
            await Navigator.push(context,platformPageRoute(context:context,builder: (context) => ManageTrustHostPage()));
          },
        ),
        ListTile(
          title: Text(S.of(context).settingTitle),
          leading: Icon(PlatformIcons(context).settingsSolid),
          onTap: () async {
            VibrationUtils.vibrateWithClickIfPossible();
            await Navigator.push(context,
                platformPageRoute(context:context,builder: (context) => SettingPage()));
          },
        )
      ],
    );
  }

  void _toggleNavigationStatus(){
    setState(() {
      _showUserDetail = !_showUserDetail;
    });
  }

  Widget _buildUserNavigationWidgetList() {
    Discuz? discuz =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz;
    if (discuz != null) {
      log("Get discuz id ${discuz.id}");
      return StreamBuilder(
        stream: _userDao.findAllUsersStreamByDiscuzId(discuz.id!),
        builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
          if (snapshot.data == null) {
            return ListView(
              children: [
                ListTile(
                    onTap: () {
                      VibrationUtils.vibrateWithClickIfPossible();
                      Provider.of<DiscuzAndUserNotifier>(context, listen: false)
                          .setUser(null);
                      _toggleNavigationStatus();
                    },
                    title: Text(S.of(context).incognitoTitle),
                    subtitle: Text(S.of(context).incognitoTitle),
                    leading: Icon(Icons.person_pin)),
              ],
            );
          } else {
            List<User> userList = snapshot.data!;
            return ListView.builder(
                itemCount: userList.length + 1,
                itemBuilder: (context, position) {

                  if (position != userList.length) {
                    User user = userList[position];
                    return ListTile(
                        onTap: (){
                          VibrationUtils.vibrateWithClickIfPossible();
                          Provider.of<DiscuzAndUserNotifier>(context,
                              listen: false)
                              .setUser(user);
                          _toggleNavigationStatus();
                        },
                        title: Text(user.username),
                        subtitle: Text(S.of(context).userIdTitle(user.uid)),
                        leading: Container(
                          // width: 16.0,
                          // height: 16.0,
                          child: CircleAvatar(
                            backgroundColor: CustomizeColor.getColorBackgroundById(user.uid),
                            child: Text(
                              user.username.length != 0
                                  ? user.username[0].toUpperCase()
                                  : S.of(context).anonymous,
                              style: TextStyle(color: Colors.white,fontSize: 18),
                            ),
                          ),
                        )
                    );
                  } else {
                    return ListTile(
                        onTap: () {
                          VibrationUtils.vibrateWithClickIfPossible();
                          Provider.of<DiscuzAndUserNotifier>(context,
                              listen: false)
                              .setUser(null);
                          _toggleNavigationStatus();
                        },
                        title: Text(S.of(context).incognitoTitle),
                        subtitle: Text(S.of(context).incognitoTitle),
                        leading: Icon(Icons.person_pin));
                  }
                });
          }
        },
      );
    } else {
      return Container();
    }
  }

  bool _showUserDetail = false;


  @override
  Widget build(BuildContext context) {

    return PlatformScaffold(
      appBar: PlatformAppBar(
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          Consumer<DiscuzAndUserNotifier>(builder: (context, value, child) {
            if (value.discuz == null || value.user == null) {
              return UserAccountsDrawerHeader(
                margin: EdgeInsets.zero,
                accountEmail: Text(S.of(context).incognitoSubtitle),
                accountName: Text(S.of(context).incognitoTitle),
                currentAccountPicture: Icon(Icons.person_pin,color: Colors.white,),
                onDetailsPressed: () {
                  setState(() {
                    _showUserDetail = !_showUserDetail;
                  });
                },
              );
            } else {
              return UserAccountsDrawerHeader(
                margin: EdgeInsets.zero,
                accountEmail: Text(value.user!.uid.toString()),
                accountName: Text(value.user!.username),
                currentAccountPicture: UserAvatar(value.discuz!,value.user!),
                onDetailsPressed: () {
                  setState(() {
                    _showUserDetail = !_showUserDetail;
                  });
                },
              );
            }
          }),
          Expanded(
              child: _showUserDetail
                  ? _buildUserNavigationWidgetList()
                  : _buildFunctionNavWidgetList())
        ],
      ),
    );
  }

}