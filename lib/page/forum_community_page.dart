import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../client/ForumInteractionClient.dart';
import '../client/discuz_web_client.dart';
import '../client/forum_community.dart';
import '../entity/Discuz.dart';
import '../entity/User.dart';
import '../generated/l10n.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../utility/EasyRefreshUtils.dart';
import '../utility/NetworkUtils.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../utility/forum_error.dart';
import '../widget/ErrorCard.dart';
import '../widget/forum_image.dart';
import '../widget/post_settings_sheet.dart';
import 'DisplayForumSliverPage.dart';
import 'InternalWebviewBrowserPage.dart';
import 'UserProfilePage.dart';
import 'ViewThreadSliverPage.dart';

Future<T> withForumCommunity<T>(
  Discuz forum,
  User? user,
  Future<T> Function(ForumCommunityClient client) use,
) async {
  final dio = await NetworkUtils.getDioWithPersistCookieJar(
    user,
    guestForum: forum.baseURL,
  );
  try {
    return await use(
      ForumCommunityClient(
        DiscuzWebClient(ForumInteractionClient(dio, forum.baseURL)),
      ),
    );
  } finally {
    dio.close();
  }
}

Future<void> openCommunity(
  BuildContext context,
  Discuz forum,
  CommunitySection section, {
  Map<String, String> params = const {},
  String? title,
}) => pushDetailPage<void>(
  context,
  platformPageRoute(
    context: context,
    builder: (_) =>
        ForumCommunityPage(forum, section, params: params, title: title),
  ),
);

String _sectionTitle(S s, CommunitySection section) => switch (section) {
  CommunitySection.groups => s.communityGroups,
  CommunitySection.joinedGroups => s.communityJoinedGroups,
  CommunitySection.managedGroups => s.communityManagedGroups,
  CommunitySection.group => s.communityGroups,
  CommunitySection.groupMembers => s.communityMembers,
  CommunitySection.groupRequests => s.communityGroupRequests,
  CommunitySection.groupSearch => s.communityGroupSearch,
  CommunitySection.followingFeed => s.communityFollowingFeed,
  CommunitySection.following => s.communityFollowing,
  CommunitySection.followers => s.communityFollowers,
  CommunitySection.findUsers => s.communityFindUsers,
  CommunitySection.friendRequests => s.friendRequests,
  CommunitySection.myCollections => s.myForumCollections,
  CommunitySection.allCollections => s.browseForumCollections,
  CommunitySection.collection => s.forumCollections,
  CommunitySection.pendingThreads => s.forumModerationThreads,
  CommunitySection.pendingReplies => s.forumModerationReplies,
  CommunitySection.reports => s.forumModerationReports,
  CommunitySection.tasks => s.forumTasksAvailable,
  CommunitySection.activeTasks => s.forumTasksInProgress,
  CommunitySection.completedTasks => s.forumTasksCompleted,
  CommunitySection.medals => s.forumMedals,
  CommunitySection.myMedals => s.communityMyMedals,
  CommunitySection.rankings => s.communityRankings,
  CommunitySection.portal => s.communityPortal,
  CommunitySection.myActivities => s.forumMyActivities,
};

class ForumCommunityPage extends StatefulWidget {
  const ForumCommunityPage(
    this.forum,
    this.section, {
    this.params = const {},
    this.title,
    super.key,
  });

  final Discuz forum;
  final CommunitySection section;
  final Map<String, String> params;
  final String? title;

  @override
  State<ForumCommunityPage> createState() => _ForumCommunityPageState();
}

class _ForumCommunityPageState extends State<ForumCommunityPage> {
  late final account = context.read<DiscuzAndUserNotifier>();
  late final session = account.sessionIdentity;
  late final user = account.userFor(widget.forum);
  final search = TextEditingController();
  CommunityPageData? data;
  final items = <CommunityItem>[];
  final loadedPages = <Uri>{};
  String keyword = '';
  String activityType = 'orig';
  Map<String, String> get requestParams => {
    ...widget.params,
    if (widget.section == CommunitySection.myActivities && user != null) ...{
      'uid': '${user!.uid}',
      'type': activityType,
    },
  };
  Uri? next;
  Object? error;
  bool mutating = false;
  bool loading = false;
  int generation = 0;

