
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/JsonResult/ViewThreadResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/dao/BlockUserDao.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/BlockUser.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/Post.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/ReportContentPage.dart';
import 'package:discuz_flutter/page/UserProfilePage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/provider/DiscuzNotificationProvider.dart';
import 'package:discuz_flutter/provider/ReplyPostNotifierProvider.dart';
import 'package:discuz_flutter/provider/TypeSettingNotifierProvider.dart';
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:discuz_flutter/utility/PostTextUtils.dart';
import 'package:discuz_flutter/utility/TimeDisplayUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/AttachmentWidget.dart';
import 'package:discuz_flutter/widget/DiscuzHtmlWidget.dart';
import 'package:discuz_flutter/widget/PostCommentWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

import '../utility/NetworkUtils.dart';
import '../utility/UserPreferencesUtils.dart';
import 'UserAvatar.dart';

int POST_BLOCKED = 1;
int POST_WARNED = 2;
int POST_REVISED = 4;
int POST_MOBILE = 8;

class PostWidget extends StatelessWidget {
  Post _post;
  Discuz _discuz;
  int _authorId;
  String formhash;
  VoidCallback? onAuthorSelectedCallback;
  JumpToPidCallback? jumpToPidCallback;
  Map<String, List<Comment>>? postCommentList;
  bool? ignoreFontCustomization = false;
  int? tid;
  int? fid;

  PostWidget(this._discuz, this._post, this._authorId, this.formhash,
      {this.onAuthorSelectedCallback,
      this.postCommentList,
      this.ignoreFontCustomization,
      this.jumpToPidCallback,
        this.fid,
      this.tid});

  @override
  Widget build(BuildContext context) {
    return PostStatefulWidget(
      this._discuz,
      this._post,
      this._authorId,
      this.formhash,
      onAuthorSelectedCallback: this.onAuthorSelectedCallback,
      postCommentList: this.postCommentList,
      ignoreFontCustomization: this.ignoreFontCustomization,
      jumpToPidCallback: this.jumpToPidCallback,
      fid: this.fid,
      tid: this.tid,
    );
  }
}

class PostStatefulWidget extends StatefulWidget {
  Post _post;
  Discuz _discuz;
  int _authorId;
  String formhash;
  VoidCallback? onAuthorSelectedCallback;
  JumpToPidCallback? jumpToPidCallback;
  Map<String, List<Comment>>? postCommentList;
  bool? ignoreFontCustomization = false;
  int? tid;
  int? fid;

  PostStatefulWidget(this._discuz, this._post, this._authorId, this.formhash,
      {this.onAuthorSelectedCallback,
      this.postCommentList,
      this.ignoreFontCustomization,
      this.jumpToPidCallback,
        this.fid,
      this.tid});

  @override
  PostState createState() {
    return PostState(this._discuz, this._post, this._authorId, this.formhash,
        onAuthorSelectedCallback: this.onAuthorSelectedCallback,
        postCommentList: this.postCommentList,
        ignoreFontCustomization: this.ignoreFontCustomization,
        jumpToPidCallback: this.jumpToPidCallback,
        fid: this.fid,
        tid: this.tid);
  }
}

// ignore: must_be_immutable
class PostState extends State<PostStatefulWidget> {
  Post _post;
  Discuz _discuz;
  User? _user;
  int _authorId;
  VoidCallback? onAuthorSelectedCallback;
  JumpToPidCallback? jumpToPidCallback;
  Map<String, List<Comment>>? postCommentList;
  bool? ignoreFontCustomization = false;
  String formhash;
  int? tid;
  int? fid;

  bool isFontStyleIgnored() {
    if (ignoreFontCustomization == null || ignoreFontCustomization == false) {
      return false;
    } else {
      return true;
    }
  }

  List<Comment> getCommentList() {
    if (postCommentList == null) {
      return [];
    }
    String pid = _post.pid.toString();
    if (postCommentList!.containsKey(pid)) {
      return postCommentList![pid]!;
    } else {
      return [];
    }
  }

  PostState(this._discuz, this._post, this._authorId, this.formhash,
      {this.onAuthorSelectedCallback,
      this.postCommentList,
      this.ignoreFontCustomization,
      this.jumpToPidCallback,
        this.fid,
      this.tid});

  @override
  void initState() {
    super.initState();
    if(mounted){
      _loadDB();
    }

  }

  @override
  void dispose() {


    super.dispose();
  }

  late BlockUserDao _blockUserDao;
  bool isUserBlocked = false;
  String groupTitle = "";
  int groupStar = 0;

