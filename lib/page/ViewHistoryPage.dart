


import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/dao/ViewHistoryDao.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/entity/ViewHistory.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/BlankScreen.dart';
import 'package:discuz_flutter/screen/EmptyListScreen.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/TimeDisplayUtils.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'DisplayForumSliverPage.dart';
import 'ViewThreadSliverPage.dart';

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
    ViewHistoryDao viewHistoryDao = await AppDatabase.getViewHistoryDao();
    setState(() {
      _viewHistoryDao = viewHistoryDao;
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

    ViewHistoryDao viewHistoryDao = await AppDatabase.getViewHistoryDao();
    await viewHistoryDao.deleteViewHistoryByDiscuz(discuz);
    Navigator.pop(context);

  }

  Future<void> _deleteViewHistory(ViewHistory viewHistory) async{

    var viewHistoryDao = await AppDatabase.getViewHistoryDao();
    viewHistoryDao.deleteViewHistories([viewHistory]);

    ScaffoldMessenger.of(context)
        .showSnackBar(
        SnackBar(
          content: Text(S.of(context).successfullyDeleteViewHistoryContent("${viewHistory.subject}")),
          action: SnackBarAction(
            label: S.of(context).undo,
            onPressed: (){
              viewHistoryDao.insertViewHistory(viewHistory);
            },
          )
      )
    );
  }

  Widget getUserAvatar(int uid, String username){
    return CachedNetworkImage(
      imageUrl: URLUtils.getAvatarURL(discuz, uid.toString()),
      progressIndicatorBuilder: (context, url, downloadProgress) => CircularProgressIndicator(value: downloadProgress.progress),
      errorWidget: (context, url, error) => Container(
        // width: 16.0,
        // height: 16.0,
        child: CircleAvatar(
          backgroundColor: CustomizeColor.getColorBackgroundById(uid),
          child: Text(
            username.length != 0
                ? username[0].toUpperCase()
                : S.of(context).anonymous,
            style: TextStyle(color: Colors.white,fontSize: 18),
          ),
        ),
      ),
      imageBuilder: (context, imageProvider) => Container(
        // width: 16.0,
        // height: 16.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
              image: imageProvider, fit: BoxFit.cover),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if(_viewHistoryDao != null){
      return PlatformScaffold(
        appBar: PlatformAppBar(
          title: Text(S.of(context).viewHistory),
          automaticallyImplyLeading: true,
          trailingActions: [
            PlatformIconButton(
              onPressed: () {
                VibrationUtils.vibrateWithClickIfPossible();
                _showDeleteAllDialog(context);
              },
              //label: S.of(context).clearAllViewHistories,
              icon: Icon(PlatformIcons(context).delete),
            )
          ],
        ),
        body: ValueListenableBuilder(
          valueListenable: _viewHistoryDao!.viewHistoryBox.listenable(),
          builder: (context, Box<ViewHistory> box, widget){
            List<ViewHistory> viewHistoryList = _viewHistoryDao!.findAllViewHistoriesByDiscuz(discuz);
            if(viewHistoryList == null || viewHistoryList.isEmpty){
              return EmptyListScreen();
            }
            else {
              return ListView.builder(
                itemBuilder: (context, index){
                  ViewHistory viewHistory = viewHistoryList[index];
                  return Dismissible(
                    background: Container(color: Colors.pinkAccent),
                    key: Key(viewHistory.key.toString()),
                    child: InkWell(
                      child: Card(
                        child: Column(
                          children: [
                            ListTile(
                              leading: Container(
                                width: 32,
                                child: viewHistory.type == "thread" ?
                                getUserAvatar(viewHistory.authorId, viewHistory.author) :
                                CircleAvatar(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  child: Icon(Icons.forum_outlined, color: Colors.white, size: 16,),
                                )
                                ,
                              ),
                              title: Text(viewHistory.title),
                              subtitle: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  if(viewHistory.type == "thread")
                                    Icon(PlatformIcons(context).person, size: 12,),
                                  if(viewHistory.type == "thread")
                                    Text(viewHistory.author, style: TextStyle(fontSize: 12),),
                                  SizedBox(width: 4,),
                                  Icon(Icons.access_time, size: 12,),
                                  Text(TimeDisplayUtils.getLocaledTimeDisplay(context,viewHistory.updateTime), style: TextStyle(fontSize: 12),)
                                ],
                              ),
                            ),
                          ],
                        ),


                      ),
                      onTap: () async{
                        VibrationUtils.vibrateWithClickIfPossible();
                        User? user = Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
                        if(viewHistory.type == "thread"){
                          await Navigator.push(
                              context,
                              platformPageRoute(context:context,builder: (context) => ViewThreadSliverPage(discuz,user, viewHistory.identification))
                          );
                        }
                        else if(viewHistory.type == "forum"){
                          await Navigator.push(
                              context,
                              platformPageRoute(context:context,builder: (context) => DisplayForumSliverPage(discuz, user, viewHistory.identification))
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
        )
      );
    }
    else{
      return BlankScreen();
    }

  }

}