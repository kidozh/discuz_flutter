import 'dart:convert';
import 'dart:developer';

import 'package:discuz_flutter/JsonResult/PrivateMessagePortalResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/DiscuzError.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
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
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

class PrivateMessagePortalScreen extends StatefulWidget {
  const PrivateMessagePortalScreen({super.key});

  @override
  State<PrivateMessagePortalScreen> createState() =>
      _PrivateMessagePortalState();
}

class _PrivateMessagePortalState extends State<PrivateMessagePortalScreen>
    with AutomaticKeepAliveClientMixin {
  PrivateMessagePortalResult result = PrivateMessagePortalResult();
  DiscuzError? _error;
  int _page = 1;
  List<PrivateMessagePortal> _pmList = [];
  late final EasyRefreshController _controller;
  String? _accountIdentity;
  int _generation = 0;
  bool _requestInFlight = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController(
      controlFinishLoad: true,
      controlFinishRefresh: true,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _ensureInitialized(Discuz discuz, User user) {
    final identity = '${discuz.baseURL}#${user.uid}';
    if (_accountIdentity == identity) return;
    _accountIdentity = identity;
    final generation = ++_generation;
    _page = 1;
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
            discuz, user);
    try {
      final cacheResult =
          PrivateMessagePortalResult.fromJson(jsonDecode(jsonString));
      if (!mounted || generation != _generation) return;
      setState(() {
        result = cacheResult;
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
  }) {
    _page = 1;
    _controller.resetFooter();
    return _loadPrivateMessages(
      discuz,
      generation: generation ?? _generation,
    );
  }

  Future<IndicatorResult> _loadPrivateMessages(
    Discuz discuz, {
    required int generation,
  }) async {
    if (_requestInFlight) return IndicatorResult.fail;
    final user =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    if (user == null) return IndicatorResult.fail;

    _requestInFlight = true;
    final requestPage = _page;
    try {
      final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
      final client = MobileApiClient(dio, baseUrl: discuz.baseURL);
      final value = await client.privateMessagePortalResult(requestPage);
      if (!mounted || generation != _generation) return IndicatorResult.fail;

      if (requestPage == 1) {
        await UserPreferencesUtils.putDiscuzPrivateMessageResultCacheJson(
          discuz,
          user,
          jsonEncode(value.toJson()),
        );
      }
      if (!mounted || generation != _generation) return IndicatorResult.fail;

      DiscuzError? nextError;
      if (value.variables.member_uid != user.uid) {
        nextError = DiscuzError(
          S.of(context).userExpiredTitle(user.username),
          S.of(context).userExpiredSubtitle,
        );
      } else if (value.errorResult != null) {
        nextError =
            DiscuzError(value.errorResult!.key, value.errorResult!.content);
      }
      setState(() {
        result = value;
        _error = nextError;
        final merged = requestPage == 1
            ? List<PrivateMessagePortal>.from(value.variables.pmList)
            : <PrivateMessagePortal>[
                ..._pmList,
                ...value.variables.pmList,
              ];
        final unique = <String, PrivateMessagePortal>{};
        for (final conversation in merged) {
          unique[_conversationIdentity(conversation)] = conversation;
        }
        _pmList = unique.values.toList()
          ..sort(_compareConversationsNewestFirst);
        _page = requestPage + 1;
      });

      Provider.of<DiscuzNotificationProvider>(context, listen: false)
          .setNotificationCount(value.variables.noticeCount);
      if (value.getErrorString() != null) {
        EasyLoading.showError(value.getErrorString()!);
      }

      final indicator = _pmList.length >= value.variables.count
          ? IndicatorResult.noMore
          : IndicatorResult.success;
      _controller.finishRefresh(indicator);
      _controller.finishLoad(indicator);
      return indicator;
    } catch (error) {
      if (mounted && generation == _generation) {
        setState(() {
          _error = DiscuzError(error.runtimeType.toString(), error.toString());
        });
        _controller.finishRefresh(IndicatorResult.fail);
        _controller.finishLoad(IndicatorResult.fail);
      }
      return IndicatorResult.fail;
    } finally {
      _requestInFlight = false;
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
    final match = RegExp(
      r'^(\d{4})-(\d{1,2})-(\d{1,2})\s+(\d{1,2}):(\d{1,2})',
    ).firstMatch(normalized);
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
        _ensureInitialized(discuz, user);

        return PlatformLiquidGlassPageBackdrop(
          child: Column(
            children: [
              if (_error != null)
                ErrorCard(_error!, () => _controller.callRefresh()),
              Expanded(
                child: EasyRefresh(
                  header: EasyRefreshUtils.i18nClassicHeader(context),
                  footer: EasyRefreshUtils.i18nClassicFooter(context),
                  refreshOnStart: false,
                  controller: _controller,
                  onRefresh: () => _refreshPrivateMessages(discuz),
                  onLoad: () => _loadPrivateMessages(
                    discuz,
                    generation: _generation,
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: _pmList.length,
                    itemBuilder: (context, index) => PrivateMessagePortalWidget(
                      discuz,
                      _pmList[index],
                      onConversationClosed: () =>
                          _refreshPrivateMessages(discuz),
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
