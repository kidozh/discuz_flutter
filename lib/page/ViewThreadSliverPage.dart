import 'dart:collection';
import 'dart:developer';

import 'package:discuz_flutter/JsonResult/ViewThreadResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/dao/FavoriteThreadDao.dart';
import 'package:discuz_flutter/dao/ViewHistoryDao.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/DiscuzError.dart';
import 'package:discuz_flutter/entity/FavoriteThreadInDatabase.dart';
import 'package:discuz_flutter/entity/Post.dart';
import 'package:discuz_flutter/entity/Smiley.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/entity/ViewHistory.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/ExtraFuncInThreadScreen.dart';
import 'package:discuz_flutter/screen/SmileyListScreen.dart';
import 'package:discuz_flutter/utility/ConstUtils.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/PostTextFieldUtils.dart';
import 'package:discuz_flutter/utility/RewriteRuleUtils.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/CaptchaWidget.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:discuz_flutter/widget/PollWidget.dart';
import 'package:discuz_flutter/widget/PostTextField.dart';
import 'package:discuz_flutter/widget/PostWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:dio/dio.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:provider/provider.dart';
import 'package:discuz_flutter/provider/ReplyPostNotifierProvider.dart';
import 'InternalWebviewBrowserPage.dart';

class ViewThreadSliverPage extends StatelessWidget {
  late final Discuz discuz;
  late final User? user;
  int tid = 0;
  String? passedSubject;

  ViewThreadSliverPage(this.discuz, this.user, this.tid,{this.passedSubject});

  @override
  Widget build(BuildContext context) {
    return ViewThreadStatefulSliverWidget(discuz, user, tid, passedSubject: passedSubject,);
  }
}

class ViewThreadStatefulSliverWidget extends StatefulWidget {
  late final Discuz discuz;
  late final User? user;
  int tid = 0;
  String? passedSubject;

  ViewThreadStatefulSliverWidget(this.discuz, this.user, this.tid,{this.passedSubject});

  @override
  _ViewThreadSliverState createState() {
    return _ViewThreadSliverState(this.discuz, this.user, this.tid, passedSubject: passedSubject);
  }
}

class _ViewThreadSliverState extends State<ViewThreadStatefulSliverWidget> {
  ViewThreadResult _viewThreadResult = ViewThreadResult();
  DiscuzError? _error;
  List<Post> _postList = [];
  int _page = 1;
  String? passedSubject;
  final TextEditingController _replyController = new TextEditingController();
  final CaptchaController _captchaController =
      new CaptchaController(new CaptchaFields("", "post", ""));

  late final Discuz discuz;
  late final User? user;
  int tid = 0;

  bool historySaved = false;

  _ViewThreadSliverState(this.discuz, this.user, this.tid,{this.passedSubject});

  late EasyRefreshController _controller;
  late ScrollController _scrollController;
  ButtonState _sendReplyStatus = ButtonState.idle;
  ViewThreadQuery viewThreadQuery = ViewThreadQuery();
  Map<String, List<Comment>> postCommentList = {};
  final FocusNode _focusNode = FocusNode();


  // smiley=1, extra=2 or none = 0
  int dialogStatus = 0;
  List<String> insertedAidList = [];

  ValueNotifier<bool> showExtraButton = ValueNotifier(true);

  final int SHOW_SMILEY_DIALOG = 1;
  final int SHOW_EXTRA_DIALOG = 2;
  final int SHOW_NONE_DIALOG = 0;

  // 反向
  bool _reverse = false;

  // 方向
  Axis _direction = Axis.vertical;

  // Header浮动
  bool _headerFloat = false;

  // 无限加载
  bool _enableInfiniteLoad = true;

  // 控制结束
  bool _enableControlFinish = false;

  // 任务独立
  bool _taskIndependence = false;

  // 震动
  bool _vibration = true;

  // 是否开启刷新
  bool _enableRefresh = true;

  // 是否开启加载
  bool _enableLoad = true;

