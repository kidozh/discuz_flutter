


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
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/TimeDisplayUtils.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
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
    showPlatformDialog(context: context, builder: (context) {
      return PlatformAlertDialog(
        title: Text(S.of(context).clearAllViewHistories),
        content: Text(S.of(context).deleteViewHistoryWarnContent),
        actions: [
          PlatformTextButton(onPressed: () async{
            VibrationUtils.vibrateWithHeavyFeedbackIfPossible();
            await _clearAllViewHistory();
            Navigator.pop(context);

          }, child: Text(
              S.of(context).ok,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),

          ),
          PlatformTextButton(onPressed: () async{
            VibrationUtils.vibrateWithClickIfPossible();
            Navigator.pop(context);

          }, child: Text(S.of(context).cancel),

          )
        ],
      );
    }
    );
  }

  Future<void> _clearAllViewHistory() async{

    ViewHistoryDao viewHistoryDao = await AppDatabase.getViewHistoryDao();
    await viewHistoryDao.deleteViewHistoryByDiscuz(discuz);
    //Navigator.pop(context);

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
      progressIndicatorBuilder: (context, url, downloadProgress) => PlatformCircularProgressIndicator(
          material: (context, platform) => MaterialProgressIndicatorData(value: downloadProgress.progress),

      ),
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
    if(_viewHistoryDao != null){
      return PlatformScaffold(
        appBar: PlatformAppBar(
          title: Text(S.of(context).viewHistory),
          automaticallyImplyLeading: true,
          trailingActions: [
            IconButton(
              onPressed: () {
                VibrationUtils.vibrateWithClickIfPossible();
                _showDeleteAllDialog(context);
              },
              //label: S.of(context).clearAllViewHistories,
              icon: Icon(AppPlatformIcons(context).deleteSolid, size: isCupertino(context)? 24: null,),
            )
          ],
        ),
        body: ValueListenableBuilder(
          valueListenable: _viewHistoryDao!.viewHistoryBox.listenable(),
          builder: (context, Box<ViewHistory> box, widget){
            List<ViewHistory> viewHistoryList = _viewHistoryDao!.findAllViewHistoriesByDiscuz(discuz);
            if(viewHistoryList.isEmpty){
              return EmptyListScreen(EmptyItemType.history);
            }
            else {
              return ListView.builder(
                itemBuilder: (context, index){
                  ViewHistory viewHistory = viewHistoryList[index];
                  return Dismissible(
                    background: Container(color: Colors.pinkAccent),
                    key: Key(viewHistory.key.toString()),

                    child: InkWell(
                      child: PlatformWidgetBuilder(
                        material: (context, child, platform){
                          return Card(
                              elevation: isCupertino(context)? 0: 4.0,
                              child: child
                          );
                        },
                        cupertino: (context, child, platform){
                          return Column(
                              children: [
                                if(child!=null)
                                  child,
                                Divider()
                          ]);
                        },
                        child: ListTile(
                          leading: Container(
                            width: 48,
                            child: viewHistory.type == "thread" ?
                            getUserAvatar(viewHistory.authorId, viewHistory.author) :
                            CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              child: Icon(
                                AppPlatformIcons(context).forumOutlined,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                                size: 24,
                              ),
                            )
                            ,
                          ),
                          title: Text(viewHistory.title),
                          subtitle: RichText(
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              text: "",
                              style: DefaultTextStyle.of(context).style,
                              children: [
                                if(viewHistory.author.isNotEmpty)
                                  TextSpan(
                                      text: viewHistory.author,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)
                                  ),
                                if(viewHistory.author.isNotEmpty)
                                  TextSpan(
                                      text: ' · ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)
                                  ),

                                TextSpan(
                                    text:  TimeDisplayUtils.getLocaledTimeDisplay(context,viewHistory.updateTime),
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,)
                                ),
                              ],
                            ),
                          ),
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
                              platformPageRoute(context:context,builder: (context) => DisplayForumTwoPanePage(discuz, user, viewHistory.identification))
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