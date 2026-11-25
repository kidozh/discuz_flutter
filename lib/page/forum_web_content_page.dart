import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../client/ForumInteractionClient.dart';
import '../client/discuz_web_client.dart';
import '../client/forum_web_content.dart';
import '../entity/Discuz.dart';
import '../generated/l10n.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../utility/EasyRefreshUtils.dart';
import '../utility/NetworkUtils.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../utility/forum_error.dart';
import '../widget/DiscuzHtmlWidget.dart';
import '../widget/ErrorCard.dart';
import '../widget/forum_image.dart';
import 'InternalWebviewBrowserPage.dart';
import 'ViewThreadSliverPage.dart';
import 'post_edit_page.dart';

Future<void> openForumContent(
  BuildContext context,
  Discuz forum,
  ForumContentKind kind, {
  int id = 0,
  int pid = 0,
}) => pushDetailPage<void>(
  context,
  platformPageRoute(
    context: context,
    builder: (_) => ForumWebContentPage(forum, kind, id: id, pid: pid),
  ),
);

class ForumWebContentPage extends StatefulWidget {
  const ForumWebContentPage(
    this.forum,
    this.kind, {
    super.key,
    required this.id,
    this.pid = 0,
  });

  final Discuz forum;
  final ForumContentKind kind;
  final int id, pid;

  @override
  State<ForumWebContentPage> createState() => _ForumWebContentPageState();
}

class _ForumWebContentPageState extends State<ForumWebContentPage> {
  late final account = context.read<DiscuzAndUserNotifier>();
  late final session = account.sessionIdentity;
  late final user = account.userFor(widget.forum);
  final controller = EasyRefreshController();
  final scroll = ScrollController();
  late ForumContentKind kind = widget.kind;
  ForumWebContent? content;
  Uri? next;
  Object? failure;
  int selected = 0, generation = 0;
  bool loading = true, opening = false;
  final rows = <ForumContentItem>[];

  bool get current => mounted && identical(session, account.sessionIdentity);

  bool get personal => {
    ForumContentKind.drafts,
    ForumContentKind.polls,
    ForumContentKind.debates,
    ForumContentKind.rewards,
    ForumContentKind.trades,
    ForumContentKind.buyers,
  }.contains(kind);

  String? get filter => switch (kind) {
    ForumContentKind.polls => selected == 0 ? 'publish' : 'join',
    ForumContentKind.debates => selected == 0 ? 'orig' : 'reply',
    ForumContentKind.rewards => ['0', '1', '-1'][selected],
    ForumContentKind.trades => selected == 0 ? 'sell' : 'buy',
    _ => null,
  };

  String title(S s) => switch (kind) {
    ForumContentKind.memberThreads ||
    ForumContentKind.memberReplies => s.forumMemberContent,
    ForumContentKind.polls => s.forumMyPolls,
    ForumContentKind.debates => s.forumMyDebates,
    ForumContentKind.rewards => s.forumMyRewards,
    ForumContentKind.drafts => s.myContentServerDrafts,
    ForumContentKind.article => s.communityPortal,
    ForumContentKind.articleComments => s.portalArticleComments,
    ForumContentKind.relatedThreads => s.forumRelatedThreads,
    ForumContentKind.moderation => s.threadModerationHistory,
    ForumContentKind.buyers => s.threadBuyerHistory,
    ForumContentKind.trades => s.forumMyTrades,
    ForumContentKind.tradeItem => s.tradeItems,
  };

  List<String> tabs(S s) => switch (kind) {
    ForumContentKind.memberThreads ||
    ForumContentKind.memberReplies => [s.userThread, s.userPost],
    ForumContentKind.polls || ForumContentKind.debates => [
      s.forumActivitiesOrganized,
      s.forumContentJoined,
    ],
    ForumContentKind.rewards => [
      s.forumAll,
      s.forumRewardOpen,
      s.forumRewardResolved,
    ],
    ForumContentKind.trades => [s.forumTradeSold, s.forumTradeBought],
    _ => const [],
  };

  Uri get target => ForumWebContentClient.targetFor(
    Uri.parse(widget.forum.getBaseURLWithAfterfix()),
    kind,
    id: widget.id > 0 ? widget.id : user?.uid ?? 0,
    pid: widget.pid,
    filter: filter,
  );

  @override
  void initState() {
    super.initState();
    final _ = session;
    selected = kind == ForumContentKind.memberReplies ? 1 : 0;
    Future.microtask(load);
  }

  @override
  void dispose() {
    controller.dispose();
    scroll.dispose();
    super.dispose();
  }

  Future<T> request<T>(Future<T> Function(ForumWebContentClient) action) async {
    final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    try {
      if (!current || (personal && user == null)) {
        throw const ForumApiException('not_loggedin', '', fromForum: true);
      }
      return await action(
        ForumWebContentClient(
          DiscuzWebClient(ForumInteractionClient(dio, widget.forum.baseURL)),
        ),
      );
    } finally {
      dio.close();
    }
  }

