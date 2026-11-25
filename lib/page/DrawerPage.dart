import 'package:flutter/cupertino.dart' show CupertinoButton, CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../client/forum_community.dart';
import '../dao/UserDao.dart';
import '../database/AppDatabase.dart';
import '../entity/Discuz.dart';
import '../entity/User.dart';
import '../generated/l10n.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../utility/AppPlatformIcons.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../utility/VibrationUtils.dart';
import '../widget/UserAvatar.dart';
import 'BlockUserPage.dart';
import 'FavoriteForumPage.dart';
import 'FavoriteThreadPage.dart';
import 'ForumBoardPickerPage.dart';
import 'ForumGuidePage.dart';
import 'LoginPage.dart';
import 'ManageAccountPage.dart';
import 'ManageDiscuzPage.dart';
import 'ManageTrustHostPage.dart';
import 'SettingPage.dart';
import 'ShortcutPage.dart';
import 'SubscribeChannelPage.dart';
import 'ViewHistoryPage.dart';
import 'draft_inbox_page.dart';
import 'forum_attachment_history_page.dart';
import 'forum_browse_page.dart';
import 'forum_community_page.dart';
import 'forum_feed_filters_page.dart';
import 'forum_web_content_page.dart';
import 'forum_web_pages.dart';

class DrawerPage extends StatefulWidget {
  const DrawerPage({super.key});

  @override
  State<DrawerPage> createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  late Future<UserDao> _users = AppDatabase.getUserDao();
  bool _showAccounts = false;

  void _open(String title, WidgetBuilder builder) {
    VibrationUtils.vibrateWithClickIfPossible();
    pushDetailPage<void>(
      context,
      platformPageRoute(context: context, iosTitle: title, builder: builder),
    );
  }

  void _login(Discuz forum) {
    if (_showAccounts) setState(() => _showAccounts = false);
    _open(S.of(context).loginTitle, (_) => LoginPage(forum, null));
  }

