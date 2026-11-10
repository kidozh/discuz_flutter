import 'dart:async';

import '../widget/PortalHighlights.dart';

import 'dart:convert';
import 'dart:developer';

import 'package:discuz_flutter/JsonResult/DiscuzIndexResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/dao/FavoriteForumDao.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/DiscuzError.dart';
import 'package:discuz_flutter/entity/FavoriteForumInDatabase.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/page/DisplayForumSliverPage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/EmptyListScreen.dart';
import 'package:discuz_flutter/screen/NullDiscuzScreen.dart';
import 'package:discuz_flutter/utility/MobileSignUtils.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:discuz_flutter/widget/ForumPartitionWidget.dart';
import 'package:discuz_flutter/widget/LoadingStateWidget.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:provider/provider.dart';

import '../provider/DiscuzNotificationProvider.dart';
import '../utility/EasyRefreshUtils.dart';

class DiscuzPortalScreen extends StatelessWidget {
  const DiscuzPortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final account = context.watch<DiscuzAndUserNotifier>();
    return DiscuzPortalStatefulWidget(key: ValueKey(account.sessionIdentity));
  }
}

class DiscuzPortalStatefulWidget extends StatefulWidget {
  const DiscuzPortalStatefulWidget({super.key});

  _DiscuzPortalState createState() {
    return _DiscuzPortalState();
  }
}

class _DiscuzPortalState extends State<DiscuzPortalStatefulWidget> {
  DiscuzIndexResult result = DiscuzIndexResult();
  DiscuzError? _error;
  final _controller = EasyRefreshController();
  bool _loading = false;

