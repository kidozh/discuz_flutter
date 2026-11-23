import 'dart:convert';
import 'dart:async';

import '../client/forum_community.dart';
import '../page/forum_community_page.dart';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show mapEquals;
import 'package:flutter/services.dart' show LengthLimitingTextInputFormatter;
import 'package:provider/provider.dart';

import '../client/ForumInteractionClient.dart';
import '../client/discuz_web_client.dart';
import '../client/forum_web_features.dart';
import '../entity/Discuz.dart';
import '../entity/DiscuzError.dart';
import '../entity/User.dart';
import '../generated/l10n.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../utility/NetworkUtils.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../utility/discuz_json.dart';
import '../utility/forum_error.dart';
import '../utility/forum_local_records.dart';
import '../utility/forum_feed_filters.dart';
import '../utility/forum_navigation.dart';
import '../widget/ErrorCard.dart';
import '../widget/forum_search_result_card.dart';
import 'InternalWebviewBrowserPage.dart';
import 'forum_saved_searches_page.dart';
import 'ViewThreadSliverPage.dart';

void _openThread(
  BuildContext context,
  Discuz discuz,
  User? user,
  ForumLink link, {
  String? title,
}) {
  Navigator.push(
    context,
    platformPageRoute(
      context: context,
      builder: (_) => ViewThreadSliverPage(
        discuz,
        user,
        link.tid,
        initialPid: link.pid,
        passedSubject: title,
      ),
    ),
  );
}

Future<void> _openWebsite(
  BuildContext context,
  Discuz discuz,
  User? user,
  Uri uri,
) => Navigator.push<void>(
  context,
  platformPageRoute(
    context: context,
    builder: (_) => InternalWebviewBrowserPage(discuz, user, uri.toString()),
  ),
);

class ForumSearchPage extends StatefulWidget {
  const ForumSearchPage(
    this.discuz, {
    super.key,
    this.initialFid,
    this.initialBoard,
  });
  final Discuz discuz;
  final int? initialFid;
  final String? initialBoard;

  @override
  State<ForumSearchPage> createState() => _ForumSearchPageState();
}

class _ForumSearchPageState extends State<ForumSearchPage> {
  final query = TextEditingController();
  final author = TextEditingController();
  ForumSearchForm? form;
  bool fullText = false, ascending = false, older = false, didSearch = false;
  String since = '0', order = 'lastpost';
  bool filtersExpanded = false;
  String submittedDescription = '';
  final resultsAnchor = GlobalKey();
  ForumSearchOptions? submittedOptions;
  int? submittedBoard;
  ForumSearchOptions get options => ForumSearchOptions(
    author: author.text,
    fullText: fullText,
    since: since,
    order: order,
    ascending: ascending,
    older: older,
  );

  late final history = ForumLocalRecords('search_history', widget.discuz, user);
  late final presets = ForumLocalRecords('search_presets', widget.discuz, user);

  bool get canSearch =>
      query.text.trim().isNotEmpty ||
      author.text.trim().isNotEmpty ||
      since != '0';

  ForumRecord searchCriteria() => {
    'id': jsonEncode([query.text.trim(), board, options.fields]),
    'query': query.text.trim(),
    'fid': board,
    'board': boardName,
    ...options.fields,
  };

  ForumSearchOptions recordOptions(ForumRecord entry) => ForumSearchOptions(
    author: discuzString(entry['srchuname']),
    fullText: entry['srchtype'] == 'fulltext',
    since: entry['srchfrom'] as String? ?? '0',
    order: entry['orderby'] as String? ?? 'lastpost',
    ascending: entry['ascdesc'] == 'asc',
    older: entry['before'] == '1',
  );

