import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
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
import '../utility/forum_navigation.dart';
import '../widget/ErrorCard.dart';
import 'InternalWebviewBrowserPage.dart';
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
  }

  @override
  void dispose() {
    query.dispose();
    super.dispose();
  }

  Future<void> selectBoard() async {
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
          submitted = '';
          hits.clear();
          next = null;
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
  );

  Future<void> search({bool more = false}) async {
    final keyword = more ? submitted : query.text.trim();
    if (!current || busy || keyword.isEmpty || (more && next == null)) return;
    final page = more ? next : null;
    FocusScope.of(context).unfocus();
    setState(() {
      busy = true;
      submitted = keyword;
      error = null;
      if (!more) {
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
        final result = await client.search(keyword, board, next: page);
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
        await _openWebsite(context, widget.discuz, user, website(keyword));
      } else {
        setState(() => error = display);
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<DiscuzAndUserNotifier>();
    final s = S.of(context);
    final icons = PlatformIcons(context);
    return PlatformScaffold(
      iosContentPadding: true,
      iosContentBottomPadding: true,
      appBar: PlatformAppBar(title: Text(s.forumSearchWeb)),
      body: !current
          ? Center(child: Text(s.forumAccountChanged))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                PlatformTextField(
                  controller: query,
                  maxLength: 40,
                  hintText: s.forumSearchKeyword,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => search(),
                ),
                PlatformListTile(
                  leading: Icon(
                    icons.pick(
                      Icons.filter_list,
                      CupertinoIcons.line_horizontal_3_decrease,
                    ),
                  ),
                  title: Text(boardName ?? s.forumSearchAllBoards),
                  onTap: busy ? null : selectBoard,
                ),
                Wrap(
                  children: [
                    PlatformTextButton(
                      onPressed: busy ? null : () => search(),
                      child: Text(s.forumSearchWeb),
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
                      child: Text(s.specialOpenWebsite),
                    ),
                  ],
                ),
                if (error case final failure?)
                  ErrorCard(failure, null, largeSize: false),
                if (submitted.isNotEmpty &&
                    !busy &&
                    error == null &&
                    hits.isEmpty)
                  Text(s.forumEmpty),
                for (final hit in hits)
                  PlatformListTile(
                    title: Text(hit.title),
                    subtitle: Text(
                      [
                        hit.board,
                        hit.details,
                        hit.excerpt,
                      ].where((part) => part.isNotEmpty).join('\n'),
                    ),
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
            ),
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