  Widget _menu(BuildContext context, Discuz? forum, User? user) {
    final strings = S.of(context);
    final icons = PlatformIcons(context);
    final appIcons = AppPlatformIcons(context);
    Widget row(String title, IconData icon, VoidCallback onTap) => _DrawerTile(
      title: Text(title),
      leading: Icon(icon),
      trailing: Icon(icons.forward),
      onTap: onTap,
    );
    Widget page(String title, IconData icon, WidgetBuilder builder) =>
        row(title, icon, () => _open(title, builder));

    return ListView(
      key: const PageStorageKey('drawer-menu'),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
      children: [
        if (forum != null)
          _DrawerQuickActions(
            search: () =>
                _open(strings.forumSearchWeb, (_) => ForumSearchPage(forum)),
            post: user == null
                ? null
                : () => _open(
                    strings.postThread,
                    (_) => ForumBoardPickerPage(forum),
                  ),
          ),
        _DrawerSection(
          title: strings.drawerMyContent,
          children: [
            if (forum != null) ...[
              page(
                strings.favoriteThread,
                icons.favoriteSolid,
                (_) => FavoriteThreadPage(),
              ),
              page(
                strings.favoriteForum,
                icons.bookmarkSolid,
                (_) => FavoriteForumPage(),
              ),
            ],
            page(
              strings.draftInbox,
              icons.pick(Icons.drafts_outlined, CupertinoIcons.doc_text),
              (_) => const DraftInboxPage(),
            ),
            if (forum != null) ...[
              page(
                strings.viewHistory,
                icons.timeSolid,
                (_) => ViewHistoryPage(forum),
              ),
              if (user != null) ...[
                row(
                  strings.forumMyActivities,
                  icons.pick(Icons.event_outlined, CupertinoIcons.calendar),
                  () => openCommunity(
                    context,
                    forum,
                    CommunitySection.myActivities,
                  ),
                ),
                row(
                  strings.forumMyParticipation,
                  icons.pick(
                    Icons.how_to_vote_outlined,
                    CupertinoIcons.chart_bar,
                  ),
                  () => openForumParticipation(context, forum),
                ),
              ],
              page(
                strings.attachmentDownloadHistory,
                icons.pick(
                  Icons.download_for_offline_outlined,
                  CupertinoIcons.arrow_down_circle,
                ),
                (_) => ForumAttachmentHistoryPage(forum),
              ),
            ],
          ],
        ),
        if (forum != null)
          _DrawerSection(
            title: strings.drawerBrowseForum,
            children: [
              page(
                strings.forumGuide,
                icons.pick(Icons.explore_outlined, CupertinoIcons.compass),
                (_) => ForumGuidePage(forum),
              ),
              ForumCommunityEntry(
                forum,
                CommunitySection.groups,
                tileBuilder: row,
                key: ValueKey((forum.siteIdentity, CommunitySection.groups)),
              ),
              if (user != null)
                ForumCommunityEntry(
                  forum,
                  CommunitySection.followingFeed,
                  tileBuilder: row,
                  key: ValueKey((
                    forum.siteIdentity,
                    CommunitySection.followingFeed,
                  )),
                ),
              page(
                strings.forumAnnouncements,
                icons.pick(Icons.campaign_outlined, CupertinoIcons.bell),
                (_) => ForumBrowsePage(forum),
              ),
              page(
                strings.shortcut,
                appIcons.shortcutSolid,
                (_) => ShortcutPage(),
              ),
            ],
          ),
        _DrawerSection(
          title: strings.drawerAccountAndForum,
          children: [
            if (forum != null)
              page(
                strings.manageAccount,
                icons.pick(
                  Icons.manage_accounts_outlined,
                  CupertinoIcons.person_crop_circle,
                ),
                (_) => ManageAccountPage(forum),
              ),
            page(
              strings.manageDiscuz,
              icons.folderSolid,
              (_) => ManageDiscuzPage(),
            ),
          ],
        ),
        _DrawerSection(
          title: strings.drawerPreferences,
          children: [
            page(
              strings.settingTitle,
              icons.settingsSolid,
              (_) => SettingPage(),
            ),
            if (forum != null) ...[
              page(
                strings.forumContentFilters,
                icons.pick(
                  Icons.filter_list,
                  CupertinoIcons.line_horizontal_3_decrease,
                ),
                (_) => ForumFeedFiltersPage(forum),
              ),
              page(
                strings.blockedUserList,
                icons.removeCircledSolid,
                (_) => BlockUserPage(forum),
              ),
              page(
                strings.subscribeChannel,
                appIcons.subscribeChannelSolid,
                (_) => SubscribeChannelPage(),
              ),
            ],
            page(
              strings.trustHostTitle,
              icons.checkMarkCircledSolid,
              (_) => ManageTrustHostPage(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _accountList(DiscuzAndUserNotifier account, Discuz forum, User? user) {
    final strings = S.of(context);
    final icons = PlatformIcons(context);
    void select(User? item) {
      VibrationUtils.vibrateWithClickIfPossible();
      account.setUser(item);
      setState(() => _showAccounts = false);
    }

    return FutureBuilder<UserDao>(
      future: _users,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: PlatformTextButton(
              onPressed: () =>
                  setState(() => _users = AppDatabase.getUserDao()),
              child: Text(strings.retry),
            ),
          );
        }
        final dao = snapshot.data;
        if (dao == null) {
          return const Center(child: PlatformCircularProgressIndicator());
        }
        return ValueListenableBuilder(
          valueListenable: dao.userBox.listenable(),
          builder: (context, _, _) {
            final users = dao.findAllUsersByDiscuz(forum);
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
              children: [
                _DrawerSection(
                  title: strings.drawerSwitchAccount,
                  children: [
                    if (user != null) _loginTile(forum),
                    for (final item in users)
                      _DrawerTile(
                        title: Text(item.username),
                        subtitle: Text(strings.userIdTitle(item.uid)),
                        leading: UserAvatar(
                          forum,
                          item.uid,
                          item.username,
                          size: 32,
                        ),
                        trailing: item.uid == user?.uid
                            ? Icon(icons.checkMark)
                            : null,
                        selected: item.uid == user?.uid,
                        onTap: () => select(item),
                      ),
                    _DrawerTile(
                      title: Text(strings.incognitoTitle),
                      leading: const _IncognitoAvatar(),
                      trailing: user == null ? Icon(icons.checkMark) : null,
                      selected: user == null,
                      onTap: () => select(null),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _loginTile(Discuz forum, {Color? color}) {
    final icons = PlatformIcons(context);
    return _DrawerTile(
      title: Text(S.of(context).loginTitle, style: TextStyle(color: color)),
      leading: Icon(icons.personAddSolid, color: color),
      trailing: Icon(icons.forward, color: color),
      onTap: () => _login(forum),
    );
  }

  @override
  Widget build(BuildContext context) {
    final account = context.watch<DiscuzAndUserNotifier>();
    final forum = account.discuz;
    final user = forum == null ? null : account.userFor(forum);
    final strings = S.of(context);
    final colors = Theme.of(context).colorScheme;
    final icons = PlatformIcons(context);
    return PlatformScaffold(
      iosContentPadding: true,
      iosContentBottomPadding: true,
      appBar: PlatformAppBar(title: Text(strings.menuDrawerTitle)),
      body: Column(
        children: [
          if (forum != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: PlatformCard(
                margin: EdgeInsets.zero,
                elevation: 0,
                color: colors.surfaceContainerHigh,
                clipBehavior: Clip.antiAlias,
                semanticContainer: false,
                child: Column(
                  children: [
                    _DrawerTile(
                      leading: user == null
                          ? const _IncognitoAvatar()
                          : UserAvatar(
                              forum,
                              user.uid,
                              user.username,
                              size: 32,
                            ),
                      title: Text(
                        user?.username ?? strings.incognitoTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colors.onSurface),
                      ),
                      subtitle: Text(
                        forum.siteName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                      trailing: Icon(
                        _showAccounts
                            ? icons.pick(
                                Icons.expand_less,
                                CupertinoIcons.chevron_up,
                              )
                            : icons.pick(
                                Icons.expand_more,
                                CupertinoIcons.chevron_down,
                              ),
                        color: colors.onSurfaceVariant,
                        semanticLabel: strings.drawerSwitchAccount,
                      ),
                      onTap: () =>
                          setState(() => _showAccounts = !_showAccounts),
                    ),
                    if (user == null) ...[
                      Divider(
                        height: 1,
                        indent: 14,
                        endIndent: 14,
                        color: colors.outlineVariant,
                      ),
                      _loginTile(forum, color: colors.primary),
                    ],
                  ],
                ),
              ),
            ),
          Expanded(
            child: _showAccounts && forum != null
                ? _accountList(account, forum, user)
                : _menu(context, forum, user),
          ),
        ],
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.title,
    required this.leading,
    required this.onTap,
    this.subtitle,
    this.trailing,
    this.selected = false,
  });

  final Widget title;
  final Widget leading;
  final VoidCallback onTap;
  final Widget? subtitle;
  final Widget? trailing;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return PlatformListTile(
      title: title,
      subtitle: subtitle,
      leading: SizedBox(
        width: 32,
        child: Center(
          widthFactor: 1,
          heightFactor: 1,
          child: IconTheme.merge(
            data: const IconThemeData(size: 22),
            child: leading,
          ),
        ),
      ),
      trailing: trailing == null
          ? null
          : SizedBox(
              width: 18,
              child: Center(
                widthFactor: 1,
                heightFactor: 1,
                child: IconTheme.merge(
                  data: const IconThemeData(size: 16),
                  child: trailing!,
                ),
              ),
            ),
      contentPadding: const EdgeInsetsDirectional.fromSTEB(14, 4, 14, 4),
      selected: selected,
      onTap: onTap,
    );
  }
}

class _DrawerSection extends StatelessWidget {
  const _DrawerSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(4, 0, 4, 6),
            child: Semantics(
              header: true,
              child: Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          PlatformCard(
            margin: EdgeInsets.zero,
            elevation: 0,
            semanticContainer: false,
            clipBehavior: Clip.antiAlias,
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _DrawerQuickActions extends StatelessWidget {
  const _DrawerQuickActions({required this.search, required this.post});

  final VoidCallback search;
  final VoidCallback? post;

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final icons = PlatformIcons(context);
    final colors = Theme.of(context).colorScheme;
    const padding = EdgeInsets.symmetric(horizontal: 12, vertical: 12);
    Widget action(
      String label,
      IconData icon,
      VoidCallback onPressed, {
      bool primary = false,
    }) {
      final content = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 19),
          const SizedBox(width: 8),
          Flexible(child: Text(label, textAlign: TextAlign.center)),
        ],
      );
      if (isCupertino(context)) {
        if (primary) {
          return CupertinoButton.filled(
            onPressed: onPressed,
            color: colors.primary,
            foregroundColor: colors.onPrimary,
            padding: padding,
            minimumSize: const Size(44, 48),
            borderRadius: BorderRadius.circular(24),
            child: content,
          );
        }
        return PlatformTextButton(
          onPressed: onPressed,
          padding: padding,
          child: content,
        );
      }
      return FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: padding,
          backgroundColor: primary
              ? colors.primary
              : colors.surfaceContainerHighest,
          foregroundColor: primary ? colors.onPrimary : colors.onSurface,
        ),
        child: content,
      );
    }

    final searchButton = action(
      strings.forumSearchWeb,
      icons.pick(Icons.search, CupertinoIcons.search),
      search,
    );
    final compose = post;
    if (compose == null) return searchButton;
    final postButton = action(
      strings.postThread,
      icons.pick(Icons.edit_outlined, CupertinoIcons.square_pencil),
      compose,
      primary: true,
    );
    return LayoutBuilder(
      builder: (context, constraints) =>
          constraints.maxWidth < MediaQuery.textScalerOf(context).scale(272)
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [searchButton, postButton],
            )
          : Row(
              spacing: 8,
              children: [
                Expanded(child: searchButton),
                Expanded(child: postButton),
              ],
            ),
    );
  }
}

class _IncognitoAvatar extends StatelessWidget {
  const _IncognitoAvatar();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: 16,
      backgroundColor: colors.secondaryContainer,
      foregroundColor: colors.onSecondaryContainer,
      child: Icon(AppPlatformIcons(context).userIncognitoSolid, size: 18),
    );
  }
}