  Future<void> openSavedSearches() async {
    FocusScope.of(context).unfocus();
    final selected = await Navigator.push<ForumRecord>(
      context,
      platformPageRoute(
        context: context,
        builder: (_) => ForumSavedSearchesPage(
          history: history,
          presets: presets,
          criteria: canSearch ? searchCriteria() : null,
          isCurrent: () => current,
          describe: (entry) {
            final s = S.of(context);
            final settings = recordOptions(entry);
            return [
              if (entry['name'] != null &&
                  discuzString(entry['query']).isNotEmpty)
                discuzString(entry['query']),
              entry['board']?.toString() ?? s.forumSearchAllBoards,
              settings.fullText ? s.searchTitleAndBody : s.searchTitleOnly,
              filterSummary(settings),
            ].join(' · ');
          },
        ),
      ),
    );
    if (!current || selected == null) return;
    final settings = recordOptions(selected);
    setState(() {
      query.text = discuzString(selected['query']);
      author.text = settings.author;
      board = selected['fid'] as int?;
      boardName = selected['board'] as String?;
      fullText = settings.fullText;
      since = settings.since;
      order = settings.order;
      ascending = settings.ascending;
      older = settings.older;
      filtersExpanded = true;
      error = null;
    });
  }

  final hits = <ForumSearchHit>[];
  late final DiscuzAndUserNotifier account;
  late final Object session;
  late final User? user;
  late int? board = widget.initialFid;
  late String? boardName = widget.initialBoard;
  Uri? next;
  var submitted = '';
  var busy = false;
  DiscuzError? error;

  bool get current => mounted && identical(account.sessionIdentity, session);

  @override
  void initState() {
    super.initState();
    account = context.read<DiscuzAndUserNotifier>();
    session = account.sessionIdentity;
    user = account.userFor(widget.discuz);
    Future.microtask(loadForm);
  }

  @override
  void dispose() {
    query.dispose();
    author.dispose();
    super.dispose();
  }

