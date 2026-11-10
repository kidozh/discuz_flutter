import 'package:discuz_flutter/JsonResult/FavoriteThreadResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/DiscuzError.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/page/ViewThreadSliverPage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/NullDiscuzScreen.dart';
import 'package:discuz_flutter/screen/NullUserScreen.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/TimeDisplayUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:discuz_flutter/widget/cupertino_separated_item.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:provider/provider.dart';

import '../utility/EasyRefreshUtils.dart';

class FavoriteThreadScreen extends StatelessWidget {
  FavoriteThreadScreen();

  @override
  Widget build(BuildContext context) {
    final account = context.watch<DiscuzAndUserNotifier>();
    return FavoriteThreadStatefulWidget(key: ValueKey(account.sessionIdentity));
  }
}

class FavoriteThreadStatefulWidget extends StatefulWidget {
  const FavoriteThreadStatefulWidget({super.key});

  @override
  _FavoriteThreadState createState() => _FavoriteThreadState();
}

class _FavoriteThreadState extends State<FavoriteThreadStatefulWidget> {
  final _controller = EasyRefreshController();
  DiscuzError? _error;
  int _page = 1;
  bool _hasMore = true;
  bool _loading = false;
  List<FavoriteThread> _threads = [];

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
      ).favoriteThreadResult(page);
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
        if (error == null) {
          final rows = variables.pmList;
          _threads = page == 1 ? rows : [..._threads, ...rows];
          _page = page + 1;
          _hasMore = rows.isNotEmpty && _threads.length < variables.count;
        }
      });
      if (error != null) return IndicatorResult.fail;
      return refresh || _hasMore
          ? IndicatorResult.success
          : IndicatorResult.noMore;
    } catch (error) {
      if (!isCurrent()) return IndicatorResult.fail;
      setState(() {
        _error = EasyRefreshUtils.requestError(context, error);
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
        }
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
                child: getEasyRefreshWidget(
                  discuzAndUser.discuz!,
                  discuzAndUser.user!,
                ),
              ),
            ],
          ),
        );
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
            delegate: SliverChildBuilderDelegate((context, index) {
              FavoriteThread favoriteThread = _threads[index];
              return CupertinoSeparatedItem(
                child: PlatformCard(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  child: PlatformListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    title: Text(
                      favoriteThread.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: RichText(
                      text: TextSpan(
                        text: favoriteThread.author,
                        style: DefaultTextStyle.of(context).style,
                        children: <TextSpan>[
                          //TextSpan(text: S.of(context).publishAt, style: TextStyle(fontWeight: FontWeight.w300)),
                          TextSpan(
                            text: " · ",
                            style: TextStyle(fontWeight: FontWeight.w300),
                          ),
                          TextSpan(text: favoriteThread.description),
                          TextSpan(
                            text: " · ",
                            style: TextStyle(fontWeight: FontWeight.w300),
                          ),
                          TextSpan(
                            text: TimeDisplayUtils.getLocaledTimeDisplay(
                              context,
                              favoriteThread.publishAt,
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: Icon(PlatformIcons(context).forward),
                    onTap: () async {
                      VibrationUtils.vibrateWithClickIfPossible();
                      await pushDetailPage(
                        context,
                        platformPageRoute(
                          context: context,
                          iosTitle: favoriteThread.title,
                          builder: (context) => ViewThreadSliverPage(
                            discuz,
                            user,
                            favoriteThread.id,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }, childCount: _threads.length),
          ),
        ],
      ),
    );
  }
}
