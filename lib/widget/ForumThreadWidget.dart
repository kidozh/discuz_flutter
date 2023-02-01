
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/JsonResult/DisplayForumResult.dart';
import 'package:discuz_flutter/dao/BlockUserDao.dart';
import 'package:discuz_flutter/dao/ViewHistoryDao.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/BlockUser.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/ForumThread.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/UserProfilePage.dart';
import 'package:discuz_flutter/page/ViewThreadSliverPage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/TimeDisplayUtils.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';

import '../entity/ViewHistory.dart';

// ignore: must_be_immutable
class ForumThreadWidget extends StatelessWidget{

  ForumThread _forumThread;
  Discuz _discuz;
  User? _user;
  ThreadType? threadType;

  ForumThreadWidget(this._discuz,this._user,this._forumThread, this.threadType);



  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ForumThreadStatefulWidget(this._discuz,this._user,this._forumThread, this.threadType);
  }


}

class ForumThreadStatefulWidget extends StatefulWidget{
  ForumThread _forumThread;
  Discuz _discuz;
  User? _user;
  ThreadType? threadType;

  ForumThreadStatefulWidget(this._discuz,this._user,this._forumThread, this.threadType);

  @override
  ForumThreadState createState() {

    return ForumThreadState(this._discuz,this._user,this._forumThread, this.threadType);
  }

}

class ForumThreadState extends State<ForumThreadStatefulWidget>{
  ForumThread _forumThread;
  Discuz _discuz;
  User? _user;
  ThreadType? threadType;
  bool read = false;

  ForumThreadState(this._discuz,this._user,this._forumThread, this.threadType);

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
    List<BlockUser> userBlockedInDB = blockUserDao.isUserBlocked(_forumThread.getAuthorId(), _discuz);
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

  Widget getTailingWidget(){
    if(_forumThread.getDisplayOrder() > 0){
      return Icon(Icons.push_pin, color: Colors.redAccent,);
    }
    else{
      return Badge(
        label: Text(_forumThread.replies,style: TextStyle(color: Colors.white),),
        child: Icon(Icons.message_outlined),
      );

    }
  }

  void markThreadAsRead(){
    setState(() {
      read = true;
    });
  }

  Widget getForumThreadCard(bool viewed){
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

    String threadCategory = "";
    if(threadType!=null && threadType!.idNameMap.isNotEmpty && threadType!.idNameMap.containsKey(_forumThread.typeId)){
      threadCategory = threadType!.idNameMap[_forumThread.typeId]!;
    }



    return Card(
      child: ListTile(
        leading: InkWell(
          child: ClipRRect(

            borderRadius: BorderRadius.circular(10000.0),
            child: CachedNetworkImage(
              imageUrl: URLUtils.getAvatarURL(_discuz, _forumThread.authorId),
              width: 48,
              height: 48,
              progressIndicatorBuilder: (context, url, downloadProgress) => CircularProgressIndicator(value: downloadProgress.progress),
              errorWidget: (context, url, error) =>
                  CircleAvatar(
                    backgroundColor: CustomizeColor.getColorBackgroundById(_forumThread.getAuthorId()),
                    child: Text(_forumThread.author.length !=0 ? _forumThread.author[0].toUpperCase()
                        : S.of(context).anonymous,
                        style: TextStyle(color: Colors.white)),
                  )
              ,
            ),
          ),
          onTap: () async{
            User? user = Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
            VibrationUtils.vibrateWithClickIfPossible();
            await Navigator.push(
                context,
                platformPageRoute(context:context,builder: (context) => UserProfilePage(_discuz,user, int.parse(_forumThread.authorId))));

          },
        ),
        title: Text(_forumThread.subject,
            style: textStyle
        ),
        subtitle: RichText(
          text: TextSpan(
            text: "",
            style: DefaultTextStyle.of(context).style,
            children: <TextSpan>[
              TextSpan(text: _forumThread.author, style: textStyle),
              TextSpan(text: " · ", style: textStyle),
              TextSpan(text: TimeDisplayUtils.getLocaledTimeDisplay(context,_forumThread.dbdatelineMinutes), style: textStyle),
              if(threadCategory.isNotEmpty)
                TextSpan(text: " / ", style: textStyle),
              if(threadCategory.isNotEmpty)
                TextSpan(text: threadCategory, style: textStyle),
              if((_user == null && _forumThread.readPerm > 0)||(_user!= null && _forumThread.readPerm >_user!.readPerm))
                TextSpan(text: " / " + S.of(context).threadReadAccess(_forumThread.readPerm),
                    style: viewed? textStyle: textStyle.copyWith(color: Theme.of(context).errorColor)
                ),
            ],
          ),
        ),
        trailing: getTailingWidget(),
        onTap: () async {
          VibrationUtils.vibrateWithClickIfPossible();
          markThreadAsRead();
          await Navigator.push(
              context,
              platformPageRoute(context:context,builder: (context) => ViewThreadSliverPage(_discuz,_user, _forumThread.getTid(),
                passedSubject: _forumThread.subject,))
          );
        },
        onLongPress: () async{
          VibrationUtils.vibrateSuccessfullyIfPossible();
          setState(() {
            this.isUserBlocked = true;
          });
          BlockUser blockUser = BlockUser(_forumThread.getAuthorId(), _forumThread.author,DateTime.now(), _discuz );
          int insertId = await blockUserDao.insertBlockUser(blockUser);
          log("insert id into block user ${insertId}");
        },


      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if (isUserBlocked){
      return Container(
        child: Card(
          elevation: 4.0,
          child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(S.of(context).contentPostByBlockUserTitle(_forumThread.author),style:Theme.of(context).textTheme.headline6),
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
                          await blockUserDao.deleteBlockUserByUid(_forumThread.getAuthorId(),  _discuz);
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
    if(read == true){
      return getForumThreadCard(true);
    }
    if(dao == null){
      return getForumThreadCard(false);
    }
    else{
      return ValueListenableBuilder(
          valueListenable: dao!.viewHistoryBox.listenable(),
          builder: (BuildContext context, Box<ViewHistory> value, Widget? child) {
            bool exist = dao!.threadHistoryExistInDatabase(_discuz, _forumThread.getTid());
            return getForumThreadCard(exist);
          });
    }
  }

}