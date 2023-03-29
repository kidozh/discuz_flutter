

import 'dart:developer';

import 'package:discuz_flutter/screen/NewThreadScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../generated/l10n.dart';
import 'HotThreadScreen.dart';

class DashboardScreen extends StatelessWidget{
  final ValueChanged<int>? onSelectTid;

  DashboardScreen({this.onSelectTid});

  @override
  Widget build(BuildContext context) {
    return PlatformWidgetBuilder(
      material: (context,child,target){
        return MaterialDashboardScreen(onSelectTid: onSelectTid,);
      },
      cupertino: (context, child, target){
        return CupertinoDashboardScreen(onSelectTid: onSelectTid);
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
                  icon: Icon(Icons.whatshot),
                  //text: S.of(context).hotThread,
                ),
                Tab(
                  icon: Icon(CupertinoIcons.today_fill),
                  //text: S.of(context).newThread,
                ),
              ],
              labelColor: Theme.of(context).colorScheme.primary,
              indicatorColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).brightness == Brightness.light?  Colors.black54 : Colors.white54,
              unselectedLabelStyle: Theme.of(context).brightness == Brightness.light? Theme.of(context).textTheme.bodyText2: Theme.of(context).textTheme.subtitle1,

            ),
            Expanded(
              child: TabBarView(children: [
                HotThreadScreen(onSelectTid: this.onSelectTid,),
                NewThreadScreen(onSelectTid: onSelectTid,)
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
    log("Dash board when loading it ${onSelectTid}");
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          width: double.infinity,
          child: Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            child: CupertinoSlidingSegmentedControl<int>(
                children: <int, Widget>{
                  0: Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text(S.of(context).hotThread),),
                  1: Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text(S.of(context).newThread),)
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
              HotThreadScreen(onSelectTid: onSelectTid,),
              NewThreadScreen(onSelectTid: onSelectTid,)
            ][_selectedScreenIndex]
        )
      ],
    );
  }

}