  bool get current => mounted && identical(session, account.sessionIdentity);

  @override
  void initState() {
    super.initState();
    if (!widget.section.searchable) _load();
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  Future<IndicatorResult> _load({bool more = false}) async {
    if (!current ||
        (widget.section.searchable && keyword.isEmpty) ||
        (more && loading)) {
      return IndicatorResult.none;
    }
    final target = more ? next : null;
    if (more && target == null) return IndicatorResult.noMore;
    final ticket = ++generation;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final result = await withForumCommunity(
        widget.forum,
        user,
        (client) => client.load(
          widget.section,
          requestParams,
          next: target,
          keyword: keyword,
        ),
      );
      if (!current || generation != ticket) return IndicatorResult.fail;
      setState(() {
        data = result;
        if (!more) {
          items.clear();
          loadedPages.clear();
        }
        if (target != null) loadedPages.add(target);
        final seen = items.map((item) => item.uri).toSet();
        for (final item in result.items) {
          if (item.kind == CommunityTarget.web &&
                  widget.section == CommunitySection.medals ||
              item.kind == CommunityTarget.web &&
                  widget.section == CommunitySection.myMedals ||
              seen.add(item.uri)) {
            items.add(item);
          }
        }
        next = loadedPages.contains(result.next) ? null : result.next;
        loading = false;
      });
      return next == null && more
          ? IndicatorResult.noMore
          : IndicatorResult.success;
    } catch (failure) {
      if (current && generation == ticket) {
        setState(() {
          loading = false;
          error = failure;
        });
      }
      return IndicatorResult.fail;
    }
  }

  Uri _website([String? file, Map<String, String> params = const {}]) =>
      Uri.parse(widget.forum.getBaseURLWithAfterfix())
          .resolve(file ?? widget.section.file)
          .replace(
            queryParameters: {
              if (file == null) ...widget.section.query,
              if (file == null) ...requestParams,
              if (file == null &&
                  keyword.isNotEmpty &&
                  widget.section == CommunitySection.findUsers) ...{
                'username': keyword,
                'searchsubmit': 'yes',
              },
              if (file == null &&
                  keyword.isNotEmpty &&
                  widget.section == CommunitySection.groupSearch)
                'srchtxt': keyword,
              ...params,
              'mobile': 'no',
            },
          );

  Future<void> _web(Uri uri) => pushDetailPage<void>(
    context,
    platformPageRoute(
      context: context,
      builder: (_) =>
          InternalWebviewBrowserPage(widget.forum, user, uri.toString()),
    ),
  );

  Future<void> _open(CommunityItem row) async {
    if (!current) return;
    final forum = widget.forum;
    switch (row.kind) {
      case CommunityTarget.group:
        await openCommunity(
          context,
          forum,
          CommunitySection.group,
          title: row.title,
          params: {'fid': '${row.id}'},
        );
      case CommunityTarget.groupCategory:
        await openCommunity(
          context,
          forum,
          CommunitySection.groups,
          title: row.title,
          params: {
            'gid': ?row.uri.queryParameters['gid'],
            'sgid': ?row.uri.queryParameters['sgid'],
          },
        );
      case CommunityTarget.ranking:
        await openCommunity(
          context,
          forum,
          CommunitySection.rankings,
          title: row.title,
          params: {
            for (final key in ['type', 'view', 'orderby'])
              key: ?row.uri.queryParameters[key],
          },
        );
      case CommunityTarget.collection:
        await openCommunity(
          context,
          forum,
          CommunitySection.collection,
          title: row.title,
          params: {'ctid': '${row.id}'},
        );
      case CommunityTarget.person:
        await pushDetailPage<void>(
          context,
          platformPageRoute(
            context: context,
            builder: (_) =>
                UserProfilePage(forum, user, row.id!, username: row.title),
          ),
        );
      case CommunityTarget.thread:
        if (row.uri.queryParameters.containsKey('modthreadkey')) {
          await _web(row.uri);
          return;
        }
        await pushDetailPage<void>(
          context,
          platformPageRoute(
            context: context,
            builder: (_) => ViewThreadSliverPage(
              forum,
              user,
              row.id!,
              passedSubject: row.title,
              initialPid: row.post,
            ),
          ),
        );
      case CommunityTarget.portalCategory:
        await openCommunity(
          context,
          forum,
          CommunitySection.portal,
          title: row.title,
          params: {'mod': 'list', 'catid': '${row.id}'},
        );
      case CommunityTarget.article:
      case CommunityTarget.web:
        await _web(row.uri);
    }
  }

