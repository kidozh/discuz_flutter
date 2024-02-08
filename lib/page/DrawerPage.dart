import 'dart:developer';

import 'package:discuz_flutter/dao/UserDao.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/FavoriteThreadPage.dart';
import 'package:discuz_flutter/page/ShortcutPage.dart';
import 'package:discuz_flutter/page/SubscribeChannelPage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/provider/UserPreferenceNotifierProvider.dart';
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/UserAvatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'BlockUserPage.dart';
import 'FavoriteForumPage.dart';
import 'LoginPage.dart';
import 'ManageAccountPage.dart';
import 'ManageDiscuzPage.dart';
import 'ManageTrustHostPage.dart';
import 'PushServicePage.dart';
import 'SettingPage.dart';
import 'ViewHistoryPage.dart';

class DrawerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DrawerStatefulWidget();
  }
}

class DrawerStatefulWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DrawerState();
  }
}

class DrawerState extends State<DrawerStatefulWidget> {
  late UserDao _userDao;

  @override
  void initState() {
    super.initState();
    _initDb();
  }

  void _initDb() async {
    _userDao = await AppDatabase.getUserDao();
  }

  Widget _buildFunctionNavWidgetList() {
    return ListView(
      padding: EdgeInsets.zero,
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
              await Navigator.push(
                  context,
                  platformPageRoute(
                      context: context,
                      builder: (context) => LoginPage(discuz, null)));
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
                Provider.of<DiscuzAndUserNotifier>(context, listen: false)
                    .discuz;
            if (discuz != null) {
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
          title: Text(S.of(context).favoriteThread),
          leading: Icon(PlatformIcons(context).favoriteSolid),
          onTap: () async {
            Discuz? discuz =
                Provider.of<DiscuzAndUserNotifier>(context, listen: false)
                    .discuz;
            if (discuz != null) {
              VibrationUtils.vibrateWithClickIfPossible();
              await Navigator.push(
                  context,
                  platformPageRoute(
                      context: context,
                      builder: (context) => FavoriteThreadPage()));
            }
          },
        ),
        ListTile(
          title: Text(S.of(context).favoriteForum),
          leading: Icon(PlatformIcons(context).bookmarkSolid),
          onTap: () async {
            Discuz? discuz =
                Provider.of<DiscuzAndUserNotifier>(context, listen: false)
                    .discuz;
            if (discuz != null) {
              VibrationUtils.vibrateWithClickIfPossible();
              await Navigator.push(
                  context,
                  platformPageRoute(
                      context: context,
                      builder: (context) => FavoriteForumPage()));
            }
          },
        ),
        ListTile(
          title: Text(S.of(context).shortcut),
          leading: Icon(AppPlatformIcons(context).shortcutSolid),
          onTap: () async {
            Discuz? discuz =
                Provider.of<DiscuzAndUserNotifier>(context, listen: false)
                    .discuz;
            if (discuz != null) {
              VibrationUtils.vibrateWithClickIfPossible();
              await Navigator.push(
                  context,
                  platformPageRoute(
                      context: context, builder: (context) => ShortcutPage()));
            }
          },
        ),
        ListTile(
          title: Text(S.of(context).blockedUserList),
          leading: Icon(PlatformIcons(context).removeCircledSolid),
          onTap: () async {
            Discuz? discuz =
                Provider.of<DiscuzAndUserNotifier>(context, listen: false)
                    .discuz;

            if (discuz != null) {
              VibrationUtils.vibrateWithClickIfPossible();
              await Navigator.push(
                  context,
                  platformPageRoute(
                      context: context,
                      builder: (context) => BlockUserPage(discuz)));
            }
          },
        ),
        ListTile(
          title: Text(S.of(context).trustHostTitle),
          leading: Icon(PlatformIcons(context).checkMarkCircledSolid),
          onTap: () async {
            VibrationUtils.vibrateWithClickIfPossible();
            await Navigator.push(
                context,
                platformPageRoute(
                    context: context,
                    builder: (context) => ManageTrustHostPage()));
          },
        ),
        // Consumer<UserPreferenceNotifierProvider>(
        //   builder: (context, userPreference, child) {
        //     if (userPreference.allowPush) {
        //       return ListTile(
        //         title: Text(S.of(context).pushNotification),
        //         leading: Icon(AppPlatformIcons(context).pushServiceSolid),
        //
        //         onTap: () async {
        //           VibrationUtils.vibrateWithClickIfPossible();
        //           await Navigator.push(
        //               context,
        //               platformPageRoute(
        //                   context: context,
        //                   builder: (context) => PushServicePage()));
        //         },
        //       );
        //     } else {
        //       return Container();
        //     }
        //   },
        // ),
        // ListTile(
        //   title: Text(S.of(context).subscribeChannel),
        //   leading: Icon(AppPlatformIcons(context).subscribeChannelSolid),
        //   onTap: () async {
        //     VibrationUtils.vibrateWithClickIfPossible();
        //     await Navigator.push(
        //         context,
        //         platformPageRoute(
        //             context: context,
        //             builder: (context) => SubscribeChannelPage()));
        //   },
        // ),
        ListTile(
          title: Text(S.of(context).settingTitle),
          leading: Icon(PlatformIcons(context).settingsSolid),
          onTap: () async {
            VibrationUtils.vibrateWithClickIfPossible();
            await Navigator.push(
                context,
                platformPageRoute(
                    context: context, builder: (context) => SettingPage()));
          },
        )
      ],
    );
  }

  void _toggleNavigationStatus() {
    setState(() {
      _showUserDetail = !_showUserDetail;
    });
  }

  Widget _buildUserNavigationWidgetList() {
    Discuz? discuz =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz;
    if (discuz != null) {
      log("Get discuz id ${discuz.key}");
      return ValueListenableBuilder(
        valueListenable: _userDao.userBox.listenable(),
        builder: (BuildContext context, Box<User> value, Widget? child) {
          List<User> userList = _userDao.findAllUsersByDiscuz(discuz);
          if (userList.isEmpty) {
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
            return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: userList.length + 1,
                itemBuilder: (context, position) {
                  if (position != userList.length) {
                    User user = userList[position];
                    return ListTile(
                        onTap: () {
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
                            backgroundColor:
                                CustomizeColor.getColorBackgroundById(user.uid),
                            child: Text(
                              user.username.length != 0
                                  ? user.username[0].toUpperCase()
                                  : S.of(context).anonymous,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ));
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
                currentAccountPicture: Icon(
                  Icons.person_pin,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
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
                currentAccountPicture: UserAvatar(
                  value.discuz!,
                  value.user!.uid,
                  value.user!.username,
                  size: 32,
                ),
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
