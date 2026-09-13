import '../widget/ForumFeedEmptyState.dart';
import '../utility/MobileSignUtils.dart';
import '../utility/ForumFeedPreferences.dart';
import '../client/ForumInteractionClient.dart';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/JsonResult/NewThreadResult.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../client/MobileApiClient.dart';
import '../entity/Discuz.dart';
import '../entity/DiscuzError.dart';
import '../entity/NewThread.dart';
import '../entity/User.dart';
import '../generated/l10n.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../provider/DiscuzNotificationProvider.dart';
import '../provider/UserPreferenceNotifierProvider.dart';
import '../utility/EasyRefreshUtils.dart';
import '../utility/NetworkUtils.dart';
import '../utility/PostTextFieldUtils.dart';
import '../widget/AppBannerAdWidget.dart';
import '../widget/ErrorCard.dart';
import '../widget/LoadingStateWidget.dart';
import '../widget/NewThreadWidget.dart';
import '../widget/ThreadSlideShowCarouselWidget.dart';
import 'EmptyListScreen.dart';
import 'NullDiscuzScreen.dart';

class NewThreadScreen extends StatelessWidget {
  final ValueChanged<int>? onSelectTid;
  NewThreadScreen({this.onSelectTid}) {
    log("New thread When create it ${onSelectTid}");
  }

  @override
  Widget build(BuildContext context) {
    final account = context.watch<DiscuzAndUserNotifier>();
    return ValueListenableBuilder<int>(
      valueListenable: ForumFeedPreferences.revision,
      builder: (_, revision, __) => NewThreadStatefulWidget(
        key: ValueKey(
          '${account.discuz?.baseURL}:${account.user?.uid}:${account.user?.auth}:$revision',
        ),
        onSelectTid: onSelectTid,
      ),
    );
  }
}

class NewThreadStatefulWidget extends StatefulWidget {
  final ValueChanged<int>? onSelectTid;
  NewThreadStatefulWidget({super.key, this.onSelectTid});

  _NewThreadState createState() {
    return _NewThreadState(onSelectTid: onSelectTid);
  }
}

class _NewThreadState extends State<NewThreadStatefulWidget> {
  bool _isFirstLoading = true;
  NewThreadResult result = NewThreadResult();
  DiscuzError? _error;
  int _page = 1;
  List<NewThread> _newThreadList = [];
  final ValueChanged<int>? onSelectTid;

  _NewThreadState({this.onSelectTid});

