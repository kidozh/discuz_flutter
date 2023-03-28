
import 'dart:developer';
import 'dart:math' as Math;

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
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:discuz_flutter/utility/TimeDisplayUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/UserAvatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:hive_flutter/adapters.dart';

import '../entity/ViewHistory.dart';
import '../page/ViewThreadSliverPage.dart';

// ignore: must_be_immutable
class ForumThreadWidget extends StatelessWidget{

  ForumThread _forumThread;
  Discuz _discuz;
  User? _user;
  ThreadType? threadType;
  final ValueChanged<int>? onSelectTid;

  ForumThreadWidget(this._discuz,this._user,this._forumThread, this.threadType, this.onSelectTid);



  @override
  Widget build(BuildContext context) {
    return ForumThreadStatefulWidget(this._discuz,this._user,this._forumThread, this.threadType, onSelectTid);
  }


}

class ForumThreadStatefulWidget extends StatefulWidget{
  ForumThread _forumThread;
  Discuz _discuz;
  User? _user;
  ThreadType? threadType;
  ValueChanged<int>? onSelectTid;

  ForumThreadStatefulWidget(this._discuz,this._user,this._forumThread, this.threadType, this.onSelectTid);

  @override
  ForumThreadState createState() {

    return ForumThreadState(this._discuz,this._user,this._forumThread, this.threadType, this.onSelectTid);
  }

}


class ForumThreadState extends State<ForumThreadStatefulWidget>{
  ForumThread _forumThread;
  Discuz _discuz;
  User? _user;
  ThreadType? threadType;
  bool read = false;

  final ValueChanged<int>? onSelectTid;