  _loadDB() async {
    _blockUserDao = await AppDatabase.getBlockUserDao();
    // need to remove
    groupTitle = await UserPreferencesUtils.getDiscuzGroupNameById(
        _discuz, _post.groupId);
    groupStar = await UserPreferencesUtils.getDiscuzGroupStarById(
        _discuz, _post.groupId);
    groupTitle = groupTitle.replaceAll(RegExp(r'<.*?>'), "");
    // query whether use get blocked
    if(mounted){
      Discuz discuz =
      Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz!;
      _user = Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
      List<BlockUser> userBlockedInDB =
      await _blockUserDao.isUserBlocked(_post.authorId, discuz);
      if (userBlockedInDB.isEmpty) {
        setState(() {
          this.isUserBlocked = false;
        });
      } else {
        setState(() {
          this.isUserBlocked = true;
        });
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    if (this.isUserBlocked) {
      // show blocked user interface
      return Container(
        child: Card(
          elevation: 2.0,
          surfaceTintColor: Theme.of(context).colorScheme.surface,
          color: Theme.of(context).colorScheme.surface,
          child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(S.of(context).contentPostByBlockUserTitle(_post.author),
                      style: Theme.of(context).textTheme.headlineSmall),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        child: Text(S.of(context).unblockContent),
                        onPressed: () async {
                          VibrationUtils.vibrateWithClickIfPossible();
                          setState(() {
                            this.isUserBlocked = false;
                          });
                        },
                      ),
                      TextButton(
                        child: Text(S.of(context).unblockUser),
                        onPressed: () async {
                          // unblock user
                          VibrationUtils.vibrateWithClickIfPossible();
                          setState(() {
                            this.isUserBlocked = false;
                          });
                          await _blockUserDao.deleteBlockUserByUid(
                              _post.authorId, _discuz);
                        },
                      )
                    ],
                  )
                ],
              )),
        ),
      );
    }

    return Consumer<TypeSettingNotifierProvider>(
        builder: (context, typesetting, _) {
      // should return the container
      return PlatformWidgetBuilder(
        material: (_, child, platform) => Card(
          //surfaceTintColor: Theme.of(context).colorScheme.background,
          surfaceTintColor: Theme.of(context).brightness == Brightness.light? Colors.white: Colors.black38,
          color: Theme.of(context).brightness == Brightness.light? Colors.white: Colors.white24,
          elevation: _post.first ? 0 : 8.0,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 12.0),
            child: child,
          ),
        ),
        cupertino: (_, child, platform) => Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 4.0, right: 4.0, top: 16.0),
              child: child,
            ),
            Divider(indent: 8.0,)


          ],
        ),
        child: getPostContent(context, typesetting.useCompactParagraph),
      );
    });
  }

  Widget getPostContent(BuildContext context, bool compactParagraph) {
    String _html = _post.message;
    log("Original HTML ${_html}");

    if (this.isFontStyleIgnored()) {
      // regex
      // _html = _html
      //     .replaceAll(RegExp(r'<font.*?>', multiLine: true), "")
      //     .replaceAll(RegExp(r'</font.*?>'), "")
      //     .replaceAll(RegExp(r'<span style="display:none">.+</span>'), "")
      //     //.replaceAll(RegExp(r'\\n'), '<br />')
      // ;
      _html = PostTextUtils.decodePostMessage(_html);
    }


    if(compactParagraph){
      _html = _html.replaceAll(RegExp("[\r\n]+"), "");
      _html = _html
          .replaceAll(RegExp(r"<br.?/>(<br.?/>)+", multiLine: true), "<br />")
          //.replaceAll(RegExp(r"\s+$"), "")
          //.replaceAll(RegExp(r"[(<br.?/>)]+$"), "")
      ;

      _html = _html.replaceAllMapped(RegExp("<br\\W+/>"), (match){
        //print("match! ${match.group(0)} ${match.end} ${_html.length}");
        if(_html.length - match.end < 3){
          return "";
        }
        else{
          return "<br />";
        }
      });

      // _html = _html.replaceAll(RegExp(r"<br.?/>$"), "");
      _html = _html.replaceAll(RegExp(r"\s+$"), "");
    }

    log("AFTER HTML ${_html}");


    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // post header
        getPostHeader(context),
        // banned or warn
        if (_post.status & POST_BLOCKED != 0) getPostBlockedBlock(context),
        if (_post.status & POST_WARNED != 0) getPostWarnBlock(context),
        if (_post.status & POST_REVISED != 0) getPostRevisedBlock(context),

        // rich text rendering
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.0),
          child: Column(

            children: [
              // add a padding btm
              SizedBox(height: 8,),
              DiscuzHtmlWidget(
                _discuz,
                _html,
                tid: this.tid,
                callback: jumpToPidCallback,
              ),
              if (_post.attachmentMapper.isNotEmpty)
                ListView.builder(
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    Attachment attachment = _post.getAttachmentList()[index];
                    return AttachmentWidget(_discuz, attachment);
                  },
                  itemCount: _post.getAttachmentList().length,
                  physics: new NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                ),
              if (getCommentList().length != 0)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        Comment comment = getCommentList()[index];
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PostCommentWidget(comment),
                            if(index != getCommentList().length-1)
                              Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Divider(),
                              )

                          ],
                        );
                      },
                      itemCount: getCommentList().length,
                      physics: new NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                    ),
                  ),
                ),
            ],
          ),
        ),
        getPostTailWidget(context)
      ],
    );
  }



  Widget getPostPopupMenu(BuildContext context) {
    return PlatformPopupMenu(
        icon: Padding(
          padding: EdgeInsets.symmetric(horizontal: isCupertino(context)?8.0:0.0),
          child: Icon(
              PlatformIcons(context).ellipsis,
              size: 24,
              color: Theme.of(context).disabledColor
          ),
        ),

        options: [
          PopupMenuOption(
            label: S.of(context).replyPost,
            onTap: (option){
              VibrationUtils.vibrateWithClickIfPossible();
              Provider.of<ReplyPostNotifierProvider>(context, listen: false)
                  .setPost(_post);
            }
          ),
          PopupMenuOption(
            label: S.of(context).viewUserInfo(_post.author),
              onTap: (option){
                VibrationUtils.vibrateWithClickIfPossible();
                User? user =
                    Provider.of<DiscuzAndUserNotifier>(context, listen: false)
                        .user;
                Navigator.push(
                    context,
                    platformPageRoute(
                        context: context,
                        builder: (context) =>
                            UserProfilePage(_discuz, user, _post.authorId, username: _post.author,)));
              }
          ),
          PopupMenuOption(
            label: S.of(context).onlyViewAuthor,
              onTap: (option){
                VibrationUtils.vibrateWithClickIfPossible();
                if (onAuthorSelectedCallback != null) {
                  VibrationUtils.vibrateWithClickIfPossible();
                  onAuthorSelectedCallback!();
                }
              }
          ),
          if (!this.isUserBlocked)
            PopupMenuOption(
              label: S.of(context).blockUser,
                onTap: (option) async {
                  VibrationUtils.vibrateWithClickIfPossible();
                  // block user
                  setState(() {
                    this.isUserBlocked = true;
                  });
                  BlockUser blockUser = BlockUser(
                      _post.authorId, _post.author, DateTime.now(), _discuz);
                  int insertId = await _blockUserDao.insertBlockUser(blockUser);
                },
                material: (context, platform)=> MaterialPopupMenuOptionData(
                  textStyle: TextStyle(color: Theme.of(context).colorScheme.error)
                ),
                cupertino: (context, platform) => CupertinoPopupMenuOptionData(
                    isDestructiveAction: true
                )
            ),
          if (this.isUserBlocked)
            PopupMenuOption(
              label: S.of(context).unblockUser,
                onTap: (option){
                  VibrationUtils.vibrateWithClickIfPossible();
                  setState(() {
                    this.isUserBlocked = false;
                  });
                  _blockUserDao.deleteBlockUserByUid(_post.authorId, _discuz);
                },
              cupertino: (context, platform) => CupertinoPopupMenuOptionData(
                isDestructiveAction: true
              )
            ),

        ]
    );
  }

  Widget getUserAvatar(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: _post.first ? 4 : 2, horizontal: 8.0),
      child: UserAvatar(_discuz,
        _post.authorId,
        _post.author,
        size: _post.first ? 30.0 : 24.0,
      )
    );
  }

  Widget getPostFunctionWidget(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [


        Consumer<DiscuzNotificationProvider>(
          builder: (BuildContext context, DiscuzNotificationProvider value, Widget? child) {
            if(value.baseVariableResult.isModerator == 0){
              if (_user != null){
                return IconButton(
                  icon: Icon(
                    Icons.flag,
                    size: 16,
                    color: Theme.of(context).disabledColor,
                    semanticLabel: S.of(context).reportContentTitle(_post.author),
                  ),
                  onPressed: () {
                    VibrationUtils.vibrateWithClickIfPossible();
                    Navigator.push(
                        context,
                        platformPageRoute(
                            context: context,
                            builder: (context) => ReportContentPage(
                                _post.author, _post.pid, 0, formhash)));
                  },
                );
              }
              else{
                return Container();
              }
            }
            if(fid == null){
              return Container();
            }
            else{
              return adminPostPopupMenu;

            }
          }),
        getPostPopupMenu(context)
      ],
    );
  }



  WidgetSpan getGroupWidgetSpan(BuildContext context){
    return WidgetSpan(
      child:Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if(groupStar != 0)
          Padding(
            padding: EdgeInsets.only(left: 6.0),
            child: Container(
              color: Theme.of(context)
                  .colorScheme
                  .primary,
              padding: EdgeInsets.all(2.0),
              child: Text("Lv ${groupStar}",
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: Theme.of(context).textTheme.bodySmall?.fontSize)),
            ),
          ),
          Padding(
              padding: EdgeInsets.only(right: 6.0, left: groupStar == 0? 6.0: 0.0),
              child: Container(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer,
                padding: EdgeInsets.all(2.0),
                child: Text(groupTitle,
                    style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimaryContainer,
                        fontWeight: FontWeight.normal,
                        fontSize: Theme.of(context).textTheme.bodySmall?.fontSize)),
              )
          )
        ],
      )
      ,
    );
  }

  Widget getPostHeader(BuildContext context) {
    // get star and member title

    if (_post.first) {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          getUserAvatar(context),
          Expanded(
              child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 4.0,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // username and OP come first
                  RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      text: "",
                      style: DefaultTextStyle.of(context).style,
                      children: [
                        TextSpan(
                            text: _post.author,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),

                        if (_authorId == _post.authorId)
                          TextSpan(
                              text: ' ' + S.of(context).postAuthorLabel,
                              style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 14)),
                      ],
                    ),
                  ),

                  RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      text: TimeDisplayUtils.getLocaledTimeDisplay(
                        context,
                        _post.publishAt,
                      ),
                      style: DefaultTextStyle.of(context).style,
                      children: [
                        if (_post.status & POST_REVISED != 0)
                          TextSpan(
                              text: ' · ' + S.of(context).editedPost,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                        if (_post.ipLocation != "")
                          TextSpan(
                              text: ' ' + _post.ipLocation,
                              style: TextStyle(fontSize: 14)),
                        if (groupTitle != "")
                          getGroupWidgetSpan(context),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          )),
          getPostFunctionWidget(context)
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          getUserAvatar(context),
          Expanded(
              // the author
              child: RichText(
                
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              text: "",
              style: DefaultTextStyle.of(context).style,
              children: [
                TextSpan(
                    text: _post.author,
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                if (groupTitle != "")
                  getGroupWidgetSpan(context),
                if (_authorId == _post.authorId)
                  TextSpan(
                      text: ' ' + S.of(context).postAuthorLabel,
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 18)),
              ],
            ),
          )),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(_post.position.toString(), style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).disabledColor),
            ),
          )
        ],
      );
    }
  }

  Widget getPostTailWidget(BuildContext context) {
    if (_post.first) {
      return Container();
    } else {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  text: "",
                  children: [
                    TextSpan(
                        text: TimeDisplayUtils.getLocaledTimeDisplay(
                          context,
                          _post.publishAt,
                        ),
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Theme.of(context).disabledColor)
                    ),
                    if (_post.status & POST_REVISED != 0)
                      TextSpan(
                          text: ' · ' + S.of(context).editedPost,
                          style: TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 14,
                              color: Theme.of(context).disabledColor
                          )
                      ),
                    if (_post.ipLocation != "")
                      TextSpan(
                          text: ' ' + _post.ipLocation,
                          style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).disabledColor)
                      ),
                  ],
                ),
              ),
            ),
            // reports etcs
            getPostFunctionWidget(context)
          ],
        ),
      );
    }
  }

  Widget getPostBlockedBlock(BuildContext context) {
    return Container(
      color: Colors.red.withOpacity(0.15),
      child: Padding(
        padding: EdgeInsets.all(6.0),
        child: Row(
          children: [
            Icon(
              Icons.block,
              color: Colors.red,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  S.of(context).blockedPost,
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget getPostWarnBlock(BuildContext context) {
    return Container(
      color: Colors.deepOrange.withOpacity(0.15),
      child: Padding(
        padding: EdgeInsets.all(6.0),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_outlined,
              color: Colors.deepOrange,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  S.of(context).warnedPost,
                  style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget getPostRevisedBlock(BuildContext context) {
    return Container(
      color: Colors.blue.withOpacity(0.15),
      child: Padding(
        padding: EdgeInsets.all(6.0),
        child: Row(
          children: [
            Icon(
              Icons.edit_outlined,
              color: Colors.blue,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  S.of(context).revisedPost,
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget get adminPostPopupMenu => PlatformPopupMenu(
    icon: Icon(AppPlatformIcons(context).adminPostSolid, size: 16,),
    options: [
      PopupMenuOption(
          label: _post.warned? S.of(context).adminUnwarnPost : S.of(context).adminWarnPost,

          onTap: (option){
            VibrationUtils.vibrateWithClickIfPossible();
            toggleAdminWarnRequest();
          }
      ),
      PopupMenuOption(
          label: _post.blocked? S.of(context).adminUnblockPost : S.of(context).adminBlockPost,
          onTap: (option){
            VibrationUtils.vibrateWithClickIfPossible();
            toggleAdminBlockRequest();

          }
      ),
      PopupMenuOption(
          label: S.of(context).adminDeletePost,
          cupertino: (context, platform)=> CupertinoPopupMenuOptionData(
            isDestructiveAction: true
          ),
          onTap: (option){
            VibrationUtils.vibrateWithClickIfPossible();
            adminDeletePostRequest();
          }
      ),
    ]
  );

  bool isSendingAdminRequest = false;


  Future<void> toggleAdminBlockRequest() async {
    setState((){
      isSendingAdminRequest = true;
    });
    User? user =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    Discuz? discuz =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz;
    if(discuz == null || fid == null){
      return;
    }
    Dio dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    MobileApiClient client = MobileApiClient(dio, baseUrl: discuz.baseURL);

    int banned = _post.blocked? 0 : 1;


    client.banPostResult(formhash, fid!, _post.tid, [_post.pid], banned, "").then((value){
      if(value.errorResult?.key == "admin_succeed"){
        // it should be banned
        Post newPostStage = _post;
        newPostStage.status = newPostStage.status ^ POST_BLOCKED;
        setState(() {
          _post = newPostStage;
        });
        EasyLoading.showSuccess(value.errorResult?.content == null? S.of(context).ok: value.errorResult!.content);
      }
      else{
        EasyLoading.showError(value.errorResult?.content == null? S.of(context).error: value.errorResult!.content);
      }
      setState((){
        isSendingAdminRequest = false;

      });
    });
  }

  Future<void> toggleAdminWarnRequest() async {
    setState((){
      isSendingAdminRequest = true;
    });
    User? user =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    Discuz? discuz =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz;
    if(discuz == null || fid == null){
      return;
    }
    Dio dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    MobileApiClient client = MobileApiClient(dio, baseUrl: discuz.baseURL);

    int banned = _post.blocked? 0 : 1;


    client.warnPostResult(formhash, fid!, _post.tid, [_post.pid], banned, "").then((value){
      if(value.errorResult?.key == "admin_succeed"){
        // it should be banned
        Post newPostStage = _post;
        newPostStage.status = newPostStage.status ^ POST_WARNED;
        setState(() {
          _post = newPostStage;
        });
        EasyLoading.showSuccess(value.errorResult?.content == null? S.of(context).ok: value.errorResult!.content);
      }
      else{
        EasyLoading.showError(value.errorResult?.content == null? S.of(context).error: value.errorResult!.content);
      }
      setState((){
        isSendingAdminRequest = false;
      });

    });
  }

  Future<void> adminDeletePostRequest() async {
    setState((){
      isSendingAdminRequest = true;
    });
    User? user =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    Discuz? discuz =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz;
    if(discuz == null || fid == null){
      return;
    }
    Dio dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    MobileApiClient client = MobileApiClient(dio, baseUrl: discuz.baseURL);

    int banned = _post.blocked? 0 : 1;


    client.deletePostResult(formhash, fid!, _post.tid, [_post.pid], banned, "").then((value){
      if(value.errorResult?.key == "admin_succeed"){
        // it should be banned
        Post newPostStage = _post;
        newPostStage.status = newPostStage.status ^ POST_BLOCKED;
        setState(() {
          _post = newPostStage;
        });
        EasyLoading.showSuccess(value.errorResult?.content == null? S.of(context).ok: value.errorResult!.content);
      }
      else{
        EasyLoading.showError(value.errorResult?.content == null? S.of(context).error: value.errorResult!.content);
      }
      setState((){
        isSendingAdminRequest = false;
      });
      // Navigator.of(context).pop();
    });
  }
}
