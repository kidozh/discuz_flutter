
import 'dart:developer';

import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/dao/BlockUserDao.dart';
import 'package:discuz_flutter/dao/ViewHistoryDao.dart';
import 'package:discuz_flutter/entity/BlockUser.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/HotThread.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/entity/ViewHistory.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/UserProfilePage.dart';
import 'package:discuz_flutter/page/ViewThreadSliverPage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/utility/ConstUtils.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/DBHelper.dart';
import 'package:discuz_flutter/utility/TimeDisplayUtils.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class HotThreadWidget extends StatelessWidget{

  HotThread _hotThread;
  Discuz _discuz;
  User? _user;

  HotThreadWidget(this._discuz,this._user,this._hotThread);

  @override
  Widget build(BuildContext context) {
    return HotThreadStatefulWidget(this._discuz,this._user,this._hotThread);
  }




}


class HotThreadStatefulWidget extends StatefulWidget{
  HotThread _hotThread;
  Discuz _discuz;
  User? _user;

  HotThreadStatefulWidget(this._discuz,this._user,this._hotThread);

  @override
  HotThreadState createState() {
    return HotThreadState(this._discuz,this._user,this._hotThread);
  }

}

class HotThreadState extends State<HotThreadStatefulWidget>{

  HotThread _hotThread;
  Discuz _discuz;
  User? _user;

  HotThreadState(this._discuz,this._user,this._hotThread);

  @override
  void initState() {
    loadDatabase();
    super.initState();
  }

  ViewHistoryDao? dao;
  late BlockUserDao blockUserDao;
  bool isUserBlocked = false;

  void loadDatabase() async{
    final db = await DBHelper.getAppDb();
    setState(() {
      dao = db.viewHistoryDao;

    });
    blockUserDao = db.blockUserDao;
    // check with block information
    List<BlockUser> userBlockedInDB = await blockUserDao.isUserBlocked(_hotThread.authorId, _discuz.id!);
    log("get blocked info ${userBlockedInDB} In DB");
    if (userBlockedInDB.isEmpty){
      setState(() {
        this.isUserBlocked = false;
      });
    }
    else{
      setState(() {
        this.isUserBlocked = true;
      });
    }


  }

  bool read = false;

  void markThreadAsRead(){
    setState(() {
      read = true;
    });
  }

  Widget getTailingWidget(){
    if(_hotThread.displayOrder > 0){
      return Icon(Icons.vertical_align_top, color: Colors.redAccent,);
    }
    else{
      return Badge(
        badgeContent: Text(_hotThread.replies,style: TextStyle(color: Colors.white),),
        child: Icon(Icons.message_outlined),
      );

    }
  }

