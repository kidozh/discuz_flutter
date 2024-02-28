import 'dart:collection';
import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/JsonResult/ViewThreadResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/dao/FavoriteThreadDao.dart';
import 'package:discuz_flutter/dao/ImageAttachmentDao.dart';
import 'package:discuz_flutter/dao/ViewHistoryDao.dart';
import 'package:discuz_flutter/dao/ViewThreadCacheDao.dart';
import 'package:discuz_flutter/dao/ViewThreadScrollDistanceDao.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/DiscuzError.dart';
import 'package:discuz_flutter/entity/FavoriteThreadInDatabase.dart';
import 'package:discuz_flutter/entity/ImageAttachment.dart';
import 'package:discuz_flutter/entity/Post.dart';
import 'package:discuz_flutter/entity/Smiley.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/entity/ViewHistory.dart';
import 'package:discuz_flutter/entity/ViewThreadCache.dart';
import 'package:discuz_flutter/entity/ViewThreadScrollDistance.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/provider/ReplyPostNotifierProvider.dart';
import 'package:discuz_flutter/screen/EmptyListScreen.dart';
import 'package:discuz_flutter/screen/ExtraFuncInThreadScreen.dart';
import 'package:discuz_flutter/screen/SmileyListScreen.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/PostTextFieldUtils.dart';
import 'package:discuz_flutter/utility/RewriteRuleUtils.dart';
import 'package:discuz_flutter/utility/ToastUtils.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/CaptchaWidget.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:discuz_flutter/widget/LoadingStateWidget.dart';
import 'package:discuz_flutter/widget/PollWidget.dart';
import 'package:discuz_flutter/widget/PostTextField.dart';
import 'package:discuz_flutter/widget/PostWidget.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:share_plus/share_plus.dart';

import '../provider/DiscuzNotificationProvider.dart';
import '../utility/EasyRefreshUtils.dart';
import '../widget/AppBannerAdWidget.dart';
import '../widget/DiscuzNotificationAppbarIconWidget.dart';
import 'InternalWebviewBrowserPage.dart';
import 'SettingPage.dart';

class ViewThreadSliverPage extends StatelessWidget {
  Discuz discuz;
  User? user;
  int tid;
  String? passedSubject;
  VoidCallback? onClosed;

  ViewThreadSliverPage(this.discuz, this.user, this.tid,
      {this.passedSubject, this.onClosed});

  @override
  Widget build(BuildContext context) {
    return ViewThreadStatefulSliverWidget(
      discuz,
      user,
      tid,
      passedSubject: passedSubject,
      onClosed: onClosed,
    );
  }
}

class ViewThreadStatefulSliverWidget extends StatefulWidget {
  late final Discuz discuz;
  late final User? user;
  int tid = 0;
  String? passedSubject;
  VoidCallback? onClosed;

  ViewThreadStatefulSliverWidget(this.discuz, this.user, this.tid,
      {this.passedSubject, this.onClosed});

  @override
  _ViewThreadSliverState createState() {
    return _ViewThreadSliverState(this.discuz, this.user, this.tid,
        passedSubject: passedSubject, onClosed: onClosed);
  }
}

class _ViewThreadSliverState extends State<ViewThreadStatefulSliverWidget> {
  ViewThreadResult _viewThreadResult = ViewThreadResult();
  bool _isFirstLoading = true;
  DiscuzError? _error;
  List<Post> _postList = [];
  int _page = 1;
  String? passedSubject;
  final TextEditingController _replyController = new TextEditingController();
  final CaptchaController _captchaController =
      new CaptchaController(new CaptchaFields("", "post", ""));

  late final Discuz discuz;
  late final User? user;

  int tid;

  bool historySaved = false;
  VoidCallback? onClosed;
  _ViewThreadSliverState(this.discuz, this.user, this.tid,
      {this.passedSubject, this.onClosed});

  EasyRefreshController _controller = EasyRefreshController(
      controlFinishLoad: true, controlFinishRefresh: true);
  ScrollController _scrollController = ScrollController();
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
  // cache status
  bool cached = false;
  int _initialPage = 1;
  int preCachedItemNum = 0;

