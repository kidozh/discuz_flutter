

import 'package:discuz_flutter/dao/TrustHostDao.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/TrustHost.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/screen/BlankScreen.dart';
import 'package:discuz_flutter/screen/EmptyListScreen.dart';
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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async{
      //     await Navigator.push(context,
      //         MaterialPageRoute(builder: (context) => AddDiscuzPage()));
      //   },
      //   tooltip: S.of(context).trustHostTitle,
      //   child: Icon(Icons.add),
      // ),
    );
  }

}

class ManageTrustHostStateWidget extends StatefulWidget{

  @override
  ManageTrustHostState createState() {
    // TODO: implement createState
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

    setState(() async {
      _trustHostDao = await AppDatabase.getTrustHostDao();
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
            if(list == null || list.isEmpty){
              return EmptyListScreen();
            }
            else {
              return ListView.builder(
                itemBuilder: (context, index){
                  TrustHost trustHost = list[index];
                  return Dismissible(
                    key: Key(trustHost.key),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(trustHost.host),
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