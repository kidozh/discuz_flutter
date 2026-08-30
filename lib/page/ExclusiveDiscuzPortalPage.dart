import 'package:discuz_flutter/dao/UserDao.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/ExploreWebsitePage.dart';
import 'package:discuz_flutter/page/TestFlightBannerPage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/ConfigurationScreen.dart';
import 'package:discuz_flutter/screen/DiscuzPortalScreen.dart';
import 'package:discuz_flutter/screen/HotThreadScreen.dart';
import 'package:discuz_flutter/screen/NotificationScreen.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class ExclusiveDiscuzPortalPage extends StatelessWidget {
  Discuz _discuz;

  ExclusiveDiscuzPortalPage(this._discuz);

  @override
  Widget build(BuildContext context) {
    return ExclusiveDiscuzPortalStatefulWidget(this._discuz);
  }
}

class ExclusiveDiscuzPortalStatefulWidget extends StatefulWidget {
  Discuz _discuz;

  ExclusiveDiscuzPortalStatefulWidget(this._discuz);

  @override
  ExclusiveDiscuzPortalState createState() {
    return ExclusiveDiscuzPortalState(this._discuz);
  }
}

class ExclusiveDiscuzPortalState
    extends State<ExclusiveDiscuzPortalStatefulWidget> {
  Discuz _discuz;
  ExclusiveDiscuzPortalState(this._discuz);

  late UserDao _userDao;

  void _initDb() async {
    Provider.of<DiscuzAndUserNotifier>(context, listen: false)
        .setDiscuz(_discuz);
    _userDao = await AppDatabase.getUserDao();
    await _setFirstUserInDiscuz(_discuz);
  }

  Future<void> _setFirstUserInDiscuz(Discuz discuz) async {
    List<User> userList = await _userDao.findAllUsersByDiscuz(discuz);
    if (userList.isNotEmpty && userList.length > 0) {
      print("find a user in the database ${userList.length}");
      Provider.of<DiscuzAndUserNotifier>(context, listen: false)
          .setUser(userList.last);
      // might need to refresh the layout
    }
  }

  _showNotificationIfFirstlyShown() async {
    String flag = await UserPreferencesUtils.getAcceptVersionCodeFlag();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    if (flag != version) {
      // shown
      Navigator.push(
          context,
          platformPageRoute(
              //iosTitle: S.of(context).testVersion,
              context: context,
              builder: (context) => TestFlightBannerPage()));
    }
  }

  @override
  void initState() {
    super.initState();

    _initDb();

    _showNotificationIfFirstlyShown();
  }

  @override
  Widget build(BuildContext context) {
    return PlatformTabScaffold(
      tabDestinations: [
        TabDestination(
          inactiveIcon: Icon(PlatformIcons(context).globe),
          label: S.of(context).sitePage,
          view: _buildTab(ExploreWebsitePage(key: ValueKey(0))),
        ),
        TabDestination(
          inactiveIcon: Icon(PlatformIcons(context).home),
          label: S.of(context).index,
          view: _buildTab(DiscuzPortalScreen(key: ValueKey(1))),
        ),
        TabDestination(
          inactiveIcon: Icon(PlatformIcons(context).dashboard),
          label: S.of(context).dashboard,
          view: _buildTab(HotThreadScreen()),
        ),
        TabDestination(
          inactiveIcon: Icon(PlatformIcons(context).notificationOutline),
          label: S.of(context).notification,
          view: _buildTab(NotificationScreen()),
        ),
        TabDestination(
          inactiveIcon: Icon(PlatformIcons(context).settings),
          label: S.of(context).settings,
          view: _buildTab(ConfigurationScreen()),
        ),
      ],
    );
  }

  Widget _buildTab(Widget body) => PlatformScaffold(
        appBar: PlatformAppBar(
          title: Text(_discuz.siteName),
          automaticallyImplyLeading: false,
        ),
        body: body,
      );

  @override
  void setState(fn) {
    if (this.mounted) {
      super.setState(fn);
    }
  }
}
