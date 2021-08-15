
import 'dart:developer';

import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/JsonResult/DiscuzIndexResult.dart';
import 'package:discuz_flutter/JsonResult/DisplayForumResult.dart';
import 'package:discuz_flutter/dao/ViewHistoryDao.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/ForumThread.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/entity/ViewHistory.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/UserProfilePage.dart';
import 'package:discuz_flutter/page/ViewThreadSliverPage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/DBHelper.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:provider/provider.dart';

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
    // TODO: implement createState
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

  void loadDatabase() async{
    final db = await DBHelper.getAppDb();
    setState(() {
      dao = db.viewHistoryDao;
    });

  }

  Widget getTailingWidget(){
    if(_forumThread.getDisplayOrder() > 0){
      return Icon(Icons.push_pin, color: Colors.redAccent,);
    }
    else{
      return Badge(
        badgeContent: Text(_forumThread.replies,style: TextStyle(color: Colors.white),),
        child: Icon(Icons.message_outlined),
      );

    }
  }

  Widget getUnViewedThreadCard(){
    Locale locale = Localizations.localeOf(context);
    log("languages ${locale} ${locale.toLanguageTag()} ${locale.scriptCode} ${locale.languageCode}");
    // retrieve threadtype
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
        title: Text(_forumThread.subject,style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: RichText(
          text: TextSpan(
            text: _forumThread.author,
            style: DefaultTextStyle.of(context).style,
            children: <TextSpan>[
              //TextSpan(text: S.of(context).publishAt, style: TextStyle(fontWeight: FontWeight.w300)),
              TextSpan(text: " · ",style: TextStyle(fontWeight: FontWeight.w300)),
              TextSpan(text: GetTimeAgo.parse(_forumThread.dbdatelineMinutes,locale: locale.scriptCode)),
              if(threadCategory.isNotEmpty)
                TextSpan(text: " / ",style: TextStyle(fontWeight: FontWeight.w300)),
              if(threadCategory.isNotEmpty)
                TextSpan(text: threadCategory,style: TextStyle(color: Theme.of(context).accentColor)),
            ],
          ),
        ),
        trailing: getTailingWidget(),
        onTap: () async {
          VibrationUtils.vibrateWithClickIfPossible();
          markThreadAsRead();
          await Navigator.push(
              context,
              platformPageRoute(context:context,builder: (context) => ViewThreadSliverPage(_discuz,_user, _forumThread.getTid()))
          );
        },


      ),
    );
  }

  void markThreadAsRead(){
    setState(() {
      read = true;
    });
  }

  Widget getViewedThreadCard(){
    Locale locale = Localizations.localeOf(context);
    log("languages ${locale} ${locale.toLanguageTag()} ${locale.scriptCode} ${locale.languageCode}");
    // retrieve threadtype
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
            style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Theme.of(context).brightness == Brightness.light ? Colors.black38: Colors.white38
            )
        ),
        subtitle: RichText(
          text: TextSpan(
            text: "",
            style: DefaultTextStyle.of(context).style,
            children: <TextSpan>[
              TextSpan(text: _forumThread.author, style: TextStyle(fontWeight: FontWeight.w300,
                  color: Theme.of(context).brightness == Brightness.light ? Colors.black38: Colors.white38)
              ),
              TextSpan(text: " · ",style: TextStyle(fontWeight: FontWeight.w300,
                  color: Theme.of(context).brightness == Brightness.light ? Colors.black38: Colors.white38)),
              TextSpan(text: GetTimeAgo.parse(_forumThread.dbdatelineMinutes,locale: locale.scriptCode), style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light ? Colors.black38: Colors.white38
              )),
              if(threadCategory.isNotEmpty)
                TextSpan(text: " / ",style: TextStyle(fontWeight: FontWeight.w300, color: Theme.of(context).brightness == Brightness.light ? Colors.black38: Colors.white38)),
              if(threadCategory.isNotEmpty)
                TextSpan(text: threadCategory,style: TextStyle(color: Theme.of(context).brightness == Brightness.light ? Colors.black38: Colors.white38)),
            ],
          ),
        ),
        trailing: getTailingWidget(),
        onTap: () async {
          VibrationUtils.vibrateWithClickIfPossible();
          markThreadAsRead();
          await Navigator.push(
              context,
              platformPageRoute(context:context,builder: (context) => ViewThreadSliverPage(_discuz,_user, _forumThread.getTid()))
          );
        },


      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if(read == true){
      return getViewedThreadCard();
    }
    if(dao == null|| _discuz.id == null){
      return getUnViewedThreadCard();
    }
    else{
      return StreamBuilder(
        stream: dao!.threadHistoryExistInDatabase(_discuz.id!, _forumThread.getTid()),
        builder: (BuildContext context, AsyncSnapshot<ViewHistory?> snapshot) {
          print("Get view history in db ${snapshot.data} ${_forumThread.subject}");
          if(snapshot.data == null){
            return getUnViewedThreadCard();
          }
          else{
            return getViewedThreadCard();
          }
        },
      );
    }
  }

}