  Future<IndicatorResult> load({bool more = false}) async {
    if (!current || (more && (loading || next == null)))
      return IndicatorResult.none;
    final ticket = ++generation;
    final section = kind;
    final url = target;
    final cursor = more ? next : null;
    setState(() {
      failure = null;
      loading = true;
    });
    try {
      final data = await request(
        (client) => client.read(section, url, next: cursor),
      );
      if (!current || ticket != generation) return IndicatorResult.fail;
      setState(() {
        if (!more || section == ForumContentKind.article) {
          rows.clear();
          content = data;
        }
        final seen = rows.toSet();
        rows.addAll(data.items.where(seen.add));
        next = data.next;
        loading = false;
      });
      if (more && section == ForumContentKind.article && scroll.hasClients) {
        scroll.jumpTo(0);
      }
      return next == null && more
          ? IndicatorResult.noMore
          : IndicatorResult.success;
    } catch (error) {
      if (current && ticket == generation) {
        setState(() {
          failure = error;
          loading = false;
        });
      }
      return IndicatorResult.fail;
    }
  }

  void changeTab(int index) {
    if (index == selected) return;
    setState(() {
      selected = index;
      if (kind == ForumContentKind.memberThreads ||
          kind == ForumContentKind.memberReplies) {
        kind = index == 0
            ? ForumContentKind.memberThreads
            : ForumContentKind.memberReplies;
      }
      content = null;
      next = null;
      rows.clear();
    });
    controller.resetFooter();
    load();
  }

  Future<void> website([Uri? url]) async {
    if (!current) return;
    await pushDetailPage<void>(
      context,
      platformPageRoute(
        context: context,
        builder: (_) => InternalWebviewBrowserPage(
          widget.forum,
          user,
          (url ?? target).toString(),
        ),
      ),
    );
    if (current && kind == ForumContentKind.drafts) await load();
  }

