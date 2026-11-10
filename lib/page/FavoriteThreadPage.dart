import 'package:discuz_flutter/JsonResult/FavoriteThreadResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/dao/FavoriteThreadDao.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/DiscuzError.dart';
import 'package:discuz_flutter/entity/FavoriteThreadInDatabase.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/BlankScreen.dart';
import 'package:discuz_flutter/screen/EmptyListScreen.dart';
import 'package:discuz_flutter/screen/NullDiscuzScreen.dart';
import 'package:discuz_flutter/utility/EasyRefreshUtils.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/TimeDisplayUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/cupertino_separated_item.dart';
import 'package:flutter/material.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'ViewThreadSliverPage.dart';

class FavoriteThreadPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final account = context.watch<DiscuzAndUserNotifier>();
    final discuz = account.discuz;
    return PlatformScaffold(
      iosContentPadding: true,
      iosContentBottomPadding: true,
      appBar: PlatformAppBar(
        liquidGlassTitle: S.of(context).favoriteThread,
        title: Text(S.of(context).favoriteThread),
        // trailingActions: [
        //   PlatformIconButton(
        //     onPressed: () async{
        //       VibrationUtils.vibrateWithClickIfPossible();
        //       // sync information from
        //     },
        //     icon: Icon(Icons.sync),
        //   )
        // ],
      ),
      body: PlatformLiquidGlassPageBackdrop(
        child: discuz == null
            ? NullDiscuzScreen()
            : FavoriteThreadStatefulWidget(
                key: ValueKey(account.sessionIdentity),
                discuz: discuz,
                user: account.user,
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
  DiscuzError? _error;
  bool _syncing = false;

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
    if (mounted) setState(() => _dao = dao);
  }

  Future<IndicatorResult> _syncFavorites() async {
    final dao = _dao;
    final user = widget.user;
    final discuz = widget.discuz;
    if (_syncing || dao == null || user == null) return IndicatorResult.fail;
    final account = context.read<DiscuzAndUserNotifier>();
    final session = account.sessionIdentity;
    bool isCurrent() => mounted && identical(session, account.sessionIdentity);
    _syncing = true;
    try {
      final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
      final client = MobileApiClient(dio, baseUrl: discuz.baseURL);
      final favorites = <int, FavoriteThread>{};
      var page = 1;
      while (isCurrent()) {
        final response = await client.favoriteThreadResult(page++);
        if (!isCurrent()) return IndicatorResult.fail;
        final variables = response.variables;
        final error = EasyRefreshUtils.responseError(
          context,
          response,
          user,
          variables.member_uid,
        );
        if (error != null) {
          setState(() => _error = error);
          return IndicatorResult.fail;
        }
        final previousCount = favorites.length;
        for (final favorite in variables.pmList) {
          favorites[favorite.id] = favorite;
        }
        if (favorites.length >= variables.count || variables.pmList.isEmpty) {
          break;
        }
        if (favorites.length == previousCount) {
          final strings = S.of(context);
          setState(
            () => _error = DiscuzError(strings.error, strings.loadFailed),
          );
          return IndicatorResult.fail;
        }
      }
      for (final favorite in favorites.values) {
        if (!isCurrent()) return IndicatorResult.fail;
        final existing = dao.getFavoriteThreadByTid(
          favorite.id,
          discuz,
          uid: user.uid,
        );
        final updated = favorite.toDb(discuz)..uid = user.uid;
        if (existing == null) {
          await dao.insertFavoriteThread(updated);
        } else {
          await dao.favoriteThreadBox.put(existing.key, updated);
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
      _syncing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dao = _dao;
    if (dao == null) return BlankScreen();
    final discuz = widget.discuz;
    final user = widget.user;
    return Column(
      children: [
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
            child: ValueListenableBuilder(
              valueListenable: dao.favoriteThreadBox.listenable(),
              builder: (context, box, child) {
                final favorites = dao.getFavoriteThreadList(
                  discuz,
                  uid: user?.uid ?? 0,
                );
                if (favorites.isEmpty) {
                  return ListView(
                    children: [EmptyListScreen(EmptyItemType.thread)],
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) =>
                      FavoriteThreadCardWidget(discuz, user, favorites[index]),
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
  FavoriteThreadInDatabase favoriteThreadInDatabase;
  Discuz discuz;
  User? user;
  FavoriteThreadCardWidget(
    this.discuz,
    this.user,
    this.favoriteThreadInDatabase,
  );

  @override
  Widget build(BuildContext context) {
    return CupertinoSeparatedItem(
      child: PlatformCard(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: PlatformListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 6,
          ),
          title: Text(
            favoriteThreadInDatabase.title,
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: RichText(
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
          trailing: Icon(PlatformIcons(context).forward),
          onTap: () async {
            VibrationUtils.vibrateWithClickIfPossible();
            await pushDetailPage(
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
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
