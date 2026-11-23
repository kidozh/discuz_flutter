import '../utility/forum_feed_filters.dart';
import '../client/forum_community.dart';
import '../page/forum_community_page.dart';

import 'dart:async';

import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/DiscuzError.dart';
import 'package:discuz_flutter/entity/DiscuzNotification.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/NullDiscuzScreen.dart';
import 'package:discuz_flutter/screen/NullUserScreen.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/widget/DiscuzNotificationWidget.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:discuz_flutter/widget/LoadingStateWidget.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utility/EasyRefreshUtils.dart';
import '../utility/MobileSignUtils.dart';
import '../client/MobileApiClient.dart';
import '../JsonResult/UserDiscuzNotificationResult.dart';
import '../page/ViewThreadSliverPage.dart';
import 'EmptyListScreen.dart';

enum _NoticeFilter {
  all('all'),
  reply('mypost', 'post'),
  mention('mypost', 'at'),
  comment('mypost', 'pcomment'),
  rating('mypost', 'rate'),
  activity('mypost', 'activity'),
  friend('interactive', 'friend'),
  group('interactive', 'group'),
  system('system');

  const _NoticeFilter(this.view, [this.type]);
  final String view;
  final String? type;
  String label(S s) => switch (this) {
    all => s.forumAll,
    reply => s.noticeReplies,
    mention => s.noticeMentions,
    comment => s.noticeReviews,
    rating => s.noticeRatings,
    activity => s.noticeActivities,
    friend => s.friendRequests,
    group => s.communityGroups,
    system => s.noticeSystem,
  };
}

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({this.onSelectTid, super.key});

  final ThreadSelectionCallback? onSelectTid;

  @override
  Widget build(BuildContext context) {
    final account = context.watch<DiscuzAndUserNotifier>();
    return NotificationStatefulWidget(
      key: ValueKey(account.sessionIdentity),
      onSelectTid: onSelectTid,
    );
  }
}

class NotificationStatefulWidget extends StatefulWidget {
  final ThreadSelectionCallback? onSelectTid;

  const NotificationStatefulWidget({this.onSelectTid, super.key});

  @override
  _NotificationState createState() => _NotificationState();
}

