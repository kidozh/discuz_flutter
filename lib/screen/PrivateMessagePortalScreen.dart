import 'dart:convert';
import 'dart:developer';

import 'package:discuz_flutter/JsonResult/PrivateMessagePortalResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/DiscuzError.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/provider/DiscuzNotificationProvider.dart';
import 'package:discuz_flutter/screen/NullDiscuzScreen.dart';
import 'package:discuz_flutter/screen/NullUserScreen.dart';
import 'package:discuz_flutter/utility/EasyRefreshUtils.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:discuz_flutter/widget/PrivateMessagePortalWidget.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PrivateMessagePortalScreen extends StatefulWidget {
  const PrivateMessagePortalScreen({super.key});

  @override
  State<PrivateMessagePortalScreen> createState() =>
      _PrivateMessagePortalState();
}

class _PrivateMessagePortalState extends State<PrivateMessagePortalScreen>
    with AutomaticKeepAliveClientMixin {
  DiscuzError? _error;
  int _page = 1;
  List<PrivateMessagePortal> _pmList = [];
  final _controller = EasyRefreshController();
  Object? _accountIdentity;
  int _generation = 0;
  int? _requestGeneration;
  bool _hasMore = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _ensureInitialized(Discuz discuz, User user, Object identity) {
    if (_accountIdentity == identity) return;
    _accountIdentity = identity;
    final generation = ++_generation;
    _page = 1;
    _hasMore = true;
    _pmList = [];
    _error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || generation != _generation) return;
      await _loadCache(discuz, user, generation);
      if (!mounted || generation != _generation) return;
      await _refreshPrivateMessages(discuz, generation: generation);
    });
  }

  Future<void> _loadCache(Discuz discuz, User user, int generation) async {
    final jsonString =
        await UserPreferencesUtils.getDiscuzPrivateMessageResultCacheJson(
          discuz,
          user,
        );
    try {
      final cacheResult = PrivateMessagePortalResult.fromJson(
        jsonDecode(jsonString),
      );
      if (!mounted ||
          generation != _generation ||
          _page != 1 ||
          !identical(
            _accountIdentity,
            context.read<DiscuzAndUserNotifier>().sessionIdentity,
          ) ||
          cacheResult.variables.member_uid != user.uid ||
          cacheResult.getErrorString() != null)
        return;
      setState(() {
        _pmList = List<PrivateMessagePortal>.from(cacheResult.variables.pmList)
          ..sort(_compareConversationsNewestFirst);
      });
    } catch (error) {
      log('Unable to load private-message cache: $error');
    }
  }

  Future<IndicatorResult> _refreshPrivateMessages(
    Discuz discuz, {
    int? generation,
  }) => _loadPrivateMessages(
    discuz,
    generation: generation ?? _generation,
    refresh: true,
  );

  Future<IndicatorResult> _loadPrivateMessages(
    Discuz discuz, {
    required int generation,
    bool refresh = false,
  }) async {
    final account = context.read<DiscuzAndUserNotifier>();
    bool isCurrent() =>
        mounted &&
        generation == _generation &&
        identical(_accountIdentity, account.sessionIdentity);
    final user = account.user;
    if (!isCurrent() || user == null || _requestGeneration == generation) {
      return IndicatorResult.fail;
    }
    if (!refresh && !_hasMore) return IndicatorResult.noMore;
    _requestGeneration = generation;
    final page = refresh ? 1 : _page;
    try {
      final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
      final value = await MobileApiClient(
        dio,
        baseUrl: discuz.baseURL,
      ).privateMessagePortalResult(page);
      if (!isCurrent()) return IndicatorResult.fail;
      final variables = value.variables;
      final error = EasyRefreshUtils.responseError(
        context,
        value,
        user,
        variables.member_uid,
      );
      if (error != null) {
        setState(() => _error = error);
        return IndicatorResult.fail;
      }

      final rows = variables.pmList;
      setState(() {
        _error = null;
        final unique = <String, PrivateMessagePortal>{
          if (page > 1)
            for (final row in _pmList) _conversationIdentity(row): row,
          for (final row in rows) _conversationIdentity(row): row,
        };
        _pmList = unique.values.toList()
          ..sort(_compareConversationsNewestFirst);
        _page = page + 1;
        _hasMore = rows.isNotEmpty && _pmList.length < variables.count;
      });
      if (refresh) _controller.resetFooter();
      context.read<DiscuzNotificationProvider>().setNotificationCount(
        variables.noticeCount,
      );
      if (page == 1) {
        try {
          await UserPreferencesUtils.putDiscuzPrivateMessageResultCacheJson(
            discuz,
            user,
            jsonEncode(value.toJson()),
          );
        } catch (error) {
          log('Unable to save private-message cache: $error');
        }
      }
      return refresh || _hasMore
          ? IndicatorResult.success
          : IndicatorResult.noMore;
    } catch (error) {
      if (isCurrent()) {
        setState(() => _error = EasyRefreshUtils.requestError(context, error));
      }
      return IndicatorResult.fail;
    } finally {
      if (_requestGeneration == generation) _requestGeneration = null;
    }
  }

  String _conversationIdentity(PrivateMessagePortal conversation) {
    if (conversation.plid != 0) return 'plid:${conversation.plid}';
    if (conversation.toUid != 0) return 'user:${conversation.toUid}';
    return '${conversation.toUserName}|${conversation.subject}';
  }

  int _compareConversationsNewestFirst(
    PrivateMessagePortal left,
    PrivateMessagePortal right,
  ) {
    final leftTime = _conversationTime(left);
    final rightTime = _conversationTime(right);
    if (leftTime != null && rightTime != null && leftTime != rightTime) {
      return rightTime.compareTo(leftTime);
    }
    if (left.pmId != 0 && right.pmId != 0 && left.pmId != right.pmId) {
      return right.pmId.compareTo(left.pmId);
    }
    return right.plid.compareTo(left.plid);
  }

  DateTime? _conversationTime(PrivateMessagePortal conversation) {
    final normalized = conversation.readableString.trim();
    final match = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})\s+(\d{1,2}):(\d{1,2})')
        .firstMatch(normalized);
    if (match == null) return null;
    return DateTime(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
      int.parse(match.group(4)!),
      int.parse(match.group(5)!),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<DiscuzAndUserNotifier>(
      builder: (context, discuzAndUser, child) {
        final discuz = discuzAndUser.discuz;
        final user = discuzAndUser.user;
        if (discuz == null) return NullDiscuzScreen();
        if (user == null) return NullUserScreen();
        _ensureInitialized(discuz, user, discuzAndUser.sessionIdentity);
        final generation = _generation;

        return PlatformLiquidGlassPageBackdrop(
          child: Column(
            children: [
              if (_error != null)
                ErrorCard(
                  _error!,
                  () => _controller.callRefresh(),
                  errorType: _error!.errorType,
                ),
              Expanded(
                child: EasyRefresh(
                  key: ValueKey(generation),
                  header: EasyRefreshUtils.i18nClassicHeader(context),
                  footer: EasyRefreshUtils.i18nClassicFooter(context),
                  refreshOnStart: false,
                  controller: _controller,
                  onRefresh: () =>
                      _refreshPrivateMessages(discuz, generation: generation),
                  onLoad: () =>
                      _loadPrivateMessages(discuz, generation: generation),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: _pmList.length,
                    itemBuilder: (context, index) => PrivateMessagePortalWidget(
                      discuz,
                      _pmList[index],
                      onConversationClosed: () => _refreshPrivateMessages(
                        discuz,
                        generation: generation,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
