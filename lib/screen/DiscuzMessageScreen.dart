import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/NullUserScreen.dart';
import 'package:discuz_flutter/screen/PrivateMessagePortalScreen.dart';
import 'package:discuz_flutter/screen/PublicMessagePortalScreen.dart';
import 'package:flutter/material.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:provider/provider.dart';

import 'NullDiscuzScreen.dart';

class DiscuzMessageScreen extends StatelessWidget {
  DiscuzMessageScreen({required Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformWidgetBuilder(
      material: (context, child, target) {
        return MaterialDiscuzMessageStatefulWidget();
      },
      cupertino: (context, child, target) {
        return CupertinoDiscuzMessageScreen();
      },
    );
  }
}

class MaterialDiscuzMessageStatefulWidget extends StatefulWidget {
  @override
  State<MaterialDiscuzMessageStatefulWidget> createState() {
    // TODO: implement createState
    return MaterialDiscuzMessageState();
  }
}

class MaterialDiscuzMessageState
    extends State<MaterialDiscuzMessageStatefulWidget> {
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
                  labelColor: Theme.of(context).colorScheme.primary,
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor:
                      Theme.of(context).brightness == Brightness.light
                          ? Colors.black54
                          : Colors.white54,
                  unselectedLabelStyle:
                      Theme.of(context).brightness == Brightness.light
                          ? Theme.of(context).textTheme.bodyMedium
                          : Theme.of(context).textTheme.titleMedium,
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

class CupertinoDiscuzMessageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoDiscuzMessageStatefulWidget();
  }
}

class CupertinoDiscuzMessageStatefulWidget extends StatefulWidget {
  @override
  CupertinoDiscuzMessageState createState() {
    return CupertinoDiscuzMessageState();
  }
}

class CupertinoDiscuzMessageState
    extends State<CupertinoDiscuzMessageStatefulWidget> {
  int _selectedScreenIndex = 0;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PlatformLiquidGlassPageBackdrop(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                child: PlatformSegmentedControl(
                  labels: [
                    S.of(context).privateMessage,
                    S.of(context).publicMessage,
                  ],
                  selectedIndex: _selectedScreenIndex,
                  onValueChanged: (value) {
                    setState(() {
                      _selectedScreenIndex = value;
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _selectedScreenIndex,
                children: const [
                  PrivateMessagePortalScreen(
                    key: PageStorageKey<String>('private_messages'),
                  ),
                  PublicMessagePortalScreen(
                    key: PageStorageKey<String>('public_messages'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
