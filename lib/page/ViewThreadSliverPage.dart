import 'PostCommentDialog.dart';
import 'ActivityRegistrationPage.dart';
import 'ModerateThreadPage.dart';
import '../widget/BestAnswerButton.dart';
import '../widget/ForumInteractionWidgets.dart';
import 'package:discuz_flutter/utility/app_motion.dart';
import 'package:discuz_flutter/widget/message_composer_surface.dart';
import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/JsonResult/ViewThreadResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/dao/FavoriteThreadDao.dart';
import 'package:discuz_flutter/dao/ViewHistoryDao.dart';
import 'package:discuz_flutter/dao/ViewThreadCacheDao.dart';
import 'package:discuz_flutter/dao/ViewThreadScrollDistanceDao.dart';
import 'package:discuz_flutter/utility/ReadingPerformanceProbe.dart';
import 'package:discuz_flutter/utility/latest_value_writer.dart';
import 'package:discuz_flutter/utility/reading_position_restorer.dart';
import 'package:discuz_flutter/utility/reading_page_update.dart';
import 'package:discuz_flutter/utility/reply_submission_controller.dart';
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
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
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
import 'package:discuz_flutter/widget/ThreadReplyTargetBanner.dart';
import 'package:discuz_flutter/widget/thread_reply_composer.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:share_plus/share_plus.dart';

import '../provider/DiscuzNotificationProvider.dart';
import '../provider/UserPreferenceNotifierProvider.dart';
import '../utility/EasyRefreshUtils.dart';
import '../widget/AppBannerAdWidget.dart';
import '../widget/DiscuzNotificationAppbarIconWidget.dart';
import 'InternalWebviewBrowserPage.dart';
import 'SettingPage.dart';
import '../widget/SpecialThreadCard.dart';
import '../widget/PostPermissionGate.dart';
import '../utility/post_locator.dart';

class ViewThreadSliverPage extends StatelessWidget {
  Discuz discuz;
  User? user;
  int tid;
  String? passedSubject;
  VoidCallback? onClosed;
  final int? initialPid;

  ViewThreadSliverPage(
    this.discuz,
    this.user,
    this.tid, {
    this.passedSubject,
    this.onClosed,
    this.initialPid,
  });

  @override
  Widget build(BuildContext context) {
    return ViewThreadStatefulSliverWidget(
      discuz,
      user,
      tid,
      passedSubject: passedSubject,
      onClosed: onClosed,
      initialPid: initialPid,
    );
  }
}

class ViewThreadStatefulSliverWidget extends StatefulWidget {
  late final Discuz discuz;
  late final User? user;
  int tid = 0;
  String? passedSubject;
  VoidCallback? onClosed;
  final int? initialPid;

  ViewThreadStatefulSliverWidget(
    this.discuz,
    this.user,
    this.tid, {
    this.passedSubject,
    this.onClosed,
    this.initialPid,
  });

  @override
  _ViewThreadSliverState createState() {
    return _ViewThreadSliverState(
      this.discuz,
      this.user,
      this.tid,
      passedSubject: passedSubject,
      onClosed: onClosed,
    );
  }
}

