
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
import 'package:discuz_flutter/provider/SelectedTidNotifierProvider.dart';
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:discuz_flutter/utility/TimeDisplayUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/UserAvatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';

import '../entity/ViewHistory.dart';
import '../page/ViewThreadSliverPage.dart';
import '../provider/DiscuzAndUserNotifier.dart';

// ignore: must_be_immutable
class ForumThreadWidget extends StatelessWidget{

  ForumThread _forumThread;
  Discuz _discuz;
  User? _user;
  ThreadType? threadType;
  final ValueChanged<int>? onSelectTid;
  int? afterTid = null;

  ForumThreadWidget(this._discuz,this._user,this._forumThread, this.threadType, this.onSelectTid, {this.afterTid});



  @override
  Widget build(BuildContext context) {
    return ForumThreadStatefulWidget(this._discuz,
      this._user,this._forumThread,
      this.threadType, onSelectTid,
      afterTid: afterTid,);
  }


}

class ForumThreadStatefulWidget extends StatefulWidget{
  ForumThread _forumThread;
  Discuz _discuz;
  User? _user;
  ThreadType? threadType;
  ValueChanged<int>? onSelectTid;
  int? afterTid = null;

  ForumThreadStatefulWidget(this._discuz,this._user,this._forumThread, this.threadType, this.onSelectTid, {this.afterTid});

  @override
  ForumThreadState createState() {
    return ForumThreadState(this._discuz,this._user,this._forumThread, this.threadType, this.onSelectTid, afterTid: afterTid);
  }

}


class ForumThreadState extends State<ForumThreadStatefulWidget>{
  ForumThread _forumThread;
  Discuz _discuz;
  User? _user;
  ThreadType? threadType;
  bool read = false;
  int? afterTid = null;

  final ValueChanged<int>? onSelectTid;

  ForumThreadState(this._discuz,this._user,this._forumThread, this.threadType, this.onSelectTid, {this.afterTid}){
    log("Last selected during forum in init thread state ${_forumThread.tid} ${afterTid}");
  }

  @override
  void initState() {
    // set in case
    _user = Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
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

  Widget? getTailingWidget(){
    if(_forumThread.getDisplayOrder() > 0){
      return Icon(AppPlatformIcons(context).pinContentSolid, color: Theme.of(context).colorScheme.primary,);
    }

    else{
      return null;
    }
  }

  void markThreadAsRead(){
    setState(() {
      read = true;
    });
  }

  Widget getForumThreadCard(bool viewed){
    return Consumer<SelectedTidNotifierProvider>(
      builder: (context, selectedTid, child){
        bool selected = selectedTid.tid == _forumThread.getTid();
        bool lastSelected = selectedTid.tid == afterTid;
        log("Select changed ${_forumThread.tid} ${selected} ${afterTid} ${lastSelected}");
        return InkWell(
          child: PlatformWidgetBuilder(
              material: (context, child, platform) => Card(
                elevation: 4.0,
                color: selected? Theme.of(context).colorScheme.primaryContainer: null,
                //surfaceTintColor: selected? Theme.of(context).colorScheme.primary: brightness == Brightness.light? Colors.white: Colors.black45,
                // color: Theme.of(context).colorScheme.background,
                child: Container(
                  padding: EdgeInsets.only(bottom: 12.0),
                  child: child,
                ),
              ),
              cupertino: (_, child, __) => Column(
                mainAxisSize: MainAxisSize.min,

                children: [
                  if(child!= null)
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.0),
                      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                      decoration: BoxDecoration(
                        color: selected? Theme.of(context).colorScheme.primaryContainer: null,
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      ),
                      //color: ,
                      child: child,
                    ),
                  if(!selected && !lastSelected)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Divider(),
                  )

                ],
              ),
              child: getForumThreadListTile(viewed, selected)
          ),
          onTap:  () async {
            triggerTapFunction();
          },
          onLongPress: () async{
            triggerLongPressFunction();
          },
        );
      },
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
  
