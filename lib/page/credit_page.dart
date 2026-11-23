import '../client/forum_community.dart';
import '../page/forum_community_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../JsonResult/UserProfileResult.dart';
import '../client/ForumInteractionClient.dart';
import '../client/discuz_web_client.dart';
import '../client/forum_web_features.dart';
import '../client/forum_site_features.dart';
import '../entity/Discuz.dart';
import '../entity/DiscuzError.dart';
import '../entity/User.dart';
import '../generated/l10n.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../utility/NetworkUtils.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../utility/forum_error.dart';
import '../widget/ErrorCard.dart';
import 'InternalWebviewBrowserPage.dart';
import 'ViewThreadSliverPage.dart';
import 'forum_feature_links.dart';

class CreditOverviewCard extends StatelessWidget {
  const CreditOverviewCard(
    this.profile, {
    this.onHistory,
    this.showUpgrade = false,
    super.key,
  });

  final UserProfileVariables profile;
  final VoidCallback? onHistory;
  final bool showUpgrade;

  @override
  Widget build(BuildContext context) {
    final space = profile.space;
    if (space == null) return const SizedBox.shrink();
    final strings = S.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final icons = PlatformIcons(context);
    final numbers = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toLanguageTag(),
    );
    final values = [
      space.extcredits1,
      space.extcredits2,
      space.extcredits3,
      space.extcredits4,
      space.extcredits5,
      space.extcredits6,
      space.extcredits7,
      space.extcredits8,
    ];
    return PlatformCard(
      margin: EdgeInsets.zero,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                Row(
                  children: [
                    Icon(
                      icons.credits,
                      color: colors.onSurfaceVariant,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        strings.credit,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        numbers.format(space.credits),
                        textAlign: TextAlign.end,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (space.upgrade case final upgrade? when showUpgrade) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          space.groupInfo.groupTitle,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      Text('${upgrade.percent}%'),
                    ],
                  ),
                  Semantics(
                    label: strings.creditUpgradeRemaining(
                      numbers.format(upgrade.remaining),
                    ),
                    value: '${upgrade.percent}%',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: upgrade.percent / 100,
                        minHeight: 6,
                        backgroundColor: colors.surfaceContainerHighest,
                      ),
                    ),
                  ),
                  Text(
                    strings.creditUpgradeRemaining(
                      numbers.format(upgrade.remaining),
                    ),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
                if (profile.extendCreditMap.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 20,
                      runSpacing: 10,
                      children: [
                        for (final (index, value) in values.indexed)
                          if (profile.extendCreditMap['${index + 1}']
                              case final currency?
                              when currency.title.trim().isNotEmpty)
                            ConstrainedBox(
                              constraints: const BoxConstraints(minWidth: 58),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    currency.title,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    [
                                          numbers.format(value),
                                          currency.unit.trim(),
                                        ]
                                        .where((part) => part.isNotEmpty)
                                        .join(' '),
                                    style: theme.textTheme.titleSmall,
                                  ),
                                ],
                              ),
                            ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (onHistory != null) ...[
            Divider(height: 1, color: colors.outlineVariant),
            MergeSemantics(
              child: PlatformListTile(
                title: Text(strings.creditHistory),
                leading: Icon(icons.chart, size: 20),
                trailing: Icon(
                  icons.pick(
                    Icons.chevron_right,
                    CupertinoIcons.chevron_forward,
                  ),
                  size: 16,
                ),
                onTap: onHistory,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class CreditPage extends StatefulWidget {
  const CreditPage(this.discuz, this.user, this.profile, {super.key});

  final Discuz discuz;
  final User user;
  final UserProfileVariables profile;

  @override
  State<CreditPage> createState() => _CreditPageState();
}

class _CreditPageState extends State<CreditPage> {
  late final DiscuzAndUserNotifier account;
  late final Object session;
  late final Future<List<bool>> _forumExtras;
  final scrollController = ScrollController();
  final entries = <CreditEntry>[];
  Uri? next;
  DiscuzError? error;
  bool busy = true;
  int selectedTab = 0;
  bool get rewards => selectedTab == 1;
  bool get rules => selectedTab == 2;
  int? ruleBoard;
  Map<int, String> ruleBoards = {};
  int requestNumber = 0;

  bool get current =>
      mounted &&
      identical(session, account.sessionIdentity) &&
      account.userFor(widget.discuz)?.uid == widget.user.uid;

  @override
  void initState() {
    super.initState();
    account = context.read<DiscuzAndUserNotifier>();
    session = account.sessionIdentity;
    _forumExtras = Future.wait([
      for (final feature in [ForumSiteFeature.tasks, ForumSiteFeature.medals])
        forumFeatureAvailable(session, widget.discuz, widget.user, feature),
    ]);
    Future.microtask(load);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> load({bool more = false}) async {
    if (!current || (more && (busy || next == null))) return;
    final page = more ? next : null;
    final selectedRewards = rewards;
    final selectedRules = rules;
    final selectedBoard = ruleBoard;
    final request = ++requestNumber;
    bool isActive() => current && request == requestNumber;
    setState(() {
      busy = true;
      error = null;
      if (!more) {
        entries.clear();
        next = null;
      }
    });
    try {
      final dio = await NetworkUtils.getDioWithPersistCookieJar(widget.user);
      try {
        if (!isActive()) return;
        final client = CreditHistoryClient(
          DiscuzWebClient(ForumInteractionClient(dio, widget.discuz.baseURL)),
          widget.user.uid,
        );
        final ruleResult = selectedRules
            ? await client.loadRules(fid: selectedBoard)
            : null;
        final CreditBatch result = ruleResult == null
            ? await client.load(rewards: selectedRewards, next: page)
            : (entries: ruleResult.entries, next: null);
        if (!isActive()) return;
        setState(() {
          entries.addAll(result.entries);
          if (ruleResult != null) ruleBoards = ruleResult.boards;
          next = result.next == page ? null : result.next;
        });
      } finally {
        dio.close();
      }
    } catch (failure) {
      if (isActive()) {
        setState(() => error = forumRequestError(S.of(context), failure));
      }
    } finally {
      if (isActive()) setState(() => busy = false);
    }
  }

  void selectTab(int index) {
    if (index == selectedTab) return;
    selectedTab = index;
    if (scrollController.hasClients) scrollController.jumpTo(0);
    load();
  }

  Future<void> chooseRuleBoard() async {
    final chosen = await showPlatformModalSheet<int>(
      context: context,
      builder: (sheet) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheet).height * 0.6,
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              PlatformListTile(
                title: Text(S.of(sheet).creditGlobalRules),
                onTap: () => Navigator.pop(sheet, 0),
              ),
              for (final board in ruleBoards.entries)
                PlatformListTile(
                  title: Text(board.value),
                  onTap: () => Navigator.pop(sheet, board.key),
                ),
            ],
          ),
        ),
      ),
    );
    if (!current || !rules || chosen == null || chosen == (ruleBoard ?? 0))
      return;
    ruleBoard = chosen == 0 ? null : chosen;
    if (scrollController.hasClients) scrollController.jumpTo(0);
    await load();
  }

  void openWebsite(Uri uri) {
    if (!current) return;
    Navigator.push<void>(
      context,
      platformPageRoute(
        context: context,
        builder: (_) => InternalWebviewBrowserPage(
          widget.discuz,
          widget.user,
          uri.toString(),
        ),
      ),
    );
  }

  void openThread(ForumLink thread) {
    if (!current) return;
    Navigator.push<void>(
      context,
      platformPageRoute(
        context: context,
        builder: (_) => ViewThreadSliverPage(
          widget.discuz,
          widget.user,
          thread.tid,
          initialPid: thread.pid,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<DiscuzAndUserNotifier>();
    final s = S.of(context);
    final theme = Theme.of(context);
    final base = Uri.parse(widget.discuz.getBaseURLWithAfterfix());
    return PlatformScaffold(
      iosContentPadding: true,
      iosContentBottomPadding: true,
      appBar: PlatformAppBar(
        title: Text(s.credit),
        trailingActions: [
          PlatformIconButton(
            icon: Icon(
              PlatformIcons(context).globe,
              semanticLabel: s.specialOpenWebsite,
            ),
            liquidGlassSymbol: 'globe',
            onPressed: current
                ? () => openWebsite(
                    rules
                        ? CreditHistoryClient.rulesWebsite(base, fid: ruleBoard)
                        : CreditHistoryClient.website(base, rewards: rewards),
                  )
                : null,
          ),
        ],
      ),
      body: !current
          ? Center(child: Text(s.forumAccountChanged))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: PlatformSegmentedControl(
                    labels: [
                      s.creditTransactions,
                      s.creditRewards,
                      s.creditRules,
                    ],
                    selectedIndex: selectedTab,
                    onValueChanged: selectTab,
                  ),
                ),
                if (rules && ruleBoards.isNotEmpty)
                  PlatformTextButton(
                    onPressed: chooseRuleBoard,
                    child: Text(ruleBoards[ruleBoard] ?? s.creditGlobalRules),
                  ),
                Expanded(
                  child: CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                        sliver: SliverToBoxAdapter(
                          child: CreditOverviewCard(
                            widget.profile,
                            showUpgrade: true,
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: FutureBuilder<List<bool>>(
                          future: _forumExtras,
                          builder: (context, snapshot) {
                            final enabled = snapshot.data;
                            if (enabled == null || !enabled.contains(true)) {
                              return const SizedBox.shrink();
                            }
                            final icons = PlatformIcons(context);
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                              child: PlatformCard(
                                margin: EdgeInsets.zero,
                                child: Column(
                                  children: [
                                    if (enabled[0])
                                      PlatformListTile(
                                        leading: Icon(icons.checkMarkCircled),
                                        title: Text(s.forumTasks),
                                        trailing: Icon(icons.forward, size: 17),
                                        onTap: () => openForumTasks(
                                          context,
                                          widget.discuz,
                                          widget.user,
                                        ),
                                      ),
                                    if (enabled[0] && enabled[1])
                                      const Divider(height: 1),
                                    if (enabled[1])
                                      PlatformListTile(
                                        leading: Icon(
                                          icons.pick(
                                            Icons.workspace_premium_outlined,
                                            CupertinoIcons.rosette,
                                          ),
                                        ),
                                        title: Text(s.forumMedals),
                                        trailing: Icon(icons.forward, size: 17),
                                        onTap: () => openCommunity(
                                          context,
                                          widget.discuz,
                                          CommunitySection.medals,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList.separated(
                          itemCount: entries.length,
                          separatorBuilder: (_, _) => Divider(
                            height: 1,
                            color: theme.colorScheme.outlineVariant,
                          ),
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            final thread = entry.thread;
                            final rule = entry.rule;
                            return _CreditRow(
                              entry: entry,
                              onTap: thread != null
                                  ? () => openThread(thread)
                                  : rule == null
                                  ? null
                                  : () => openWebsite(rule),
                            );
                          },
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                        sliver: SliverToBoxAdapter(
                          child: switch ((busy, error, entries.isEmpty, next)) {
                            (true, _, _, _) => const Center(
                              child: PlatformCircularProgressIndicator(),
                            ),
                            (_, final failure?, _, _) => ErrorCard(
                              failure,
                              () => load(more: entries.isNotEmpty),
                              largeSize: false,
                            ),
                            (_, _, true, _) => Center(
                              child: Text(
                                s.forumEmpty,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                            (_, _, _, final Uri _) => PlatformTextButton(
                              onPressed: () => load(more: true),
                              child: Text(s.loadMore),
                            ),
                            _ => const SizedBox.shrink(),
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _CreditRow extends StatelessWidget {
  const _CreditRow({required this.entry, this.onTap});

  final CreditEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final secondary = theme.textTheme.bodySmall?.copyWith(
      color: colors.onSurfaceVariant,
    );
    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        Text(entry.label, style: theme.textTheme.titleSmall),
        if (entry.details.isNotEmpty) Text(entry.details, style: secondary),
        if (entry.date.isNotEmpty) Text(entry.date, style: secondary),
      ],
    );
    final amounts = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final amount in entry.amounts)
          Text(
            amount,
            textAlign: TextAlign.end,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: amount.contains(RegExp(r'\+\d'))
                  ? (theme.brightness == Brightness.dark
                        ? Colors.green.shade300
                        : Colors.green.shade800)
                  : colors.onSurface,
            ),
          ),
      ],
    );
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked =
              constraints.maxWidth < 280 ||
              MediaQuery.textScalerOf(context).scale(14) > 21;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: stacked && entry.amounts.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 6,
                        children: [info, amounts],
                      )
                    : info,
              ),
              if (!stacked && entry.amounts.isNotEmpty) ...[
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth * 0.4,
                  ),
                  child: amounts,
                ),
              ],
              if (onTap != null) ...[
                const SizedBox(width: 6),
                Icon(
                  PlatformIcons(
                    context,
                  ).pick(Icons.chevron_right, CupertinoIcons.chevron_forward),
                  size: 16,
                  color: colors.onSurfaceVariant,
                ),
              ],
            ],
          );
        },
      ),
    );
    if (onTap == null) return row;
    return isCupertino(context)
        ? CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onTap,
            child: row,
          )
        : Material(
            type: MaterialType.transparency,
            child: InkWell(onTap: onTap, child: row),
          );
  }
}
