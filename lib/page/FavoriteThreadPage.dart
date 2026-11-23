import 'package:discuz_flutter/JsonResult/FavoriteThreadResult.dart';

import '../client/ForumInteractionClient.dart';
import '../client/favorite_sync.dart';

import 'package:discuz_flutter/dao/FavoriteThreadDao.dart';
import 'package:discuz_flutter/dao/ViewThreadScrollDistanceDao.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/DiscuzError.dart';
import 'package:discuz_flutter/entity/FavoriteThreadInDatabase.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/entity/ViewThreadScrollDistance.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/EmptyListScreen.dart';
import 'package:discuz_flutter/screen/NullDiscuzScreen.dart';
import 'package:discuz_flutter/utility/EasyRefreshUtils.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/TimeDisplayUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/cupertino_separated_item.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'ViewThreadSliverPage.dart';
import '../client/forum_site_features.dart';
import 'forum_feature_links.dart';

class FavoriteThreadPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final account = context.watch<DiscuzAndUserNotifier>();
    final discuz = account.discuz;
    final user = account.user;
    return FutureBuilder<bool>(
      key: ValueKey(account.sessionIdentity),
      future: discuz == null || user == null
          ? null
          : forumFeatureAvailable(
              account.sessionIdentity, discuz, user, ForumSiteFeature.collections,
            ),
      builder: (context, snapshot) => PlatformScaffold(
        iosContentPadding: true,
        appBar: PlatformAppBar(
          liquidGlassTitle: S.of(context).favoriteThread,
          title: Text(S.of(context).favoriteThread),
          trailingActions: [
            if (snapshot.data == true && discuz != null && user != null)
              PlatformIconButton(
                liquidGlassSymbol: 'books.vertical',
                icon: Icon(
                  PlatformIcons(context).collectionsSolid,
                  semanticLabel: S.of(context).forumCollections,
                ),
                onPressed: () => openForumCollections(context, discuz, user),
              ),
          ],
        ),
        body: PlatformLiquidGlassPageBackdrop(
          child: discuz == null
              ? NullDiscuzScreen()
              : FavoriteThreadStatefulWidget(
                  key: ValueKey(account.sessionIdentity),
                  discuz: discuz,
                  user: user,
                ),
        ),
      ),
    );
  }
}

class FavoriteThreadStatefulWidget extends StatefulWidget {
  final Discuz discuz;
  final User? user;

  const FavoriteThreadStatefulWidget({
    required this.discuz,
    this.user,
    super.key,
  });

  @override
  State<FavoriteThreadStatefulWidget> createState() => FavoriteThreadState();
}

class FavoriteThreadState extends State<FavoriteThreadStatefulWidget> {
  final _controller = EasyRefreshController();
  FavoriteThreadDao? _dao;
  ViewThreadScrollDistanceDao? _progressDao;
  DiscuzError? _error;
  bool _syncing = false;
  bool _updatesOnly = false;

