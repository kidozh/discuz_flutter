

import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/ExploreWebsitePage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/ConfigurationScreen.dart';
import 'package:discuz_flutter/screen/DiscuzMessageScreen.dart';
import 'package:discuz_flutter/screen/DiscuzPortalScreen.dart';
import 'package:discuz_flutter/screen/FavoriteThreadScreen.dart';
import 'package:discuz_flutter/screen/HotThreadScreen.dart';
import 'package:discuz_flutter/screen/NotificationScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

class ExclusiveApp extends StatelessWidget{
  Discuz _discuz;

  ExclusiveApp(this._discuz);

  @override
  Widget build(BuildContext context) {
    return ExclusiveAppStatefulWidget(this._discuz);
  }
}

class ExclusiveAppStatefulWidget extends StatefulWidget{
  Discuz _discuz;

  ExclusiveAppStatefulWidget(this._discuz);

  @override
  ExclusiveAppState createState() {
    return ExclusiveAppState(this._discuz);
  }

}

class ExclusiveAppState extends State<ExclusiveAppStatefulWidget>{

  Discuz _discuz;
  ExclusiveAppState(this._discuz);

  late PlatformTabController tabController;

  late List<Widget> tabs;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    tabController = PlatformTabController(
      initialIndex: 0,
    );

    Provider.of<DiscuzAndUserNotifier>(context, listen: false).setDiscuz(_discuz);

    tabs = [
      ExploreWebsitePage(),
      DiscuzPortalScreen(),
      HotThreadScreen(),
      ConfigurationScreen(),
      // NotificationScreen(),
      // FavoriteThreadScreen(),
      // DiscuzMessageScreen()
    ];
  }



  @override
  Widget build(BuildContext context) {
    return PlatformTabScaffold(
      iosContentBottomPadding: true,
      iosContentPadding: true,
      tabController: tabController,
      materialTabs: (_,__) => MaterialNavBarData(
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
      ),
      appBarBuilder: (_,index) => PlatformAppBar(
        title: Text(_discuz.siteName),
        automaticallyImplyLeading: false,
      ),
      items: [
        BottomNavigationBarItem(
            icon: new Icon(CupertinoIcons.today),
            label: S.of(context).sitePage),
        BottomNavigationBarItem(
            icon: new Icon(Icons.home),
            label: S.of(context).index),
        BottomNavigationBarItem(
            icon: new Icon(Icons.dashboard),
            label: S.of(context).dashboard),
        // BottomNavigationBarItem(
        //     icon: new Icon(PlatformIcons(context).info),
        //     label: S.of(context).notification),
        // BottomNavigationBarItem(
        //     icon: new Icon(PlatformIcons(context).star),
        //
        //     label: S.of(context).favorites),
        // BottomNavigationBarItem(
        //     icon: new Icon(PlatformIcons(context).mailSolid),
        //
        //     label: S.of(context).chatMessage),
        BottomNavigationBarItem(
            icon: new Icon(Icons.supervised_user_circle_sharp),

            label: S.of(context).chatMessage),
      ],
      bodyBuilder: (context, index) => IndexedStack(
        index: index,
        children: tabs,
      ),

    );
  }

}