class _NotificationState extends State<NotificationStatefulWidget> {
  final _controller = EasyRefreshController();
  DiscuzError? _error;
  int _page = 1;
  bool _hasMore = true;
  int _generation = 0;
  int? _loading;
  _NoticeFilter _filter = _NoticeFilter.all;
  List<DiscuzNotification> _noteList = [];
  bool _isFirstLoading = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<IndicatorResult> _loadPage(
    Discuz discuz,
    User user, {
    bool refresh = false,
  }) async {
    final generation = _generation;
    final filter = _filter;
    if (_loading == generation) return IndicatorResult.fail;
    if (!refresh && !_hasMore) return IndicatorResult.noMore;
    final account = context.read<DiscuzAndUserNotifier>();
    final session = account.sessionIdentity;
    bool isCurrent() =>
        mounted &&
        generation == _generation &&
        identical(session, account.sessionIdentity);
    if (!identical(user, account.user)) return IndicatorResult.fail;
    _loading = generation;
    final page = refresh ? 1 : _page;
    try {
      final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
      final UserDiscuzNotificationResult response;
      try {
        response = await MobileApiClient(dio, baseUrl: discuz.baseURL)
            .userNotificationResult(
              page,
              view: filter == _NoticeFilter.all ? null : filter.view,
              type: filter.type,
            );
      } finally {
        dio.close();
      }
      if (!isCurrent()) return IndicatorResult.fail;
      final variables = response.variables;
      final error = EasyRefreshUtils.responseError(
        context,
        response,
        user,
        variables.member_uid,
      );
      setState(() {
        _error = error;
        _isFirstLoading = false;
        if (error == null) {
          final rows = variables.notificationList;
          _noteList = page == 1 ? rows : [..._noteList, ...rows];
          _page = page + 1;
          _hasMore = rows.isNotEmpty && _noteList.length < variables.count;
        }
      });
      if (error != null) return IndicatorResult.fail;
      unawaited(
        MobileSignUtils.conductMobileSign(
          context,
          discuz,
          user,
          variables.formHash,
        ),
      );
      if (refresh) _controller.resetFooter();
      return refresh || _hasMore
          ? IndicatorResult.success
          : IndicatorResult.noMore;
    } catch (error) {
      if (!isCurrent()) return IndicatorResult.fail;
      setState(() {
        _error = EasyRefreshUtils.requestError(context, error);
        _isFirstLoading = false;
      });
      return IndicatorResult.fail;
    } finally {
      if (_loading == generation) _loading = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DiscuzAndUserNotifier>(
      builder: (context, discuzAndUser, child) {
        if (discuzAndUser.discuz == null) {
          return NullDiscuzScreen();
        } else if (discuzAndUser.user == null) {
          return NullUserScreen();
        } else {
          return PlatformLiquidGlassPageBackdrop(
            child: Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      spacing: 8,
                      children: [
                        for (final item in _NoticeFilter.values)
                          PlatformChoiceChip(
                            label: Text(item.label(S.of(context))),
                            selected: item == _filter,
                            onSelected: (_) {
                              if (item == _filter) return;
                              setState(() {
                                _generation++;
                                _filter = item;
                                _page = 1;
                                _hasMore = true;
                                _isFirstLoading = true;
                                _error = null;
                                _noteList = [];
                              });
                              unawaited(
                                _loadPage(
                                  discuzAndUser.discuz!,
                                  discuzAndUser.user!,
                                  refresh: true,
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                if (_error != null)
                  PlatformCard(
                    margin: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                    child: ErrorCard(
                      _error!,
                      () => _controller.callRefresh(),
                      errorType: _error!.errorType,
                    ),
                  ),
                Expanded(
                  child: getEasyRefreshWidget(
                    discuzAndUser.discuz!,
                    discuzAndUser.user!,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget getEasyRefreshWidget(Discuz discuz, User user) {
    return withForumFeedFilters(discuz, user, (context, rules) {
      final muted = rules.map((rule) => rule['tid']).whereType<int>().toSet();
      final visibleNotes = muted.isEmpty
          ? _noteList
          : _noteList
                .where(
                  (row) => !muted.contains(
                    row.threadId ?? row.replyTarget(discuz)?.$1,
                  ),
                )
                .toList();
      return EasyRefresh(
        header: EasyRefreshUtils.i18nClassicHeader(context),
        footer: EasyRefreshUtils.i18nClassicFooter(context),
        refreshOnStart: true,
        controller: _controller,
        onRefresh: () => _loadPage(discuz, user, refresh: true),
        onLoad: () => _loadPage(discuz, user),
        child: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => PlatformTextButton(
                  onPressed: () async {
                    await openCommunity(
                      context,
                      discuz,
                      CommunitySection.friendRequests,
                    );
                    if (mounted) await _loadPage(discuz, user, refresh: true);
                  },
                  child: Text(S.of(context).friendRequests),
                ),
                childCount: _filter == _NoticeFilter.friend ? 1 : 0,
              ),
            ),
            if (visibleNotes.isEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _isFirstLoading
                      ? LoadingStateWidget(hintText: S.of(context).notification)
                      : EmptyListScreen(EmptyItemType.notification),
                  childCount: 1,
                ),
              ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => DiscuzNotificationWidget(
                  discuz,
                  visibleNotes[index],
                  onSelectTid: widget.onSelectTid,
                  onOpenReply: (tid, pid) => pushDetailPage(
                    context,
                    platformPageRoute(
                      context: context,
                      builder: (_) => ViewThreadSliverPage(
                        discuz,
                        user,
                        tid,
                        initialPid: pid,
                      ),
                    ),
                  ),
                ),
                childCount: visibleNotes.length,
              ),
            ),
            const SliverSafeArea(
              top: false,
              left: false,
              right: false,
              sliver: SliverToBoxAdapter(),
            ),
          ],
        ),
      );
    });
  }
}
