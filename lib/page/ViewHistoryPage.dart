

import 'dart:math' hide log;

import 'package:discuz_flutter/dao/UserDao.dart';
import 'package:discuz_flutter/dao/ViewHistoryDao.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/entity/ViewHistory.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/LoginPage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/BlankScreen.dart';
import 'package:discuz_flutter/screen/EmptyListScreen.dart';
import 'package:discuz_flutter/screen/NullUserScreen.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/DBHelper.dart';
import 'package:discuz_flutter/widget/DiscuzHtmlWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'DisplayForumPage.dart';
import 'ViewThreadPage.dart';

class ViewHistoryPage extends StatelessWidget{
  Discuz discuz;

  ViewHistoryPage(this.discuz);

  @override
  Widget build(BuildContext context) {

    return ViewHistoryStateWidget(discuz);
  }
}

class ViewHistoryStateWidget extends StatefulWidget{
  Discuz discuz;

  ViewHistoryStateWidget(this.discuz);

  @override
  ViewHistoryState createState() {
    // TODO: implement createState
    return ViewHistoryState(discuz);
  }

}

class ViewHistoryState extends State<ViewHistoryStateWidget>{
  Discuz discuz;
  ViewHistoryDao? _viewHistoryDao;



  ViewHistoryState(this.discuz){
    _initDb();
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initDb();

  }

  void _initDb() async {
    final db = await DBHelper.getAppDb();
    setState(() {
      _viewHistoryDao = db.viewHistoryDao;
    });

  }

  void _showDeleteAllDialog(BuildContext context){
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text(S.of(context).clearAllViewHistories),
        content: Text(S.of(context).deleteViewHistoryWarnContent),
        actions: [
          TextButton(onPressed: () async{
            await _clearAllViewHistory();
            Navigator.pop(context);

          }, child: Text(S.of(context).ok))
        ],
      );
    }
    );
  }

  Future<void> _clearAllViewHistory() async{
    final db = await DBHelper.getAppDb();
    ViewHistoryDao viewHistoryDao = db.viewHistoryDao;
    await viewHistoryDao.deleteAllHistories();
    Navigator.pop(context);

  }

  Future<void> _deleteViewHistory(ViewHistory viewHistory) async{
    final db = await DBHelper.getAppDb();
    var viewHistoryDao = db.viewHistoryDao;
    int primaryKey = await viewHistoryDao.deleteViewHistories([viewHistory]);
    print("delete primary key ${primaryKey} ${viewHistory.id}");
    ScaffoldMessenger.of(context)
        .showSnackBar(
        SnackBar(
          content: Text(S.of(context).successfullyDeleteViewHistoryContent("${viewHistory.subject} ($primaryKey)")),
          action: SnackBarAction(
            label: S.of(context).undo,
            onPressed: (){
              viewHistoryDao.insertViewHistory(viewHistory);
            },
          )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if(_viewHistoryDao != null){
      return Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).viewHistory),
        ),
        body: StreamBuilder(
            stream: _viewHistoryDao!.findAllViewHistoriesStreamByDiscuzId(discuz.id!),
            builder: (BuildContext context, AsyncSnapshot<List<ViewHistory>> snapshot){
              List<ViewHistory>? viewHistoryList = snapshot.data;
              if(viewHistoryList == null || viewHistoryList.isEmpty){
                return EmptyListScreen();
              }
              else {
                return ListView.builder(
                  itemBuilder: (context, index){
                    ViewHistory viewHistory = viewHistoryList[index];
                    return Dismissible(
                      background: Container(color: Colors.pinkAccent),
                      key: Key(viewHistory.id.toString()),
                      child: InkWell(
                        child: Card(
                          child: Column(
                            children: [
                              ListTile(
                                leading: Container(
                                  width: 12,
                                  child: viewHistory.type == "thread" ? Icon(Icons.message_outlined, color: Colors.teal,) : Icon(Icons.forum_outlined, color: Colors.blue),
                                ),
                                title: Text(viewHistory.title),
                                subtitle: DiscuzHtmlWidget(discuz,viewHistory.subject.substring(0,min(800,viewHistory.subject.length))),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 2.0,horizontal: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(Icons.access_time, size: 12,),
                                    Text(timeago.format(viewHistory.updateTime), style: TextStyle(fontSize: 12),)
                                  ],
                                ),

                              ),
                            ],
                          ),


                        ),
                        onTap: () async{
                          User? user = Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
                          if(viewHistory.type == "thread"){
                            await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ViewThreadPage(discuz,user, viewHistory.identification))
                            );
                          }
                          else if(viewHistory.type == "forum"){
                            await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => DisplayForumPage(discuz, user, viewHistory.identification))
                            );
                          }
                        },
                      ),
                      onDismissed: (direction) async{
                        await _deleteViewHistory(viewHistory);
                      },
                    );
                  },
                  itemCount: viewHistoryList.length,
                );
              }

            }
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showDeleteAllDialog(context);
          },
          tooltip: S.of(context).clearAllViewHistories,
          child: Icon(Icons.delete_sweep),
        ),
      );
    }
    else{
      return BlankScreen();
    }

  }

}