  Future<void> _mutate(
    String title,
    Future<void> Function(ForumCommunityClient, User) apply,
  ) async {
    final member = user;
    if (member == null || !current || mutating) return;
    final confirmed = await _confirmCommunity(context, title);
    if (!current || confirmed != true || mutating) return;
    setState(() => mutating = true);
    try {
      await withForumCommunity(
        widget.forum,
        member,
        (client) => apply(client, member),
      );
    } catch (failure) {
      if (mounted && current) {
        await _communityAlert(
          context,
          title,
          forumRequestError(S.of(context), failure).content,
        );
      }
    } finally {
      if (current) {
        setState(() => mutating = false);
        await _load();
      }
    }
  }

  Widget _section(
    CommunitySection section, {
    Map<String, String> params = const {},
  }) => PlatformListTile(
    title: Text(_sectionTitle(S.of(context), section)),
    trailing: Icon(PlatformIcons(context).forward, size: 17),
    onTap: () => openCommunity(context, widget.forum, section, params: params),
  );

  List<Widget> _links(CommunityPageData? page) {
    final s = S.of(context);
    final fid = int.tryParse(widget.params['fid'] ?? '');
    return [
      if (widget.section == CommunitySection.groups &&
          widget.params.isEmpty) ...[
        if (user != null) ...[
          _section(CommunitySection.joinedGroups),
          _section(CommunitySection.managedGroups),
          ForumCommunityEntry(widget.forum, CommunitySection.groupSearch),
        ],
        if (page?.canCreate == true)
          PlatformListTile(
            title: Text(s.communityCreateGroup),
            onTap: () => _web(
              _website('forum.php', {'mod': 'group', 'action': 'create'}),
            ),
          ),
      ],
      if (widget.section == CommunitySection.group &&
          page != null &&
          fid != null) ...[
        if (page.detail case final description? when description.isNotEmpty)
          Padding(padding: const EdgeInsets.all(14), child: Text(description)),
        if (page.groupStatus case final status? when status.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Text(status),
          ),
        if (page.canReadGroup) ...[
          PlatformListTile(
            title: Text(s.communityGroupThreads),
            trailing: Icon(PlatformIcons(context).forward, size: 17),
            onTap: () => pushDetailPage<void>(
              context,
              platformPageRoute(
                context: context,
                builder: (_) => DisplayForumSliverPage(
                  widget.forum,
                  user,
                  fid,
                  forumTitle: widget.title ?? page.title,
                ),
              ),
            ),
          ),
          _section(CommunitySection.groupMembers, params: {'fid': '$fid'}),
        ],
        if (user != null && (page.canJoin || page.canLeave))
          PlatformListTile(
            title: Text(
              page.canLeave ? s.communityLeaveGroup : s.communityJoinGroup,
            ),
            onTap: mutating
                ? null
                : () => _mutate(
                    page.canLeave
                        ? s.communityLeaveGroup
                        : s.communityJoinGroup,
                    (client, member) => client.changeGroup(
                      member.uid,
                      fid,
                      !page.canLeave,
                      () => current,
                    ),
                  ),
          ),
        if (page.canManage) ...[
          _section(CommunitySection.groupRequests, params: {'fid': '$fid'}),
          PlatformListTile(
            title: Text(s.communityManageGroup),
            onTap: () => _web(
              _website('forum.php', {
                'mod': 'group',
                'action': 'manage',
                'fid': '$fid',
              }),
            ),
          ),
        ],
      ],
      if (widget.section == CommunitySection.followingFeed && page != null) ...[
        _section(CommunitySection.following),
        _section(CommunitySection.followers),
      ],
      if (widget.section == CommunitySection.tasks) ...[
        _section(CommunitySection.activeTasks),
        _section(CommunitySection.completedTasks),
      ],
      if (widget.section == CommunitySection.medals)
        _section(CommunitySection.myMedals),
      if (widget.section == CommunitySection.myCollections) ...[
        _section(CommunitySection.allCollections),
        PlatformListTile(
          title: Text(s.createForumCollection),
          onTap: () => _web(
            _website('forum.php', {
              'mod': 'collection',
              'action': 'edit',
              'op': 'add',
            }),
          ),
        ),
      ],
      if (widget.section == CommunitySection.pendingThreads && fid != null) ...[
        _section(CommunitySection.pendingReplies, params: {'fid': '$fid'}),
        _section(CommunitySection.reports, params: {'fid': '$fid'}),
        PlatformListTile(
          title: Text(s.forumModerationRecycleBin),
          onTap: () => _web(
            _website('forum.php', {
              'mod': 'modcp',
              'action': 'recyclebin',
              'fid': '$fid',
            }),
          ),
        ),
      ],
    ];
  }