  bool _isFirstlyRefreshing = true;
  int _highlightRefresh = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _DiscuzPortalState();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _initializePortal();
    });
  }

  FavoriteForumDao? favoriteForumDao;

  Future<void> _initializePortal() async {
    await Future.wait([_loadFavoriteForum(), _loadPortalCache()]);
    if (!mounted) return;
    final discuz = Provider.of<DiscuzAndUserNotifier>(
      context,
      listen: false,
    ).discuz;
    if (discuz != null) {
      await _loadPortalContent(discuz, refreshHighlights: false);
    }
  }

  Future<void> _loadFavoriteForum() async {
    FavoriteForumDao dao = await AppDatabase.getFavoriteForumDao();
    if (!mounted) return;
    setState(() {
      favoriteForumDao = dao;
    });
  }

  Future<void> _loadPortalCache() async {
    final account = context.read<DiscuzAndUserNotifier>();
    final discuz = account.discuz;
    final session = account.sessionIdentity;
    final uid = account.user?.uid ?? 0;
    if (discuz == null) return;
    try {
      final json = await UserPreferencesUtils.getDiscuzPortalResultCacheJson(
        discuz,
      );
      if (!mounted ||
          !identical(session, account.sessionIdentity) ||
          !_isFirstlyRefreshing ||
          json.isEmpty)
        return;
      final cached = DiscuzIndexResult.fromJson(jsonDecode(json));
      if (cached.discuzIndexVariables.member_uid == uid &&
          cached.getErrorString() == null) {
        setState(() => result = cached);
      }
    } catch (error) {
      log('Unable to load the forum directory cache: $error');
    }
  }

  Future<IndicatorResult> _loadPortalContent(
    Discuz discuz, {
    bool refreshHighlights = true,
  }) async {
    if (_loading) return IndicatorResult.fail;
    _loading = true;
    if (refreshHighlights) setState(() => _highlightRefresh++);
    final account = context.read<DiscuzAndUserNotifier>();
    final user = account.user;
    final session = account.sessionIdentity;
    bool isCurrent() => mounted && identical(session, account.sessionIdentity);
    try {
      final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
      final response = await MobileApiClient(
        dio,
        baseUrl: discuz.baseURL,
      ).getDiscuzPortalResult();
      if (!isCurrent()) return IndicatorResult.fail;
      final variables = response.discuzIndexVariables;
      final error = EasyRefreshUtils.responseError(
        context,
        response,
        user,
        variables.member_uid,
      );
      setState(() {
        _isFirstlyRefreshing = false;
        _error = error;
        if (error == null) result = response;
      });
      if (error != null) return IndicatorResult.fail;

      context.read<DiscuzNotificationProvider>().setNotificationCount(
        variables.noticeCount,
      );
      if (variables.forumList.isNotEmpty) {
        final fids = variables.forumList.map((forum) => '${forum.fid},').join();
        UserPreferencesUtils.putDiscuzForumFids(discuz, fids);
        UserPreferencesUtils.putDiscuzPortalResultCacheJson(
          discuz,
          jsonEncode(response.toJson()),
        );
        final group = variables.groupInfo;
        if (group.getGroupId() != 0) {
          UserPreferencesUtils.putDiscuzGroupNameById(
            discuz,
            group.getGroupId(),
            group.groupTitle,
          );
        }
      }
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
      return IndicatorResult.success;
    } catch (error) {
      if (!isCurrent()) return IndicatorResult.fail;
      setState(() {
        _isFirstlyRefreshing = false;
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
        } else {
          return SafeArea(
            bottom: false,
            child: PlatformLiquidGlassPageBackdrop(
              child: Column(
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
              ),
            ),
          );
        }
      },
    );
  }

  Widget getEasyRefreshWidget(Discuz discuz, User? user) {
    return EasyRefresh(
      header: EasyRefreshUtils.i18nClassicHeader(context),
      footer: EasyRefreshUtils.i18nClassicFooter(context),
      refreshOnStart: false,
      controller: _controller,
      onRefresh: () => _loadPortalContent(discuz),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: PortalHighlights(
              discuz: discuz,
              user: user,
              refresh: _highlightRefresh,
              knownForums: result.discuzIndexVariables.forumList,
            ),
          ),
          if (favoriteForumDao != null)
            ValueListenableBuilder(
              valueListenable: favoriteForumDao!.favoriteForumBox.listenable(),
              builder: (BuildContext context, value, Widget? child) {
                List<FavoriteForumInDatabase> favoriteForumInDbList =
                    favoriteForumDao!.getFavoriteForumList(
                      discuz,
                      uid: user?.uid ?? 0,
                    );
                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return FavoriteForumCardWidget(
                      discuz,
                      user,
                      favoriteForumInDbList[index],
                    );
                  }, childCount: favoriteForumInDbList.length),
                );
              },
            ),
          if (result.discuzIndexVariables.forumPartitionList.isEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return _isFirstlyRefreshing
                    ? LoadingStateWidget()
                    : EmptyListScreen(EmptyItemType.forum);
              }, childCount: 1),
            ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                List<ForumPartition> forumPartitionList =
                    result.discuzIndexVariables.forumPartitionList;
                List<Forum> _allForumList =
                    result.discuzIndexVariables.forumList;
                ForumPartition forumPartition = forumPartitionList[index];
                //log("Forum partition length ${result!.discuzIndexVariables.forumPartitionList.length} all ${_allForumList.length}" );
                return ForumPartitionWidget(
                  discuz,
                  user,
                  forumPartition,
                  _allForumList,
                );
              },
              childCount: result.discuzIndexVariables.forumPartitionList.length,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => SafeArea(child: Container(), top: false),
              childCount: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class FavoriteForumCardWidget extends StatelessWidget {
  FavoriteForumInDatabase favoriteForumInDatabase;
  Discuz discuz;
  User? user;
  FavoriteForumCardWidget(this.discuz, this.user, this.favoriteForumInDatabase);

  @override
  Widget build(BuildContext context) {
    return PlatformCard(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: PlatformListTile(
        //dense: true,
        leading: isCupertino(context)
            ? Icon(
                PlatformIcons(context).favoriteSolid,
                color: Theme.of(context).colorScheme.primary,
              )
            : null,
        title: Text(
          favoriteForumInDatabase.title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            //fontWeight: FontWeight.bold
          ),
        ),
        onTap: () async {
          VibrationUtils.vibrateWithClickIfPossible();
          await Navigator.push(
            context,
            platformPageRoute(
              context: context,
              iosTitle: favoriteForumInDatabase.title,
              builder: (context) => DisplayForumTwoPanePage(
                discuz,
                user,
                favoriteForumInDatabase.idKey,
              ),
            ),
          );
        },
        trailing: Icon(
          PlatformIcons(context).forward,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
