import 'package:flutter/material.dart';
import 'package:html/parser.dart' show parseFragment;
import '../client/ForumInteractionClient.dart';
import '../database/AppDatabase.dart';
import '../entity/Discuz.dart';
import '../entity/User.dart';
import '../generated/l10n.dart';
import '../utility/ForumFeedPreferences.dart';
import '../utility/NetworkUtils.dart';
import '../utility/PlatformAdaptiveWidgets.dart';

class ForumFeedSettingsPage extends StatefulWidget {
  final Discuz discuz;
  final User? user;
  final Future<List<Discuz>> Function()? loadSites;
  final Future<List<User>> Function()? loadUsers;
  final Future<ForumInteractionClient> Function(Discuz, User?)? createClient;
  const ForumFeedSettingsPage({
    super.key,
    required this.discuz,
    required this.user,
    this.loadSites,
    this.loadUsers,
    this.createClient,
  });
  @override
  State<ForumFeedSettingsPage> createState() => _ForumFeedSettingsPageState();
}

class _ForumFeedSettingsPageState extends State<ForumFeedSettingsPage> {
  late Discuz site = widget.discuz;
  late User? user = widget.user;
  late List<Discuz> sites = [widget.discuz];
  List<User> users = [];
  List<Map<String, dynamic>> rows = [];
  Set<String> selected = {};
  bool loading = true, saving = false;
  String? error;
  int generation = 0;
  String get scope => ForumFeedPreferences.scope(site, user);
  Iterable<String> get knownIds => rows.map((row) => '${row['fid']}');
  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    try {
      final available = widget.loadSites != null
          ? await widget.loadSites!()
          : (await AppDatabase.getDiscuzDao()).findAllDiscuzs();
      final accounts = widget.loadUsers != null
          ? await widget.loadUsers!()
          : (await AppDatabase.getUserDao()).findAllUsers();
      if (!mounted) return;
      setState(() {
        sites = {
          widget.discuz.baseURL: widget.discuz,
          for (final item in available) item.baseURL: item,
        }.values.toList();
        site = sites.firstWhere((item) => item.baseURL == site.baseURL);
        users = {
          for (final account in accounts)
            '${account.discuz.baseURL}:${account.uid}': account,
          if (widget.user != null)
            '${widget.user!.discuz.baseURL}:${widget.user!.uid}': widget.user!,
        }.values.toList();
      });
    } catch (_) {
      /* The current forum remains usable if the local catalog fails. */
    }
    if (mounted) await load();
  }

  Future<void> load() async {
    final run = ++generation;
    final requestScope = scope;
    final requestSite = site;
    final requestUser = user;
    setState(() {
      loading = true;
      error = null;
      rows = [];
      selected = {};
    });
    try {
      final cached = await ForumFeedPreferences.cachedForums(requestScope);
      final cachedSelection = await ForumFeedPreferences.selectedFor(
        requestScope,
        (cached ?? []).map((row) => '${row['fid']}'),
      );
      if (!mounted || run != generation) return;
      setState(() {
        rows = cached ?? [];
        selected = cachedSelection;
      });
      final client = widget.createClient != null
          ? await widget.createClient!(requestSite, requestUser)
          : ForumInteractionClient(
              await NetworkUtils.getDioWithPersistCookieJar(requestUser),
              requestSite.baseURL,
            );
      final fresh = await ForumFeedPreferences.forums(
        requestScope,
        client,
        refresh: true,
      );
      final selection = await ForumFeedPreferences.selectedFor(
        requestScope,
        fresh.map((row) => '${row['fid']}'),
      );
      if (mounted && run == generation)
        setState(() {
          rows = fresh;
          selected = selection;
        });
    } catch (_) {
      if (mounted && run == generation)
        setState(() => error = S.of(context).forumLoadFailed);
    } finally {
      if (mounted && run == generation) setState(() => loading = false);
    }
  }

  Future<void> save(Set<String> next, {bool all = false}) async {
    if (saving || loading) return;
    final previous = selected;
    final requestScope = scope;
    setState(() {
      saving = true;
      selected = next;
      error = null;
    });
    try {
      await ForumFeedPreferences.saveSelection(
        requestScope,
        all ? null : next.toList(),
        knownIds: knownIds,
      );
    } catch (_) {
      if (mounted)
        setState(() {
          selected = previous;
          error = S.of(context).forumActionFailed;
        });
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void selectSite(Discuz next) {
    setState(() {
      site = next;
      final accounts = users.where(
        (item) => item.discuz.baseURL == next.baseURL,
      );
      user = widget.discuz.baseURL == next.baseURL
          ? widget.user
          : accounts.firstOrNull;
    });
    load();
  }

  Widget selector<T>({
    required Key key,
    required T value,
    required Map<T, String> labels,
    required ValueChanged<T> onChanged,
  }) {
    if (isMaterial(context))
      return Material(
        type: MaterialType.transparency,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            key: key,
            value: value,
            isExpanded: true,
            items: [
              for (final entry in labels.entries)
                DropdownMenuItem(
                  value: entry.key,
                  child: Text(
                    entry.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: saving
                ? null
                : (next) {
                    if (next != null) onChanged(next);
                  },
          ),
        ),
      );
    final menu = PlatformPopupMenu(
      key: key,
      liquidGlassSymbol: 'chevron.down',
      icon: const Icon(Icons.keyboard_arrow_down),
      options: [
        for (final entry in labels.entries)
          PopupMenuOption(
            label: entry.value,
            onTap: (_) {
              if (!saving) onChanged(entry.key);
            },
          ),
      ],
    );
    return PlatformListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        labels[value] ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IgnorePointer(ignoring: saving, child: menu),
      onTap: saving ? null : () => menu.show(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final accounts = users
        .where((item) => item.discuz.baseURL == site.baseURL)
        .toList();
    return PlatformScaffold(
      appBar: PlatformAppBar(title: Text(s.feedForumsTitle)),
      iosContentPadding: true,
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: [
            PlatformCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  selector<String>(
                    key: const ValueKey('feed-site-selector'),
                    value: site.baseURL,
                    labels: {
                      for (final item in sites) item.baseURL: item.siteName,
                    },
                    onChanged: (value) {
                      if (value != site.baseURL)
                        selectSite(
                          sites.firstWhere((item) => item.baseURL == value),
                        );
                    },
                  ),
                  if (accounts.length > 1)
                    selector<int>(
                      key: const ValueKey('feed-account-selector'),
                      value: user?.uid ?? 0,
                      labels: {
                        0: s.feedGuest,
                        for (final account in accounts)
                          account.uid: account.username,
                      },
                      onChanged: (uid) {
                        setState(
                          () => user = accounts
                              .where((item) => item.uid == uid)
                              .firstOrNull,
                        );
                        load();
                      },
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${s.feedForumsTitle} · ${selected.length}/${rows.length}',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  PlatformLiquidGlassToolbarGroup(
                    children: [
                      PlatformIconButton(
                        liquidGlassSymbol: 'checkmark.circle',
                        liquidGlassIconSize: 20,
                        icon: Icon(
                          Icons.select_all,
                          semanticLabel: s.feedSelectAll,
                        ),
                        onPressed: loading || saving
                            ? null
                            : () => save(knownIds.toSet(), all: true),
                      ),
                      PlatformIconButton(
                        liquidGlassSymbol: 'circle',
                        liquidGlassIconSize: 20,
                        icon: Icon(
                          Icons.deselect,
                          semanticLabel: s.feedSelectNone,
                        ),
                        onPressed: loading || saving ? null : () => save({}),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (loading)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Center(child: PlatformCircularProgressIndicator()),
              ),
            if (error != null)
              PlatformListTile(
                title: Text(error!),
                trailing: PlatformTextButton(
                  onPressed: loading || saving ? null : load,
                  child: Text(s.refresh),
                ),
              ),
            PlatformCard(
              child: Column(
                children: [
                  for (final row in rows)
                    Semantics(
                      checked: selected.contains(row['fid']),
                      child: PlatformListTile(
                        title: Text(parseFragment('${row['name']}').text ?? ''),
                        trailing: Icon(
                          selected.contains(row['fid'])
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onTap: loading || saving
                            ? null
                            : () {
                                final next = {...selected};
                                if (!next.remove(row['fid']))
                                  next.add('${row['fid']}');
                                save(next);
                              },
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                s.feedForumsHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
