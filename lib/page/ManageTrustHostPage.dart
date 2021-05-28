

import 'package:discuz_flutter/dao/DiscuzDao.dart';
import 'package:discuz_flutter/dao/TrustHostDao.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/TrustHost.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/AddDiscuzPage.dart';
import 'package:discuz_flutter/screen/BlankScreen.dart';
import 'package:discuz_flutter/screen/EmptyListScreen.dart';
import 'package:discuz_flutter/screen/NullUserScreen.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/DBHelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ManageTrustHostPage extends StatelessWidget{

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
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
    final db = await DBHelper.getTrustHostDb();
    setState(() {
      _trustHostDao = db.trustHostDatabaseDao;
    });

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if(_trustHostDao != null){
      return StreamBuilder(
          stream: _trustHostDao!.findAllTrustHostsStream(),
          builder: (BuildContext context, AsyncSnapshot<List<TrustHost>> snapshot){
            List<TrustHost>? list = snapshot.data;
            if(list == null || list.isEmpty){
              return EmptyListScreen();
            }
            else {
              return ListView.builder(
                itemBuilder: (context, index){
                  TrustHost trustHost = list[index];
                  return Dismissible(
                    key: Key(trustHost.id.toString()),
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

          }
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