  ForumThreadState(this._discuz,this._user,this._forumThread, this.threadType, this.onSelectTid);

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
      return Icon(AppPlatformIcons(context).pinContentSolid, color: Theme.of(context).colorScheme.primary,);
    }
    // else if(_forumThread.replies == 0){
    //   return Container();
    // }
    //_forumThread.replies
    else{
      return Container(
        // color: Theme.of(context).colorScheme.onPrimary,
        child: Text(
          _forumThread.replies.toString(),
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

  void markThreadAsRead(){
    setState(() {
      read = true;
    });
  }

  Widget getForumThreadCard(bool viewed){
    return PlatformWidget(
      material: (_, __) => Card(
        elevation: 4.0,

        child: getForumThreadListTile(viewed),
      ),
      cupertino: (_, __) => Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          getForumThreadListTile(viewed),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(),
          )

        ],
      ),
    );

    
  }

  Widget getAttachmentPreviewWidget(AttachmentPreview attachmentPreview){
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: CachedNetworkImage(

        fit: BoxFit.cover,
        imageUrl: "${_discuz.getBaseURLWithAfterfix()}/data/attachment/forum/${attachmentPreview.attachment}",
        progressIndicatorBuilder: (context, url, downloadProgress) => CircularProgressIndicator(value: downloadProgress.progress),
        errorWidget: (context, url, error) {
          return Container(
            width: 64/0.618,
            height: 64,
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Icon(AppPlatformIcons(context).imageSolid, color:  Theme.of(context).colorScheme.onPrimaryContainer,),
            ),
          );
        },
      ),
    );
  }
  
  Widget getForumThreadListTile(bool viewed){
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
    if(_forumThread.message.isNotEmpty){
      // special card design
      return InkWell(
        child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(
              // like zhihu layout
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_forumThread.subject, style: TextStyle(
                  fontSize: FontSize.xLarge.value,
                  fontWeight: viewed? FontWeight.normal:FontWeight.bold,
                  color: viewed? Theme.of(context).unselectedWidgetColor: null,)
                ),
                // then user interface
                SizedBox(height: 4,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // user avatar
                    UserAvatar(
                      _discuz, _forumThread.getAuthorId(), _forumThread.author, size:16,
                    ),
                    SizedBox(width: 6,),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          text: " ",
                          style: TextStyle(
                            fontWeight: viewed? FontWeight.w200:FontWeight.w300,
                            color: viewed? Theme.of(context).unselectedWidgetColor: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                          children: [
                            TextSpan(text: _forumThread.author,
                                style:  TextStyle(
                                  fontWeight: FontWeight.w300,
                                  color: viewed? Theme.of(context).unselectedWidgetColor: Theme.of(context).textTheme.bodySmall?.color,
                                )
                            ),
                            TextSpan(text: " · ", style: textStyle),
                            TextSpan(text: TimeDisplayUtils.getLocaledTimeDisplay(context,_forumThread.dbdatelineMinutes),
                                style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  color: viewed? Theme.of(context).unselectedWidgetColor: Theme.of(context).textTheme.bodySmall?.color,
                                )
                            ),
                            if(threadCategory.isNotEmpty)
                              TextSpan(text: " / ", style: textStyle),
                            if(threadCategory.isNotEmpty)
                              TextSpan(text: threadCategory, style: textStyle),
                            if((_user == null && _forumThread.readPerm > 0)||(_user!= null && _forumThread.readPerm >_user!.readPerm))
                              TextSpan(text: " / " + S.of(context).threadReadAccess(_forumThread.readPerm),
                                  style: viewed? textStyle: textStyle.copyWith(color: Theme.of(context).colorScheme.error)
                              ),
                            if(_forumThread.replies > 0)
                            WidgetSpan(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: getTailingWidget(),
                                )
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 8,),
                // message
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                        child: Text(_forumThread.message,
                          style: TextStyle(
                            fontWeight: viewed? FontWeight.w300:FontWeight.w400,
                            color: viewed? Theme.of(context).unselectedWidgetColor: null,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        )
                    ),
                    if(_forumThread.attachmentImagePreviewList.length >0
                        && _forumThread.attachmentImagePreviewList.length < 2)
                      Container(
                        width: 64/0.618,
                        height: 64,
                        child: getAttachmentPreviewWidget(_forumThread.attachmentImagePreviewList[0]),
                      )


                  ],
                ),
                // start image
                getAttachmentGridLayout(),
              ],
            )
        ),
        onTap:  () async {
          triggerTapFunction();
        },
        onLongPress: () async{
          triggerLongPressFunction();
        },

      );
    }

    return ListTile(
      leading: UserAvatar(
        _discuz, _forumThread.getAuthorId(), _forumThread.author, size: 36,
      ),
      title: Text(_forumThread.subject, style: textStyle),
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
                  style: viewed? textStyle: textStyle.copyWith(color: Theme.of(context).colorScheme.error)
              ),
          ],
        ),
      ),

      trailing: _forumThread.replies!=0 ? getTailingWidget(): null,
      onTap: () async {
        triggerTapFunction();
      },
      onLongPress: () async{
        triggerLongPressFunction();
      },


    );
  }

  Widget getAttachmentGridLayout(){
    if(_forumThread.attachmentImagePreviewList.length > 1){
      return GridView.builder(
          physics: new NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.all(4),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: Math.min(_forumThread.attachmentImagePreviewList.length, 3),
            childAspectRatio: 1/0.618,
            mainAxisSpacing: 4,
            crossAxisSpacing: 16

          ),
          itemCount: Math.min(_forumThread.attachmentImagePreviewList.length, 3),
          itemBuilder: (context, index){
            return getAttachmentPreviewWidget(_forumThread.attachmentImagePreviewList[index]);

        },
      );
    }
    else{
      return Container();
    }
  }

  void triggerTapFunction() async{
    VibrationUtils.vibrateWithClickIfPossible();
    markThreadAsRead();
    // recall
    if(onSelectTid != null){
      onSelectTid!(_forumThread.getTid());
    }
    else{
      await Navigator.push(
          context,
          platformPageRoute(context:context,builder: (context) => ViewThreadSliverPage(_discuz,_user, _forumThread.getTid(),
            passedSubject: _forumThread.subject,))
      );
    }


  }

  void triggerLongPressFunction() async{
    VibrationUtils.vibrateSuccessfullyIfPossible();
    setState(() {
      this.isUserBlocked = true;
    });
    BlockUser blockUser = BlockUser(_forumThread.getAuthorId(), _forumThread.author,DateTime.now(), _discuz );
    int insertId = await blockUserDao.insertBlockUser(blockUser);
    log("insert id into block user ${insertId}");
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
                mainAxisSize: MainAxisSize.min,
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