  @override
  void initState() {
    super.initState();
    _loadClient();

    _loadPreference();
    //_invalidateContent();
    bindFocusNode();
    _loadDao();
    // set reply post as null
    Provider.of<ReplyPostNotifierProvider>(context, listen: false)
        .setPost(null);
  }

  void _loadDao() async {
    FavoriteThreadDao dao = await AppDatabase.getFavoriteThreadDao();


    // should check with record first
    setState(() {
      favoriteThreadDao = dao;
    });


  }

  void bindFocusNode() {
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          dialogStatus = SHOW_NONE_DIALOG;
        });
      }
    });

    _scrollController.addListener(() {
      // remove focus when
      if (_focusNode.hasFocus) {
        _focusNode.unfocus();
      }
      if (dialogStatus != SHOW_NONE_DIALOG) {
        setState(() {
          dialogStatus = SHOW_NONE_DIALOG;
        });
      }
    });

    _replyController.addListener(() {
      //print("Get reply text ${_replyController.text} ${_replyController.text.isNotEmpty}");
      if (_replyController.text.isNotEmpty) {
        if (showExtraButton.value == true) {
          showExtraButton.value = false;
        }
      } else {
        showExtraButton.value = true;
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _replyController.dispose();
    // save with distance
    double offset = _scrollController.offset;
    if(viewThreadScrollDistanceDao!=null){
      ViewThreadScrollDistance element = ViewThreadScrollDistance(tid, offset, discuz, DateTime.now(), viewThreadQuery.timeAscend);
      viewThreadScrollDistanceDao!.insertViewThreadScrollDistance(element);
    }

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

  Future<IndicatorResult> _invalidateContent() async {
    _initialPage = 1;

    if(viewThreadCacheDao == null || viewThreadScrollDistanceDao == null){
      // retrieve cache
      viewThreadCacheDao = await AppDatabase.getViewThreadCacheDao();
      viewThreadScrollDistanceDao = await AppDatabase.getViewThreadScrollDistanceDao();
      List<ViewThreadCache> viewThreadCacheList = viewThreadCacheDao!.findAllViewThreadCacheListByDiscuz(discuz, tid, viewThreadQuery.timeAscend);
      if(viewThreadCacheList.isEmpty){
        cached = false;

      }
      else{
        // point to the last cached page
        cached = true;
        _initialPage = viewThreadCacheList.last.page;

        List<Post> cachedPost = [];
        bool isCacheSuccessful = true;

        for(var threadCache in viewThreadCacheList){
          try{
            ViewThreadResult result = ViewThreadResult.fromJson(jsonDecode(threadCache.json));
            cachedPost.addAll(result.threadVariables.postList);
            if(threadCache != viewThreadCacheList.last){
              preCachedItemNum += result.threadVariables.postList.length;
            }
          }
          catch(e){
            log("Not Successful decode!!! ${threadCache.json}");
            isCacheSuccessful = false;
            break;
          }
        }

        if(isCacheSuccessful){
          // cache integrity successful
          ViewThreadResult lastResult = ViewThreadResult.fromJson(jsonDecode(viewThreadCacheList.last.json));
          setState(() {
            _viewThreadResult = lastResult;
            _postList = cachedPost;
          });
          double? offset = viewThreadScrollDistanceDao!.findViewThreadCacheListByDiscuz(discuz, tid, viewThreadQuery.timeAscend)?.offset;
          if(offset!=null){
            _scrollController.animateTo(offset, duration: Durations.short2, curve: Curves.easeInOut);
          }
          // Toast here
          ToastUtils.showSuccessfulToast("Cached successful");
        }

      }

    }
    else{
      // should delete all cache now!!!
      _initialPage = 1;
      // clear cache
      viewThreadCacheDao!.deleteAllViewThreadCacheByTid(discuz, tid);
      viewThreadScrollDistanceDao!.deleteAllViewThreadScrollDistanceByTid(discuz, tid);

    }


    setState(() {
      _page = _initialPage;
    });
    return await _loadForumContent();
  }

  void setNewViewThreadQuery(ViewThreadQuery viewThreadQuery) {
    setState(() {
      this.viewThreadQuery = viewThreadQuery;
      _page = 1;
      _postList = [];
    });
    _loadForumContent();
  }

  void _saveViewThreadCache(ViewThreadResult result, int tid, int page, bool isAscend) async {
    // check if needed
    String json = jsonEncode(result);
    ViewThreadCache viewThreadCache = ViewThreadCache(tid, json, discuz, DateTime.now(), page, isAscend);
    viewThreadCacheDao?.insertViewThreadCache(viewThreadCache);

  }

  Future<void> _sendReply(BuildContext context) async {
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
    // check with preference
    String signaturePreference =
        await UserPreferencesUtils.getSignaturePreference();
    log("Recv signature ${signaturePreference}");
    if (signaturePreference.isNotEmpty) {
      if (signaturePreference == PostTextFieldUtils.USE_DEVICE_SIGNATURE) {
        String deviceName = await PostTextFieldUtils.getDeviceName(context);
        if (deviceName.isNotEmpty) {
          message += "\n\n${S.of(context).fromDeviceSignature(deviceName)}";
        }
      } else {
        message += "\n\n${signaturePreference}";
      }
    }

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

    HashMap<String, String> attachImgMap = HashMap();
    for (var aid in insertedAidList) {
      String key = "attachnew[${aid}][description]";
      attachImgMap[key] = "${aid}";
    }

    client
        .sendReplyResult(
            fid,
            tid,
            formhash,
            replyPost == null ? null : replyPost.pid,
            replyPost == null ? null : replyPost.pid,
            notifyAuthorMessage,
            message,
            captchaHash,
            captchaMod,
            verification,
            attachImgMap)
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

      setState(() {
        _sendReplyStatus = ButtonState.fail;
      });
      if (onError is DioException) {
        DioException dioError = onError;
        EasyLoading.showError("${dioError.type.name}");
      } else {
        EasyLoading.showError('${onError}');
      }
    });
  }

  late Dio dio;
  late MobileApiClient client;
  bool dioLoaded = false;
  Future<void> _loadClient() async {
    User? user =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    client = MobileApiClient(dio, baseUrl: discuz.baseURL);

    setState(() {
      dioLoaded = true;
    });
  }

  void favoriteThread() async {
    FavoriteThreadDao favoriteThreadDao =
        await AppDatabase.getFavoriteThreadDao();
    favoriteThreadDao.insertFavoriteThread(FavoriteThreadInDatabase(
        1,
        _viewThreadResult.threadVariables.member_uid,
        tid,
        "tid",
        _viewThreadResult.threadVariables.threadInfo.authorId,
        _viewThreadResult.threadVariables.threadInfo.subject,
        "",
        _viewThreadResult.threadVariables.threadInfo.author,
        _viewThreadResult.threadVariables.threadInfo.replies,
        DateTime.now(),
        discuz));
    client
        .favoriteThreadActionResult(
            _viewThreadResult.threadVariables.formHash, tid)
        .then((value) {
      if (value.errorResult != null && value.errorResult!.key == "do_success") {
        EasyLoading.showSuccess(S.of(context).discuzOperationMessage(
            value.errorResult!.key, value.errorResult!.content));
      } else {
        EasyLoading.showToast(S.of(context).discuzOperationMessage(
            value.errorResult!.key, value.errorResult!.content));
      }
    });
  }

  void unfavoriteThread() async {
    FavoriteThreadDao favoriteThreadDao =
        await AppDatabase.getFavoriteThreadDao();
    FavoriteThreadInDatabase? favoriteThreadInDatabase =
        favoriteThreadDao.getFavoriteThreadByTid(tid, discuz);
    if (favoriteThreadInDatabase != null) {
      favoriteThreadDao.removeFavoriteThread(favoriteThreadInDatabase);
      client
          .unfavoriteThreadActionResult(
              _viewThreadResult.threadVariables.formHash,
              favoriteThreadInDatabase.favid)
          .then((value) {
        if (value.errorResult != null &&
            value.errorResult!.key == "do_success") {
          EasyLoading.showSuccess(S.of(context).discuzOperationMessage(
              value.errorResult!.key, value.errorResult!.content));
        } else {
          EasyLoading.showToast(S.of(context).discuzOperationMessage(
              value.errorResult!.key, value.errorResult!.content));
        }
      });
    }
  }

  FavoriteThreadDao? favoriteThreadDao;
  ViewThreadCacheDao? viewThreadCacheDao;
  ViewThreadScrollDistanceDao? viewThreadScrollDistanceDao;

  Future<void> checkWithCacheResponse() async{

  }

  Future<IndicatorResult> _loadForumContent() async {
    // check the availability
    log("Base url ${discuz.baseURL} ${_page}");
    User? user =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    final client = MobileApiClient(dio, baseUrl: discuz.baseURL);

    if (_postList.length >=
        _viewThreadResult.threadVariables.threadInfo.replies + 1) {
      _controller.finishLoad(IndicatorResult.noMore);
      _controller.finishRefresh(IndicatorResult.success);
      _page -= 1;
      return IndicatorResult.noMore;
    }

    return await client
        .viewThreadResult(tid, _page, viewThreadQuery.generateForumQueriesMap())
        .then((value) {
      if (!historySaved &&
          _page == 1 &&
          value.threadVariables.postList.length > 0) {
        _saveViewHistory(value.threadVariables.threadInfo,
            value.threadVariables.postList.first.message);
      }


      Provider.of<DiscuzNotificationProvider>(context, listen: false)
          .setNotificationCount(value.threadVariables.noticeCount);


      setState(() {
        _viewThreadResult = value;
        _isFirstLoading = false;
        _error = null;
        if (_page == 1) {
          _postList = value.threadVariables.postList;
        }
        else if(_page == _initialPage){
          // is a cached page?
          List<Post> preCachedPostList = _postList.sublist(0, preCachedItemNum);
          preCachedPostList.addAll(value.threadVariables.postList);
          _postList = preCachedPostList;
        }
        else {
          _postList.addAll(value.threadVariables.postList);
          _postList = _postList;
        }
        postCommentList.addAll(value.threadVariables.commentList);
      });
      _page += 1;
      _controller.finishRefresh();

      // check for loaded all?
      log("Get list ${value.threadVariables.threadInfo.allreplies} ${_postList.length} ${value.threadVariables.threadInfo.replies}");
      _controller.finishLoad(
          _postList.length >= value.threadVariables.threadInfo.replies + 1
              ? IndicatorResult.noMore
              : IndicatorResult.success);
      _controller.finishRefresh(IndicatorResult.success);

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
      // cache the result
      if(value.getErrorString() == null && value.errorResult == null){
        // cache the response if this is correct
        _saveViewThreadCache(value, tid, _page, viewThreadQuery.timeAscend);
      }

      if (user != null && value.threadVariables.member_uid != user.uid) {
        log("recv user uid different! ${user.uid} ${value.threadVariables.member_uid} ${value.threadVariables.member_username}");
        setState(() {
          _error = DiscuzError(S.of(context).userExpiredTitle(user.username),
              S.of(context).userExpiredSubtitle,
              errorType: ErrorType.userExpired);
        });
      }

      log("set successful result ${_viewThreadResult.threadVariables.threadInfo.replies} ${_postList.length}");

      // save rewrite rule
      RewriteRule rewriteRule = value.threadVariables.rewriteRule;
      if (rewriteRule.forumDisplay.isNotEmpty) {
        RewriteRuleUtils.putForumDisplayRule(discuz, rewriteRule.forumDisplay);
      }

      if (rewriteRule.viewThread.isNotEmpty) {
        RewriteRuleUtils.putViewThreadRule(discuz, rewriteRule.viewThread);
      }

      if (rewriteRule.userSpace.isNotEmpty) {
        RewriteRuleUtils.putUserProfileRule(discuz, rewriteRule.userSpace);
      }

      if (_postList.length >= value.threadVariables.threadInfo.replies + 1) {
        log("No more posts ${_postList.length} ${value.threadVariables.threadInfo.replies}");
        return IndicatorResult.noMore;
      } else {
        return IndicatorResult.success;
      }
    }).catchError((onError, stack) {
      VibrationUtils.vibrateErrorIfPossible();

      log("${onError} ${stack}");
      _controller.finishRefresh(IndicatorResult.fail);
      _controller.finishLoad(IndicatorResult.fail);
      if (onError is DioException) {
        DioException dioError = onError;
        log("DIOERROR ${dioError.message} >-> ${dioError.type} ${dioError.error}");
        // EasyLoading.showError("${dioError.message} (${dioError})");
        setState(() {
          _isFirstLoading = false;
          _error = DiscuzError(
              dioError.type.name,
              dioError.response?.statusMessage == null
                  ? S.of(context).error
                  : dioError.response!.statusMessage!,
              dioError: dioError);
        });
      } else {
        log("${onError} >-> ${onError.runtimeType}");
        setState(() {
          _error =
              DiscuzError(onError.runtimeType.toString(), onError.toString());
        });
        EasyLoading.showError('${onError}');
      }

      return IndicatorResult.fail;
    });
  }

  void scrollToPid(int pid) {
    for (var post in _postList) {
      if (post.pid == pid) {}
    }
  }

  AutoScrollController _postAutoScrollController = AutoScrollController();

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        automaticallyImplyLeading: this.onClosed == null ? true : false,
        cupertino: (_, __) => CupertinoNavigationBarData(
            heroTag: this.onClosed == null ? null : "viewthread_${tid}",
            transitionBetweenRoutes: false),
        leading: this.onClosed == null
            ? null
            : PlatformIconButton(
                icon: Icon(Icons.arrow_back),
                cupertinoIcon: Icon(CupertinoIcons.back),
                onPressed: onClosed,
                cupertino: (_, __) => CupertinoIconButtonData(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.all(0)),
              ),
        //middle: Text(S.of(context).forumDisplayTitle),
        // title: Text(S.of(context).viewThreadTitle),
        title: _viewThreadResult.threadVariables.threadInfo.subject.isEmpty
            ? Text(S.of(context).viewThreadTitle,
                overflow: TextOverflow.ellipsis)
            : Text(_viewThreadResult.threadVariables.threadInfo.subject,
                overflow: TextOverflow.ellipsis),
        trailingActions: [
          DiscuzNotificationAppbarIconWidget(),
          if (favoriteThreadDao != null)
            IconButton(
                onPressed: () async {
                  VibrationUtils.vibrateWithClickIfPossible();
                  FavoriteThreadInDatabase? favoriteThreadInDatabase =
                      favoriteThreadDao!.getFavoriteThreadByTid(tid, discuz);
                  if(Provider.of<DiscuzAndUserNotifier>(context, listen: false).user != null){
                    if (favoriteThreadInDatabase == null) {
                      favoriteThread();
                    } else {
                      unfavoriteThread();
                    }
                  }
                  else{
                    // only save in the local storage
                  }

                },
                tooltip: S.of(context).favoriteThreadTooltip,
                icon: ValueListenableBuilder(
                  valueListenable:
                      favoriteThreadDao!.favoriteThreadBox.listenable(),
                  builder: (BuildContext context, value, Widget? child) {
                    FavoriteThreadInDatabase? favList =
                        favoriteThreadDao!.getFavoriteThreadByTid(tid, discuz);
                    if (favList == null) {
                      return Icon(
                        PlatformIcons(context).favoriteOutline,
                        size: 24,
                      );
                    } else {
                      return Icon(
                        PlatformIcons(context).favoriteSolid,
                        size: 24,
                        color: Theme.of(context).colorScheme.primary,
                      );
                    }
                  },
                )),
          IconButton(
            tooltip: viewThreadQuery.timeAscend
                ? S.of(context).sortThreadInAscendOrder
                : S.of(context).sortThreadInDescendOrder,
            icon: Icon(
              viewThreadQuery.timeAscend
                  ? PlatformIcons(context).upArrow
                  : PlatformIcons(context).downArrow,
              size: 24,
            ),
            onPressed: () {
              VibrationUtils.vibrateWithClickIfPossible();
              viewThreadQuery.timeAscend = !viewThreadQuery.timeAscend;
              setNewViewThreadQuery(viewThreadQuery);
            },
          ),
          PlatformPopupMenu(
              icon: Icon(
                PlatformIcons(context).ellipsis,
                size: 24,
              ),
              options: [
                PopupMenuOption(
                    label: S.of(context).openViaInternalBrowser,
                    onTap: (option) {
                      VibrationUtils.vibrateWithClickIfPossible();
                      Navigator.push(
                          context,
                          platformPageRoute(
                              context: context,
                              builder: (context) => InternalWebviewBrowserPage(
                                  discuz,
                                  user,
                                  URLUtils.getViewThreadURL(discuz, tid))));
                    }),
                PopupMenuOption(
                    label: S.of(context).share,
                    onTap: (option) {
                      VibrationUtils.vibrateWithClickIfPossible();
                      Share.share(URLUtils.getViewThreadURL(discuz, tid),
                          subject: _viewThreadResult
                              .threadVariables.threadInfo.subject);
                    }),
                PopupMenuOption(
                    label: S.of(context).settings,
                    onTap: (option) async {
                      VibrationUtils.vibrateWithClickIfPossible();
                      await Navigator.push(
                          context,
                          platformPageRoute(
                              context: context, builder: (context) => SettingPage()));
                    }),
              ]),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: EasyRefresh(
              header: EasyRefreshUtils.i18nClassicHeader(context),
              footer: EasyRefreshUtils.i18nClassicFooter(context),
              refreshOnStart: true,
              controller: _controller,
              //scrollController: _scrollController,
              onRefresh: () async {
                return await _invalidateContent();
              },
              onLoad: () async {
                return await _loadForumContent();
              },
              // if first load then should display a loading screen
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverList(
                      delegate: SliverChildBuilderDelegate(
                    (context, _) {
                      return SafeArea(
                        child: Container(),
                        bottom: false,
                      );
                    },
                    childCount: 1,
                  )),
                  if(!_isFirstLoading)
                  SliverList(
                      delegate: SliverChildBuilderDelegate(
                    (context, _) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          _viewThreadResult.threadVariables.threadInfo.subject
                                      .isEmpty &&
                                  passedSubject != null
                              ? passedSubject!
                              : _viewThreadResult
                                  .threadVariables.threadInfo.subject,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
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
                        return ErrorCard(
                          _error!,
                          () {
                            _controller.callRefresh();
                          },
                          errorType: _error!.errorType,
                          webpageUrl: URLUtils.getViewThreadURL(discuz, tid),
                        );
                      },
                      childCount: 1,
                    )),

                  if (_postList.isEmpty && _error == null)
                    SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                      return _isFirstLoading? LoadingStateWidget(hintText: passedSubject,): EmptyListScreen(EmptyItemType.post);
                    }, childCount: 1)),
                  if (_viewThreadResult.threadVariables.poll != null)
                    SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                      return PollWidget(
                        _viewThreadResult.threadVariables.poll!,
                        _viewThreadResult.threadVariables.formHash,
                        tid,
                        _viewThreadResult.threadVariables.fid,
                      );
                    },
                            childCount:
                                _viewThreadResult.threadVariables.poll != null
                                    ? 1
                                    : 0)),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Column(
                          children: [
                            AutoScrollTag(
                              key: ValueKey(index),
                              controller: _postAutoScrollController,
                              index: index,
                              child: PostWidget(
                                discuz,
                                _postList[index],
                                _viewThreadResult
                                    .threadVariables.threadInfo.authorId,
                                _viewThreadResult.threadVariables.formHash,
                                tid: tid,
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
                                ignoreFontCustomization:
                                    ignoreFontCustomization,
                                jumpToPidCallback: (pid) {
                                  // need to find the pid and scroll to it
                                  log("jump to pid ${pid} and we are looking it");
                                  int cnt = 0;
                                  for (var post in _postList) {
                                    if (post.pid == pid) {
                                      log("!find it: ${pid} in ${cnt}");
                                      _postAutoScrollController
                                          .scrollToIndex(cnt);
                                      break;
                                    }
                                    cnt += 1;
                                  }
                                  // check whether it's the end of the scroll
                                },
                              ),
                            ),
                            if (index % 10 == 0 && index != 0)
                              AppBannerAdWidget()
                          ],
                        );
                      },
                      childCount: _postList.length,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // comment parts
          if (_viewThreadResult.threadVariables.threadInfo.closed)
            Container(
              color: Theme.of(context).colorScheme.error.withOpacity(0.1),
              child: Padding(
                padding: EdgeInsets.only(top: 6.0, bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      S.of(context).threadIsClosed,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.error),
                    )
                  ],
                ),
              ),
            ),
          if (!_viewThreadResult.threadVariables.threadInfo.closed &&
              _viewThreadResult.errorResult == null)
            Consumer<DiscuzAndUserNotifier>(
              builder: (context, discuzAndUser, child) {
                if (discuzAndUser.user != null) {
                  return Container(
                    //padding: EdgeInsets.all(4.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Consumer<ReplyPostNotifierProvider>(
                          builder: (context, replyPost, child) {
                            if (replyPost.post != null &&
                                _viewThreadResult.threadVariables.member_uid !=
                                    0) {
                              return Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 4.0),
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer
                                    .withOpacity(0.3),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    InkWell(
                                      child: Icon(
                                        PlatformIcons(context)
                                            .clearThickCircled,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      onTap: () {
                                        VibrationUtils
                                            .vibrateWithClickIfPossible();
                                        // removing it
                                        Provider.of<ReplyPostNotifierProvider>(
                                                context,
                                                listen: false)
                                            .setPost(null);
                                      },
                                    ),
                                    Expanded(
                                        child: Container(

                                            padding: EdgeInsets.only(
                                                left: 8.0, right: 8.0),
                                            child: Column(

                                              children: [
                                                Text(
                                                  replyPost.post!.author,
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                                                    fontSize: 16
                                                  ),
                                                  maxLines: 1,
                                                ),
                                                Text(
                                                  replyPost.post!.message
                                                      .replaceAll(
                                                          RegExp(r"<img*?>"),
                                                          S
                                                              .of(context)
                                                              .pictureTagInMessage)
                                                      .replaceAll(
                                                          RegExp(
                                                              r"<div.*?>.*?</div>"),
                                                          "")
                                                      .replaceAll(
                                                          RegExp(r"<.*?>"), ""),
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onPrimaryContainer.withOpacity(0.5)
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                )
                                              ],
                                              crossAxisAlignment: CrossAxisAlignment.start,

                                            ),
                                        )
                                    )
                                  ],
                                ),
                              );
                            } else {
                              return Container(height: 0);
                            }
                          },
                        ),

                        // input fields
                        if (_viewThreadResult.threadVariables.member_uid != 0)
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
                                        borderRadius:
                                            BorderRadius.all(Radius.circular(
                                          4.0,
                                        )),
                                      ),
                                      child: PostTextField(
                                        discuz,
                                        _replyController,
                                        focusNode: _focusNode,
                                      ),
                                    ),
                                  )),
                                  IconButton(
                                    icon: dialogStatus != SHOW_SMILEY_DIALOG
                                        ? Icon(
                                            Icons.emoji_emotions_outlined,
                                            semanticLabel: S
                                                .of(context)
                                                .emoijButtonTooltip,
                                          )
                                        : Icon(
                                            Icons.keyboard_outlined,
                                            semanticLabel: S
                                                .of(context)
                                                .closeKeyboardTooltip,
                                          ),
                                    onPressed: () {
                                      if (dialogStatus != SHOW_SMILEY_DIALOG) {
                                        FocusScope.of(context)
                                            .requestFocus(new FocusNode());
                                        setState(() {
                                          dialogStatus = SHOW_SMILEY_DIALOG;
                                        });
                                      } else {
                                        FocusScope.of(context)
                                            .requestFocus(_focusNode);
                                        setState(() {
                                          dialogStatus = SHOW_NONE_DIALOG;
                                        });
                                      }
                                    },
                                  ),
                                  ValueListenableBuilder(
                                      valueListenable: showExtraButton,
                                      builder: (context, value, _) {
                                        if (value == false) {
                                          return ProgressButton.icon(
                                              maxWidth: 60.0,
                                              iconedButtons: {
                                                ButtonState.idle: IconedButton(
                                                    //text: S.of(context).sendReply,
                                                    icon: Icon(
                                                      Icons.send,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onPrimaryContainer,
                                                      semanticLabel: S
                                                          .of(context)
                                                          .sendReply,
                                                    ),
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primaryContainer),
                                                ButtonState.loading:
                                                    IconedButton(
                                                        //text: S.of(context).progressButtonReplySending,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .secondary),
                                                ButtonState.fail: IconedButton(
                                                    //text: S.of(context).progressButtonReplyFailed,
                                                    icon: Icon(
                                                      Icons.cancel,
                                                      color: Colors.white,
                                                      semanticLabel: S
                                                          .of(context)
                                                          .progressButtonReplyFailed,
                                                    ),
                                                    color: Colors.red.shade300),
                                                ButtonState.success: IconedButton(
                                                    //text: S.of(context).progressButtonReplySuccess,
                                                    icon: Icon(
                                                      Icons.check_circle,
                                                      color: Colors.white,
                                                      semanticLabel: S
                                                          .of(context)
                                                          .progressButtonReplySuccess,
                                                    ),
                                                    color: Colors.green.shade400)
                                              },
                                              onPressed: () {
                                                VibrationUtils
                                                    .vibrateWithClickIfPossible();
                                                _sendReply(context);
                                              },
                                              state: _sendReplyStatus);
                                        } else {
                                          //return Container();
                                          return IconButton(
                                            icon: Icon(
                                              dialogStatus == SHOW_EXTRA_DIALOG
                                                  ? Icons.close
                                                  : Icons.add_circle_outline,
                                              semanticLabel: S
                                                  .of(context)
                                                  .extraFuncButtonTooltip,
                                            ),
                                            onPressed: () {
                                              if (dialogStatus !=
                                                  SHOW_EXTRA_DIALOG) {
                                                FocusScope.of(context)
                                                    .requestFocus(
                                                        new FocusNode());
                                                setState(() {
                                                  dialogStatus =
                                                      SHOW_EXTRA_DIALOG;
                                                });
                                              } else {
                                                FocusScope.of(context)
                                                    .requestFocus(_focusNode);
                                                setState(() {
                                                  dialogStatus =
                                                      SHOW_NONE_DIALOG;
                                                });
                                              }
                                            },
                                          );
                                        }
                                      })
                                ],
                              ),
                              if (dioLoaded)
                                CaptchaWidget(
                                  dio,
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
                                    ExtraFuncInThreadScreen(
                                      discuz,
                                      tid,
                                      _viewThreadResult.threadVariables.fid,
                                      onReplyWithImage: (aid, path) async {
                                        // fill with text first
                                        // refresh the layout
                                        // insertedAidList.clear();
                                        if (aid.isNotEmpty) {
                                          _replyController
                                              .text = _replyController
                                                  .text +
                                              "[attachimg]${aid}[/attachimg]";
                                          // add aid to list
                                          insertedAidList.add(aid);
                                          // add to historical attachment
                                          bool savedInDatabase =
                                              await UserPreferencesUtils
                                                  .getRecordHistoryEnabled();
                                          if (savedInDatabase) {
                                            // save it to database
                                            ImageAttachmentDao
                                                imageAttachmentDao =
                                                await AppDatabase
                                                    .getImageAttachmentDao();
                                            ImageAttachment? imageAttachment =
                                                imageAttachmentDao
                                                    .findImageAttachmentByDiscuzAndAid(
                                                        discuz, aid);
                                            if (imageAttachment != null) {
                                              imageAttachment.updateAt =
                                                  DateTime.now();
                                              imageAttachmentDao
                                                  .insertImageAttachmentWithKey(
                                                      imageAttachment.key,
                                                      imageAttachment);
                                            } else {
                                              imageAttachmentDao
                                                  .insertImageAttachment(
                                                      ImageAttachment(
                                                          aid, discuz, path));
                                            }
                                          }
                                        } else {}
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