  Widget getForumThreadListTile(bool viewed, bool selected){
    TextStyle? textStyle;
    if (viewed){
      textStyle = TextStyle(
        fontWeight: FontWeight.w300,
        color: selected? Theme.of(context).colorScheme.onPrimaryContainer:Theme.of(context).unselectedWidgetColor,
      );
    }
    else{
      textStyle = TextStyle(

        fontWeight: FontWeight.normal,
      );

    }
    String threadCategory = "";
    // set for popular terms
    threadCategory = _forumThread.typeName;
    if(threadType!=null && threadType!.idNameMap.isNotEmpty && threadType!.idNameMap.containsKey(_forumThread.typeId)){
      threadCategory = threadType!.idNameMap[_forumThread.typeId]!;
    }
    if(_forumThread.message.isNotEmpty){
      // special card design
      return Padding(
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
                color: selected? Theme.of(context).colorScheme.onPrimaryContainer: viewed? Theme.of(context).unselectedWidgetColor: null,)
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
                          fontWeight: viewed? FontWeight.w300:FontWeight.normal,
                          color: selected? Theme.of(context).colorScheme.onPrimaryContainer:viewed? Theme.of(context).unselectedWidgetColor: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        children: [
                          TextSpan(text: _forumThread.author,
                              style:  TextStyle(
                                fontWeight: FontWeight.w300,
                                color: selected? Theme.of(context).colorScheme.onPrimaryContainer:viewed? Theme.of(context).unselectedWidgetColor: Theme.of(context).textTheme.bodySmall?.color,
                              )
                          ),
                          TextSpan(text: " · ", style: textStyle),
                          TextSpan(text: TimeDisplayUtils.getLocaledTimeDisplay(context,_forumThread.dbdatelineMinutes),
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                                color: selected? Theme.of(context).colorScheme.onPrimaryContainer: viewed? Theme.of(context).unselectedWidgetColor: Theme.of(context).textTheme.bodySmall?.color,
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
                          color: selected? Theme.of(context).colorScheme.onPrimaryContainer: viewed? Theme.of(context).unselectedWidgetColor: null,
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
      );
    }

    // normal without message
    return Consumer<SelectedTidNotifierProvider>(
      builder: (context, selectedTid, child){
        //log("Changed tid ${selectedTid.tid} ${_forumThread.getTid()}");
        bool selected = selectedTid.tid == _forumThread.getTid();
        return Column(
          children: [
            ListTile(
              selected: selected,
              leading: UserAvatar(
                _discuz, _forumThread.getAuthorId(), _forumThread.author,
                size: 48,
                disableTap: true,
              ),
              title: Text(_forumThread.subject, style: TextStyle(
                  color: selected? Theme.of(context).colorScheme.primary: viewed? Theme.of(context).disabledColor :null,
                  fontWeight: selected? FontWeight.bold: viewed? FontWeight.w400: FontWeight.normal,
              )),
              subtitle: RichText(
                text: TextSpan(
                  text: "",
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: selected? Theme.of(context).colorScheme.primary: Theme.of(context).disabledColor,
                      fontWeight: selected? FontWeight.normal : viewed? FontWeight.w300: null,
                      //fontSize: 12
                  ),
                  //style: ..copyWith(color: selected? Theme.of(context).colorScheme.onPrimary: null),
                  children: <TextSpan>[
                    TextSpan(text: _forumThread.author),
                    TextSpan(text: " · "),
                    TextSpan(text: TimeDisplayUtils.getLocaledTimeDisplay(context,_forumThread.dbdatelineMinutes)),
                  ],
                ),
              ),

              // trailing: selected? Icon(AppPlatformIcons(context).selectedThreadSolid, color: Theme.of(context).colorScheme.primary,):
              // _forumThread.replies!=0 ? getTailingWidget(): null,



            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if(threadCategory.isNotEmpty)
                  Container(
                      padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: viewed? Theme.of(context).disabledColor.withOpacity(0.1): Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      
                      child: Text(threadCategory, style: TextStyle(
                        color: viewed? Theme.of(context).disabledColor:Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 12
                      )
                      ),
                  ),
                  RichText(
                    text: TextSpan(
                        text: "",
                        style: TextStyle(

                        ),
                        children: <TextSpan>[
                          if(threadCategory.isNotEmpty)
                            TextSpan(text: " · ", style: viewed? TextStyle(color: Theme.of(context).disabledColor) : TextStyle(
                                color:  Theme.of(context).disabledColor
                            )),

                          TextSpan(text: S.of(context).threadView(_forumThread.views),
                              style: TextStyle(color: Theme.of(context).disabledColor)

                          ),
                          TextSpan(text: " · " + S.of(context).threadReply(_forumThread.replies),
                              style: TextStyle(color: Theme.of(context).disabledColor)
                          ),
                          if((_user == null && _forumThread.readPerm > 0)|| (_user!= null && _forumThread.readPerm > _user!.readPerm))
                            TextSpan(text: " · ",
                                style: TextStyle(color: Theme.of(context).disabledColor)
                            ),
                          if((_user == null && _forumThread.readPerm > 0)|| (_user!= null && _forumThread.readPerm > _user!.readPerm))
                            TextSpan(text: S.of(context).threadReadAccess(_forumThread.readPerm),
                                style: viewed? textStyle: textStyle?.copyWith(color: Theme.of(context).colorScheme.error)
                            ),

                        ]
                    ),
                  )
                ],
              ),
            )
          ],
        );
      }
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
    if (isUserBlocked){
      return Container(
        child: Card(
          elevation: 4.0,
          child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(S.of(context).contentPostByBlockUserTitle(_forumThread.author),style:Theme.of(context).textTheme.titleLarge),
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