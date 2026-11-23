import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../JsonResult/ViewThreadResult.dart';
import '../client/ForumInteractionClient.dart';
import '../entity/Discuz.dart';
import '../entity/DiscuzError.dart';
import '../entity/Post.dart';
import '../entity/User.dart';
import '../generated/l10n.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../utility/EasyRefreshUtils.dart';
import '../utility/NetworkUtils.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../utility/discuz_json.dart';
import '../utility/forum_error.dart';
import '../widget/ErrorCard.dart';
import '../widget/UserAvatar.dart';

class RushWinnersPage extends StatefulWidget {
  const RushWinnersPage(this.discuz, this.user, this.tid, {super.key});
  final Discuz discuz;
  final User? user;
  final int tid;

  @override
  State<RushWinnersPage> createState() => _RushWinnersPageState();
}

class _RushWinnersPageState extends State<RushWinnersPage> {
  final _controller = EasyRefreshController();
  final Map<int, Post> _winners = {};
  DiscuzError? _error;
  int _page = 1;
  bool _loading = false, _more = true;
  bool _failedRefresh = false;

  @override
  void initState() {
    super.initState();
    _load(refresh: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<IndicatorResult> _load({bool refresh = false}) async {
    if (_loading) return IndicatorResult.fail;
    if (!refresh && !_more) return IndicatorResult.noMore;
    final account = context.read<DiscuzAndUserNotifier>();
    final session = account.sessionIdentity;
    bool isCurrent() => mounted && identical(account.sessionIdentity, session);
    final requestedPage = refresh ? 1 : _page;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final dio = await NetworkUtils.getDioWithPersistCookieJar(
        widget.user,
        guestForum: widget.discuz.baseURL,
      );
      try {
        if (!isCurrent()) return IndicatorResult.fail;
        final response =
            await ForumInteractionClient(dio, widget.discuz.baseURL).request(
              'viewthread',
              {'tid': widget.tid, 'page': requestedPage, 'checkrush': 1},
            );
        if (!isCurrent()) return IndicatorResult.fail;
        response.requireData('postlist');
        if (discuzInt(response.variables['member_uid']) !=
            (widget.user?.uid ?? 0)) {
          throw const ForumApiException('account_changed', '');
        }
        final variables = ThreadVariables.fromJson(response.variables);
        final posts = variables.postList;
        final pageSize = int.tryParse(variables.ppp) ?? 0;
        setState(() {
          if (refresh) _winners.clear();
          for (final post in posts)
            if (!post.first && post.rewardFloor && post.pid > 0)
              _winners[post.pid] = post;
          _more =
              pageSize > 0 &&
              posts.isNotEmpty &&
              requestedPage * pageSize < variables.threadInfo.replies + 1;
          _page = requestedPage + 1;
        });
        if (refresh) _controller.resetFooter();
        return refresh || _more
            ? IndicatorResult.success
            : IndicatorResult.noMore;
      } finally {
        dio.close();
      }
    } catch (failure) {
      if (isCurrent()) {
        setState(() {
          _error = forumRequestError(S.of(context), failure);
          _failedRefresh = refresh;
        });
      }
      return IndicatorResult.fail;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return PlatformScaffold(
      appBar: PlatformAppBar(title: Text(s.rushWinnerList)),
      iosContentPadding: true,
      body: EasyRefresh(
        controller: _controller,
        header: EasyRefreshUtils.i18nClassicHeader(context),
        footer: EasyRefreshUtils.i18nClassicFooter(context),
        onRefresh: () => _load(refresh: true),
        onLoad: _load,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            for (final winner in _winners.values)
              PlatformListTile(
                leading: UserAvatar(
                  widget.discuz,
                  winner.authorId,
                  winner.author,
                  size: 32,
                ),
                title: Text(winner.author),
                subtitle: Text(
                  '#${winner.position > 0 ? winner.position : winner.number}',
                ),
                trailing: Icon(PlatformIcons(context).forward),
                onTap: () => Navigator.pop(context, winner.pid),
              ),
            if (_error case final failure?)
              ErrorCard(
                failure,
                () => _load(refresh: _failedRefresh),
                largeSize: false,
              )
            else if (_winners.isEmpty && _loading)
              const Center(child: PlatformCircularProgressIndicator())
            else if (_winners.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    _more
                        ? s.easyRefreshClassicFooterDragText
                        : s.rushNoWinners,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