  @override
  void initState() {
    super.initState();
    _loadDb();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadDb() async {
    final dao = await AppDatabase.getFavoriteThreadDao();
    final progress = await AppDatabase.getViewThreadScrollDistanceDao();
    if (!mounted) return;
    setState(() {
      _dao = dao;
      _progressDao = progress;
    });
  }

  Future<IndicatorResult> _syncFavorites() async {
    final dao = _dao;
    final user = widget.user;
    final discuz = widget.discuz;
    if (_syncing || dao == null || user == null) return IndicatorResult.fail;
    final account = context.read<DiscuzAndUserNotifier>();
    final session = account.sessionIdentity;
    bool isCurrent() => mounted && identical(session, account.sessionIdentity);
    final before = {
      for (final row in dao.getFavoriteThreadList(discuz, uid: user.uid))
        row.idInServer: row,
    };
    _syncing = true;
    Dio? dio;
    try {
      dio = await NetworkUtils.getDioWithPersistCookieJar(user);
      final favorites = await loadFavoriteSnapshot(
        ForumInteractionClient(dio, discuz.baseURL),
        uid: user.uid,
        threads: true,
        isCurrent: isCurrent,
      );
      final decoded = favorites.map(
        (id, row) => MapEntry(id, FavoriteThread.fromJson(row)),
      );
      for (final entry in decoded.entries) {
        if (!isCurrent()) return IndicatorResult.fail;
        final existing = dao.getFavoriteThreadByTid(
          entry.key,
          discuz,
          uid: user.uid,
        );
        if (!identical(before[entry.key], existing)) continue;
        final updated = entry.value.toDb(discuz)..uid = user.uid;
        if (existing == null) {
          await dao.insertFavoriteThread(updated);
        } else {
          await dao.favoriteThreadBox.put(existing.key, updated);
        }
      }
      for (final old in before.values) {
        if (!isCurrent()) return IndicatorResult.fail;
        if (old.favid >= 0 &&
            !decoded.containsKey(old.idInServer) &&
            identical(dao.favoriteThreadBox.get(old.key), old)) {
          await dao.removeFavoriteThread(old);
        }
      }
      if (!isCurrent()) return IndicatorResult.fail;
      setState(() => _error = null);
      return IndicatorResult.success;
    } catch (error) {
      if (isCurrent()) {
        setState(() => _error = EasyRefreshUtils.requestError(context, error));
      }
      return IndicatorResult.fail;
    } finally {
      dio?.close();
      _syncing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dao = _dao;
    final progressDao = _progressDao;
    if (dao == null || progressDao == null) {
      return const Center(child: PlatformCircularProgressIndicator());
    }
    final discuz = widget.discuz;
    final user = widget.user;
    final strings = S.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
          child: PlatformSegmentedControl(
            labels: [strings.favoriteAllThreads, strings.favoriteHasUpdates],
            selectedIndex: _updatesOnly ? 1 : 0,
            onValueChanged: (index) =>
                setState(() => _updatesOnly = index == 1),
          ),
        ),
        if (_error != null)
          ErrorCard(
            _error!,
            () => _controller.callRefresh(),
            errorType: _error!.errorType,
          ),
        Expanded(
          child: EasyRefresh(
            controller: _controller,
            header: EasyRefreshUtils.i18nClassicHeader(context),
            refreshOnStart: user != null,
            onRefresh: user == null ? null : _syncFavorites,
            child: AnimatedBuilder(
              animation: Listenable.merge([
                dao.favoriteThreadBox.listenable(),
                progressDao.viewThreadScrollDistanceBox.listenable(),
              ]),
              builder: (context, child) {
                final uid = user?.uid ?? 0;
                final favorites =
                    [
                          for (final item in dao.getFavoriteThreadList(
                            discuz,
                            uid: uid,
                          ))
                            (
                              item,
                              progressDao.latestProgress(
                                discuz,
                                uid,
                                item.idInServer,
                              ),
                            ),
                        ]
                        .where(
                          (entry) =>
                              !_updatesOnly ||
                              (entry.$2?.hasUpdates(entry.$1.replies) ?? false),
                        )
                        .toList();
                if (favorites.isEmpty) {
                  return ListView(
                    children: [
                      if (_updatesOnly)
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            strings.favoriteNoUpdates,
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        EmptyListScreen(EmptyItemType.thread),
                    ],
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.only(
                    top: 6,
                    bottom: 6 + MediaQuery.paddingOf(context).bottom,
                  ),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final (favorite, progress) = favorites[index];
                    return FavoriteThreadCardWidget(
                      discuz,
                      user,
                      favorite,
                      progress: progress,
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class FavoriteThreadCardWidget extends StatelessWidget {
  final FavoriteThreadInDatabase favoriteThreadInDatabase;
  final Discuz discuz;
  final User? user;
  final ViewThreadScrollDistance? progress;

  const FavoriteThreadCardWidget(
    this.discuz,
    this.user,
    this.favoriteThreadInDatabase, {
    this.progress,
    super.key,
  });

  Future<void> _open(BuildContext context, {int? pid, bool latest = false}) {
    VibrationUtils.vibrateWithClickIfPossible();
    return pushDetailPage<void>(
      context,
      platformPageRoute(
        context: context,
        iosTitle: favoriteThreadInDatabase.title.length > 12
            ? S.of(context).viewThreadTitle
            : favoriteThreadInDatabase.title,
        builder: (context) => ViewThreadSliverPage(
          discuz,
          user,
          favoriteThreadInDatabase.idInServer,
          passedSubject: favoriteThreadInDatabase.title,
          initialPid: pid,
          openLatestReply: latest,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);
    final actionStyle = theme.brightness == Brightness.dark
        ? TextStyle(color: theme.colorScheme.onSurface)
        : null;
    final hasUpdates =
        progress?.hasUpdates(favoriteThreadInDatabase.replies) ?? false;
    return CupertinoSeparatedItem(
      child: PlatformCard(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PlatformListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              title: Text(
                favoriteThreadInDatabase.title,
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: "",
                      style: DefaultTextStyle.of(context).style,
                      children: <TextSpan>[
                        TextSpan(
                          text: favoriteThreadInDatabase.author,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const TextSpan(text: " · "),
                        TextSpan(
                          text: TimeDisplayUtils.getLocaledTimeDisplay(
                            context,
                            favoriteThreadInDatabase.date,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasUpdates)
                    Text(
                      strings.favoriteHasUpdates,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              trailing: Icon(PlatformIcons(context).forward),
              onTap: () => _open(context),
            ),
            if (progress?.pid != null || favoriteThreadInDatabase.replies > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (progress?.pid case final pid?)
                      PlatformTextButton(
                        onPressed: () => _open(context, pid: pid),
                        semanticLabel: strings.favoriteContinueReading,
                        child: Text(
                          strings.favoriteContinueReading,
                          style: actionStyle,
                        ),
                      ),
                    if (favoriteThreadInDatabase.replies > 0)
                      PlatformTextButton(
                        onPressed: () => _open(context, latest: true),
                        semanticLabel: strings.favoriteLatestReply,
                        child: Text(
                          strings.favoriteLatestReply,
                          style: actionStyle,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
