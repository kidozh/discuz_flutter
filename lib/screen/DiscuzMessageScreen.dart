import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/NullUserScreen.dart';
import 'package:discuz_flutter/screen/PrivateMessagePortalScreen.dart';
import 'package:discuz_flutter/screen/PublicMessagePortalScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'NullDiscuzScreen.dart';

class DiscuzMessageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DiscuzMessageStatefulWidget();
  }
}

class DiscuzMessageStatefulWidget extends StatefulWidget {
  @override
  State<DiscuzMessageStatefulWidget> createState() {
    // TODO: implement createState
    return DiscuzMessageState();
  }
}

class DiscuzMessageState extends State<DiscuzMessageStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Consumer<DiscuzAndUserNotifier>(
        builder: (context, discuzAndUser, child) {
      if (discuzAndUser.discuz == null) {
        return NullDiscuzScreen();
      } else if (discuzAndUser.user == null) {
        return NullUserScreen();
      } else {
        return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                    tabs: [

                  Tab(
                    icon: Icon(Icons.chat_bubble_rounded),
                    //text: S.of(context).privateMessage,
                  ),
                  Tab(
                    icon: Icon(Icons.campaign_rounded),
                    //text: S.of(context).publicMessage,
                  ),
                ],
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Theme.of(context).brightness == Brightness.light?  Colors.black54 : Colors.white54,
                  unselectedLabelStyle: Theme.of(context).brightness == Brightness.light? Theme.of(context).textTheme.bodyText2: Theme.of(context).textTheme.subtitle1,

                ),
                Expanded(
                  child: TabBarView(children: [
                    PrivateMessagePortalScreen(),
                    PublicMessagePortalScreen()
                  ]),
                )
              ],
            ));
      }
    });
  }
}