  Widget _row(CommunityItem row) {
    final s = S.of(context);
    final uid = row.id;
    final fid = int.tryParse(widget.params['fid'] ?? '');
    final friend = widget.section == CommunitySection.friendRequests;
    final review =
        widget.section == CommunitySection.groupRequests && fid != null;
    return PlatformCard(
      margin: const EdgeInsets.only(top: 6),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PlatformListTile(
            title: Text(row.title),
            subtitle: row.detail == null ? null : Text(row.detail!),
            trailing: Icon(PlatformIcons(context).forward, size: 17),
            onTap: () => _open(row),
          ),
          if (uid != null && user != null && (friend || review))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                children: [
                  PlatformTextButton(
                    onPressed: mutating
                        ? null
                        : () => _mutate(
                            s.communityIgnore,
                            (client, member) => friend
                                ? client.ignoreFriend(
                                    member.uid,
                                    uid,
                                    () => current,
                                  )
                                : client.reviewGroup(
                                    member.uid,
                                    fid!,
                                    uid,
                                    false,
                                    () => current,
                                  ),
                          ),
                    child: Text(s.communityIgnore),
                  ),
                  PlatformTextButton(
                    onPressed: mutating
                        ? null
                        : () => _mutate(
                            s.communityAccept,
                            (client, member) => friend
                                ? client.friend(
                                    member.uid,
                                    uid,
                                    accept: true,
                                    current: () => current,
                                  )
                                : client.reviewGroup(
                                    member.uid,
                                    fid!,
                                    uid,
                                    true,
                                    () => current,
                                  ),
                          ),
                    child: Text(s.communityAccept),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<DiscuzAndUserNotifier>();
    final s = S.of(context);
    final page = data;
    final links = _links(page);
    final failure = error;
    final needsQuery = widget.section.searchable && keyword.isEmpty;
    return PlatformScaffold(
      iosContentPadding: true,
      appBar: PlatformAppBar(
        title: Text(
          widget.title ??
              (widget.section != CommunitySection.myActivities &&
                      page?.title.isNotEmpty == true
                  ? page!.title
                  : _sectionTitle(s, widget.section)),
        ),
      ),
      body: PlatformLiquidGlassPageBackdrop(
        child: !current
            ? Center(child: Text(s.forumAccountChanged))
            : EasyRefresh(
                header: EasyRefreshUtils.i18nClassicHeader(context),
                footer: EasyRefreshUtils.i18nClassicFooter(context),
                onRefresh: _load,
                onLoad: next == null ? null : () => _load(more: true),
                child: CustomScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                      sliver: SliverList.list(
                        children: [
                          if (widget.section == CommunitySection.myActivities)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: PlatformSegmentedControl(
                                selectedIndex: activityType == 'orig' ? 0 : 1,
                                labels: [
                                  s.forumActivitiesOrganized,
                                  s.forumActivitiesJoined,
                                ],
                                onValueChanged: (index) {
                                  final value = index == 0 ? 'orig' : 'apply';
                                  if (value == activityType || !current) return;
                                  setState(() {
                                    activityType = value;
                                    data = null;
                                    items.clear();
                                    next = null;
                                  });
                                  _load();
                                },
                              ),
                            ),
                          if (widget.section.searchable) ...[
                            PlatformTextField(
                              controller: search,
                              hintText: s.searchKeywordHint,
                              textInputAction: TextInputAction.search,
                              onSubmitted: (_) => _search(),
                            ),
                            Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: PlatformTextButton(
                                onPressed: _search,
                                child: Text(s.searchSubmit),
                              ),
                            ),
                          ],
                          if (page?.image case final image?)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight: 180,
                                ),
                                child: ForumImage(
                                  forum: widget.forum,
                                  url: image.toString(),
                                  fit: BoxFit.contain,
                                  loading: (_, value) => Center(
                                    child: PlatformCircularProgressIndicator(
                                      value: value,
                                    ),
                                  ),
                                  error: (_) => const SizedBox.shrink(),
                                ),
                              ),
                            ),
                          if (links.isNotEmpty)
                            PlatformCard(child: Column(children: links)),
                          if (failure != null)
                            ErrorCard(
                              forumRequestError(s, failure),
                              _load,
                              largeSize: false,
                            )
                          else if (page == null && !needsQuery)
                            const Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(
                                child: PlatformCircularProgressIndicator(),
                              ),
                            )
                          else if (page != null &&
                              items.isEmpty &&
                              links.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Center(child: Text(s.forumEmpty)),
                            ),
                        ],
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      sliver: SliverList.builder(
                        itemCount: items.length,
                        itemBuilder: (_, index) => _row(items[index]),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Center(
                        child: PlatformTextButton(
                          onPressed: () => _web(_website()),
                          child: Text(s.navigateToWebPage),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _search() {
    final query = search.text.trim();
    if (query.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      keyword = query;
      items.clear();
      data = null;
      next = null;
    });
    _load();
  }
}

Future<bool?> _confirmCommunity(BuildContext context, String title) =>
    showPostSettingsSheet<bool>(
      context,
      (sheet) => PostSettingsSheet(
        title: title,
        children: [
          PlatformListTile(
            title: Text(S.of(sheet).cancel),
            onTap: () => Navigator.of(sheet).pop(false),
          ),
          PlatformListTile(
            title: Text(S.of(sheet).forumConfirm),
            onTap: () => Navigator.of(sheet).pop(true),
          ),
        ],
      ),
    );

class ForumRelationshipActions extends StatefulWidget {
  const ForumRelationshipActions(
    this.forum,
    this.viewer,
    this.uid, {
    super.key,
  });
  final Discuz forum;
  final User viewer;
  final int uid;

  @override
  State<ForumRelationshipActions> createState() =>
      _ForumRelationshipActionsState();
}

class _ForumRelationshipActionsState extends State<ForumRelationshipActions> {
  late final account = context.read<DiscuzAndUserNotifier>();
  late final session = account.sessionIdentity;
  bool? following;
  bool busy = false;
  bool sent = false;

  bool get current => mounted && identical(session, account.sessionIdentity);

  @override
  void initState() {
    super.initState();
    _readFollow();
  }

  Future<void> _readFollow() async {
    try {
      final status = await withForumCommunity(
        widget.forum,
        widget.viewer,
        (client) => client.followStatus(widget.uid),
      );
      if (current) setState(() => following = status);
    } catch (_) {
      if (current) setState(() => following = null);
    }
  }

  Future<void> _action(bool isFollow) async {
    if (!current || busy) return;
    final s = S.of(context);
    final status = following;
    if (isFollow && status == null) return;
    final title = isFollow
        ? (status! ? s.communityUnfollowUser : s.communityFollowUser)
        : s.friendRequest;
    final confirmed = await _confirmCommunity(context, title);
    if (!current || confirmed != true || busy) return;
    setState(() => busy = true);
    try {
      await withForumCommunity(
        widget.forum,
        widget.viewer,
        (client) => isFollow
            ? client.follow(
                widget.viewer.uid,
                widget.uid,
                status!,
                () => current,
              )
            : client.friend(
                widget.viewer.uid,
                widget.uid,
                accept: false,
                current: () => current,
              ),
      );
      if (!current) return;
      if (isFollow) {
        await _readFollow();
      } else {
        setState(() => sent = true);
      }
    } catch (failure) {
      if (mounted && current) {
        await _communityAlert(
          context,
          title,
          forumRequestError(s, failure).content,
        );
      }
    } finally {
      if (current) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        if (following case final status?)
          PlatformTextButton(
            onPressed: busy ? null : () => _action(true),
            child: Text(
              status ? s.communityUnfollowUser : s.communityFollowUser,
            ),
          ),
        PlatformTextButton(
          onPressed: sent || busy ? null : () => _action(false),
          child: Text(sent ? s.communityFriendSent : s.friendRequest),
        ),
      ],
    );
  }
}

class ForumCommunityEntry extends StatefulWidget {
  const ForumCommunityEntry(this.forum, this.section, {super.key});
  final Discuz forum;
  final CommunitySection section;

  @override
  State<ForumCommunityEntry> createState() => _ForumCommunityEntryState();
}

class _ForumCommunityEntryState extends State<ForumCommunityEntry> {
  Object? session;
  Future<bool>? available;

  @override
  Widget build(BuildContext context) {
    final account = context.watch<DiscuzAndUserNotifier>();
    final user = account.userFor(widget.forum);
    if (widget.section == CommunitySection.followingFeed && user == null) {
      return const SizedBox.shrink();
    }
    if (!identical(session, account.sessionIdentity)) {
      session = account.sessionIdentity;
      available = withForumCommunity(widget.forum, user, (client) async {
        final page = await client.load(widget.section, const {});
        return widget.section != CommunitySection.portal ||
            page.items.isNotEmpty;
      }).catchError((Object _) => false);
    }
    final icons = PlatformIcons(context);
    return FutureBuilder<bool>(
      key: ValueKey(session),
      future: available,
      builder: (context, snapshot) {
        if (snapshot.data != true) return const SizedBox.shrink();
        return PlatformListTile(
          title: Text(_sectionTitle(S.of(context), widget.section)),
          leading: Icon(switch (widget.section) {
            CommunitySection.groups => icons.groupSolid,
            CommunitySection.groupSearch => icons.pick(
              Icons.search,
              CupertinoIcons.search,
            ),
            CommunitySection.followingFeed => icons.pick(
              Icons.dynamic_feed_outlined,
              CupertinoIcons.person_crop_circle,
            ),
            CommunitySection.rankings => icons.pick(
              Icons.leaderboard_outlined,
              CupertinoIcons.chart_bar,
            ),
            CommunitySection.portal => icons.pick(
              Icons.article_outlined,
              CupertinoIcons.news,
            ),
            _ => icons.forward,
          }),
          trailing: Icon(icons.forward, size: 17),
          onTap: () => openCommunity(context, widget.forum, widget.section),
        );
      },
    );
  }
}

Future<void> copyForumRss(BuildContext context, Discuz forum, int fid) async {
  final account = context.read<DiscuzAndUserNotifier>();
  final session = account.sessionIdentity;
  final s = S.of(context);
  try {
    final link = await withForumCommunity(
      forum,
      null,
      (client) => client.rssLink(fid),
    );
    if (!context.mounted || !identical(session, account.sessionIdentity)) {
      return;
    }
    if (link == null) {
      await _communityAlert(context, s.communityRss, s.forumApiUnavailable);
      return;
    }
    await Clipboard.setData(ClipboardData(text: link.toString()));
    if (context.mounted && identical(session, account.sessionIdentity)) {
      await _communityAlert(context, s.communityRssCopied);
    }
  } catch (failure) {
    if (!context.mounted || !identical(session, account.sessionIdentity)) {
      return;
    }
    await _communityAlert(
      context,
      s.communityRss,
      forumRequestError(s, failure).content,
    );
  }
}

Future<void> _communityAlert(
  BuildContext context,
  String title, [
  String? message,
]) => showPlatformAlert(
  context: context,
  title: title,
  message: message,
  actions: [
    PlatformAlertAction(
      label: S.of(context).forumConfirm,
      isDefaultAction: true,
    ),
  ],
);