  Future<void> loadForm() async {
    setState(() => busy = true);
    try {
      final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
      try {
        final value = await ForumSearchClient(
          DiscuzWebClient(ForumInteractionClient(dio, widget.discuz.baseURL)),
        ).loadForm();
        if (current)
          setState(() {
            form = value;
            error = null;
          });
      } finally {
        dio.close();
      }
    } catch (failure) {
      if (current)
        setState(() => error = forumRequestError(S.of(context), failure));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> chooseSearchValue(
    String title,
    Map<String, String> choices,
    String value,
    void Function(String) changed,
  ) async {
    FocusScope.of(context).unfocus();
    final selected = await showPlatformModalSheet<String>(
      context: context,
      builder: (sheet) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Semantics(
                header: true,
                child: Text(
                  title,
                  style: Theme.of(sheet).textTheme.titleMedium,
                ),
              ),
            ),
            for (final entry in choices.entries)
              PlatformListTile(
                title: Text(entry.value),
                trailing: entry.key == value
                    ? Icon(PlatformIcons(sheet).checkMark)
                    : null,
                onTap: () => Navigator.pop(sheet, entry.key),
              ),
          ],
        ),
      ),
    );
    if (selected != null && current) setState(() => changed(selected));
  }

  Future<void> selectBoard() async {
    FocusScope.of(context).unfocus();
    setState(() => busy = true);
    try {
      final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
      try {
        final boards = await loadForumNavigation(
          ForumInteractionClient(dio, widget.discuz.baseURL),
        );
        if (!current) return;
        final s = S.of(context);
        final selection = await Navigator.push<({int? id, String? name})>(
          context,
          platformPageRoute(
            context: context,
            builder: (routeContext) => PlatformScaffold(
              iosContentPadding: true,
              iosContentBottomPadding: true,
              appBar: PlatformAppBar(title: Text(s.forumSearchBoard)),
              body: ListView(
                children: [
                  PlatformListTile(
                    title: Text(s.forumSearchAllBoards),
                    onTap: () =>
                        Navigator.pop(routeContext, (id: null, name: null)),
                  ),
                  for (final item in boards)
                    PlatformListTile(
                      title: Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: 14.0 * discuzInt(item['depth']).clamp(0, 5),
                        ),
                        child: Text(discuzString(item['name'])),
                      ),
                      onTap: () => Navigator.pop(routeContext, (
                        id: discuzInt(item['fid']),
                        name: discuzString(item['name']),
                      )),
                    ),
                ],
              ),
            ),
          ),
        );
        if (selection == null || !current || selection.id == board) return;
        setState(() {
          board = selection.id;
          boardName = selection.name;
          error = null;
        });
      } finally {
        dio.close();
      }
    } catch (failure) {
      if (current)
        setState(() => error = forumRequestError(S.of(context), failure));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Uri website([String? keyword]) => ForumSearchClient.website(
    Uri.parse(widget.discuz.getBaseURLWithAfterfix()),
    keyword ?? query.text,
    board,
    options: options,
  );

  Future<void> search({bool more = false}) async {
    final keyword = more ? submitted : query.text.trim();
    final selectedOptions = more ? submittedOptions! : options;
    final selectedBoard = more ? submittedBoard : board;
    if (!current ||
        busy ||
        (keyword.isEmpty &&
            selectedOptions.author.trim().isEmpty &&
            selectedOptions.since == '0') ||
        (more && next == null))
      return;
    final page = more ? next : null;
    if (!more) {
      unawaited(
        history.put(searchCriteria(), limit: 30).catchError((Object _) {}),
      );
    }
    FocusScope.of(context).unfocus();
    setState(() {
      busy = true;
      submitted = keyword;
      didSearch = true;
      submittedOptions = selectedOptions;
      submittedBoard = selectedBoard;
      error = null;
      if (!more) {
        filtersExpanded = false;
        final s = S.of(context);
        submittedDescription = [
          if (keyword.isNotEmpty) '“$keyword”',
          '${s.forumSearchBoard}: ${boardName ?? s.forumSearchAllBoards}',
          selectedOptions.fullText ? s.searchTitleAndBody : s.searchTitleOnly,
          filterSummary(selectedOptions),
        ].join(' · ');
        next = null;
        hits.clear();
      }
    });
    try {
      final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
      try {
        final client = ForumSearchClient(
          DiscuzWebClient(ForumInteractionClient(dio, widget.discuz.baseURL)),
        );
        final result = await client.search(
          keyword,
          selectedBoard,
          next: page,
          options: selectedOptions,
        );
        if (!current) return;
        final seen = hits.map((hit) => hit.tid).toSet();
        setState(() {
          hits.addAll(result.hits.where((hit) => seen.add(hit.tid)));
          next = result.next == page ? null : result.next;
        });
      } finally {
        dio.close();
      }
    } catch (failure) {
      if (!current) return;
      final s = S.of(context);
      final display = forumRequestError(s, failure);
      if ({
        'forum_search_captcha',
        'forum_security_challenge',
        'submit_seccode_invalid',
        'submit_secqaa_invalid',
      }.contains(display.key)) {
        setState(
          () => error = DiscuzError(
            'forum_search_captcha',
            s.forumSearchVerification,
          ),
        );
        await _openWebsite(
          context,
          widget.discuz,
          user,
          ForumSearchClient.website(
            Uri.parse(widget.discuz.getBaseURLWithAfterfix()),
            keyword,
            selectedBoard,
            options: selectedOptions,
          ),
        );
      } else {
        setState(() => error = display);
      }
    } finally {
      if (mounted) setState(() => busy = false);
      if (current && !more && error == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final target = resultsAnchor.currentContext;
          if (current && target != null) {
            Scrollable.ensureVisible(
              target,
              alignment: .05,
              duration: const Duration(milliseconds: 250),
            );
          }
        });
      }
    }
  }

  String directionLabel(ForumSearchOptions value) {
    final s = S.of(context);
    final counts = value.order == 'replies' || value.order == 'views';
    return counts
        ? (value.ascending ? s.searchFewestFirst : s.searchMostFirst)
        : (value.ascending ? s.searchOldestFirst : s.searchNewestFirst);
  }

  String timeLabel(ForumSearchOptions value) {
    final s = S.of(context);
    if (value.since == '0') return s.searchAnyTime;
    final period = form?.times[value.since] ?? value.since;
    return value.older
        ? s.searchBeforePeriod(period)
        : s.searchRecentPeriod(period);
  }

  String filterSummary(ForumSearchOptions value) {
    final s = S.of(context);
    return [
      if (value.author.trim().isNotEmpty)
        '${s.searchAuthor}: ${value.author.trim()}',
      timeLabel(value),
      '${form?.orders[value.order] ?? s.searchLastPost} · ${directionLabel(value)}',
    ].join(' · ');
  }

  bool get changedSinceSearch =>
      didSearch &&
      submittedOptions != null &&
      (query.text.trim() != submitted ||
          board != submittedBoard ||
          !mapEquals(options.fields, submittedOptions!.fields));

  Widget group(List<Widget> children) => PlatformCard(
    margin: const EdgeInsets.only(bottom: 12),
    elevation: 0,
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    ),
  );

  Widget sectionLabel(String label) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
    child: Semantics(
      header: true,
      child: Text(label, style: Theme.of(context).textTheme.titleSmall),
    ),
  );

  Widget setting(
    String label,
    String value,
    VoidCallback? action, {
    IconData? icon,
  }) {
    final theme = Theme.of(context);
    return PlatformListTile(
      leading: icon == null ? null : Icon(icon, size: 22),
      title: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      subtitle: Text(value, style: theme.textTheme.titleSmall),
      isThreeLine: isCupertino(context),
      trailing: action == null
          ? null
          : Icon(
              PlatformIcons(context)
                  .pick(Icons.chevron_right, CupertinoIcons.chevron_right),
              size: 18,
            ),
      onTap: busy ? null : action,
    );
  }

  Widget field(String label, String hint, TextEditingController controller) =>
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            PlatformTextField(
              controller: controller,
              inputFormatters: [LengthLimitingTextInputFormatter(40)],
              enabled: !busy,
              hintText: hint,
              textInputAction: TextInputAction.search,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => search(),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    context.watch<DiscuzAndUserNotifier>();
    final s = S.of(context);
    final icons = PlatformIcons(context);
    final theme = Theme.of(context);
    final available = form;
    return PlatformScaffold(
      iosContentPadding: true,
      iosContentBottomPadding: true,
      appBar: PlatformAppBar(
        title: Text(s.forumSearchWeb),
        trailingActions: [
          PlatformIconButton(
            liquidGlassSymbol: 'clock.arrow.circlepath',
            icon: Icon(
              icons.pick(Icons.history, CupertinoIcons.clock),
              semanticLabel: s.savedSearches,
            ),
            onPressed: busy ? null : openSavedSearches,
          ),
          if (context.watch<DiscuzAndUserNotifier>().userFor(widget.discuz) !=
              null)
            PlatformIconButton(
              liquidGlassSymbol: 'person.magnifyingglass',
              icon: Icon(
                PlatformIcons(context).personAddSolid,
                semanticLabel: s.communityFindUsers,
              ),
              onPressed: () => openCommunity(
                context,
                widget.discuz,
                CommunitySection.findUsers,
              ),
            ),
        ],
      ),
      body: !current
          ? Center(child: Text(s.forumAccountChanged))
          : withForumFeedFilters(widget.discuz, user, (context, rules) {
              final visibleHits = hits
                  .where(
                    (hit) => !hidesForumThread(
                      rules,
                      hit.tid,
                      hit.title,
                      fid: hit.fid ?? submittedBoard,
                      excerpt: hit.excerpt,
                    ),
                  )
                  .toList();
              return ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(16),
                children: [
                  group([
                    field(s.searchKeyword, s.searchKeywordHint, query),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    sectionLabel(s.searchScope),
                    setting(
                      s.forumSearchBoard,
                      boardName ?? s.forumSearchAllBoards,
                      selectBoard,
                      icon: icons.pick(
                        Icons.folder_outlined,
                        CupertinoIcons.folder,
                      ),
                    ),
                    if (available != null)
                      setting(
                        s.searchMatchIn,
                        fullText ? s.searchTitleAndBody : s.searchTitleOnly,
                        available.fullText
                            ? () => chooseSearchValue(
                                s.searchMatchIn,
                                {
                                  'title': s.searchTitleOnly,
                                  'fulltext': s.searchTitleAndBody,
                                },
                                fullText ? 'fulltext' : 'title',
                                (v) => fullText = v == 'fulltext',
                              )
                            : null,
                        icon: icons.pick(
                          Icons.manage_search,
                          CupertinoIcons.doc_text_search,
                        ),
                      ),
                  ]),
                  if (available != null)
                    group([
                      PlatformListTile(
                        key: const ValueKey('search-filters-toggle'),
                        leading: Icon(
                          icons.pick(
                            Icons.tune,
                            CupertinoIcons.slider_horizontal_3,
                          ),
                        ),
                        title: Text(
                          s.searchFiltersSort,
                          style: theme.textTheme.titleMedium,
                        ),
                        subtitle: Text(filterSummary(options)),
                        isThreeLine: true,
                        trailing: Icon(
                          icons.pick(
                            filtersExpanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                            filtersExpanded
                                ? CupertinoIcons.chevron_up
                                : CupertinoIcons.chevron_down,
                          ),
                        ),
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          setState(() => filtersExpanded = !filtersExpanded);
                        },
                      ),
                      if (filtersExpanded) ...[
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        sectionLabel(s.searchNarrowResults),
                        field(s.searchAuthor, s.searchAuthorHint, author),
                        setting(
                          s.searchTime,
                          timeLabel(options),
                          () => chooseSearchValue(
                            s.searchTime,
                            available.times,
                            since,
                            (v) {
                              since = v;
                              if (v == '0') older = false;
                            },
                          ),
                        ),
                        if (since != '0')
                          setting(
                            s.searchTimeRelation,
                            timeLabel(options),
                            () => chooseSearchValue(
                              s.searchTimeRelation,
                              {
                                'recent': s.searchRecentPeriod(
                                  available.times[since] ?? since,
                                ),
                                'older': s.searchBeforePeriod(
                                  available.times[since] ?? since,
                                ),
                              },
                              older ? 'older' : 'recent',
                              (v) => older = v == 'older',
                            ),
                          ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        sectionLabel(s.searchArrangeResults),
                        setting(
                          s.searchOrder,
                          available.orders[order] ?? s.searchLastPost,
                          () => chooseSearchValue(
                            s.searchOrder,
                            available.orders,
                            order,
                            (v) => order = v,
                          ),
                        ),
                        setting(
                          s.searchDirection,
                          directionLabel(options),
                          () => chooseSearchValue(
                            s.searchDirection,
                            {
                              'desc': directionLabel(
                                ForumSearchOptions(order: order),
                              ),
                              'asc': directionLabel(
                                ForumSearchOptions(
                                  order: order,
                                  ascending: true,
                                ),
                              ),
                            },
                            ascending ? 'asc' : 'desc',
                            (v) => ascending = v == 'asc',
                          ),
                        ),
                      ],
                    ]),
                  if (available != null && available.notice.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        available.notice,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  PlatformElevatedButton(
                    widgetKey: const ValueKey('search-submit'),
                    color: theme.colorScheme.primary,
                    onPressed: busy || !canSearch ? null : () => search(),
                    child: Text(
                      s.searchSubmit,
                      style: TextStyle(color: theme.colorScheme.onPrimary),
                    ),
                  ),
                  PlatformTextButton(
                    onPressed: busy
                        ? null
                        : () => _openWebsite(
                            context,
                            widget.discuz,
                            user,
                            website(),
                          ),
                    child: Text(s.searchWebsite),
                  ),
                  if (error case final failure?)
                    ErrorCard(failure, null, largeSize: false),
                  if (didSearch) ...[
                    const SizedBox(height: 16),
                    Semantics(
                      key: resultsAnchor,
                      header: true,
                      child: Text(
                        s.searchResults,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      submittedDescription,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (changedSinceSearch)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          s.searchConditionsChanged,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    if (visibleHits.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          s.searchLoadedResults(visibleHits.length),
                          style: theme.textTheme.labelMedium,
                        ),
                      ),
                    if (!busy && error == null && visibleHits.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(s.searchNoMatches),
                      ),
                  ] else if (!busy && error == null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        s.searchStartHint,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  for (final hit in visibleHits)
                    ForumSearchResultCard(
                      key: ValueKey('search-hit-${hit.tid}'),
                      hit: hit,
                      keyword: submitted,
                      onTap: () => _openThread(context, widget.discuz, user, (
                        tid: hit.tid,
                        pid: null,
                      ), title: hit.title),
                    ),
                  if (busy)
                    const Center(child: PlatformCircularProgressIndicator())
                  else if (next != null)
                    PlatformTextButton(
                      onPressed: () => search(more: true),
                      child: Text(s.loadMore),
                    ),
                ],
              );
            }),
    );
  }
}

class ActivityReviewPage extends StatefulWidget {
  const ActivityReviewPage(
    this.discuz,
    this.user,
    this.tid, {
    super.key,
    this.onChanged,
  });
  final VoidCallback? onChanged;

  final Discuz discuz;
  final User user;
  final int tid;

  @override
  State<ActivityReviewPage> createState() => _ActivityReviewPageState();
}

class _ActivityReviewPageState extends State<ActivityReviewPage> {
  late final DiscuzAndUserNotifier account;
  late final Object session;
  final reason = TextEditingController();
  final selected = <int>{};
  List<ActivityApplicant> applicants = [];
  bool busy = true, changed = false;
  DiscuzError? error;

  bool get current =>
      mounted &&
      identical(session, account.sessionIdentity) &&
      account.userFor(widget.discuz)?.uid == widget.user.uid;

  @override
  void initState() {
    super.initState();
    account = context.read<DiscuzAndUserNotifier>();
    session = account.sessionIdentity;
    Future.microtask(refresh);
  }

  @override
  void dispose() {
    reason.dispose();
    super.dispose();
  }

  Future<void> refresh([ActivityReviewAction? action]) async {
    if (!current) return;
    final rows = applicants.where((row) => selected.contains(row.id)).toList();
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final dio = await NetworkUtils.getDioWithPersistCookieJar(widget.user);
      try {
        final client = ActivityReviewClient(
          DiscuzWebClient(ForumInteractionClient(dio, widget.discuz.baseURL)),
          widget.tid,
          widget.user.uid,
        );
        if (!current) return;
        if (action != null) {
          await client.review(
            action: action,
            selected: rows,
            reason: reason.text,
            isCurrent: () => current,
          );
          changed = true;
        }
        final form = await client.load();
        if (!current) return;
        setState(() {
          selected.clear();
          reason.clear();
          applicants = form.applicants;
        });
      } finally {
        dio.close();
      }
    } catch (failure) {
      if (current) {
        setState(() {
          applicants = [];
          selected.clear();
          error = forumRequestError(
            S.of(context),
            failure,
            submitted: action != null,
          );
        });
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  String label(S s, ActivityReviewAction action) => switch (action) {
    ActivityReviewAction.approve => s.activityReviewApprove,
    ActivityReviewAction.replenish => s.activityReviewReplenish,
    ActivityReviewAction.notify => s.activityReviewNotify,
    ActivityReviewAction.reject => s.activityReviewReject,
  };

  Future<void> confirm(ActivityReviewAction action) async {
    final s = S.of(context);
    if (action == ActivityReviewAction.notify && reason.text.trim().isEmpty) {
      setState(
        () => error = DiscuzError(
          'activity_reason',
          s.activityReviewReasonRequired,
        ),
      );
      return;
    }
    var confirmed = false;
    await showPlatformAlert(
      context: context,
      title: label(s, action),
      message: s.activityReviewConfirm(selected.length),
      actions: [
        PlatformAlertAction(label: s.cancel, isCancelAction: true),
        PlatformAlertAction(
          label: s.forumConfirm,
          onPressed: () => confirmed = true,
        ),
      ],
    );
    if (current && confirmed && !busy) await refresh(action);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<DiscuzAndUserNotifier>();
    final s = S.of(context);
    final icons = PlatformIcons(context);
    return PopScope(
      onPopInvokedWithResult: (popped, _) {
        if (popped && changed) widget.onChanged?.call();
      },
      child: PlatformScaffold(
        iosContentPadding: true,
        iosContentBottomPadding: true,
        appBar: PlatformAppBar(title: Text(s.activityReview)),
        body: !current
            ? Center(child: Text(s.forumAccountChanged))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (busy)
                    const Center(child: PlatformCircularProgressIndicator()),
                  if (error case final failure?)
                    ErrorCard(failure, () => refresh(), largeSize: false),
                  if (!busy && error == null && applicants.isEmpty)
                    Text(s.forumEmpty),
                  for (final row in applicants)
                    PlatformListTile(
                      title: Text('${row.name} · ${row.status}'),
                      subtitle: Text(
                        [
                          row.message,
                          ...row.details,
                        ].where((line) => line.isNotEmpty).join('\n'),
                      ),
                      trailing: row.id == null
                          ? null
                          : Icon(
                              selected.contains(row.id)
                                  ? icons.checkMarkCircledSolid
                                  : icons.pick(
                                      Icons.radio_button_unchecked,
                                      CupertinoIcons.circle,
                                    ),
                            ),
                      onTap: busy || row.id == null
                          ? null
                          : () => setState(() {
                              if (!selected.add(row.id!))
                                selected.remove(row.id);
                            }),
                    ),
                  if (selected.isNotEmpty) ...[
                    PlatformTextField(
                      controller: reason,
                      enabled: !busy,
                      hintText: s.activityReviewReason,
                      maxLength: 200,
                    ),
                    Wrap(
                      children: [
                        for (final action in ActivityReviewAction.values)
                          PlatformTextButton(
                            onPressed:
                                busy ||
                                    ((action == ActivityReviewAction.approve ||
                                            action ==
                                                ActivityReviewAction
                                                    .replenish) &&
                                        applicants.any(
                                          (row) =>
                                              row.approved &&
                                              selected.contains(row.id),
                                        ))
                                ? null
                                : () => confirm(action),
                            child: Text(label(s, action)),
                          ),
                      ],
                    ),
                  ],
                  Wrap(
                    children: [
                      PlatformTextButton(
                        onPressed: busy ? null : () => refresh(),
                        child: Text(s.forumRefresh),
                      ),
                      PlatformTextButton(
                        onPressed: busy
                            ? null
                            : () async {
                                final uri =
                                    Uri.parse(
                                          widget.discuz
                                              .getBaseURLWithAfterfix(),
                                        )
                                        .resolve('forum.php')
                                        .replace(
                                          queryParameters: {
                                            'mod': 'misc',
                                            'action': 'activityapplylist',
                                            'tid': '${widget.tid}',
                                            'mobile': 'no',
                                          },
                                        );
                                await _openWebsite(
                                  context,
                                  widget.discuz,
                                  widget.user,
                                  uri,
                                );
                                if (current) {
                                  changed = true;
                                  await refresh();
                                }
                              },
                        child: Text(s.specialOpenWebsite),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
