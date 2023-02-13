
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/dao/BlockUserDao.dart';
import 'package:discuz_flutter/dao/ViewHistoryDao.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/BlockUser.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/HotThread.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/UserProfilePage.dart';
import 'package:discuz_flutter/page/ViewThreadSliverPage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/utility/ConstUtils.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/TimeDisplayUtils.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../entity/ViewHistory.dart';

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
    ViewHistoryDao viewHistoryDao = await AppDatabase.getViewHistoryDao();
    setState((){
      dao = viewHistoryDao;

    });
    blockUserDao = await AppDatabase.getBlockUserDao();
    // check with block information
    List<BlockUser> userBlockedInDB = await blockUserDao.isUserBlocked(_hotThread.authorId, _discuz);
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
    else if(_hotThread.replies == 0){
      return Container();
    }
    else{
      return Container(
        // color: Theme.of(context).colorScheme.onPrimary,
        child: Text(
          _hotThread.replies.toString(),
          textScaleFactor: .8,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          color: Theme.of(context).colorScheme.primaryContainer,
          boxShadow: [
            BoxShadow(color: Theme.of(context).colorScheme.primaryContainer, spreadRadius: 4),
          ],
        ),
      );

    }
  }

  Widget getHotThreadListTile(bool viewed){
    TextStyle? textStyle;
    if (viewed){
      textStyle = TextStyle(
        fontWeight: FontWeight.w300,
        color: Theme.of(context).unselectedWidgetColor,
      );
    }
    else{
      textStyle = TextStyle(

        fontWeight: FontWeight.normal,
      );

    }

    return ListTile(
      leading: InkWell(
        child: ClipRRect(

          borderRadius: BorderRadius.circular(10000.0),
          child: CachedNetworkImage(
            height: 48,
            width: 48,
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
        child: Text(_hotThread.subject,style: textStyle),
      ),
      subtitle: RichText(
        text: TextSpan(
          text: "",
          style: DefaultTextStyle.of(context).style,
          children: <TextSpan>[
            //TextSpan(text: S.of(context).publishAt, style: TextStyle(fontWeight: FontWeight.w300)),
            TextSpan(text: _hotThread.author,style: textStyle),
            TextSpan(text: " · ",style: textStyle),
            TextSpan(text: TimeDisplayUtils.getLocaledTimeDisplay(context,_hotThread.publishAt), style: textStyle),
            if((_user == null && _hotThread.readPerm > 0)||(_user!= null && _hotThread.readPerm>_user!.readPerm))
              TextSpan(text: " / " + S.of(context).threadReadAccess(_hotThread.readPerm),style: textStyle.copyWith(color: Theme.of(context).errorColor)),
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
      onLongPress: () async{
        VibrationUtils.vibrateSuccessfullyIfPossible();
        // block user
        setState(() {
          this.isUserBlocked = true;
        });
        BlockUser blockUser = BlockUser(_hotThread.authorId, _hotThread.author, DateTime.now(), _discuz);
        int insertId = await blockUserDao.insertBlockUser(blockUser);
        log("insert id into block user ${insertId}");
      },


    );


  }

  Widget getHotThreadCard(bool viewed){
    return PlatformWidget(
      material: (_, __)=> Card(
        elevation: 1,
        color: Theme.of(context).cardColor,
        child: getHotThreadListTile(viewed)
      ),
      cupertino:  (_, __) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          getHotThreadListTile(viewed),
          Padding(
            padding: EdgeInsets.only(left: 80),
            child: Divider(),
          )

        ],
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
                          await blockUserDao.deleteBlockUserByUid(_hotThread.authorId,  _discuz);
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
      return getHotThreadCard(read);
    }
    else if(dao == null){
      return getHotThreadCard(false);
    }
    else{
      return ValueListenableBuilder(
          valueListenable: dao!.viewHistoryBox.listenable(),
          builder: (BuildContext context, Box<ViewHistory> value, Widget? child) {
            bool exist = dao!.threadHistoryExistInDatabase(_discuz, _hotThread.tid);
            return getHotThreadCard(exist);
          });
    }
  }

}