  late EasyRefreshController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController(
      controlFinishLoad: true,
      controlFinishRefresh: true,
    );
  }

  Future<IndicatorResult> _invalidateNewThreadContent(Discuz discuz) async {
    _page = 1;
    return await _loadNewThreadContent(discuz);
  }

  bool _cacheRestored = false;
  String? _activeFids;
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<IndicatorResult> _loadNewThreadContent(Discuz discuz) async {
    if (_loading) return IndicatorResult.none;
    _loading = true;
    final user = context.read<DiscuzAndUserNotifier>().user;
    final scope = ForumFeedPreferences.scope(discuz, user);
    try {
      final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
      final fids = await ForumFeedPreferences.resolveFids(
        scope,
        ForumInteractionClient(dio, discuz.baseURL),
      );
      if (!mounted) return IndicatorResult.none;
      if (_activeFids != fids) {
        _activeFids = fids;
        _page = 1;
        _cacheRestored = false;
        _newThreadList = [];
      }
      if (fids.isEmpty) {
        setState(() {
          _newThreadList = [];
          _isFirstLoading = false;
          _error = null;
        });
        _controller.finishRefresh(IndicatorResult.success);
        _controller.finishLoad(IndicatorResult.noMore);
        return IndicatorResult.noMore;
      }
      if (!_cacheRestored) {
        _cacheRestored = true;
        final cached = await ForumFeedPreferences.cachedFeed(scope, fids);
        if (!mounted) return IndicatorResult.none;
        if (cached != null) {
          try {
            final value = NewThreadResult.fromJson(cached);
            if (value.variables.member_uid == (user?.uid ?? 0)) {
              setState(() {
                _newThreadList = value.variables.newThreadList;
                _isFirstLoading = false;
              });
            }
          } catch (_) {
            /* Malformed cache must not block a live request. */
          }
        }
      }
      final page = _page;
      final value = await MobileApiClient(
        dio,
        baseUrl: discuz.baseURL,
      ).newThreadsResult(fids, (page - 1) * 20);
      if (!mounted) return IndicatorResult.none;
      if (value.errorResult != null)
        throw ForumApiException(
          value.errorResult!.key,
          value.errorResult!.content,
        );
      if (value.variables.member_uid != (user?.uid ?? 0)) {
        setState(() {
          _isFirstLoading = false;
          _newThreadList = [];
          _error = DiscuzError(
            S.of(context).errorUserExpired,
            S.of(context).userExpiredSubtitle,
            errorType: ErrorType.userExpired,
          );
        });
        _controller.finishRefresh(IndicatorResult.fail);
        _controller.finishLoad(IndicatorResult.fail);
        return IndicatorResult.fail;
      }
      setState(() {
        result = value;
        _error = null;
        _isFirstLoading = false;
        if (page == 1)
          _newThreadList = value.variables.newThreadList;
        else {
          final seen = _newThreadList.map((thread) => thread.tid).toSet();
          _newThreadList.addAll(
            value.variables.newThreadList.where(
              (thread) => seen.add(thread.tid),
            ),
          );
        }
        _page = page + 1;
      });
      context.read<DiscuzNotificationProvider>().setNotificationCount(
        value.variables.noticeCount,
      );
      if (page == 1)
        await ForumFeedPreferences.saveFeed(scope, fids, value.toJson());
      if (!mounted) return IndicatorResult.none;
      final status = value.variables.newThreadList.isEmpty
          ? IndicatorResult.noMore
          : IndicatorResult.success;
      _controller.finishRefresh(IndicatorResult.success);
      _controller.finishLoad(status);
      if (user != null) {
        await MobileSignUtils.conductMobileSign(
          context,
          discuz,
          user,
          value.variables.formHash,
        );
      }
      return status;
    } catch (error) {
      if (!mounted) return IndicatorResult.none;
      setState(() {
        _isFirstLoading = false;
        _error = DiscuzError(
          S.of(context).forumLoadFailed,
          error is ForumApiException
              ? error.toString()
              : S.of(context).forumLoadFailed,
          dioError: error is DioException ? error : null,
        );
      });
      _controller.finishRefresh(IndicatorResult.fail);
      _controller.finishLoad(IndicatorResult.fail);
      return IndicatorResult.fail;
    } finally {
      _loading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DiscuzAndUserNotifier>(
      builder: (context, discuzAndUser, child) {
        if (discuzAndUser.discuz == null) {
          return NullDiscuzScreen();
        }
        return Column(
          children: [
            if (_error != null)
              ErrorCard(_error!, () {
                _controller.callRefresh();
              }, errorType: _error!.errorType),
            Expanded(
              child: getEasyRefreshWidget(
                discuzAndUser.discuz!,
                discuzAndUser.user,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget getEasyRefreshWidget(Discuz discuz, User? user) {
    return EasyRefresh(
      header: EasyRefreshUtils.i18nClassicHeader(context),
      footer: EasyRefreshUtils.i18nClassicFooter(context),
      refreshOnStart: true,
      controller: _controller,
      onRefresh: () async {
        return await _invalidateNewThreadContent(discuz);
      },
      onLoad: () async {
        return await _loadNewThreadContent(discuz);
      },
      child: CustomScrollView(
        slivers: [
          if (_newThreadList.isEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _isFirstLoading
                    ? LoadingStateWidget()
                    : _activeFids == ''
                    ? ForumFeedEmptyState(discuz: discuz, user: user)
                    : EmptyListScreen(EmptyItemType.thread),
                childCount: 1,
              ),
            ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Column(
                children: [
                  if (index == 0)
                    ThreadSlideShowCarouselWidget(onSelectTid: onSelectTid),
                  NewThreadWidget(
                    discuz,
                    user,
                    _newThreadList[index],
                    this.onSelectTid,
                    afterTid: index < _newThreadList.length - 1
                        ? _newThreadList[index + 1].tid
                        : null,
                  ),
                  if (index % 15 == 0 && index != 0)
                    Consumer<UserPreferenceNotifierProvider>(
                      builder: (context, value, child) {
                        if (value.signature ==
                                PostTextFieldUtils.USE_APP_SIGNATURE &&
                            index > 20) {
                          return Container();
                        } else {
                          return const AppBannerAdWidget();
                        }
                      },
                    ),
                ],
              ),
              childCount: _newThreadList.length,
            ),
          ),
        ],
      ),
    );
  }
}