  Widget getUnViewedHotThread(){
    // retrieve threadtype
    return Card(
      elevation: 2.0,
      child: ListTile(
        leading: InkWell(
          child: ClipRRect(

            borderRadius: BorderRadius.circular(10000.0),
            child: CachedNetworkImage(
              imageUrl: URLUtils.getAvatarURL(_discuz, _hotThread.authorId.toString()),
              progressIndicatorBuilder: (context, url, downloadProgress) => CircularProgressIndicator(value: downloadProgress.progress),
              errorWidget: (context, url, error) =>
                  CircleAvatar(

                    backgroundColor: CustomizeColor.getColorBackgroundById(_hotThread.authorId),
                    child: Text(_hotThread.author.length !=0 ? _hotThread.author[0].toUpperCase()
                        : S.of(context).anonymous,
                        style: TextStyle(color: Colors.white)),
                  )
              ,
            ),
          ),
          onTap: () async{
            VibrationUtils.vibrateWithClickIfPossible();
            User? user = Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
            await Navigator.push(
                context,
                platformPageRoute(context:context,builder: (context) => UserProfilePage(_discuz,user, _hotThread.authorId)));
          },
        ),
        title: Hero(
          tag: ConstUtils.HERO_TAG_THREAD_SUBJECT,
          child: Text(_hotThread.subject,style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        subtitle: RichText(
          text: TextSpan(
            text: _hotThread.author,
            style: DefaultTextStyle.of(context).style,
            children: <TextSpan>[
              //TextSpan(text: S.of(context).publishAt, style: TextStyle(fontWeight: FontWeight.w300)),
              TextSpan(text: " · ",style: TextStyle(fontWeight: FontWeight.w300)),
              TextSpan(text: TimeDisplayUtils.getLocaledTimeDisplay(context,_hotThread.publishAt)),
            ],
          ),
        ),
        trailing: getTailingWidget(),
        onTap: () async {
          VibrationUtils.vibrateWithClickIfPossible();
          markThreadAsRead();
          await Navigator.push(
              context,
              platformPageRoute(context:context,builder: (context) => ViewThreadSliverPage( _discuz,  _user, _hotThread.tid,
                passedSubject: _hotThread.subject,
              ))
          );
        },


      ),
    );
  }

  Widget getViewedHotThread(){
    return Card(
      elevation: 2.0,
      child: ListTile(
        leading: InkWell(
          child: ClipRRect(

            borderRadius: BorderRadius.circular(10000.0),
            child: CachedNetworkImage(
              imageUrl: URLUtils.getAvatarURL(_discuz, _hotThread.authorId.toString()),
              progressIndicatorBuilder: (context, url, downloadProgress) => CircularProgressIndicator(value: downloadProgress.progress),
              errorWidget: (context, url, error) =>
                  CircleAvatar(

                    backgroundColor: CustomizeColor.getColorBackgroundById(_hotThread.authorId),
                    child: Text(_hotThread.author.length !=0 ? _hotThread.author[0].toUpperCase()
                        : S.of(context).anonymous,
                        style: TextStyle(color: Colors.white)),
                  )
              ,
            ),
          ),
          onTap: () async{
            VibrationUtils.vibrateWithClickIfPossible();
            User? user = Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
            await Navigator.push(
                context,
                platformPageRoute(context:context,builder: (context) => UserProfilePage(_discuz,user, _hotThread.authorId)));
          },
        ),
        title: Text(_hotThread.subject,style: TextStyle(fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.light ? Colors.black38: Colors.white38)),
        subtitle: RichText(
          text: TextSpan(
            text: "",
            style: DefaultTextStyle.of(context).style,
            children: <TextSpan>[
              TextSpan(text: _hotThread.author, style: TextStyle(fontWeight: FontWeight.w300, color: Theme.of(context).brightness == Brightness.light ? Colors.black38: Colors.white38)),
              TextSpan(text: " · ",style: TextStyle(fontWeight: FontWeight.w300, color: Theme.of(context).brightness == Brightness.light ? Colors.black38: Colors.white38)),
              TextSpan(text: TimeDisplayUtils.getLocaledTimeDisplay(context,_hotThread.publishAt),style: TextStyle(color: Theme.of(context).brightness == Brightness.light ? Colors.black38: Colors.white38)),
            ],
          ),
        ),
        trailing: getTailingWidget(),
        onTap: () async {
          VibrationUtils.vibrateWithClickIfPossible();
          markThreadAsRead();
          await Navigator.push(
              context,
              platformPageRoute(context:context,builder: (context) => ViewThreadSliverPage( _discuz,  _user, _hotThread.tid,))
          );
        },


      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isUserBlocked){
      return Container(
        child: Card(
          elevation: 4.0,
          child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(S.of(context).contentPostByBlockUserTitle(_hotThread.author),style:Theme.of(context).textTheme.headline6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        child: Text(S.of(context).unblockContent),
                        onPressed: () async{
                          VibrationUtils.vibrateWithClickIfPossible();
                          setState(() {
                            this.isUserBlocked = false;
                          });
                        },
                      ),
                      TextButton(
                        child: Text(S.of(context).unblockUser),
                        onPressed: () async{
                          // unblock user
                          VibrationUtils.vibrateWithClickIfPossible();
                          setState(() {
                            this.isUserBlocked = false;
                          });
                          await blockUserDao.deleteBlockUserByUid(_hotThread.authorId,  _discuz.id!);
                        },
                      )
                    ],
                  )
                ],
              )
          ),
        ),
      );
    }
    else if(read == true){
      return getViewedHotThread();
    }
    else if(dao == null|| _discuz.id == null){
      return getUnViewedHotThread();
    }
    else{
      return StreamBuilder(
        stream: dao!.threadHistoryExistInDatabase(_discuz.id!, _hotThread.tid),
        builder: (BuildContext context, AsyncSnapshot<ViewHistory?> snapshot) {
          if(snapshot.data == null){
            return getUnViewedHotThread();
          }
          else{
            return getViewedHotThread();
          }
        },
      );
    }
  }

}