  Future<void> openItem(ForumContentItem item) async {
    if (!current || opening) return;
    if (item.article case final id?) {
      await openForumContent(
        context,
        widget.forum,
        ForumContentKind.article,
        id: id,
      );
    } else if (item.thread case final link?) {
      if (kind == ForumContentKind.drafts && user != null && item.fid != null) {
        setState(() {
          opening = true;
          failure = null;
        });
        try {
          final pid = await request(
            (client) => client.draftPid(user!.uid, item.fid!, link.tid),
          );
          if (!mounted || !current) return;
          await pushDetailPage<bool>(
            context,
            platformPageRoute(
              context: context,
              builder: (_) => PostEditPage(
                widget.forum,
                user!,
                item.fid!,
                link.tid,
                pid,
                serverDraft: true,
              ),
            ),
          );
          if (current) await load();
        } catch (error) {
          if (current) setState(() => failure = error);
        } finally {
          if (current) setState(() => opening = false);
        }
      } else {
        await pushDetailPage<void>(
          context,
          platformPageRoute(
            context: context,
            builder: (_) => ViewThreadSliverPage(
              widget.forum,
              user,
              link.tid,
              initialPid: link.pid,
              passedSubject: item.title,
            ),
          ),
        );
      }
    } else if (item.link case final link?) {
      await website(link);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<DiscuzAndUserNotifier>();
    final s = S.of(context);
    final icons = PlatformIcons(context);
    final sections = tabs(s);
    final value = content;
    final article = kind == ForumContentKind.article;
    return PlatformScaffold(
      iosContentPadding: true,
      iosContentBottomPadding: true,
      appBar: PlatformAppBar(
        title: Text(title(s)),
        trailingActions: [
          PlatformIconButton(
            liquidGlassSymbol: 'safari',
            icon: Icon(
              icons.pick(Icons.open_in_browser, CupertinoIcons.compass),
              semanticLabel: s.navigateToWebPage,
            ),
            onPressed: current ? () => website() : null,
          ),
        ],
      ),
      body: PlatformLiquidGlassPageBackdrop(
        child: !current
            ? Center(child: Text(s.forumAccountChanged))
            : Column(
                children: [
                  if (sections.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: PlatformSegmentedControl(
                        labels: sections,
                        selectedIndex: selected,
                        onValueChanged: changeTab,
                      ),
                    ),
                  Expanded(
                    child: EasyRefresh(
                      controller: controller,
                      header: EasyRefreshUtils.i18nClassicHeader(context),
                      footer: EasyRefreshUtils.i18nClassicFooter(context),
                      onRefresh: load,
                      onLoad: next == null || article
                          ? null
                          : () => load(more: true),
                      child: ListView(
                        controller: scroll,
                        padding: const EdgeInsets.all(16),
                        children: [
                          if (failure case final error?)
                            ErrorCard(
                              forumRequestError(s, error),
                              () => load(more: value != null && next != null),
                              largeSize: false,
                            ),
                          if (opening || (loading && value == null))
                            const Center(
                              child: PlatformCircularProgressIndicator(),
                            ),
                          if (value != null) ...[
                            if (value.title.isNotEmpty)
                              Text(
                                value.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall,
                              ),
                            if (value.detail.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  value.detail,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            if (value.image case final uri?)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxHeight: 280,
                                  ),
                                  child: ForumImage(
                                    forum: widget.forum,
                                    url: uri.toString(),
                                    fit: BoxFit.contain,
                                    error: (_) => const SizedBox.shrink(),
                                    loading: (_, value) =>
                                        PlatformCircularProgressIndicator(
                                          material: (_, _) =>
                                              MaterialProgressIndicatorData(
                                                value: value,
                                              ),
                                        ),
                                  ),
                                ),
                              ),
                            if (value.body.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: DiscuzHtmlWidget(
                                  widget.forum,
                                  value.body,
                                ),
                              ),
                            if (article && next != null)
                              PlatformTextButton(
                                onPressed: loading
                                    ? null
                                    : () => load(more: true),
                                child: Text(s.loadMore),
                              ),
                            if (article && rows.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Text(
                                  s.portalArticleComments,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                              ),
                            if (rows.isNotEmpty)
                              PlatformCard(
                                semanticContainer: false,
                                margin: EdgeInsets.zero,
                                child: Column(
                                  children: [
                                    for (final item in rows)
                                      PlatformListTile(
                                        title: Text(
                                          item.title.isEmpty
                                              ? s.portalAnonymousComment
                                              : item.title,
                                        ),
                                        subtitle: item.detail.isEmpty
                                            ? null
                                            : Text(item.detail),
                                        isThreeLine: item.detail.isNotEmpty,
                                        trailing:
                                            item.thread == null &&
                                                item.article == null &&
                                                item.link == null
                                            ? null
                                            : Icon(icons.forward, size: 16),
                                        onTap:
                                            !opening &&
                                                (item.thread != null ||
                                                    item.article != null ||
                                                    item.link != null)
                                            ? () => openItem(item)
                                            : null,
                                      ),
                                  ],
                                ),
                              )
                            else if (value.body.isEmpty)
                              Center(child: Text(s.forumEmpty)),
                            if (value.relatedArticles.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Text(
                                  s.portalRelatedArticles,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                              ),
                              PlatformCard(
                                semanticContainer: false,
                                margin: EdgeInsets.zero,
                                child: Column(
                                  children: [
                                    for (final item in value.relatedArticles)
                                      PlatformListTile(
                                        title: Text(item.title),
                                        trailing: Icon(icons.forward, size: 16),
                                        onTap: () => openItem(item),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                            if (value.comments != null)
                              PlatformTextButton(
                                onPressed: () => openForumContent(
                                  context,
                                  widget.forum,
                                  ForumContentKind.articleComments,
                                  id: widget.id,
                                ),
                                child: Text(s.portalAllComments),
                              ),
                            if (kind == ForumContentKind.tradeItem ||
                                kind == ForumContentKind.articleComments)
                              PlatformTextButton(
                                onPressed: () => website(),
                                child: Text(s.navigateToWebPage),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

Future<void> openForumParticipation(BuildContext context, Discuz forum) =>
    pushDetailPage<void>(
      context,
      platformPageRoute(
        context: context,
        builder: (route) {
          final s = S.of(route);
          final icons = PlatformIcons(route);
          return PlatformScaffold(
            iosContentPadding: true,
            iosContentBottomPadding: true,
            appBar: PlatformAppBar(title: Text(s.forumMyParticipation)),
            body: ListView(
              children: [
                for (final (kind, title, icon) in [
                  (
                    ForumContentKind.polls,
                    s.forumMyPolls,
                    icons.pick(
                      Icons.how_to_vote_outlined,
                      CupertinoIcons.chart_bar,
                    ),
                  ),
                  (
                    ForumContentKind.rewards,
                    s.forumMyRewards,
                    icons.pick(
                      Icons.emoji_events_outlined,
                      CupertinoIcons.star,
                    ),
                  ),
                  (
                    ForumContentKind.debates,
                    s.forumMyDebates,
                    icons.pick(
                      Icons.forum_outlined,
                      CupertinoIcons.bubble_left_bubble_right,
                    ),
                  ),
                  (
                    ForumContentKind.trades,
                    s.forumMyTrades,
                    icons.pick(Icons.shopping_bag_outlined, CupertinoIcons.bag),
                  ),
                ])
                  PlatformListTile(
                    leading: Icon(icon),
                    title: Text(title),
                    trailing: Icon(icons.forward, size: 16),
                    onTap: () => openForumContent(route, forum, kind),
                  ),
              ],
            ),
          );
        },
      ),
    );