  // 顶部回弹
  bool _topBouncing = true;

  // 底部回弹
  bool _bottomBouncing = true;

  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController();
    _scrollController = ScrollController();
    _loadClient();

    _loadPreference();
    //_invalidateContent();
    bindFocusNode();
    _loadDao();
  }

  void _loadDao() async{
    setState(() async{
      favoriteThreadDao = await AppDatabase.getFavoriteThreadDao();
    });

  }

  void bindFocusNode(){
    _focusNode.addListener(() {
      if(_focusNode.hasFocus){
        setState(() {
          dialogStatus = SHOW_NONE_DIALOG;
        });
      }
    });

    _scrollController.addListener(() {
      // remove focus when
      if(_focusNode.hasFocus){
        _focusNode.unfocus();
      }
      if(dialogStatus != SHOW_NONE_DIALOG){
        setState(() {
          dialogStatus = SHOW_NONE_DIALOG;
        });
      }
    });



    _replyController.addListener(() {
      //print("Get reply text ${_replyController.text} ${_replyController.text.isNotEmpty}");
      if(_replyController.text.isNotEmpty){
        if(showExtraButton.value == true){
          showExtraButton.value = false;
        }

      }
      else{
        showExtraButton.value = true;
      }
    });
  }

  @override
  void dispose(){
    _focusNode.dispose();
    _replyController.dispose();

    super.dispose();
  }

  bool ignoreFontCustomization = false;

  void _loadPreference() async {
    ignoreFontCustomization =
        await UserPreferencesUtils.getDisableFontCustomizationPreference();


  }

  void _saveViewHistory(DetailedThreadInfo threadInfo, String contents) async {
    // check if needed
    bool allowViewHistory =
        await UserPreferencesUtils.getRecordHistoryEnabled();
    if (!allowViewHistory) {
      historySaved = true;
      historySaved = true;
      return;
    }

    // prepare database

    ViewHistoryDao viewHistoryDao = await AppDatabase.getViewHistoryDao();

    ViewHistory insertViewHistory = ViewHistory(
        threadInfo.subject,
        contents,
        threadInfo.freeMessage,
        "thread",
        threadInfo.tid,
        threadInfo.author,
        threadInfo.authorId,
        discuz,
        DateTime.now());
    int primaryKey = await viewHistoryDao.insertViewHistory(insertViewHistory);
    print("save history with primary key ${primaryKey}");
    historySaved = true;
  }

  void _invalidateContent() {
    setState(() {
      _page = 1;
    });
    _loadForumContent();
  }

  void setNewViewThreadQuery(ViewThreadQuery viewThreadQuery) {
    setState(() {
      this.viewThreadQuery = viewThreadQuery;
      _page = 1;
      _postList = [];
    });
    _loadForumContent();
  }

  Future<void> _sendReply() async {
    User? user =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    String formhash = _viewThreadResult.threadVariables.formHash;
    int fid = _viewThreadResult.threadVariables.fid;
    if (user == null) {
      return;
    }
    setState(() {
      _sendReplyStatus = ButtonState.loading;
    });
    final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    final client = MobileApiClient(dio, baseUrl: discuz.baseURL);
    // need to be filtered
    String message = PostTextFieldUtils.getPostMessage(_replyController.text);

    // check for captcha information
    CaptchaFields? captchaFields = _captchaController.value;
    String captchaHash = "";
    String captchaMod = "";
    String verification = "";
    if (captchaFields != null && captchaFields.captchaFormHash.isNotEmpty) {
      captchaHash = captchaFields.captchaFormHash;
      verification = captchaFields.verification;
      // captchaMod = "forum::post";
      captchaMod = "forum::viewthread";
      print(
          "Captcha hash: ${captchaFields.captchaFormHash} verification: ${captchaFields.verification}");
    }

    Post? replyPost =
        Provider.of<ReplyPostNotifierProvider>(context, listen: false).post;
    //print("reply post ${replyPost}");
    String? notifyAuthorMessage = null;
    if (replyPost != null) {
      DateFormat dateFormat = DateFormat.yMEd().add_jms();
      String fullTimeString = dateFormat.format(replyPost.publishAt);
      String removedTagMessage =
          replyPost.message.replaceAll(RegExp(r"<.*?>"), "");
      if (removedTagMessage.length > 200) {
        removedTagMessage = removedTagMessage.substring(0, 100) + "...";
      }
      String trimMessage = removedTagMessage;
      notifyAuthorMessage = S.of(context).replyPostTrimMessage(replyPost.pid,
          replyPost.tid, replyPost.author, fullTimeString, trimMessage);
    }

    HashMap<String,String> attachImgMap = HashMap();
    for(var aid in insertedAidList){
      String key = "attachnew[${aid}][description]";
      attachImgMap[key] = "${aid}";
    }

    client
        .sendReplyResult(
            fid,
            tid,
            formhash,
            replyPost == null ? null : replyPost.pid,
            notifyAuthorMessage,
            message,
            captchaHash,
            captchaMod,
            verification,attachImgMap)
        .then((value) {
      if (value.errorResult!.key == "post_reply_succeed") {
        EasyLoading.showSuccess(
            '${value.errorResult!.content}(${value.errorResult!.key})');
        setState(() {
          _sendReplyStatus = ButtonState.success;
          // just to clear the pic
          insertedAidList.clear();
        });
        // delay
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _sendReplyStatus = ButtonState.idle;
            _replyController.clear();
          });
        });
      } else {
        setState(() {
          _sendReplyStatus = ButtonState.fail;
        });
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _sendReplyStatus = ButtonState.idle;
            //_replyController.clear();
          });
        });
        EasyLoading.showError(
            '${value.errorResult!.content}(${value.errorResult!.key})');
      }
    }).catchError((onError) {
      VibrationUtils.vibrateErrorIfPossible();
      EasyLoading.showError('${onError}');
      setState(() {
        _sendReplyStatus = ButtonState.fail;
      });
    });
  }

  late Dio dio;
  late MobileApiClient client;

  Future<void> _loadClient() async{
    User? user =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    client = MobileApiClient(dio, baseUrl: discuz.baseURL);

  }

  void favoriteThread() async{
    FavoriteThreadDao favoriteThreadDao = await AppDatabase.getFavoriteThreadDao();
    favoriteThreadDao.insertFavoriteThread(
        FavoriteThreadInDatabase(1, _viewThreadResult.threadVariables.member_uid,
            tid,
            "tid",
            _viewThreadResult.threadVariables.threadInfo.authorId,
            _viewThreadResult.threadVariables.threadInfo.subject,
            "",
            _viewThreadResult.threadVariables.threadInfo.author,
            _viewThreadResult.threadVariables.threadInfo.replies,
            DateTime.now(),
            discuz)
    );
    client.favoriteThreadActionResult(_viewThreadResult.threadVariables.formHash, tid).then((value){
      if(value.errorResult!= null && value.errorResult!.key == "do_success"){
        EasyLoading.showSuccess(S.of(context).discuzOperationMessage(value.errorResult!.key, value.errorResult!.content));
      }
      else{
        EasyLoading.showToast(S.of(context).discuzOperationMessage(value.errorResult!.key, value.errorResult!.content));
      }
    });
  }

  void unfavoriteThread() async{
    FavoriteThreadDao favoriteThreadDao = await AppDatabase.getFavoriteThreadDao();
    FavoriteThreadInDatabase? favoriteThreadInDatabase = favoriteThreadDao.getFavoriteThreadByTid(tid, discuz);
    if(favoriteThreadInDatabase!= null){
      favoriteThreadDao.removeFavoriteThread(favoriteThreadInDatabase);
      client.unfavoriteThreadActionResult(_viewThreadResult.threadVariables.formHash, favoriteThreadInDatabase.favid).then((value){
        if(value.errorResult!= null && value.errorResult!.key == "do_success"){
          EasyLoading.showSuccess(S.of(context).discuzOperationMessage(value.errorResult!.key, value.errorResult!.content));
        }
        else{
          EasyLoading.showToast(S.of(context).discuzOperationMessage(value.errorResult!.key, value.errorResult!.content));
        }
      });
    }


  }

  FavoriteThreadDao? favoriteThreadDao;

  Future<void> _loadForumContent() async {
    // check the availability
    log("Base url ${discuz.baseURL} ${_page}");
    User? user =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    final client = MobileApiClient(dio, baseUrl: discuz.baseURL);

    client
        .viewThreadResult(tid, _page, viewThreadQuery.generateForumQueriesMap())
        .then((value) {
      if (!historySaved &&
          _page == 1 &&
          value.threadVariables.postList.length > 0) {
        _saveViewHistory(value.threadVariables.threadInfo,
            value.threadVariables.postList.first.message);
      }

      setState(() {
        _viewThreadResult = value;
        _error = null;
        if (_page == 1) {
          _postList = value.threadVariables.postList;
        } else {
          _postList.addAll(value.threadVariables.postList);
          _postList = _postList;
        }
        postCommentList.addAll(value.threadVariables.commentList);
      });
      _page += 1;

      if (!_enableControlFinish) {
        _controller.resetLoadState();
        _controller.finishRefresh();
      }
      // check for loaded all?
      log("Get list ${value.threadVariables.threadInfo.allreplies} ${_postList.length} ${value.threadVariables.threadInfo.replies}");
      if (!_enableControlFinish) {
        _controller.finishLoad(
            noMore: _postList.length >=
                value.threadVariables.threadInfo.replies + 1);
      }

      if (value.getErrorString() != null) {
        EasyLoading.showError(value.getErrorString()!);
      }

      if (value.errorResult != null) {
        setState(() {
          _error =
              DiscuzError(value.errorResult!.key, value.errorResult!.content);
        });
      } else {
        setState(() {
          _error = null;
        });
      }
      if (user != null && value.threadVariables.member_uid != user.uid) {
        log("recv user uid different! ${user.uid} ${value.threadVariables.member_uid} ${value.threadVariables.member_username}");
        setState(() {
          _error = DiscuzError(S.of(context).userExpiredTitle(user.username),
              S.of(context).userExpiredSubtitle);
        });
      }

      log("set successful result ${_viewThreadResult} ${_postList.length}");

      // save rewrite rule
      if (value.threadVariables.rewriteRule != null) {
        // save rewrite url in database
        RewriteRule rewriteRule = value.threadVariables.rewriteRule;
        if (rewriteRule.forumDisplay.isNotEmpty) {
          RewriteRuleUtils.putForumDisplayRule(
              discuz, rewriteRule.forumDisplay);
        }

        if (rewriteRule.viewThread.isNotEmpty) {
          RewriteRuleUtils.putViewThreadRule(discuz, rewriteRule.viewThread);
        }

        if (rewriteRule.userSpace.isNotEmpty) {
          RewriteRuleUtils.putUserProfileRule(discuz, rewriteRule.userSpace);
        }
      }
    }).catchError((onError, stack) {
      VibrationUtils.vibrateErrorIfPossible();
      EasyLoading.showError('${onError}');
      log("${onError} ${stack}");
      if (!_enableControlFinish) {
        _controller.resetLoadState();
        _controller.finishRefresh();
      }
      switch (onError.runtimeType) {
        case DioError:
          {
            _error =
                DiscuzError(onError.runtimeType.toString(), onError.toString());
            break;
          }
        default:
          {
            setState(() {
              _error = DiscuzError(
                  onError.runtimeType.toString(), onError.toString());
            });
          }
      }
    });
  }

  void scrollToPid(int pid){
    for(var post in _postList){
      if(post.pid == pid){
        
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      iosContentPadding: true,
      iosContentBottomPadding: true,
      appBar: PlatformAppBar(
        //middle: Text(S.of(context).forumDisplayTitle),
        // title: Text(S.of(context).viewThreadTitle),
        title: _viewThreadResult.threadVariables.threadInfo.subject.isEmpty
            ? Text(S.of(context).viewThreadTitle,
                overflow: TextOverflow.ellipsis)
            : Text(_viewThreadResult.threadVariables.threadInfo.subject,
                overflow: TextOverflow.ellipsis),
        trailingActions: [
          if(favoriteThreadDao != null)
          IconButton(
              onPressed: () async{
                VibrationUtils.vibrateWithClickIfPossible();
                FavoriteThreadInDatabase? favoriteThreadInDatabase = favoriteThreadDao!.getFavoriteThreadByTid(tid, discuz);
                if(favoriteThreadInDatabase == null){
                  favoriteThread();
                }
                else{
                  unfavoriteThread();
                }
              },
              icon: ValueListenableBuilder(
                valueListenable: favoriteThreadDao!.favoriteThreadBox.listenable(),
                builder: (BuildContext context, value, Widget? child) {
                    FavoriteThreadInDatabase? favList = favoriteThreadDao!.getFavoriteThreadByTid(tid, discuz);
                    if(favList == null){
                      return Icon(Icons.favorite_border,size: 24,);
                    }
                    else{
                      return Icon(Icons.favorite,size: 24);
                    }
                },

              )
          ),


          IconButton(
            icon: Icon(viewThreadQuery.timeAscend
                ? PlatformIcons(context).upArrow
                : PlatformIcons(context).downArrow, size: 24,),
            onPressed: () {
              VibrationUtils.vibrateWithClickIfPossible();
              viewThreadQuery.timeAscend = !viewThreadQuery.timeAscend;
              setNewViewThreadQuery(viewThreadQuery);
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem<int>(
                child: Text(S.of(context).openViaInternalBrowser),
                value: 0,
              )
            ],
            onSelected: (int pos) {
              VibrationUtils.vibrateWithClickIfPossible();
              switch (pos) {
                case 0:
                  {
                    Navigator.push(
                        context,
                        platformPageRoute(
                            context: context,
                            builder: (context) => InternalWebviewBrowserPage(
                                discuz,
                                user,
                                URLUtils.getViewThreadURL(discuz, tid))));
                  }
              }
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child: EasyRefresh.custom(
            enableControlFinishRefresh: true,
            enableControlFinishLoad: true,
            taskIndependence: _taskIndependence,
            controller: _controller,
            scrollController: _scrollController,
            reverse: _reverse,
            scrollDirection: _direction,
            topBouncing: _topBouncing,
            bottomBouncing: _bottomBouncing,
            header: _enableRefresh
                ? ClassicalHeader(
                    enableInfiniteRefresh: false,
                    bgColor: _headerFloat
                        ? Theme.of(context).primaryColor
                        : Colors.transparent,
                    // infoColor: _headerFloat ? Colors.black87 : Theme.of(context).primaryColor,
                    textColor:
                        Theme.of(context).textTheme.headline1!.color == null
                            ? Theme.of(context).primaryColorDark
                            : Theme.of(context).textTheme.headline1!.color!,
                    float: _headerFloat,
                    enableHapticFeedback: _vibration,
                    refreshText: S.of(context).pullToRefresh,
                    refreshReadyText: S.of(context).releaseToRefresh,
                    refreshingText: S.of(context).refreshing,
                    refreshedText: S.of(context).refreshed,
                    refreshFailedText: S.of(context).refreshFailed,
                    noMoreText: S.of(context).noMore,
                    infoText: S.of(context).updateAt,
                  )
                : null,
            footer: _enableLoad
                ? ClassicalFooter(
                    enableInfiniteLoad: _enableInfiniteLoad,
                    enableHapticFeedback: _vibration,
                    textColor:
                        Theme.of(context).textTheme.headline1!.color == null
                            ? Theme.of(context).primaryColorDark
                            : Theme.of(context).textTheme.headline1!.color!,
                    loadText: S.of(context).pushToLoad,
                    loadReadyText: S.of(context).releaseToLoad,
                    loadingText: S.of(context).loading,
                    loadedText: S.of(context).loaded,
                    loadFailedText: S.of(context).loadFailed,
                    noMoreText: S.of(context).noMore,
                    infoText: S.of(context).updateAt,
                  )
                : null,
            onRefresh: _enableRefresh
                ? () async {
                    _invalidateContent();
                    if (!_enableControlFinish) {
                      _controller.resetLoadState();
                      _controller.finishRefresh();
                    }
                  }
                : null,
            onLoad: _enableLoad
                ? () async {
                    _loadForumContent();
                  }
                : null,
            firstRefresh: true,
            firstRefreshWidget: Container(
              width: double.infinity,
              height: double.infinity,
              child: Center(
                  child: SizedBox(
                height: 200.0,
                width: 300.0,
                child: Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 50.0,
                        height: 50.0,
                        child: SpinKitFadingCube(
                          color: Theme.of(context).primaryColor,
                          size: 25.0,
                        ),
                      ),
                      Container(
                        child: Text(S.of(context).loading),
                      )
                    ],
                  ),
                ),
              )),
            ),
            slivers: <Widget>[
              SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, _) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Hero(
                          tag: ConstUtils.HERO_TAG_THREAD_SUBJECT,
                          child: Text(
                            _viewThreadResult.threadVariables.threadInfo.subject.isEmpty && passedSubject!=null? passedSubject!: _viewThreadResult.threadVariables.threadInfo.subject,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,

                            ),
                          ),
                        ),
                      );
                    },
                    childCount: 1,
                  )),

              if (_error != null)
                SliverList(
                    delegate: SliverChildBuilderDelegate(
                  (context, _) {
                    return ErrorCard(_error!.key, _error!.content, () {
                      _controller.callRefresh();
                    });
                  },
                  childCount: 1,
                )),

              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Column(
                      children: [
                        // insert poll here
                        if (index == 0 &&
                            _viewThreadResult.threadVariables.poll != null)
                          PollWidget(
                            _viewThreadResult.threadVariables.poll!,
                            _viewThreadResult.threadVariables.formHash,
                            tid,
                            _viewThreadResult.threadVariables.fid,
                          ),
                        PostWidget(
                          discuz,
                          _postList[index],
                          _viewThreadResult.threadVariables.threadInfo.authorId,
                          _viewThreadResult.threadVariables.formHash,
                          onAuthorSelectedCallback: () {
                            if (viewThreadQuery.authorId == 0) {
                              viewThreadQuery.authorId =
                                  _postList[index].authorId;
                            } else {
                              viewThreadQuery.authorId = 0;
                            }
                            setNewViewThreadQuery(viewThreadQuery);
                          },
                          postCommentList: postCommentList,
                          ignoreFontCustomization: ignoreFontCustomization,
                          jumpToPidCallback: (pid){
                            // need to find the pid and scroll to it

                          },
                        ),
                      ],
                    );
                  },
                  childCount: _postList.length,
                ),
              ),
            ],
          )),
          // comment parts
          if(_viewThreadResult.threadVariables.threadInfo.closed)
            Container(
              color: Theme.of(context).errorColor.withOpacity(0.1),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Text(S.of(context).threadIsClosed,style: Theme.of(context).textTheme.bodyText1?.copyWith(
                        color: Theme.of(context).errorColor
                    ),)
                  ],
                ),

                ),
            )
            ,
          if(!_viewThreadResult.threadVariables.threadInfo.closed && _viewThreadResult.errorResult==null)
          Consumer<DiscuzAndUserNotifier>(
            builder: (context, discuzAndUser, child) {
              if (discuzAndUser.user != null) {
                return
                  Container(

                    padding: EdgeInsets.all(4.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Consumer<ReplyPostNotifierProvider>(
                          builder: (context, replyPost, child) {
                            if (replyPost.post != null) {
                              return Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  ActionChip(
                                    label: Text(replyPost.post!.author),
                                    avatar: Icon(
                                        PlatformIcons(context).clearThickCircled),
                                    onPressed: () {
                                      VibrationUtils.vibrateWithClickIfPossible();
                                      // removing it
                                      Provider.of<ReplyPostNotifierProvider>(
                                          context,
                                          listen: false)
                                          .setPost(null);
                                    },
                                  ),
                                  Expanded(
                                      child: Padding(
                                          padding: EdgeInsets.only(
                                              left: 8.0, right: 8.0),
                                          child: Text(
                                            replyPost.post!.message
                                                .replaceAll(RegExp(r"<img*?>"),
                                                S.of(context).pictureTagInMessage)
                                                .replaceAll(
                                                RegExp(r"<div.*?>.*?</div>"),
                                                "")
                                                .replaceAll(RegExp(r"<.*?>"), ""),
                                            style: TextStyle(fontSize: 14),
                                            overflow: TextOverflow.ellipsis,
                                          )))
                                ],
                              );
                            } else {
                              return Container(height: 0);
                            }
                          },
                        ),

                        // input fields
                        Column(
                          children: [
                            Row(
                              children: [

                                Expanded(
                                    child: Padding(
                                        padding: EdgeInsets.all(12.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            //color: Colors.white,
                                            borderRadius: BorderRadius.all(Radius.circular(4.0,)),
                                          ),
                                          child: PostTextField(discuz, _replyController,focusNode: _focusNode,),
                                        ),
                                    )),
                                IconButton(

                                  icon: dialogStatus != SHOW_SMILEY_DIALOG ?
                                  Icon(Icons.emoji_emotions_outlined) :
                                  Icon(Icons.keyboard_outlined),
                                  onPressed: (){
                                    if (dialogStatus!=SHOW_SMILEY_DIALOG) {
                                      FocusScope.of(context).requestFocus(new FocusNode());
                                      setState(() {
                                        dialogStatus = SHOW_SMILEY_DIALOG;
                                      });
                                    } else {
                                      FocusScope.of(context).requestFocus(_focusNode);
                                      setState(() {
                                        dialogStatus = SHOW_NONE_DIALOG;
                                      });
                                    }
                                  },

                                ),
                                ValueListenableBuilder(
                                    valueListenable: showExtraButton,
                                    builder: (context, value, _){
                                      if(value == false){
                                        return ProgressButton.icon(
                                            maxWidth: 60.0,

                                            iconedButtons: {
                                              ButtonState.idle: IconedButton(
                                                //text: S.of(context).sendReply,
                                                  icon: Icon(Icons.send,
                                                      color: Colors.white),
                                                  color: Theme.of(context).primaryColor),
                                              ButtonState.loading: IconedButton(
                                                //text: S.of(context).progressButtonReplySending,
                                                  color: Theme.of(context).colorScheme.secondary),
                                              ButtonState.fail: IconedButton(
                                                //text: S.of(context).progressButtonReplyFailed,
                                                  icon: Icon(Icons.cancel,
                                                      color: Colors.white),
                                                  color: Colors.red.shade300),
                                              ButtonState.success: IconedButton(
                                                //text: S.of(context).progressButtonReplySuccess,
                                                  icon: Icon(
                                                    Icons.check_circle,
                                                    color: Colors.white,
                                                  ),
                                                  color: Colors.green.shade400)
                                            },
                                            onPressed: () {
                                              VibrationUtils.vibrateWithClickIfPossible();
                                              _sendReply();
                                            },
                                            state: _sendReplyStatus);
                                      }
                                      else{
                                        //return Container();
                                        return IconButton(
                                            icon: Icon(dialogStatus == SHOW_EXTRA_DIALOG ? Icons.close :Icons.add_circle_outline),
                                            onPressed: (){
                                              if (dialogStatus!=SHOW_EXTRA_DIALOG) {
                                                FocusScope.of(context).requestFocus(new FocusNode());
                                                setState(() {
                                                  dialogStatus = SHOW_EXTRA_DIALOG;
                                                });
                                              } else {
                                                FocusScope.of(context).requestFocus(_focusNode);
                                                setState(() {
                                                  dialogStatus = SHOW_NONE_DIALOG;
                                                });
                                              }
                                            },
                                        );
                                      }
                                    }
                                )

                              ],
                            ),
                            CaptchaWidget(
                              null,
                              discuz,
                              user,
                              "post",
                              captchaController: _captchaController,
                            ),
                            if (dialogStatus == SHOW_SMILEY_DIALOG)
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SmileyListScreen((smiley) {
                                    insertSmiley(smiley);
                                  })
                                ],
                              ),
                            if (dialogStatus == SHOW_EXTRA_DIALOG)
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ExtraFuncInThreadScreen(tid,_viewThreadResult.threadVariables.fid,
                                    onReplyWithImage: (aid){
                                      // fill with text first
                                      // refresh the layout
                                      // insertedAidList.clear();
                                      if(aid.isNotEmpty){
                                        _replyController.text = _replyController.text + "[attachimg]${aid}[/attachimg]";
                                        // add aid to list
                                        insertedAidList.add(aid);
                                      }
                                      else{

                                      }

                                      // not to send it automatically
                                      // check whether need seccode
                                      // CaptchaFields? captchaFields = _captchaController.value;
                                      // if(captchaFields != null && captchaFields.captchaFormHash.isNotEmpty){
                                      //   EasyLoading.showInfo(S.of(context).sendImageWithVerificationNotice);
                                      // }
                                      // else{
                                      //   _sendReply();
                                      // }


                                    },
                                  ),
                                ],
                              )
                          ],
                        )
                      ],
                    ),
                  );
              } else {
                return Container(
                  width: 0,
                  height: 0,
                );
              }
            },
          )
        ],
      ),
    );
  }



  void insertSmiley(Smiley smiley) {
    print("Smiley is pressed ${smiley.code} ${smiley.relativePath}");

    final TextSelection selection = _replyController.selection.copyWith();
    final int start = selection.baseOffset;
    int end = selection.extentOffset;

    final TextEditingValue value = _replyController.value;

    String smileyCode =
        "${SmileyText.smileyStartFlag}${smiley.toString()}${SmileyText.smileyEndFlag}";
    final text = smileyCode;
    if (selection.isValid) {
      String newText = "";
      if (value.selection.isCollapsed) {
        if (end > 0) {
          newText += value.text.substring(0, end);
        }
        newText += text;
        if (value.text.length > end) {
          newText += value.text.substring(end, value.text.length);
        }
      } else {
        newText = value.text.replaceRange(start, end, text);
        end = start;
      }
      _replyController.value = value.copyWith(
          text: newText,
          selection: selection.copyWith(
              baseOffset: end + text.length, extentOffset: end + text.length));
    } else {
      String newText = "";
      newText = _replyController.text + text;
      // if (end > 0) {
      //   newText += value.text.substring(0, end);
      // }
      // newText += text;

      _replyController.value = TextEditingValue(
          text: newText,
          selection:
              TextSelection.fromPosition(TextPosition(offset: newText.length)));
    }
  }
}

class ViewThreadQuery {
  int authorId = 0;
  bool timeAscend = true;

  Map<String, String> generateForumQueriesMap() {
    Map<String, String> queriesMap = {};
    if (authorId != 0) {
      queriesMap["authorid"] = authorId.toString();
    }
    if (!timeAscend) {
      queriesMap["ordertype"] = "1";
    }
    return queriesMap;
  }
}
