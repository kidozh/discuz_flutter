


import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/NewThreadScreen.dart';
import 'package:discuz_flutter/screen/NullDiscuzScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

import '../generated/l10n.dart';
import 'HotThreadScreen.dart';

class DashboardScreen extends StatelessWidget{
  final ValueChanged<int>? onSelectTid;

  DashboardScreen({this.onSelectTid});

  @override
  Widget build(BuildContext context) {

    return Consumer<DiscuzAndUserNotifier>(
      builder: (BuildContext context, DiscuzAndUserNotifier value, Widget? child) {
        if(value.discuz == null){
          return NullDiscuzScreen();
        }

        return PlatformWidgetBuilder(
          material: (context,child,target){
            return MaterialDashboardScreen(onSelectTid: onSelectTid,);
          },
          cupertino: (context, child, target){
            return SafeArea(
                bottom: false,
                child: CupertinoDashboardScreen(onSelectTid: onSelectTid)
            );
          },
        );
      },
    );

  }

}

class MaterialDashboardScreen extends StatelessWidget{
  final ValueChanged<int>? onSelectTid;

  MaterialDashboardScreen({this.onSelectTid});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(
                  icon: Icon(
                    CupertinoIcons.today_fill,
                    semanticLabel: S.of(context).newThread,
                  ),
                  //text: S.of(context).newThread,
                ),
                Tab(
                  icon: Icon(
                    Icons.whatshot,
                    semanticLabel: S.of(context).hotThread,
                  ),

                  //text: S.of(context).hotThread,
                ),

              ],
              labelColor: Theme.of(context).colorScheme.primary,
              indicatorColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).brightness == Brightness.light?  Colors.black54 : Colors.white54,
              unselectedLabelStyle: Theme.of(context).brightness == Brightness.light? Theme.of(context).textTheme.bodyMedium: Theme.of(context).textTheme.titleMedium,

            ),
            Expanded(
              child: TabBarView(children: [
                NewThreadScreen(onSelectTid: onSelectTid,),
                HotThreadScreen(onSelectTid: this.onSelectTid,)
              ]),
            )
          ],
        ));
  }

}



class CupertinoDashboardScreen extends StatelessWidget{
  final ValueChanged<int>? onSelectTid;

  CupertinoDashboardScreen({this.onSelectTid});

  @override
  Widget build(BuildContext context) {
    return CupertinoDashboardStatefulWidget(onSelectTid: onSelectTid,);
  }

}

class CupertinoDashboardStatefulWidget extends StatefulWidget{
  final ValueChanged<int>? onSelectTid;

  CupertinoDashboardStatefulWidget({this.onSelectTid});

  @override
  CupertinoDashboardState createState() {

    return CupertinoDashboardState(onSelectTid: this.onSelectTid);
  }

}

class CupertinoDashboardState extends State<CupertinoDashboardStatefulWidget>{
  final ValueChanged<int>? onSelectTid;

  CupertinoDashboardState({this.onSelectTid});

  int _selectedScreenIndex = 0;
  @override
  Widget build(BuildContext context) {
    //log("Dash board when loading it ${onSelectTid}");
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          width: double.infinity,
          child: Padding(padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: CupertinoSlidingSegmentedControl<int>(
                children: <int, Widget>{
                  0: Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text(S.of(context).newThread),),
                  1: Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text(S.of(context).hotThread),)
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
              NewThreadScreen(onSelectTid: onSelectTid,),
              HotThreadScreen(onSelectTid: onSelectTid,),

            ][_selectedScreenIndex]
        )
      ],
    );
  }

}