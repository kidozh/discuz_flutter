import 'dart:async';

import '../utility/ForumFeedPreferences.dart';
import '../client/ForumInteractionClient.dart';
import '../widget/ForumFeedEmptyState.dart';

import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/DiscuzError.dart';
import 'package:discuz_flutter/entity/HotThread.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/NullDiscuzScreen.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:discuz_flutter/widget/HotThreadWidget.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/DiscuzNotificationProvider.dart';
import '../provider/UserPreferenceNotifierProvider.dart';
import '../utility/EasyRefreshUtils.dart';
import '../utility/MobileSignUtils.dart';
import '../widget/AppBannerAdWidget.dart';
import '../widget/LoadingStateWidget.dart';
import '../widget/ThreadSlideShowCarouselWidget.dart';
import 'EmptyListScreen.dart';

class HotThreadScreen extends StatelessWidget {
  final ValueChanged<int>? onSelectTid;

  HotThreadScreen({this.onSelectTid}) {
    log("Hot thread When create it ${onSelectTid}");
  }

  @override
  Widget build(BuildContext context) {
    final account = context.watch<DiscuzAndUserNotifier>();
    return ValueListenableBuilder<int>(
      valueListenable: ForumFeedPreferences.revision,
      builder: (_, revision, __) => HotThreadStatefulWidget(
        key: ValueKey((account.sessionIdentity, revision)),
        onSelectTid: onSelectTid,
      ),
    );
  }
}

class HotThreadStatefulWidget extends StatefulWidget {
  final ValueChanged<int>? onSelectTid;
  HotThreadStatefulWidget({super.key, this.onSelectTid});

  @override
  _HotThreadState createState() => _HotThreadState();
}

class _HotThreadState extends State<HotThreadStatefulWidget> {
  bool _isFirstLoading = true;
  DiscuzError? _error;
  int _page = 1;
  bool _selectionEmpty = false;
  bool _hasMore = true;
  bool _loading = false;
  List<HotThread> _hotThreadList = [];

  final _controller = EasyRefreshController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<IndicatorResult> _loadHotThreadContent(
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
    final page = refresh ? 1 : _page;
    try {
      final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
      var selectionEmpty = false;
      try {
        final fids = await ForumFeedPreferences.resolveFids(
          ForumFeedPreferences.scope(discuz, user),
          ForumInteractionClient(dio, discuz.baseURL),
        );
        selectionEmpty = fids.isEmpty;
      } catch (_) {
        // A directory outage should not prevent the independent hot-thread API.
      }
      if (!isCurrent()) return IndicatorResult.fail;
      if (selectionEmpty) {
        setState(() {
          _selectionEmpty = true;
          _hotThreadList = [];
          _error = null;
          _isFirstLoading = false;
          _hasMore = false;
        });
        return refresh ? IndicatorResult.success : IndicatorResult.noMore;
      }

      final value = await MobileApiClient(
        dio,
        baseUrl: discuz.baseURL,
      ).hotThreadResult(page);
      if (!isCurrent()) return IndicatorResult.fail;
      final apiError = value.getErrorString();
      if (apiError != null) {
        setState(() {
          _isFirstLoading = false;
          _error = DiscuzError(
            value.errorResult?.key ?? S.of(context).error,
            value.errorResult?.content ?? apiError,
          );
        });
        return IndicatorResult.fail;
      }
      final variables = value.variables;
      if (user != null && variables.member_uid != user.uid) {
        setState(() {
          _isFirstLoading = false;
          _error = DiscuzError(
            S.of(context).userExpiredTitle(user.username),
            S.of(context).userExpiredSubtitle,
            errorType: ErrorType.userExpired,
          );
        });
        return IndicatorResult.fail;
      }

      final threads = variables.hotThreadList;
      setState(() {
        _isFirstLoading = false;
        _selectionEmpty = false;
        _error = null;
        if (page == 1) {
          _hotThreadList = threads;
        } else {
          _hotThreadList.addAll(threads);
        }
        _page = page + 1;
        _hasMore = threads.isNotEmpty && threads.length >= variables.perPage;
      });
      context.read<DiscuzNotificationProvider>().setNotificationCount(
        variables.noticeCount,
      );
      if (user != null) {
        unawaited(
          MobileSignUtils.conductMobileSign(
            context,
            discuz,
            user,
            variables.formHash,
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
        _error = error is DioException
            ? DiscuzError(
                error.message ?? S.of(context).error,
                error.type.name,
                dioError: error,
              )
            : DiscuzError(error.runtimeType.toString(), error.toString());
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
      onRefresh: () => _loadHotThreadContent(discuz, refresh: true),
      onLoad: () => _loadHotThreadContent(discuz),
      child: CustomScrollView(
        slivers: [
          if (_hotThreadList.isEmpty && _error == null)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _isFirstLoading
                    ? LoadingStateWidget()
                    : _selectionEmpty
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
                  HotThreadWidget(
                    discuz,
                    user,
                    _hotThreadList[index],
                    widget.onSelectTid,
                    afterTid: index < _hotThreadList.length - 1
                        ? _hotThreadList[index + 1].tid
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
              childCount: _hotThreadList.length,
            ),
          ),
        ],
      ),
    );
  }
}
