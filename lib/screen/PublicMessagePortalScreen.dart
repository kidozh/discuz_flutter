import 'dart:developer';

import 'package:discuz_flutter/JsonResult/PublicMessagePortalResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/DiscuzError.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/InternalWebviewBrowserPage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/NullDiscuzScreen.dart';
import 'package:discuz_flutter/screen/NullUserScreen.dart';
import 'package:discuz_flutter/utility/EasyRefreshUtils.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/utility/TimeDisplayUtils.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

class PublicMessagePortalScreen extends StatefulWidget {
  const PublicMessagePortalScreen({super.key});

  @override
  State<PublicMessagePortalScreen> createState() => _PublicMessagePortalState();
}

class _PublicMessagePortalState extends State<PublicMessagePortalScreen>
    with AutomaticKeepAliveClientMixin {
  PublicMessagePortalResult result = PublicMessagePortalResult();
  DiscuzError? _error;
  int _page = 1;
  List<PublicMessagePortal> _messages = [];
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
    _messages = [];
    _error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && generation == _generation) {
        _refreshMessages(discuz, generation: generation);
      }
    });
  }

  Future<IndicatorResult> _refreshMessages(
    Discuz discuz, {
    int? generation,
  }) {
    _page = 1;
    _controller.resetFooter();
    return _loadMessages(discuz, generation: generation ?? _generation);
  }

  Future<IndicatorResult> _loadMessages(
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
      final value = await client.publicMessagePortalResult(requestPage);
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
        if (requestPage == 1) {
          _messages = List<PublicMessagePortal>.from(value.variables.pmList);
        } else {
          _messages.addAll(value.variables.pmList);
        }
        _page = requestPage + 1;
      });

      if (value.getErrorString() != null) {
        EasyLoading.showError(value.getErrorString()!);
      }
      final indicator = _messages.length >= value.variables.count
          ? IndicatorResult.noMore
          : IndicatorResult.success;
      _controller.finishRefresh(indicator);
      _controller.finishLoad(indicator);
      return indicator;
    } catch (error) {
      log('Unable to load public messages: $error');
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
                  onRefresh: () => _refreshMessages(discuz),
                  onLoad: () => _loadMessages(discuz, generation: _generation),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return PlatformCard(
                        color: usesLiquidGlass(context)
                            ? Theme.of(context).colorScheme.primary
                            : null,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: PlatformListTile(
                          leading: PlatformLiquidGlassAvatar(
                            size: 48,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                    Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer,
                                  ],
                                ),
                              ),
                              child: Icon(
                                PlatformIcons(context).micSolid,
                                size: 18,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                            ),
                          ),
                          title: Text(message.message),
                          subtitle: Text(
                            TimeDisplayUtils.getLocaledTimeDisplay(
                              context,
                              message.publishAt,
                            ),
                          ),
                          trailing: Icon(PlatformIcons(context).forward),
                          onTap: () {
                            Navigator.push(
                              context,
                              platformPageRoute(
                                context: context,
                                iosTitle: message.message,
                                builder: (context) =>
                                    InternalWebviewBrowserPage(
                                  discuz,
                                  user,
                                  URLUtils.getPublicMessageURL(
                                    discuz,
                                    message.id,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
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
