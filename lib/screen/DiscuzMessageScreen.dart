import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/NullUserScreen.dart';
import 'package:discuz_flutter/screen/PrivateMessagePortalScreen.dart';
import 'package:discuz_flutter/screen/PublicMessagePortalScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

import 'NullDiscuzScreen.dart';

class DiscuzMessageScreen extends StatelessWidget {
  DiscuzMessageScreen({required Key key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformWidgetBuilder(
      material: (context,child,target){
        return MaterialDiscuzMessageStatefulWidget();
      },
      cupertino: (context, child, target){
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

class MaterialDiscuzMessageState extends State<MaterialDiscuzMessageStatefulWidget> {
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

class CupertinoDiscuzMessageScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return CupertinoDiscuzMessageStatefulWidget();
  }

}

class CupertinoDiscuzMessageStatefulWidget extends StatefulWidget{
  @override
  CupertinoDiscuzMessageState createState() {

    return CupertinoDiscuzMessageState();
  }

}

class CupertinoDiscuzMessageState extends State<CupertinoDiscuzMessageStatefulWidget>{
  int _selectedScreenIndex = 0;
  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          width: double.infinity,
          child: Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            child: CupertinoSlidingSegmentedControl<int>(
                children: <int, Widget>{
                  0: Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text(S.of(context).privateMessage),),
                  1: Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text(S.of(context).publicMessage),)
                },
                groupValue: _selectedScreenIndex,
                onValueChanged: (int? value){
                  if(value == null || ![0,1].contains(value)){
                    setState((){
                      _selectedScreenIndex = 0;
                    });
                  }
                  else{
                    setState((){
                      _selectedScreenIndex = value;
                    });
                  }
                }
            ),
          ),
        ),

        Expanded(
            child: [
              PrivateMessagePortalScreen(),
              PublicMessagePortalScreen()
            ][_selectedScreenIndex]
        )
      ],
    );
  }

}