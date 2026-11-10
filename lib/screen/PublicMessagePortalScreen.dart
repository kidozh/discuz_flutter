import 'package:discuz_flutter/JsonResult/PublicMessagePortalResult.dart'
    show PublicMessagePortal;
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/DiscuzError.dart';
import 'package:discuz_flutter/entity/User.dart';
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
import 'package:discuz_flutter/widget/cupertino_separated_item.dart';
import 'package:provider/provider.dart';

class PublicMessagePortalScreen extends StatefulWidget {
  const PublicMessagePortalScreen({super.key});

  @override
  State<PublicMessagePortalScreen> createState() => _PublicMessagePortalState();
}

class _PublicMessagePortalState extends State<PublicMessagePortalScreen>
    with AutomaticKeepAliveClientMixin {
  DiscuzError? _error;
  int _page = 1;
  List<PublicMessagePortal> _messages = [];
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
    _messages = [];
    _error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && generation == _generation) {
        _refreshMessages(discuz, generation: generation);
      }
    });
  }

  Future<IndicatorResult> _refreshMessages(Discuz discuz, {int? generation}) =>
      _loadMessages(
        discuz,
        generation: generation ?? _generation,
        refresh: true,
      );

  Future<IndicatorResult> _loadMessages(
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
      ).publicMessagePortalResult(page);
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
        _messages = page == 1 ? rows : [..._messages, ...rows];
        _page = page + 1;
        _hasMore = rows.isNotEmpty && _messages.length < variables.count;
      });
      if (refresh) _controller.resetFooter();
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
                      _refreshMessages(discuz, generation: generation),
                  onLoad: () => _loadMessages(discuz, generation: generation),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return CupertinoSeparatedItem(
                        child: PlatformCard(
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
