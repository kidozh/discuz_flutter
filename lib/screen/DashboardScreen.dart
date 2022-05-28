

import 'package:discuz_flutter/screen/NewThreadScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../generated/l10n.dart';

import 'HotThreadScreen.dart';

class DashboardScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return PlatformWidgetBuilder(
      material: (context,child,target){
        return MaterialDashboardScreen();
      },
      cupertino: (context, child, target){
        return CupertinoDashboardScreen();
      },
    );
  }

}

class MaterialDashboardScreen extends StatelessWidget{
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
              labelColor: Theme.of(context).primaryColor,
              indicatorColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Theme.of(context).brightness == Brightness.light?  Colors.black54 : Colors.white54,
              unselectedLabelStyle: Theme.of(context).brightness == Brightness.light? Theme.of(context).textTheme.bodyText2: Theme.of(context).textTheme.subtitle1,

            ),
            Expanded(
              child: TabBarView(children: [
                HotThreadScreen(key: UniqueKey(),),
                NewThreadScreen()
              ]),
            )
          ],
        ));
  }

}



class CupertinoDashboardScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return CupertinoDashboardStatefulWidget();
  }

}

class CupertinoDashboardStatefulWidget extends StatefulWidget{
  @override
  CupertinoDashboardState createState() {

    return CupertinoDashboardState();
  }

}

class CupertinoDashboardState extends State<CupertinoDashboardStatefulWidget>{
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
              HotThreadScreen(key: UniqueKey(),),
              NewThreadScreen()
            ][_selectedScreenIndex]
        )
      ],
    );
  }

}