class _ViewThreadSliverState extends State<ViewThreadStatefulSliverWidget>
    with WidgetsBindingObserver {
  ViewThreadResult _viewThreadResult = ViewThreadResult();
  bool _isFirstLoading = true;
  DiscuzError? _error;
  List<Post> _postList = [];
  int _page = 1;
  String? passedSubject;
  final TextEditingController _replyController = new TextEditingController();
  final CaptchaController _captchaController = new CaptchaController(
    new CaptchaFields("", "post", ""),
  );

  late final Discuz discuz;
  late final User? user;

  int tid;

  bool historySaved = false;
  VoidCallback? onClosed;
  _ViewThreadSliverState(
    this.discuz,
    this.user,
    this.tid, {
    this.passedSubject,
    this.onClosed,
  });

  EasyRefreshController _controller = EasyRefreshController(
    controlFinishLoad: true,
    controlFinishRefresh: true,
  );
  late final _positionWriter = LatestValueWriter<ViewThreadScrollDistance>(
    write: (value) => ReadingPerformanceProbe.measure(
      'readingPosition.submit',
      () => viewThreadScrollDistanceDao!.insertViewThreadScrollDistance(value),
    ),
    onError: (error, stack) =>
        log('Could not save reading position', error: error, stackTrace: stack),
  );
  late final ScrollController _scrollController = ScrollController(
    onAttach: (position) =>
        position.isScrollingNotifier.addListener(_savePositionWhenIdle),
    onDetach: (position) =>
        position.isScrollingNotifier.removeListener(_savePositionWhenIdle),
  );
  final _subjectSliverKey = GlobalKey();
  final _showNavigationTitle = ValueNotifier<bool>(false);
  bool _navigationTitleUpdatePending = false;

  void _updateNavigationTitle() {
    if (_navigationTitleUpdatePending) return;
    _navigationTitleUpdatePending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigationTitleUpdatePending = false;
      if (!mounted) return;
      final sliver = _subjectSliverKey.currentContext?.findRenderObject();
      _showNavigationTitle.value =
          sliver is RenderSliver &&
          sliver.geometry != null &&
          sliver.geometry!.scrollExtent > 0 &&
          sliver.constraints.scrollOffset >= sliver.geometry!.scrollExtent;
    });
  }

  final _readingRestorer = ReadingPositionRestorer();
  Completer<void>? _initialReadingLoad;
  int _contentGeneration = 0;
  bool _initialPidHandled = false;
  bool _locatingPost = false;
  int _locateGeneration = 0;
  bool _focusedPage = false;
  int? _focusedPpp;
  int? _highlightPid;

  bool get _hasLazyFirstPost =>
      isCupertino(context) &&
      _postList.isNotEmpty &&
      _postList.first.first &&
      _postList.first.message.length >= 4000;
  late final ReplySubmissionController _replySubmission;
  SendReplyStatus get _sendReplyStatus => _replySubmission.status;
  ViewThreadQuery viewThreadQuery = ViewThreadQuery();
  Map<String, List<Comment>> postCommentList = {};
  final FocusNode _focusNode = FocusNode(debugLabel: "view_thread_textfield");

  // smiley=1, extra=2 or none = 0
  int dialogStatus = 0;
  List<String> insertedAidList = [];

  ValueNotifier<bool> showExtraButton = ValueNotifier(true);

  final int SHOW_SMILEY_DIALOG = 1;
  final int SHOW_NONE_DIALOG = 0;
  final GlobalKey<ExtraFuncInThreadState> _extraFunctionsKey =
      GlobalKey<ExtraFuncInThreadState>();
  // cache status
  bool cached = false;
  int _initialPage = 1;
  int preCachedItemNum = 0;
  DateTime lastFocusAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    _replySubmission = ReplySubmissionController(
      _replyController,
      insertedAidList,
    )..addListener(_onReplySubmissionChanged);
    _postAutoScrollController.parentController = _scrollController;
    _postAutoScrollController.addListener(_updateNavigationTitle);
    WidgetsBinding.instance.addObserver(this);
    _loadClient();

    _loadPreference();
    //_invalidateContent();
    bindFocusNode();
    _loadDao();
    // set reply post as null
    Provider.of<ReplyPostNotifierProvider>(
      context,
      listen: false,
    ).setPost(null);
  }

  void _onReplySubmissionChanged() {
    if (mounted) setState(() {});
  }

  void _loadDao() async {
    FavoriteThreadDao dao = await AppDatabase.getFavoriteThreadDao();
    if (!mounted) return;
    // should check with record first
    setState(() {
      favoriteThreadDao = dao;
    });
  }

  void bindFocusNode() {
    _focusNode.addListener(() {
      //debugDumpFocusTree();
      if (_focusNode.hasFocus) {
        setState(() {
          dialogStatus = SHOW_NONE_DIALOG;
        });
      } else {
        lastFocusAt = DateTime.now();
      }
    });

    _scrollController.addListener(() {
      // remove focus when

      if (_focusNode.hasFocus) {
        DateTime now = DateTime.now();
        if (now.difference(lastFocusAt).inSeconds > 1) {
          print(
            "Unfocus node due to scroll ${now.difference(lastFocusAt).inSeconds}",
          );
          _focusNode.unfocus();
        }
      }
      if (dialogStatus != SHOW_NONE_DIALOG) {
        setState(() {
          dialogStatus = SHOW_NONE_DIALOG;
        });
      }
    });

    _scrollController.addListener(() {
      // save with distance
      double offset = _scrollController.offset;
      if (!_focusedPage &&
          !_locatingPost &&
          viewThreadScrollDistanceDao != null &&
          !_readingRestorer.pending) {
        ViewThreadScrollDistance element = ViewThreadScrollDistance(
          tid,
          offset,
          discuz,
          DateTime.now(),
          viewThreadQuery.timeAscend,
        );
        _positionWriter.schedule(element);
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
    WidgetsBinding.instance.removeObserver(this);
    _readingRestorer.cancel();
    unawaited(_positionWriter.close());
    _scrollController.dispose();
    _postAutoScrollController.dispose();
    _showNavigationTitle.dispose();
    _focusNode.dispose();
    _replySubmission.dispose();
    _replyController.dispose();
    super.dispose();
  }

  void _savePositionWhenIdle() {
    if (_readingRestorer.pending) return;
    if (!_scrollController.positions.any((p) => p.isScrollingNotifier.value)) {
      unawaited(_positionWriter.flush());
    }
  }

  Future<void> _restoreReadingPositionWhenReady() async {
    if (!_readingRestorer.pending) return;
    await _readingRestorer.restoreWhenReady(
      _scrollController,
      contentSettled: _initialReadingLoad?.future,
    );
    if (!mounted || _readingRestorer.pending || !_scrollController.hasClients) {
      return;
    }
    if (viewThreadScrollDistanceDao != null) {
      _positionWriter.schedule(
        ViewThreadScrollDistance(
          tid,
          _scrollController.offset,
          discuz,
          DateTime.now(),
          viewThreadQuery.timeAscend,
        ),
      );
      _savePositionWhenIdle();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      unawaited(_positionWriter.flush());
    }
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
      DateTime.now(),
    );
    int primaryKey = await viewHistoryDao.insertViewHistory(insertViewHistory);
    print("save history with primary key ${primaryKey}");
    historySaved = true;
  }

  Future<IndicatorResult> _invalidateContent() async {
    _contentGeneration++;
    _locateGeneration++;
    _locatingPost = false;
    _readingRestorer.cancel();
    // Complete pending old-position writes before refresh can clear the cache.
    await _positionWriter.flush();
    if (!mounted) return IndicatorResult.fail;
    _initialPage = 1;
    if (!_initialPidHandled && widget.initialPid != null) {
      _initialPidHandled = true;
      final found = await scrollToPid(widget.initialPid!);
      if (found) return IndicatorResult.success;
      if (!mounted) return IndicatorResult.fail;
    }
    if (_focusedPage) {
      _postList = [];
      postCommentList = {};
      preCachedItemNum = 0;
    }
    _focusedPage = false;
    _focusedPpp = null;

    if (viewThreadCacheDao == null || viewThreadScrollDistanceDao == null) {
      _initialReadingLoad = Completer<void>();
      // retrieve cache
      viewThreadCacheDao = await AppDatabase.getViewThreadCacheDao();
      viewThreadScrollDistanceDao =
          await AppDatabase.getViewThreadScrollDistanceDao();
      List<ViewThreadCache> viewThreadCacheList = viewThreadCacheDao!
          .findAllViewThreadCacheListByDiscuz(
            discuz,
            tid,
            viewThreadQuery.timeAscend,
          );
      if (viewThreadCacheList.isEmpty) {
        cached = false;
      } else {
        // point to the last cached page
        cached = true;
        _initialPage = viewThreadCacheList.last.page;

        List<Post> cachedPost = [];
        bool isCacheSuccessful = true;
        log("Change to initial page ${_initialPage}");

        for (var threadCache in viewThreadCacheList) {
          try {
            ViewThreadResult result = ViewThreadResult.fromJson(
              jsonDecode(threadCache.json),
            );
            cachedPost.addAll(result.threadVariables.postList);
            if (threadCache != viewThreadCacheList.last) {
              preCachedItemNum += result.threadVariables.postList.length;
            }
          } catch (e) {
            log("Not Successful decode!!! ${threadCache.json}");
            isCacheSuccessful = false;
            break;
          }
        }

        if (isCacheSuccessful) {
          // cache integrity successful
          ViewThreadResult lastResult = ViewThreadResult.fromJson(
            jsonDecode(viewThreadCacheList.last.json),
          );
          setState(() {
            _viewThreadResult = lastResult;
            _postList = cachedPost;
            // should not present first loading page
            _isFirstLoading = false;
          });

          double? offset = viewThreadScrollDistanceDao!
              .findViewThreadCacheListByDiscuz(
                discuz,
                tid,
                viewThreadQuery.timeAscend,
              )
              ?.offset;
          log("GET cache information ${cachedPost.length} OFFSET ${offset}");
          if (offset != null) {
            // Box-mode/multi-image posts also parse and lay out asynchronously.
            // Starting before the body exists clamps the old offset too early.
            _readingRestorer.schedule(offset);
          }
          // Toast here
          ToastUtils.showSuccessfulToast(
            S.of(context).animateToLastReadingPosition,
          );
        }
      }
    } else {
      // should delete all cache now!!!
      _initialPage = 1;
      // clear cache
      viewThreadCacheDao!.deleteAllViewThreadCacheByTid(discuz, tid);
      viewThreadScrollDistanceDao!.deleteAllViewThreadScrollDistanceByTid(
        discuz,
        tid,
      );
    }

    setState(() {
      _page = _initialPage;
    });
    try {
      return await _loadForumContent();
    } finally {
      final initialLoad = _initialReadingLoad;
      if (initialLoad != null && !initialLoad.isCompleted) {
        // Let EasyRefresh process the returned result before the last offset
        // correction. A manual drag/disposal still cancels the restoration.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!initialLoad.isCompleted) initialLoad.complete();
        });
        WidgetsBinding.instance.scheduleFrame();
      }
    }
  }

  void setNewViewThreadQuery(ViewThreadQuery viewThreadQuery) {
    _contentGeneration++;
    _locateGeneration++;
    _locatingPost = false;
    _readingRestorer.cancel();
    setState(() {
      _focusedPage = false;
      _focusedPpp = null;
      _initialPage = 1;
      preCachedItemNum = 0;
      this.viewThreadQuery = viewThreadQuery;
      _page = 1;
      _postList = [];
    });
    _loadForumContent();
  }

  void _saveViewThreadCache(
    ViewThreadResult result,
    int tid,
    int page,
    bool isAscend,
  ) async {
    // check if needed
    String json = jsonEncode(result);
    ViewThreadCache viewThreadCache = ViewThreadCache(
      tid,
      json,
      discuz,
      DateTime.now(),
      page,
      isAscend,
    );
    viewThreadCacheDao?.insertViewThreadCache(viewThreadCache);
  }

  Widget _withReplyPermission(User user, Widget child) => PostPermissionGate(
    key: ValueKey(
      '${discuz.baseURL}:$tid:${_viewThreadResult.threadVariables.fid}:${user.uid}',
    ),
    reply: true,
    load: () async => MobileApiClient(
      await NetworkUtils.getDioWithPersistCookieJar(user),
      baseUrl: discuz.baseURL,
    ).checkPost(_viewThreadResult.threadVariables.fid, tid),
    child: child,
  );

  Future<void> _sendReply() async {
    final user = Provider.of<DiscuzAndUserNotifier>(
      context,
      listen: false,
    ).user;
    if (user == null) return;
    // Capture all mutable request fields before the first async operation.
    final strings = S.of(context);
    final formhash = _viewThreadResult.threadVariables.formHash;
    final fid = _viewThreadResult.threadVariables.fid;
    final threadId = tid;
    final replyPost = Provider.of<ReplyPostNotifierProvider>(
      context,
      listen: false,
    ).post;
    final replyPid = replyPost?.pid;
    final captchaFields = _captchaController.value;
    final captchaHash = captchaFields?.captchaFormHash ?? '';
    final verification = captchaFields?.verification ?? '';
    final captchaMod = captchaHash.isEmpty ? '' : 'forum::viewthread';
    String? notifyAuthorMessage;
    if (replyPost != null) {
      final fullTimeString = DateFormat.yMEd().add_jms().format(
        replyPost.publishAt,
      );
      var trimMessage = replyPost.message.replaceAll(RegExp(r"<.*?>"), "");
      if (trimMessage.length > 200) {
        trimMessage = '${trimMessage.substring(0, 100)}...';
      }
      notifyAuthorMessage = strings.replyPostTrimMessage(
        replyPost.pid,
        replyPost.tid,
        replyPost.author,
        fullTimeString,
        trimMessage,
      );
    }

    try {
      final value = await _replySubmission.submit(
        request: (draft) async {
          final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
          if (!mounted) return null;
          final permission = await MobileApiClient(
            dio,
            baseUrl: discuz.baseURL,
          ).checkPost(fid, threadId);
          if (!mounted) return null;
          if (permission.getErrorString() != null ||
              permission.variables.allowPerm.allowReply != true) {
            throw StateError(
              permission.getErrorString() ??
                  (permission.variables.allowPerm.allowReply == false
                      ? strings.replyPermissionDenied
                      : strings.postPermissionUnknown),
            );
          }
          var message = PostTextFieldUtils.getPostMessage(draft.text);
          final signature = await UserPreferencesUtils.getSignaturePreference();
          if (!mounted) return null;
          if (signature == PostTextFieldUtils.USE_DEVICE_SIGNATURE ||
              signature == PostTextFieldUtils.USE_APP_SIGNATURE) {
            final deviceName = await PostTextFieldUtils.getDeviceName(context);
            if (!mounted) return null;
            if (deviceName.isNotEmpty) {
              if (signature == PostTextFieldUtils.USE_APP_SIGNATURE) {
                final packageInfo = await PackageInfo.fromPlatform();
                if (!mounted) return null;
                message +=
                    "\n\n${strings.fromAppSignature(deviceName, packageInfo.version)}";
              } else {
                message += "\n\n${strings.fromDeviceSignature(deviceName)}";
              }
            }
          } else if (signature.isNotEmpty) {
            message += "\n\n$signature";
          }
          final attachImgMap = HashMap<String, String>.from({
            for (final aid in draft.attachmentIds)
              'attachnew[$aid][description]': aid,
          });
          return MobileApiClient(dio, baseUrl: discuz.baseURL).sendReplyResult(
            fid,
            threadId,
            formhash,
            replyPid,
            replyPid,
            notifyAuthorMessage,
            message,
            captchaHash,
            captchaMod,
            verification,
            attachImgMap,
          );
        },
        succeeded: (value) => value?.errorResult?.key == 'post_reply_succeed',
      );
      if (!mounted || value == null) return;
      final result = value.errorResult;
      if (result?.key == 'post_reply_succeed') {
        EasyLoading.showSuccess('${result!.content}(${result.key})');
      } else {
        EasyLoading.showError(
          result == null
              ? strings.progressButtonReplyFailed
              : '${result.content}(${result.key})',
        );
      }
    } catch (error) {
      if (!mounted) return;
      VibrationUtils.vibrateErrorIfPossible();
      EasyLoading.showError(error is DioException ? error.type.name : '$error');
    }
  }

  late Dio dio;
  late MobileApiClient client;
  bool dioLoaded = false;
  Future<void> _loadClient() async {
    User? user = Provider.of<DiscuzAndUserNotifier>(
      context,
      listen: false,
    ).user;
    dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    if (!mounted) return;
    client = MobileApiClient(dio, baseUrl: discuz.baseURL);

    setState(() {
      dioLoaded = true;
    });
  }

  Future<void> favoriteThread() async {
    final user = Provider.of<DiscuzAndUserNotifier>(
      context,
      listen: false,
    ).user;
    FavoriteThreadDao favoriteThreadDao =
        await AppDatabase.getFavoriteThreadDao();
    await favoriteThreadDao.insertFavoriteThread(
      FavoriteThreadInDatabase(
        user == null ? 0 : 1,
        user?.uid ?? _viewThreadResult.threadVariables.member_uid,
        tid,
        "tid",
        _viewThreadResult.threadVariables.threadInfo.authorId,
        _viewThreadResult.threadVariables.threadInfo.subject,
        "",
        _viewThreadResult.threadVariables.threadInfo.author,
        _viewThreadResult.threadVariables.threadInfo.replies,
        DateTime.now(),
        discuz,
      ),
    );
    if (mounted) setState(() {});
    if (user == null) {
      return;
    }
    client
        .favoriteThreadActionResult(
          _viewThreadResult.threadVariables.formHash,
          tid,
        )
        .then((value) {
          if (value.errorResult != null &&
              value.errorResult!.key == "do_success") {
            EasyLoading.showSuccess(
              S
                  .of(context)
                  .discuzOperationMessage(
                    value.errorResult!.key,
                    value.errorResult!.content,
                  ),
            );
          } else {
            EasyLoading.showToast(
              S
                  .of(context)
                  .discuzOperationMessage(
                    value.errorResult!.key,
                    value.errorResult!.content,
                  ),
            );
          }
        });
  }

  Future<void> unfavoriteThread() async {
    final user = Provider.of<DiscuzAndUserNotifier>(
      context,
      listen: false,
    ).user;
    FavoriteThreadDao favoriteThreadDao =
        await AppDatabase.getFavoriteThreadDao();
    FavoriteThreadInDatabase? favoriteThreadInDatabase = favoriteThreadDao
        .getFavoriteThreadByTid(tid, discuz);
    if (favoriteThreadInDatabase != null) {
      await favoriteThreadDao.removeFavoriteThread(favoriteThreadInDatabase);
      if (mounted) setState(() {});
      if (user == null) {
        return;
      }
      client
          .unfavoriteThreadActionResult(
            _viewThreadResult.threadVariables.formHash,
            favoriteThreadInDatabase.favid,
          )
          .then((value) {
            if (value.errorResult != null &&
                value.errorResult!.key == "do_success") {
              EasyLoading.showSuccess(
                S
                    .of(context)
                    .discuzOperationMessage(
                      value.errorResult!.key,
                      value.errorResult!.content,
                    ),
              );
            } else {
              EasyLoading.showToast(
                S
                    .of(context)
                    .discuzOperationMessage(
                      value.errorResult!.key,
                      value.errorResult!.content,
                    ),
              );
            }
          });
    }
  }

  FavoriteThreadDao? favoriteThreadDao;
  ViewThreadCacheDao? viewThreadCacheDao;
  ViewThreadScrollDistanceDao? viewThreadScrollDistanceDao;

  Future<void> checkWithCacheResponse() async {}

  Future<IndicatorResult> _loadForumContent() async {
    if (_locatingPost) return IndicatorResult.fail;
    final generation = _contentGeneration;
    final requestedPage = _page;
    final timeAscend = viewThreadQuery.timeAscend;
    final query = viewThreadQuery.generateForumQueriesMap();
    // check the availability
    log("Base url ${discuz.baseURL} ${_page}");
    User? user = Provider.of<DiscuzAndUserNotifier>(
      context,
      listen: false,
    ).user;
    final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    if (!mounted || generation != _contentGeneration)
      return IndicatorResult.fail;
    final client = MobileApiClient(dio, baseUrl: discuz.baseURL);

    if (_page > _initialPage &&
        (_focusedPage
            ? !hasMoreThreadPages(
                page: _page - 1,
                postsPerPage: _focusedPpp ?? 15,
                replies: _viewThreadResult.threadVariables.threadInfo.replies,
              )
            : _postList.length >=
                  _viewThreadResult.threadVariables.threadInfo.replies + 1)) {
      _controller.finishLoad(IndicatorResult.noMore);
      _controller.finishRefresh(IndicatorResult.success);
      return IndicatorResult.noMore;
    }

    return await client
        .viewThreadPage(tid, requestedPage, _focusedPpp ?? 15, query)
        .then((value) {
          if (!mounted || generation != _contentGeneration)
            return IndicatorResult.fail;
          final update = ReadingPageUpdate.fromResponse(
            value,
            currentPosts: _postList,
            requestedPage: requestedPage,
            initialPage: _initialPage,
            cachedPrefixCount: preCachedItemNum,
          );
          if (ReadingPerformanceProbe.enabled) {
            ReadingPerformanceProbe.record('reading.pageResponse', {
              'page': requestedPage,
              'accepted': update != null,
              'received_posts': value.threadVariables.postList.length,
              'current_posts': _postList.length,
            });
          }
          if (update == null) {
            final message = value.getErrorString() ?? S.of(context).error;
            setState(() {
              _isFirstLoading = false;
              // Later-page errors belong to the load footer and toast. Inserting an
              // error card above an existing article would move its reading position.
              if (_postList.isEmpty || requestedPage <= _initialPage) {
                _error = DiscuzError(
                  value.errorResult?.key ?? S.of(context).error,
                  value.errorResult?.content ?? message,
                );
              }
              if (user != null &&
                  value.threadVariables.member_uid != user.uid) {
                _error = DiscuzError(
                  S.of(context).userExpiredTitle(user.username),
                  S.of(context).userExpiredSubtitle,
                  errorType: ErrorType.userExpired,
                );
              }
            });
            _controller.finishRefresh(IndicatorResult.fail);
            _controller.finishLoad(IndicatorResult.fail);
            EasyLoading.showError(message);
            return IndicatorResult.fail;
          }
          if (!historySaved &&
              requestedPage == 1 &&
              value.threadVariables.postList.length > 0) {
            _saveViewHistory(
              value.threadVariables.threadInfo,
              value.threadVariables.postList.first.message,
            );
          }

          Provider.of<DiscuzNotificationProvider>(
            context,
            listen: false,
          ).setNotificationCount(value.threadVariables.noticeCount);

          Provider.of<DiscuzNotificationProvider>(
            context,
            listen: false,
          ).setBaseVariableResult(value.threadVariables);

          setState(() {
            _viewThreadResult = value;
            _isFirstLoading = false;
            _error = null;
            _postList = update.posts;
            postCommentList.addAll(value.threadVariables.commentList);
          });
          // cache the result before _page changes
          if (!_focusedPage && viewThreadQuery.authorId == 0)
            _saveViewThreadCache(value, tid, requestedPage, timeAscend);
          _page = update.nextPage;
          _controller.finishRefresh();

          // check for loaded all?
          //log("Get list ${value.threadVariables.threadInfo.allreplies} ${_postList.length} ${value.threadVariables.threadInfo.replies}");
          final noMore =
              value.threadVariables.postList.isEmpty ||
              (_focusedPage
                  ? !hasMoreThreadPages(
                      page: requestedPage,
                      postsPerPage: _focusedPpp ?? 15,
                      replies: value.threadVariables.threadInfo.replies,
                    )
                  : _postList.length >=
                        value.threadVariables.threadInfo.replies + 1);
          _controller.finishLoad(
            noMore ? IndicatorResult.noMore : IndicatorResult.success,
          );
          _controller.finishRefresh(IndicatorResult.success);

          if (user != null && value.threadVariables.member_uid != user.uid) {
            log(
              "recv user uid different! ${user.uid} ${value.threadVariables.member_uid} ${value.threadVariables.member_username}",
            );
            setState(() {
              _error = DiscuzError(
                S.of(context).userExpiredTitle(user.username),
                S.of(context).userExpiredSubtitle,
                errorType: ErrorType.userExpired,
              );
            });
          }

          log(
            "set successful result ${_viewThreadResult.threadVariables.threadInfo.replies} ${_postList.length}",
          );

          // save rewrite rule
          RewriteRule rewriteRule = value.threadVariables.rewriteRule;
          if (rewriteRule.forumDisplay.isNotEmpty) {
            RewriteRuleUtils.putForumDisplayRule(
              discuz,
              rewriteRule.forumDisplay,
            );
          }

          if (rewriteRule.viewThread.isNotEmpty) {
            RewriteRuleUtils.putViewThreadRule(discuz, rewriteRule.viewThread);
          }

          if (rewriteRule.userSpace.isNotEmpty) {
            RewriteRuleUtils.putUserProfileRule(discuz, rewriteRule.userSpace);
          }

          if (noMore) {
            log(
              "No more posts ${_postList.length} ${value.threadVariables.threadInfo.replies}",
            );
            return IndicatorResult.noMore;
          } else {
            return IndicatorResult.success;
          }
        })
        .catchError((onError, stack) {
          if (!mounted || generation != _contentGeneration)
            return IndicatorResult.fail;
          VibrationUtils.vibrateErrorIfPossible();

          log("${onError} ${stack}");
          _controller.finishRefresh(IndicatorResult.fail);
          _controller.finishLoad(IndicatorResult.fail);
          if (onError is DioException) {
            DioException dioError = onError;

            // EasyLoading.showError("${dioError.message} (${dioError})");
            setState(() {
              _isFirstLoading = false;
              DioException error = onError;

              _error = DiscuzError(
                dioError.type.name,
                dioError.response?.statusMessage == null
                    ? S.of(context).error
                    : dioError.response!.statusMessage!,
                dioError: dioError,
              );
            });
          } else {
            log("${onError} >-> ${onError.runtimeType}");
            setState(() {
              _error = DiscuzError(
                onError.runtimeType.toString(),
                onError.toString(),
              );
            });
            EasyLoading.showError('${onError}');
          }

          return IndicatorResult.fail;
        });
  }

  Future<bool> scrollToPid(int pid) async {
    if (pid <= 0 || _locatingPost) return false;
    final request = ++_locateGeneration;
    _readingRestorer.cancel();
    var index = _postList.indexWhere((post) => post.pid == pid);
    try {
      if (index < 0) {
        final generation = ++_contentGeneration;
        setState(() => _locatingPost = true);
        final currentUser = context.read<DiscuzAndUserNotifier>().user;
        final dio = await NetworkUtils.getDioWithPersistCookieJar(currentUser);
        final located = await PostLocator.locate(dio, discuz.baseURL, tid, pid);
        if (!mounted ||
            request != _locateGeneration ||
            generation != _contentGeneration)
          return false;
        setState(() {
          _focusedPage = true;
          _focusedPpp = int.tryParse(located.result.threadVariables.ppp);
          _initialPage = located.page;
          preCachedItemNum = 0;
          _page = located.page + 1;
          viewThreadQuery = ViewThreadQuery();
          _viewThreadResult = located.result;
          _postList = located.result.threadVariables.postList;
          postCommentList = Map.of(located.result.threadVariables.commentList);
          _isFirstLoading = false;
          _error = null;
        });
        index = _postList.indexWhere((post) => post.pid == pid);
        _controller.finishRefresh(IndicatorResult.success);
        _controller.finishLoad(IndicatorResult.success);
      }
      if (!mounted || request != _locateGeneration) return false;
      setState(() => _highlightPid = pid);
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted ||
          !_postAutoScrollController.hasClients ||
          request != _locateGeneration)
        return false;
      await _postAutoScrollController.scrollToIndex(
        index,
        preferPosition: AutoScrollPosition.begin,
      );
      if (!mounted) return false;
      await _postAutoScrollController.highlight(index);
      return true;
    } catch (_) {
      if (mounted) EasyLoading.showError(S.of(context).postLocateFailed);
      return false;
    } finally {
      if (mounted && request == _locateGeneration)
        setState(() => _locatingPost = false);
    }
  }

  AutoScrollController _postAutoScrollController = AutoScrollController();

  Widget _buildReadingPost(int index, {bool asSliver = false}) {
    final post = _postList[index];
    final variables = _viewThreadResult.threadVariables;
    final user = context.watch<DiscuzAndUserNotifier>().user;
    final canComment =
        !_isFirstLoading &&
        _error?.errorType != ErrorType.userExpired &&
        user != null &&
        user.uid > 0 &&
        variables.member_uid == user.uid &&
        variables.commentsEnabled;
    final content = PostWidget(
      discuz,
      post,
      _viewThreadResult.threadVariables.threadInfo.authorId,
      _viewThreadResult.threadVariables.formHash,
      key: ValueKey('reading-post-${post.pid}'),
      reward: post.first ? _viewThreadResult.threadVariables.reward : null,
      onAddComment: !canComment
          ? null
          : () async {
              final changed = await showPlatformDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (_) => PostCommentDialog(
                  discuz: discuz,
                  user: user!,
                  tid: tid,
                  pid: post.pid,
                ),
              );
              if (mounted && changed == true) _controller.callRefresh();
            },
      commentCount: int.tryParse(
        '${_viewThreadResult.threadVariables.commentCounts['${post.pid}'] ?? ''}',
      ),
      onContentChanged: () {
        _controller.callRefresh();
      },
      asSliver: asSliver,
      onBodyReady: index == 0 ? _restoreReadingPositionWhenReady : null,
      tid: tid,
      fid: _viewThreadResult.threadVariables.fid,
      onAuthorSelectedCallback: () {
        viewThreadQuery.authorId = viewThreadQuery.authorId == 0
            ? post.authorId
            : 0;
        setNewViewThreadQuery(viewThreadQuery);
      },
      postCommentList: postCommentList,
      ignoreFontCustomization: ignoreFontCustomization,
      jumpToPidCallback: (pid) {
        scrollToPid(pid);
      },
    );
    if (!post.first) {
      final action = BestAnswerButton(
        discuz: discuz,
        variables: _viewThreadResult.threadVariables,
        post: post,
        onChanged: () {
          _controller.callRefresh();
        },
      );
      return asSliver
          ? SliverMainAxisGroup(
              slivers: [
                content,
                SliverToBoxAdapter(child: action),
              ],
            )
          : Column(mainAxisSize: MainAxisSize.min, children: [content, action]);
    }
    final feedback = ThreadFeedbackBar(
      key: ValueKey('feedback-$tid'),
      sessionUid: _isFirstLoading || _error?.errorType == ErrorType.userExpired
          ? 0
          : _viewThreadResult.threadVariables.member_uid,
      discuz: discuz,
      tid: tid,
      formhash: _viewThreadResult.threadVariables.formHash,
      voted: _viewThreadResult.threadVariables.threadInfo.recommended,
      positiveCount:
          _viewThreadResult.threadVariables.threadInfo.recommendCount,
      negativeCount:
          _viewThreadResult.threadVariables.threadInfo.disrecommendCount,
      onChanged: () {
        _controller.callRefresh();
      },
    );
    return asSliver
        ? SliverMainAxisGroup(
            slivers: [
              content,
              SliverToBoxAdapter(child: feedback),
            ],
          )
        : Column(mainAxisSize: MainAxisSize.min, children: [content, feedback]);
  }

  Widget _buildReplyTargetBanner(BuildContext context) {
    return Consumer<ReplyPostNotifierProvider>(
      builder: (context, replyPost, child) {
        final post = replyPost.post;
        if (post == null || _viewThreadResult.threadVariables.member_uid == 0) {
          return const SizedBox.shrink();
        }
        return ThreadReplyTargetBanner(
          author: post.author,
          messageHtml: post.message,
          picturePlaceholder: S.of(context).pictureTagInMessage,
          embeddedInComposer: true,
          onDismiss: () {
            VibrationUtils.vibrateWithClickIfPossible();
            Provider.of<ReplyPostNotifierProvider>(
              context,
              listen: false,
            ).setPost(null);
          },
        );
      },
    );
  }

  void _toggleReplyPanel() {
    VibrationUtils.vibrateWithClickIfPossible();
    if (dialogStatus == SHOW_SMILEY_DIALOG) {
      FocusScope.of(context).requestFocus(_focusNode);
      setState(() => dialogStatus = SHOW_NONE_DIALOG);
    } else {
      FocusScope.of(context).unfocus();
      setState(() => dialogStatus = SHOW_SMILEY_DIALOG);
    }
  }

  @override
  Widget build(BuildContext context) {
    CustomizeColor.updateAndroidNavigationbar(context);
    ModalRoute<Object?>? route = ModalRoute.of(context);
    final loadedSubject = _viewThreadResult.threadVariables.threadInfo.subject;
    final threadSubject = HtmlUnescape().convert(
      loadedSubject.isNotEmpty
          ? loadedSubject
          : passedSubject ?? S.of(context).viewThreadTitle,
    );
    final favoriteThreadInDatabase = favoriteThreadDao?.getFavoriteThreadByTid(
      tid,
      discuz,
    );
    // A long main post must share the outer viewport to lay out only nearby
    // blocks. Replies and short/Material posts retain their existing box path.
    final lazyFirstPost = _hasLazyFirstPost;

    _updateNavigationTitle();
    final adaptiveAppBar = PlatformAppBar(
      automaticallyImplyLeading: this.onClosed == null ? true : false,
      cupertino: (_, __) => CupertinoNavigationBarData(
        heroTag: this.onClosed == null ? null : "viewthread_${tid}",
        transitionBetweenRoutes: false,
        previousPageTitle:
            (route != null &&
                route is CupertinoPageRoute<dynamic> &&
                route.previousTitle.value != null)
            ? route.previousTitle.value
            : Provider.of<DiscuzAndUserNotifier>(
                context,
                listen: false,
              ).discuz?.siteName,
      ),
      leading: this.onClosed == null
          ? null
          : PlatformBackButton(onPressed: onClosed),
      // Reveal the compact title only after the full title leaves the viewport.
      title: ValueListenableBuilder<bool>(
        valueListenable: _showNavigationTitle,
        builder: (context, visible, _) => visible
            ? Text(threadSubject, maxLines: 1, overflow: TextOverflow.ellipsis)
            : const SizedBox.shrink(),
      ),
      liquidGlassUseNativeToolbar: false,
      trailingActions: [
        if (hasDiscuzNotification(context))
          buildDiscuzNotificationAppbarIcon(context),
        if (favoriteThreadDao != null)
          PlatformIconButton(
            liquidGlassSymbol: favoriteThreadInDatabase == null
                ? 'heart'
                : 'heart.fill',
            onPressed: () async {
              VibrationUtils.vibrateWithClickIfPossible();
              if (favoriteThreadInDatabase == null) {
                await favoriteThread();
              } else {
                await unfavoriteThread();
              }
            },
            icon: Icon(
              favoriteThreadInDatabase == null
                  ? PlatformIcons(context).favoriteOutline
                  : PlatformIcons(context).favoriteSolid,
              size: 24,
              color: favoriteThreadInDatabase == null
                  ? null
                  : Theme.of(context).colorScheme.primary,
              semanticLabel: S.of(context).favoriteThreadTooltip,
            ),
          ),
        PlatformIconButton(
          liquidGlassSymbol: viewThreadQuery.timeAscend
              ? 'arrow.up'
              : 'arrow.down',
          icon: Icon(
            viewThreadQuery.timeAscend
                ? PlatformIcons(context).upArrow
                : PlatformIcons(context).downArrow,
            size: 20,
            semanticLabel: viewThreadQuery.timeAscend
                ? S.of(context).sortThreadInAscendOrder
                : S.of(context).sortThreadInDescendOrder,
          ),
          onPressed: () {
            VibrationUtils.vibrateWithClickIfPossible();
            viewThreadQuery.timeAscend = !viewThreadQuery.timeAscend;
            setNewViewThreadQuery(viewThreadQuery);
          },
        ),
        PlatformPopupMenu(
          icon: Icon(PlatformIcons(context).ellipsis, size: 24),
          options: [
            if (_viewThreadResult.threadVariables.isModerator > 0 &&
                context.read<DiscuzAndUserNotifier>().user != null)
              PopupMenuOption(
                label: S.of(context).moderateThread,
                onTap: (_) async {
                  final changed = await Navigator.push<bool>(
                    context,
                    platformPageRoute(
                      context: context,
                      builder: (_) => ModerateThreadPage(
                        discuz: discuz,
                        user: context.read<DiscuzAndUserNotifier>().user!,
                        tid: tid,
                      ),
                    ),
                  );
                  if (mounted && changed == true) _controller.callRefresh();
                },
              ),
            PopupMenuOption(
              label: S.of(context).openViaInternalBrowser,
              onTap: (option) {
                VibrationUtils.vibrateWithClickIfPossible();
                Navigator.push(
                  context,
                  platformPageRoute(
                    iosTitle: S.of(context).openViaInternalBrowser,
                    context: context,
                    builder: (context) => InternalWebviewBrowserPage(
                      discuz,
                      user,
                      URLUtils.getViewThreadURL(discuz, tid),
                    ),
                  ),
                );
              },
            ),
            PopupMenuOption(
              label: S.of(context).share,
              onTap: (option) {
                VibrationUtils.vibrateWithClickIfPossible();
                Share.share(
                  URLUtils.getViewThreadURL(discuz, tid),
                  subject: _viewThreadResult.threadVariables.threadInfo.subject,
                );
              },
            ),
            PopupMenuOption(
              label: S.of(context).settings,
              onTap: (option) async {
                VibrationUtils.vibrateWithClickIfPossible();
                await Navigator.push(
                  context,
                  platformPageRoute(
                    iosTitle: S.of(context).settings,
                    context: context,
                    builder: (context) => SettingPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );

    return PlatformScaffold(
      appBar: adaptiveAppBar,
      iosContentPadding: true,
      body: CupertinoComposerViewport(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: NotificationListener<ScrollStartNotification>(
                onNotification: (notification) {
                  if (notification.depth == 0 &&
                      notification.dragDetails != null) {
                    _readingRestorer.cancel();
                  }
                  return false;
                },
                child: EasyRefresh(
                  header: EasyRefreshUtils.i18nClassicHeader(
                    context,
                    position: IndicatorPosition.locator,
                    safeArea: false,
                  ),
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
                    controller: _postAutoScrollController,
                    slivers: [
                      const HeaderLocator.sliver(),
                      if (!_isFirstLoading &&
                          _viewThreadResult.errorResult == null)
                        SliverToBoxAdapter(
                          key: _subjectSliverKey,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                            child: Semantics(
                              header: true,
                              child: Text(
                                threadSubject,
                                softWrap: true,
                                overflow: TextOverflow.visible,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                      height: 1.3,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      if (_error != null)
                        SliverList(
                          delegate: SliverChildBuilderDelegate((context, _) {
                            return ErrorCard(
                              _error!,
                              () {
                                _controller.callRefresh();
                              },
                              errorType: _error!.errorType,
                              largeSize: _postList.isEmpty,
                              webpageUrl: URLUtils.getViewThreadURL(
                                discuz,
                                tid,
                              ),
                            );
                          }, childCount: 1),
                        ),
                      if (_postList.isEmpty && _error == null)
                        SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            return _isFirstLoading
                                ? LoadingStateWidget(hintText: passedSubject)
                                : EmptyListScreen(EmptyItemType.post);
                          }, childCount: 1),
                        ),
                      if (_viewThreadResult.threadVariables.poll != null)
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
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
                                : 0,
                          ),
                        ),
                      SliverToBoxAdapter(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            if (_viewThreadResult
                                .threadVariables
                                .threadPayRequired)
                              ForumActionButton(
                                discuz: discuz,
                                tid: tid,
                                purchase: true,
                                label: S.of(context).forumBuyThread,
                                onChanged: () {
                                  _controller.callRefresh();
                                },
                              ),
                          ],
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SpecialThreadCard(
                          onActivityRegistration:
                              context.read<DiscuzAndUserNotifier>().user == null
                              ? null
                              : () async {
                                  final changed = await Navigator.push<bool>(
                                    context,
                                    platformPageRoute(
                                      context: context,
                                      builder: (_) => ActivityRegistrationPage(
                                        discuz: discuz,
                                        user: context
                                            .read<DiscuzAndUserNotifier>()
                                            .user!,
                                        tid: tid,
                                      ),
                                    ),
                                  );
                                  if (mounted && changed == true)
                                    _controller.callRefresh();
                                },
                          activity: _viewThreadResult.threadVariables.activity,
                          threadSort:
                              _viewThreadResult.threadVariables.threadSort,
                          onSelectPost: (pid) {
                            scrollToPid(pid);
                          },
                          onOpenWebsite: () => Navigator.push(
                            context,
                            platformPageRoute(
                              context: context,
                              builder: (_) => InternalWebviewBrowserPage(
                                discuz,
                                context.read<DiscuzAndUserNotifier>().user,
                                URLUtils.getViewThreadURL(discuz, tid),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (_locatingPost)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(S.of(context).postLocating),
                          ),
                        ),
                      if (_focusedPage)
                        SliverToBoxAdapter(
                          child: PlatformTextButton(
                            onPressed: () => _controller.callRefresh(),
                            child: Text(S.of(context).postReturnThread),
                          ),
                        ),
                      if (lazyFirstPost) ...[
                        SliverToBoxAdapter(
                          child: AutoScrollTag(
                            key: const ValueKey('lazy-first-post-anchor'),
                            controller: _postAutoScrollController,
                            index: 0,
                            highlightColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            child: SizedBox(
                              height: _highlightPid == _postList.first.pid
                                  ? 4
                                  : 0,
                            ),
                          ),
                        ),
                        _buildReadingPost(0, asSliver: true),
                      ],
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, localIndex) {
                            final index = localIndex + (lazyFirstPost ? 1 : 0);
                            return Column(
                              children: [
                                AutoScrollTag(
                                  key: ValueKey(index),
                                  controller: _postAutoScrollController,
                                  index: index,
                                  highlightColor: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  child: _buildReadingPost(index),
                                ),
                                if (index % 10 == 0 && index != 0)
                                  Consumer<UserPreferenceNotifierProvider>(
                                    builder: (context, value, child) {
                                      if (value.signature ==
                                              PostTextFieldUtils
                                                  .USE_APP_SIGNATURE &&
                                          index > 15) {
                                        return Container();
                                      } else {
                                        return const AppBannerAdWidget();
                                      }
                                    },
                                  ),
                              ],
                            );
                          },
                          childCount:
                              _postList.length - (lazyFirstPost ? 1 : 0),
                        ),
                      ),
                    ],
                  ),
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
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (!_viewThreadResult.threadVariables.threadInfo.closed &&
                _viewThreadResult.errorResult == null)
              Consumer<DiscuzAndUserNotifier>(
                builder: (context, discuzAndUser, child) {
                  if (discuzAndUser.user != null) {
                    return _withReplyPermission(
                      discuzAndUser.user!,
                      Container(
                        //padding: EdgeInsets.all(4.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // input fields
                            if (_viewThreadResult.threadVariables.member_uid !=
                                0)
                              Column(
                                children: [
                                  if (visualStyle(context) ==
                                      AppVisualStyle.cupertino)
                                    CupertinoThreadReplyComposer(
                                      key: const ValueKey(
                                        'thread-reply-composer',
                                      ),
                                      discuz: discuz,
                                      controller: _replyController,
                                      focusNode: _focusNode,
                                      replyTarget: _buildReplyTargetBanner(
                                        context,
                                      ),
                                      panelVisible:
                                          dialogStatus == SHOW_SMILEY_DIALOG,
                                      sendStatus: _sendReplyStatus,
                                      onTogglePanel: _toggleReplyPanel,
                                      onSend: () {
                                        VibrationUtils.vibrateWithClickIfPossible();
                                        _sendReply();
                                      },
                                    )
                                  else
                                    SafeArea(
                                      top: false,
                                      child: MessageComposerSurface(
                                        key: const ValueKey(
                                          'thread-reply-composer',
                                        ),
                                        margin: EdgeInsets.fromLTRB(
                                          8,
                                          4,
                                          8,
                                          isCupertino(context) ? 2 : 8,
                                        ),
                                        padding: const EdgeInsets.all(6),
                                        borderRadius: BorderRadius.circular(24),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            _buildReplyTargetBanner(context),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                PlatformIconButton(
                                                  liquidGlassSymbol:
                                                      dialogStatus ==
                                                          SHOW_SMILEY_DIALOG
                                                      ? 'keyboard'
                                                      : 'plus',
                                                  liquidGlassButtonSize: 44,
                                                  liquidGlassIconSize: 17,
                                                  icon: AnimatedSwitcher(
                                                    duration:
                                                        AppMotion.duration(
                                                          context,
                                                          140,
                                                        ),
                                                    child: Icon(
                                                      dialogStatus ==
                                                              SHOW_SMILEY_DIALOG
                                                          ? PlatformIcons(
                                                              context,
                                                            ).keyboard
                                                          : PlatformIcons(
                                                              context,
                                                            ).add,
                                                      key: ValueKey(
                                                        dialogStatus ==
                                                            SHOW_SMILEY_DIALOG,
                                                      ),
                                                      size: 20,
                                                      semanticLabel:
                                                          dialogStatus ==
                                                              SHOW_SMILEY_DIALOG
                                                          ? S
                                                                .of(context)
                                                                .closeKeyboardTooltip
                                                          : S
                                                                .of(context)
                                                                .extraFuncButtonTooltip,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    VibrationUtils.vibrateWithClickIfPossible();
                                                    if (dialogStatus ==
                                                        SHOW_SMILEY_DIALOG) {
                                                      FocusScope.of(
                                                        context,
                                                      ).requestFocus(
                                                        _focusNode,
                                                      );
                                                      setState(
                                                        () => dialogStatus =
                                                            SHOW_NONE_DIALOG,
                                                      );
                                                    } else {
                                                      FocusScope.of(
                                                        context,
                                                      ).unfocus();
                                                      setState(
                                                        () => dialogStatus =
                                                            SHOW_SMILEY_DIALOG,
                                                      );
                                                    }
                                                  },
                                                ),
                                                const SizedBox(width: 3),
                                                Expanded(
                                                  child: PostTextField(
                                                    discuz,
                                                    _replyController,
                                                    focusNode: _focusNode,
                                                    embeddedInComposer: true,
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                ValueListenableBuilder<bool>(
                                                  valueListenable:
                                                      showExtraButton,
                                                  builder: (context, showExtra, _) {
                                                    final canSend = !showExtra;
                                                    if (_sendReplyStatus ==
                                                        SendReplyStatus
                                                            .loading) {
                                                      return const SizedBox.square(
                                                        dimension: 44,
                                                        child: Center(
                                                          child: SizedBox.square(
                                                            dimension: 18,
                                                            child:
                                                                PlatformCircularProgressIndicator(),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                    if (_sendReplyStatus ==
                                                        SendReplyStatus
                                                            .success) {
                                                      return PlatformIconButton(
                                                        liquidGlassSymbol:
                                                            'checkmark.circle.fill',
                                                        liquidGlassButtonSize:
                                                            44,
                                                        liquidGlassIconSize: 17,
                                                        icon: Icon(
                                                          AppPlatformIcons(
                                                            context,
                                                          ).checkCircleSolid,
                                                          size: 20,
                                                          color: Theme.of(
                                                            context,
                                                          ).colorScheme.primary,
                                                        ),
                                                        onPressed: null,
                                                      );
                                                    }
                                                    if (_sendReplyStatus ==
                                                        SendReplyStatus.fail) {
                                                      return PlatformIconButton(
                                                        liquidGlassSymbol:
                                                            'exclamationmark.triangle',
                                                        liquidGlassButtonSize:
                                                            44,
                                                        liquidGlassIconSize: 17,
                                                        icon: Icon(
                                                          AppPlatformIcons(
                                                            context,
                                                          ).errorOutline,
                                                          size: 20,
                                                          color: Theme.of(
                                                            context,
                                                          ).colorScheme.error,
                                                        ),
                                                        onPressed: null,
                                                      );
                                                    }
                                                    if (!isCupertino(context)) {
                                                      return MaterialMessageSendButton(
                                                        onPressed: canSend
                                                            ? () {
                                                                VibrationUtils.vibrateWithClickIfPossible();
                                                                _sendReply();
                                                              }
                                                            : null,
                                                      );
                                                    }
                                                    return PlatformIconButton(
                                                      liquidGlassSymbol:
                                                          'arrow.up',
                                                      liquidGlassButtonSize: 44,
                                                      liquidGlassIconSize: 17,
                                                      color: canSend
                                                          ? Theme.of(context)
                                                                .colorScheme
                                                                .primary
                                                          : null,
                                                      icon: Icon(
                                                        PlatformIcons(
                                                          context,
                                                        ).upArrow,
                                                        size: 20,
                                                        color: canSend
                                                            ? (usesLiquidGlass(
                                                                    context,
                                                                  )
                                                                  ? Theme.of(
                                                                          context,
                                                                        )
                                                                        .colorScheme
                                                                        .onPrimary
                                                                  : Theme.of(
                                                                          context,
                                                                        )
                                                                        .colorScheme
                                                                        .primary)
                                                            : Theme.of(
                                                                context,
                                                              ).disabledColor,
                                                        semanticLabel: S
                                                            .of(context)
                                                            .send,
                                                      ),
                                                      onPressed: canSend
                                                          ? () {
                                                              VibrationUtils.vibrateWithClickIfPossible();
                                                              _sendReply();
                                                            }
                                                          : null,
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (dioLoaded)
                                    CaptchaWidget(
                                      dio,
                                      discuz,
                                      user,
                                      "post",
                                      captchaController: _captchaController,
                                    ),
                                  CupertinoKeyboardAccessory(
                                    enabled:
                                        visualStyle(context) ==
                                        AppVisualStyle.cupertino,
                                    child: AnimatedSwitcher(
                                      duration: AppMotion.duration(
                                        context,
                                        200,
                                      ),
                                      reverseDuration: AppMotion.duration(
                                        context,
                                        140,
                                      ),
                                      switchInCurve: Curves.easeOutCubic,
                                      switchOutCurve: Curves.easeInCubic,
                                      child: dialogStatus == SHOW_SMILEY_DIALOG
                                          ? SafeArea(
                                              top: false,
                                              left:
                                                  visualStyle(context) ==
                                                  AppVisualStyle.cupertino,
                                              right:
                                                  visualStyle(context) ==
                                                  AppVisualStyle.cupertino,
                                              bottom:
                                                  visualStyle(context) ==
                                                  AppVisualStyle.cupertino,
                                              child: SmileyListScreen(
                                                (smiley) =>
                                                    insertSmiley(smiley),
                                                recentActions: [
                                                  SmileyPanelAction(
                                                    icon: PlatformIcons(
                                                      context,
                                                    ).collectionsSolid,
                                                    label: S
                                                        .of(context)
                                                        .addAPhoto,
                                                    onPressed: () =>
                                                        _extraFunctionsKey
                                                            .currentState
                                                            ?.pickImageFromGallery(),
                                                  ),
                                                  SmileyPanelAction(
                                                    icon: PlatformIcons(
                                                      context,
                                                    ).photoCameraSolid,
                                                    label: S
                                                        .of(context)
                                                        .takeAPicture,
                                                    onPressed: () =>
                                                        _extraFunctionsKey
                                                            .currentState
                                                            ?.takePicture(),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : const SizedBox.shrink(
                                              key: ValueKey(
                                                'thread_composer_panel_hidden',
                                              ),
                                            ),
                                    ),
                                  ),
                                  Offstage(
                                    offstage: true,
                                    child: ExtraFuncInThreadScreen(
                                      discuz,
                                      tid,
                                      _viewThreadResult.threadVariables.fid,
                                      key: _extraFunctionsKey,
                                      showHistoricalAttachment: false,
                                      onReplyWithImage: (aid, path) =>
                                          _handleReplyWithImage(
                                            discuz,
                                            aid,
                                            path,
                                          ),
                                      onReplyWithHostedImage:
                                          (imageUrl, path) =>
                                              _handleReplyWithHostedImage(
                                                imageUrl,
                                              ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Container(width: 0, height: 0);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleReplyWithImage(
    Discuz discuz,
    String aid,
    String path,
  ) async {
    if (aid.isEmpty) return;
    _replyController.text += "[attachimg]$aid[/attachimg]";
    insertedAidList.add(aid);

    final savedInDatabase =
        await UserPreferencesUtils.getRecordHistoryEnabled();
    if (!savedInDatabase) return;

    final imageAttachmentDao = await AppDatabase.getImageAttachmentDao();
    final imageAttachment = imageAttachmentDao
        .findImageAttachmentByDiscuzAndAid(discuz, aid);
    if (imageAttachment != null) {
      imageAttachment.updateAt = DateTime.now();
      imageAttachmentDao.insertImageAttachmentWithKey(
        imageAttachment.key,
        imageAttachment,
      );
    } else {
      imageAttachmentDao.insertImageAttachment(
        ImageAttachment(aid, discuz, path),
      );
    }
  }

  void _handleReplyWithHostedImage(String imageUrl) {
    if (imageUrl.isEmpty) return;
    _replyController.text += "[img]$imageUrl[/img]";
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
          baseOffset: end + text.length,
          extentOffset: end + text.length,
        ),
      );
    } else {
      String newText = "";
      newText = _replyController.text + text;
      _replyController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.fromPosition(
          TextPosition(offset: newText.length),
        ),
      );
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
    queriesMap["ordertype"] = timeAscend ? "0" : "1";
    return queriesMap;
  }
}
