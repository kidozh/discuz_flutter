

import 'package:discuz_flutter/dao/TrustHostDao.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/TrustHost.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/screen/BlankScreen.dart';
import 'package:discuz_flutter/screen/EmptyListScreen.dart';
import 'package:discuz_flutter/utility/TimeDisplayUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ManageTrustHostPage extends StatelessWidget{

  @override
  Widget build(BuildContext context) {

    return PlatformScaffold(
      iosContentPadding: true,
      iosContentBottomPadding: true,
      appBar: PlatformAppBar(
        title: Text(S.of(context).trustHostTitle),
      ),
      body: ManageTrustHostStateWidget(),

    );
  }

}

class ManageTrustHostStateWidget extends StatefulWidget{

  @override
  ManageTrustHostState createState() {
    return ManageTrustHostState();
  }

}

class ManageTrustHostState extends State<ManageTrustHostStateWidget>{
  TrustHostDao? _trustHostDao;



  ManageAccountState(){
    _initDb();
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initDb();

  }

  void _initDb() async {
    TrustHostDao trustHostDao = await AppDatabase.getTrustHostDao();
    setState(() {
      _trustHostDao = trustHostDao;
    });

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if(_trustHostDao != null){
      return ValueListenableBuilder(
          valueListenable: _trustHostDao!.trustHostBox.listenable(),
        builder: (BuildContext context, Box<TrustHost> value, Widget? child) {
            List<TrustHost> list = _trustHostDao!.findAllTrustHosts();
            if(list.isEmpty){
              return EmptyListScreen(EmptyItemType.trustHost);
            }
            else {
              return ListView.builder(
                itemBuilder: (context, index){
                  TrustHost trustHost = list[index];
                  return Dismissible(
                    key: Key(trustHost.key.toString()),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(trustHost.host),
                          subtitle: Text(TimeDisplayUtils.getLocaledTimeDisplay(context, trustHost.trustAt)),
                        ),
                        Divider()
                      ],
                    ),
                    onDismissed: (direction){
                      _untrustHost(trustHost);
                    },
                  );
                },
                itemCount: list.length,
              );
            }

        },
      );
    }
    else{
      return BlankScreen();
    }

  }

  _untrustHost(TrustHost trustHost) async{
    if(_trustHostDao!= null){
      await _trustHostDao!.deleteTrustHost(trustHost);
    }


  }

}