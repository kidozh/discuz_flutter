import 'dart:async';

import '../widget/ForumFeedEmptyState.dart';
import '../utility/MobileSignUtils.dart';
import '../utility/ForumFeedPreferences.dart';
import '../client/ForumInteractionClient.dart';

import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/JsonResult/NewThreadResult.dart';
import 'package:discuz_flutter/utility/pane_navigation.dart';
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
import '../widget/AppBannerAdWidget.dart';
import '../widget/ErrorCard.dart';
import '../widget/LoadingStateWidget.dart';
import '../widget/NewThreadWidget.dart';
import '../widget/ThreadSlideShowCarouselWidget.dart';
import 'EmptyListScreen.dart';
import 'NullDiscuzScreen.dart';

class NewThreadScreen extends StatelessWidget {
  final ThreadSelectionCallback? onSelectTid;
  NewThreadScreen({this.onSelectTid}) {
    log("New thread When create it ${onSelectTid}");
  }

  @override
  Widget build(BuildContext context) {
    final account = context.watch<DiscuzAndUserNotifier>();
    return ValueListenableBuilder<int>(
      valueListenable: ForumFeedPreferences.revision,
      builder: (_, revision, __) => NewThreadStatefulWidget(
        key: ValueKey((account.sessionIdentity, revision)),
        onSelectTid: onSelectTid,
      ),
    );
  }
}

class NewThreadStatefulWidget extends StatefulWidget {
  final ThreadSelectionCallback? onSelectTid;
  NewThreadStatefulWidget({super.key, this.onSelectTid});

  @override
  _NewThreadState createState() => _NewThreadState();
}

class _NewThreadState extends State<NewThreadStatefulWidget> {
  bool _isFirstLoading = true;
  DiscuzError? _error;
  int _page = 1;
  bool _hasMore = true;
  List<NewThread> _newThreadList = [];
  final _controller = EasyRefreshController();

  bool _cacheRestored = false;
  String? _activeFids;
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<IndicatorResult> _loadNewThreadContent(
    Discuz discuz, {
    bool refresh = false,
  }) async {
    if (_loading) return IndicatorResult.fail;
    if (!refresh && !_hasMore) return IndicatorResult.noMore;
    _loading = true;
    final account = context.read<DiscuzAndUserNotifier>();
    final user = account.user;
    final session = account.sessionIdentity;
    bool isCurrent() => mounted && identical(session, account.sessionIdentity);
    final scope = ForumFeedPreferences.scope(discuz, user);
    try {
      final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
      final fids = await ForumFeedPreferences.resolveFids(
        scope,
        ForumInteractionClient(dio, discuz.baseURL),
      );
      if (!isCurrent()) return IndicatorResult.fail;
      if (fids.isEmpty) {
        setState(() {
          _activeFids = fids;
          _page = 1;
          _newThreadList = [];
          _isFirstLoading = false;
          _error = null;
          _hasMore = false;
        });
        return refresh ? IndicatorResult.success : IndicatorResult.noMore;
      }
      if (!_cacheRestored) {
        _cacheRestored = true;
        final cached = await ForumFeedPreferences.cachedFeed(scope, fids);
        if (!isCurrent()) return IndicatorResult.fail;
        if (cached != null) {
          try {
            final value = NewThreadResult.fromJson(cached);
            if (value.getErrorString() == null &&
                value.variables.member_uid == (user?.uid ?? 0)) {
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
      final page = refresh || _activeFids != fids ? 1 : _page;
      final value = await MobileApiClient(
        dio,
        baseUrl: discuz.baseURL,
      ).newThreadsResult(fids, (page - 1) * 20);
      if (!isCurrent()) return IndicatorResult.fail;
      final apiError = value.getErrorString();
      if (apiError != null) {
        throw ForumApiException(value.errorResult?.key ?? '', apiError);
      }
      if (value.variables.member_uid != (user?.uid ?? 0)) {
        setState(() {
          _isFirstLoading = false;
          _error = DiscuzError(
            S.of(context).errorUserExpired,
            S.of(context).userExpiredSubtitle,
            errorType: ErrorType.userExpired,
          );
        });
        return IndicatorResult.fail;
      }
      setState(() {
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
        _activeFids = fids;
        _page = page + 1;
        _hasMore = value.variables.newThreadList.isNotEmpty;
      });
      context.read<DiscuzNotificationProvider>().setNotificationCount(
        value.variables.noticeCount,
      );
      if (page == 1) {
        try {
          await ForumFeedPreferences.saveFeed(scope, fids, value.toJson());
        } catch (error) {
          log('Unable to save the latest threads cache: $error');
        }
      }
      if (!isCurrent()) return IndicatorResult.fail;
      if (user != null) {
        unawaited(
          MobileSignUtils.conductMobileSign(
            context,
            discuz,
            user,
            value.variables.formHash,
          ),
        );
      }
      return refresh || _hasMore
          ? IndicatorResult.success
          : IndicatorResult.noMore;
    } catch (error) {
      if (!isCurrent()) return IndicatorResult.fail;
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
      onRefresh: () => _loadNewThreadContent(discuz, refresh: true),
      onLoad: () => _loadNewThreadContent(discuz),
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
                  if (index == 0 &&
                      context
                          .watch<UserPreferenceNotifierProvider>()
                          .forumDisplay
                          .showCarousel)
                    ThreadSlideShowCarouselWidget(
                      onSelectTid: widget.onSelectTid,
                    ),
                  NewThreadWidget(
                    discuz,
                    user,
                    _newThreadList[index],
                    widget.onSelectTid,
                    afterTid: index < _newThreadList.length - 1
                        ? _newThreadList[index + 1].tid
                        : null,
                  ),
                  if (index % 15 == 0 && index != 0)
                    Consumer<UserPreferenceNotifierProvider>(
                      builder: (context, value, child) {
                        if (value.signature.includesApp && index > 20) {
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
