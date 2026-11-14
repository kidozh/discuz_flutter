import 'dart:async';

import 'package:discuz_flutter/client/MobileApiClient.dart';
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
import 'EmptyListScreen.dart';

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
  bool _loading = false;
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
    if (_loading) return IndicatorResult.fail;
    if (!refresh && !_hasMore) return IndicatorResult.noMore;
    final account = context.read<DiscuzAndUserNotifier>();
    final session = account.sessionIdentity;
    bool isCurrent() => mounted && identical(session, account.sessionIdentity);
    if (!identical(user, account.user)) return IndicatorResult.fail;
    _loading = true;
    final page = refresh ? 1 : _page;
    try {
      final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
      final response = await MobileApiClient(
        dio,
        baseUrl: discuz.baseURL,
      ).userNotificationResult(page);
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
      _loading = false;
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
              (context, index) => SafeArea(child: Container(), bottom: false),
              childCount: 1,
            ),
          ),
          if (_noteList.isEmpty)
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
                _noteList[index],
                onSelectTid: widget.onSelectTid,
              ),
              childCount: _noteList.length,
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
  }
}
