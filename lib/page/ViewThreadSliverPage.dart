import '../utility/post_signature_service.dart';
import '../utility/post_editor_controller.dart';
import '../widget/cupertino_separated_item.dart';
import '../widget/PostRatingsInline.dart';
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
    final account = context.watch<DiscuzAndUserNotifier>();
    final activeUser = account.userFor(discuz);
    return ThreadReplyScope(
      threadIdentity: (discuz.baseURL, activeUser?.uid, tid),
      child: ViewThreadStatefulSliverWidget(
        discuz,
        activeUser,
        tid,
        key: ValueKey((
          discuz.baseURL,
          tid,
          activeUser?.uid,
          account.sessionIdentity,
        )),
        passedSubject: passedSubject,
        onClosed: onClosed,
        initialPid: initialPid,
      ),
    );
  }
}

class ViewThreadStatefulSliverWidget extends StatefulWidget {
  late final Discuz discuz;
  late final User? user;
  int tid = 0;
  final String? passedSubject;
  VoidCallback? onClosed;
  final int? initialPid;

  ViewThreadStatefulSliverWidget(
    this.discuz,
    this.user,
    this.tid, {
    super.key,
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
  final _replyController = PostEditorController();
  final CaptchaController _captchaController = new CaptchaController(
    new CaptchaFields("", "post", ""),
  );

  late final Discuz discuz;
  late final User? user;

  int tid;

  bool historySaved = false;
  VoidCallback? onClosed;
  _ViewThreadSliverState(this.discuz, this.user, this.tid, {this.onClosed});

  final _controller = EasyRefreshController();
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
  late final Object _session;
  int _contentGeneration = 0;
  int? _requestGeneration;
  bool _hasMore = true;
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
  int _initialPage = 1;
  int preCachedItemNum = 0;
  DateTime lastFocusAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    _session = context.read<DiscuzAndUserNotifier>().sessionIdentity;
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
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _readingRestorer.cancel();
    unawaited(_positionWriter.close());
    _scrollController.dispose();
    _postAutoScrollController.dispose();
    _showNavigationTitle.dispose();
    _focusNode.dispose();
    _replySubmission.dispose();
    _replyController.dispose();
    _captchaController.dispose();
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

  Future<void> _saveViewHistory(
    DetailedThreadInfo threadInfo,
    String contents,
  ) async {
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
    var generation = ++_contentGeneration;
    _locateGeneration++;
    _locatingPost = false;
    _readingRestorer.cancel();
    final account = context.read<DiscuzAndUserNotifier>();
    bool isCurrent() =>
        mounted &&
        generation == _contentGeneration &&
        identical(_session, account.sessionIdentity);
    Completer<void>? initialLoad;
    try {
      await _positionWriter.flush();
      if (!isCurrent()) return IndicatorResult.fail;
      if (!_initialPidHandled && widget.initialPid != null) {
        _initialPidHandled = true;
        final found = await scrollToPid(widget.initialPid!);
        if (found) return IndicatorResult.success;
        if (!mounted || generation + 1 != _contentGeneration) {
          return IndicatorResult.fail;
        }
        generation = _contentGeneration;
      }

      var firstPage = 1;
      final hasCacheDao =
          viewThreadCacheDao != null && viewThreadScrollDistanceDao != null;
      if (!hasCacheDao) {
        initialLoad = _initialReadingLoad = Completer<void>();
        try {
          final cacheDao = await AppDatabase.getViewThreadCacheDao();
          final distanceDao =
              await AppDatabase.getViewThreadScrollDistanceDao();
          if (!isCurrent()) return IndicatorResult.fail;
          viewThreadCacheDao = cacheDao;
          viewThreadScrollDistanceDao = distanceDao;
          final pages = cacheDao.findAllViewThreadCacheListByDiscuz(
            discuz,
            tid,
            viewThreadQuery.timeAscend,
          );
          final posts = <Post>[];
          final comments = <String, List<Comment>>{};
          ViewThreadResult? lastResult;
          for (final page in pages) {
            final result = ViewThreadResult.fromJson(jsonDecode(page.json));
            if (result.getErrorString() != null ||
                result.threadVariables.member_uid != (user?.uid ?? 0) ||
                page.page != firstPage + (lastResult == null ? 0 : 1)) {
              break;
            }
            preCachedItemNum = posts.length;
            posts.addAll(result.threadVariables.postList);
            comments.addAll(result.threadVariables.commentList);
            firstPage = page.page;
            lastResult = result;
          }
          if (lastResult != null && posts.isNotEmpty) {
            final cachedResult = lastResult;
            setState(() {
              _viewThreadResult = cachedResult;
              _postList = posts;
              postCommentList = comments;
              _isFirstLoading = false;
            });
            final offset = distanceDao
                .findViewThreadCacheListByDiscuz(
                  discuz,
                  tid,
                  viewThreadQuery.timeAscend,
                )
                ?.offset;
            if (offset != null) {
              _readingRestorer.schedule(offset);
              ToastUtils.showSuccessfulToast(
                S.of(context).animateToLastReadingPosition,
              );
            }
          }
        } catch (error) {
          // A cache read failure must not block the network refresh.
          log('Unable to load the thread cache: $error');
          firstPage = 1;
        }
      }
      if (!isCurrent()) return IndicatorResult.fail;
      return await _loadForumContent(
        refreshPage: firstPage,
        clearCache: hasCacheDao && viewThreadQuery.authorId == 0,
      );
    } catch (error) {
      if (isCurrent())
        setState(() => _error = EasyRefreshUtils.requestError(context, error));
      return IndicatorResult.fail;
    } finally {
      final settlingLoad = initialLoad;
      if (settlingLoad != null && !settlingLoad.isCompleted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!settlingLoad.isCompleted) settlingLoad.complete();
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
      _hasMore = true;
      _postList = [];
      postCommentList = {};
    });
    _controller.resetFooter();
    _loadForumContent();
  }

  Future<void> _saveViewThreadCache(
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
    await viewThreadCacheDao?.insertViewThreadCache(viewThreadCache);
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
    final account = context.read<DiscuzAndUserNotifier>();
    final user = account.userFor(discuz);
    if (user == null) return;
    bool isCurrent() => mounted && identical(_session, account.sessionIdentity);
    if (!isCurrent()) return;
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
    if (captchaHash.isNotEmpty && verification.trim().isEmpty) {
      EasyLoading.showError(strings.captchaRequired);
      return;
    }
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
          if (!isCurrent()) return null;
          final permission = await MobileApiClient(
            dio,
            baseUrl: discuz.baseURL,
          ).checkPost(fid, threadId);
          if (!isCurrent()) return null;
          if (permission.variables.member_uid != 0 &&
              permission.variables.member_uid != user.uid)
            return null;
          if (permission.getErrorString() != null ||
              permission.variables.allowPerm.allowReply != true) {
            throw StateError(
              permission.getErrorString() ??
                  (permission.variables.allowPerm.allowReply == false
                      ? strings.replyPermissionDenied
                      : strings.postPermissionUnknown),
            );
          }
          final message = await PostSignatureService.append(
            context,
            PostTextFieldUtils.getPostMessage(draft.text),
          );
          if (!isCurrent()) return null;
          final attachImgMap = HashMap<String, String>.from({
            for (final aid in PostTextFieldUtils.getAttachmentAidList(
              draft.text,
            ).toSet())
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
      if (!isCurrent() || value == null) return;
      final result = value.errorResult;
      if (result?.key == 'post_reply_succeed') {
        if (captchaHash.isNotEmpty || _captchaController.requiredByServer) {
          _captchaController.reloadCaptcha(requiredByServer: false);
        }
        EasyLoading.showSuccess('${result!.content}(${result.key})');
      } else {
        if (result?.key == 'submit_seccode_invalid') {
          _captchaController.reloadCaptcha(requiredByServer: true);
        }
        EasyLoading.showError(
          result == null
              ? strings.progressButtonReplyFailed
              : '${result.content}(${result.key})',
        );
      }
    } catch (error) {
      if (!isCurrent()) return;
      VibrationUtils.vibrateErrorIfPossible();
      EasyLoading.showError(error is DioException ? error.type.name : '$error');
    }
  }

  late Dio dio;
  late MobileApiClient client;
  bool dioLoaded = false;
  Future<void> _loadClient() async {
    dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    if (!mounted) return;
    client = MobileApiClient(dio, baseUrl: discuz.baseURL);

    setState(() {
      dioLoaded = true;
    });
  }

  Future<void> favoriteThread() async {
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
    FavoriteThreadDao favoriteThreadDao =
        await AppDatabase.getFavoriteThreadDao();
    FavoriteThreadInDatabase? favoriteThreadInDatabase = favoriteThreadDao
        .getFavoriteThreadByTid(tid, discuz, uid: user?.uid ?? 0);
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

  Future<IndicatorResult> _loadForumContent({
    int? refreshPage,
    bool clearCache = false,
  }) async {
    final generation = _contentGeneration;
    if (_locatingPost || _requestGeneration == generation) {
      return IndicatorResult.fail;
    }
    if (refreshPage == null && !_hasMore) return IndicatorResult.noMore;
    final account = context.read<DiscuzAndUserNotifier>();
    bool isCurrent() =>
        mounted &&
        generation == _contentGeneration &&
        identical(_session, account.sessionIdentity);
    if (!isCurrent()) return IndicatorResult.fail;
    _requestGeneration = generation;
    final requestedPage = refreshPage ?? _page;
    final initialPage = refreshPage ?? _initialPage;
    final focused = refreshPage == null && _focusedPage;
    final postsPerPage = focused ? _focusedPpp ?? 15 : 15;
    final timeAscend = viewThreadQuery.timeAscend;
    final authorId = viewThreadQuery.authorId;
    final query = viewThreadQuery.generateForumQueriesMap();
    try {
      final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
      final value = await MobileApiClient(
        dio,
        baseUrl: discuz.baseURL,
      ).viewThreadPage(tid, requestedPage, postsPerPage, query);
      if (!isCurrent()) return IndicatorResult.fail;
      final variables = value.threadVariables;
      final error = EasyRefreshUtils.responseError(
        context,
        value,
        user,
        variables.member_uid,
      );
      final update = ReadingPageUpdate.fromResponse(
        value,
        currentPosts: _postList,
        requestedPage: requestedPage,
        initialPage: initialPage,
        cachedPrefixCount: preCachedItemNum,
      );
      if (ReadingPerformanceProbe.enabled) {
        ReadingPerformanceProbe.record('reading.pageResponse', {
          'page': requestedPage,
          'accepted': error == null && update != null,
          'received_posts': variables.postList.length,
          'current_posts': _postList.length,
        });
      }
      if (error != null || update == null) {
        final displayError = error ?? DiscuzError(S.of(context).error, '');
        setState(() {
          _isFirstLoading = false;
          if (_postList.isEmpty ||
              requestedPage <= initialPage ||
              displayError.errorType == ErrorType.userExpired) {
            _error = displayError;
          }
        });
        EasyLoading.showError(displayError.content);
        return IndicatorResult.fail;
      }

      final replies = variables.threadInfo.replies;
      setState(() {
        _viewThreadResult = value;
        _isFirstLoading = false;
        _error = null;
        _postList = update.posts;
        _page = update.nextPage;
        if (requestedPage == 1) postCommentList = {};
        postCommentList.addAll(variables.commentList);
        if (refreshPage != null) {
          _initialPage = refreshPage;
          _focusedPage = false;
          _focusedPpp = null;
          if (refreshPage == 1) preCachedItemNum = 0;
        }
        _hasMore =
            variables.postList.isNotEmpty &&
            (focused
                ? hasMoreThreadPages(
                    page: requestedPage,
                    postsPerPage: postsPerPage,
                    replies: replies,
                  )
                : _postList.length < replies + 1);
      });
      if (refreshPage != null) _controller.resetFooter();

      if (!historySaved &&
          requestedPage == 1 &&
          variables.postList.isNotEmpty) {
        historySaved = true;
        unawaited(
          _saveViewHistory(
            variables.threadInfo,
            variables.postList.first.message,
          ).catchError((Object error) {
            historySaved = false;
            log('Unable to save thread history: $error');
          }),
        );
      }
      if (discuz.isSameSite(account.discuz)) {
        context.read<DiscuzNotificationProvider>()
          ..setNotificationCount(variables.noticeCount)
          ..setBaseVariableResult(variables);
      }

      final rewriteRule = variables.rewriteRule;
      if (rewriteRule.forumDisplay.isNotEmpty) {
        RewriteRuleUtils.putForumDisplayRule(discuz, rewriteRule.forumDisplay);
      }
      if (rewriteRule.viewThread.isNotEmpty) {
        RewriteRuleUtils.putViewThreadRule(discuz, rewriteRule.viewThread);
      }
      if (rewriteRule.userSpace.isNotEmpty) {
        RewriteRuleUtils.putUserProfileRule(discuz, rewriteRule.userSpace);
      }

      if (!focused && authorId == 0) {
        try {
          if (clearCache) {
            await viewThreadCacheDao?.deleteAllViewThreadCacheByTid(
              discuz,
              tid,
            );
            await viewThreadScrollDistanceDao
                ?.deleteAllViewThreadScrollDistanceByTid(discuz, tid);
          }
          if (isCurrent())
            await _saveViewThreadCache(value, tid, requestedPage, timeAscend);
        } catch (error) {
          log('Unable to save the thread cache: $error');
        }
      }
      return refreshPage != null || _hasMore
          ? IndicatorResult.success
          : IndicatorResult.noMore;
    } catch (error) {
      if (!isCurrent()) return IndicatorResult.fail;
      VibrationUtils.vibrateErrorIfPossible();
      final displayError = EasyRefreshUtils.requestError(context, error);
      setState(() {
        _isFirstLoading = false;
        if (_postList.isEmpty || requestedPage <= initialPage)
          _error = displayError;
      });
      if (requestedPage > initialPage)
        EasyLoading.showError(displayError.content);
      return IndicatorResult.fail;
    } finally {
      if (_requestGeneration == generation) _requestGeneration = null;
    }
  }

  Future<bool> scrollToPid(int pid) async {
    if (pid <= 0 || _locatingPost) return false;
    final account = context.read<DiscuzAndUserNotifier>();
    final request = ++_locateGeneration;
    bool isCurrent() =>
        mounted &&
        request == _locateGeneration &&
        identical(_session, account.sessionIdentity);
    _readingRestorer.cancel();
    var index = _postList.indexWhere((post) => post.pid == pid);
    try {
      if (index < 0) {
        final generation = ++_contentGeneration;
        setState(() => _locatingPost = true);
        final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
        final located = await PostLocator.locate(dio, discuz.baseURL, tid, pid);
        if (!isCurrent() || generation != _contentGeneration) return false;
        final variables = located.result.threadVariables;
        final error = EasyRefreshUtils.responseError(
          context,
          located.result,
          user,
          variables.member_uid,
        );
        if (error != null) {
          setState(() => _error = error);
          return false;
        }
        setState(() {
          _focusedPage = true;
          _focusedPpp = int.tryParse(located.result.threadVariables.ppp);
          _initialPage = located.page;
          preCachedItemNum = 0;
          _page = located.page + 1;
          _hasMore = hasMoreThreadPages(
            page: located.page,
            postsPerPage: _focusedPpp ?? 15,
            replies: variables.threadInfo.replies,
          );
          viewThreadQuery = ViewThreadQuery();
          _viewThreadResult = located.result;
          _postList = located.result.threadVariables.postList;
          postCommentList = Map.of(located.result.threadVariables.commentList);
          _isFirstLoading = false;
          _error = null;
        });
        index = _postList.indexWhere((post) => post.pid == pid);
        _controller.resetFooter();
      }
      if (!isCurrent()) return false;
      setState(() => _highlightPid = pid);
      await WidgetsBinding.instance.endOfFrame;
      if (!isCurrent() || !_postAutoScrollController.hasClients) return false;
      await _postAutoScrollController.scrollToIndex(
        index,
        preferPosition: AutoScrollPosition.begin,
      );
      if (!isCurrent()) return false;
      await _postAutoScrollController.highlight(index);
      return true;
    } catch (_) {
      if (isCurrent()) EasyLoading.showError(S.of(context).postLocateFailed);
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
    final user = context.watch<DiscuzAndUserNotifier>().userFor(discuz);
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
      // The complete post, including its actions, owns the separator below.
      showSeparator: false,
      sessionUid: _isFirstLoading || _error?.errorType == ErrorType.userExpired
          ? 0
          : variables.member_uid,
      isBestAnswer: variables.reward?.bestPid == post.pid && post.pid > 0,
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
      return CupertinoSeparatedItem(
        sliver: asSliver,
        child: asSliver
            ? SliverMainAxisGroup(
                slivers: [
                  content,
                  SliverToBoxAdapter(child: action),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [content, action],
              ),
      );
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
    );
    final ratings =
        shouldLoadFirstPostRatings(
          discuz.baseURL,
          variables.threadInfo.views,
          post.first,
        )
        ? PostRatingsInline(
            key: ValueKey(
              'ratings-${discuz.baseURL}-${post.pid}-${user?.uid}-${user?.auth}-$_contentGeneration',
            ),
            discuz: discuz,
            user: user,
            tid: tid,
            pid: post.pid,
            asSliver: asSliver,
          )
        : null;
    return CupertinoSeparatedItem(
      sliver: asSliver,
      child: asSliver
          ? SliverMainAxisGroup(
              slivers: [
                content,
                if (ratings != null) ratings,
                SliverToBoxAdapter(child: feedback),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [content, if (ratings != null) ratings, feedback],
            ),
    );
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
    ModalRoute<Object?>? route = ModalRoute.of(context);
    final loadedSubject = _viewThreadResult.threadVariables.threadInfo.subject;
    final passedSubject = widget.passedSubject?.trim() ?? '';
    final initialSubject = passedSubject.isEmpty
        ? S.of(context).viewThreadTitle
        : passedSubject;
    final threadSubject = HtmlUnescape().convert(
      loadedSubject.isNotEmpty ? loadedSubject : initialSubject,
    );
    final favoriteThreadInDatabase = favoriteThreadDao?.getFavoriteThreadByTid(
      tid,
      discuz,
      uid: user?.uid ?? 0,
    );
    // A long main post must share the outer viewport to lay out only nearby
    // blocks. Replies and short/Material posts retain their existing box path.
    final lazyFirstPost = _hasLazyFirstPost;
    final threadClosed = _viewThreadResult.threadVariables.threadInfo.closed;
    final showReplyPanel = dialogStatus == SHOW_SMILEY_DIALOG;

    _updateNavigationTitle();
    final previousPageTitle =
        !context
            .watch<UserPreferenceNotifierProvider>()
            .forumDisplay
            .showForumName
        ? ''
        : (route is CupertinoPageRoute<dynamic> &&
              route.previousTitle.value != null)
        ? route.previousTitle.value
        : context.read<DiscuzAndUserNotifier>().discuz?.siteName;
    final adaptiveAppBar = PlatformAppBar(
      automaticallyImplyLeading: this.onClosed == null ? true : false,
      cupertino: (_, __) => CupertinoNavigationBarData(
        heroTag: this.onClosed == null ? null : "viewthread_${tid}",
        transitionBetweenRoutes: false,
        previousPageTitle: previousPageTitle,
      ),
      leading: this.onClosed == null
          ? null
          : PlatformBackButton(
              onPressed: onClosed,
              previousPageTitle: previousPageTitle,
            ),
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
                user != null)
              PopupMenuOption(
                label: S.of(context).moderateThread,
                onTap: (_) async {
                  final changed = await Navigator.push<bool>(
                    context,
                    platformPageRoute(
                      context: context,
                      builder: (_) => ModerateThreadPage(
                        discuz: discuz,
                        user: user!,
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
                await pushDetailPage(
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
                  footer: EasyRefreshUtils.i18nClassicFooter(
                    context,
                    safeArea: false,
                  ),
                  refreshOnStart: true,
                  controller: _controller,
                  //scrollController: _scrollController,
                  onRefresh: _invalidateContent,
                  onLoad: _loadForumContent,
                  // if first load then should display a loading screen
                  child: SelectionArea(
                    child: CustomScrollView(
                      controller: _postAutoScrollController,
                      slivers: [
                        const HeaderLocator.sliver(),
                        if (!_isFirstLoading &&
                            _viewThreadResult.errorResult == null)
                          SliverToBoxAdapter(
                            key: _subjectSliverKey,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                12,
                                16,
                                12,
                              ),
                              child: Semantics(
                                header: true,
                                child: Text(
                                  threadSubject,
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
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
                                  ? LoadingStateWidget(hintText: initialSubject)
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
                            onActivityRegistration: user == null
                                ? null
                                : () async {
                                    final changed = await Navigator.push<bool>(
                                      context,
                                      platformPageRoute(
                                        context: context,
                                        builder: (_) =>
                                            ActivityRegistrationPage(
                                              discuz: discuz,
                                              user: user!,
                                              tid: tid,
                                            ),
                                      ),
                                    );
                                    if (mounted && changed == true)
                                      _controller.callRefresh();
                                  },
                            activity:
                                _viewThreadResult.threadVariables.activity,
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
                                  user,
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
                              highlightColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
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
                              final index =
                                  localIndex + (lazyFirstPost ? 1 : 0);
                              return Column(
                                children: [
                                  AutoScrollTag(
                                    key: ValueKey(index),
                                    controller: _postAutoScrollController,
                                    index: index,
                                    highlightColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                    child: _buildReadingPost(index),
                                  ),
                                  if (index % 10 == 0 && index != 0)
                                    Consumer<UserPreferenceNotifierProvider>(
                                      builder: (context, value, child) {
                                        if (value.signature.includesApp &&
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
                        if (!threadClosed &&
                            (user == null ||
                                _viewThreadResult.threadVariables.member_uid ==
                                    0 ||
                                _viewThreadResult.errorResult != null))
                          const SliverSafeArea(
                            top: false,
                            left: false,
                            right: false,
                            sliver: SliverToBoxAdapter(),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // comment parts
            if (threadClosed)
              Container(
                color: Theme.of(context).colorScheme.error
                    .withValues(alpha: 0.1),
                child: SafeArea(
                  top: false,
                  minimum: const EdgeInsets.symmetric(vertical: 6),
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
            if (!threadClosed && _viewThreadResult.errorResult == null)
              Consumer<DiscuzAndUserNotifier>(
                builder: (context, discuzAndUser, child) {
                  final replyUser = discuzAndUser.userFor(discuz);
                  if (replyUser != null &&
                      _viewThreadResult.threadVariables.member_uid ==
                          replyUser.uid) {
                    return _withReplyPermission(
                      replyUser,
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
                                  if (dioLoaded)
                                    CaptchaWidget(
                                      dio,
                                      discuz,
                                      user,
                                      "post",
                                      captchaController: _captchaController,
                                    ),
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
                                      panelVisible: showReplyPanel,
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
                                      bottom: !showReplyPanel,
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
                                                      FocusScope.of(context)
                                                          .requestFocus(
                                                            _focusNode,
                                                          );
                                                      setState(
                                                        () => dialogStatus =
                                                            SHOW_NONE_DIALOG,
                                                      );
                                                    } else {
                                                      FocusScope.of(context)
                                                          .unfocus();
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
                                                        liquidGlassSymbol: 'checkmark.circle.fill',
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
                                                        liquidGlassSymbol: 'exclamationmark.triangle',
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
                                                        PlatformIcons(context)
                                                            .upArrow,
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
                                      child: showReplyPanel
                                          ? SafeArea(
                                              top: false,
                                              child: SmileyListScreen(
                                                (smiley) =>
                                                    insertSmiley(smiley),
                                                onAttachmentPressed:
                                                    (aid, path) =>
                                                        _handleReplyWithImage(
                                                          discuz,
                                                          aid,
                                                          path,
                                                        ),
                                                recentActions: [
                                                  SmileyPanelAction(
                                                    icon: PlatformIcons(context)
                                                        .collectionsSolid,
                                                    label: S
                                                        .of(context)
                                                        .addAPhoto,
                                                    onPressed: () =>
                                                        _extraFunctionsKey
                                                            .currentState
                                                            ?.pickImageFromGallery(),
                                                  ),
                                                  SmileyPanelAction(
                                                    icon: PlatformIcons(context)
                                                        .photoCameraSolid,
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
                                                path,
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
    if (!mounted || aid.isEmpty) return;
    _replyController.insertAttachment(aid, path);
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

  void _handleReplyWithHostedImage(String imageUrl, String path) {
    if (!mounted || imageUrl.isEmpty) return;
    _replyController.insertHostedImage(imageUrl, path);
  }

  void insertSmiley(Smiley smiley) {
    if (!mounted) return;
    _replyController.insertText(
      '${SmileyText.smileyStartFlag}$smiley${SmileyText.smileyEndFlag}',
    );
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
