import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:html/parser.dart' show parseFragment;
import 'package:provider/provider.dart';

import '../entity/Discuz.dart';
import '../entity/User.dart';
import '../page/FullImagePage.dart';
import '../page/poll_voters_page.dart';
import '../client/poll_voters.dart';
import '../utility/forum_image_url.dart';
import 'forum_image.dart';
import '../JsonResult/ViewThreadResult.dart';
import '../client/ForumInteractionClient.dart';
import '../client/MobileApiClient.dart';
import '../generated/l10n.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../utility/NetworkUtils.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../utility/TimeDisplayUtils.dart';
import '../utility/forum_error.dart';
import '../utility/poll_vote_store.dart';
import 'ErrorCard.dart';
import '../utility/material_surface_theme.dart';
import '../utility/thread_selection_colors.dart';

class PollWidget extends StatefulWidget {
  final Poll poll;
  final String formhash;
  final int tid;
  final int fid;
  final VoidCallback? onVoted;
  final Discuz? forum;

  const PollWidget(
    this.poll,
    this.formhash,
    this.tid,
    this.fid, {
    super.key,
    this.onVoted,
    this.forum,
  });

  @override
  State<PollWidget> createState() => _PollState();
}

class _PollState extends State<PollWidget> {
  final Set<int> selected = {};
  bool sending = false;
  Set<int> _receipt = {};
  bool _readingReceipt = false;
  bool _alreadyVoted = false;
  bool _lookedUpVote = false;
  (Object, PollVoteKey)? _voteScope;
  static const _voteStore = PollVoteStore();
  (Object, String, int, int)? _votersScope;
  Future<PollVoterBatch>? _initialVoters;

  bool get expired =>
      widget.poll.expiredAt.millisecondsSinceEpoch > 0 &&
      widget.poll.expiredAt.isBefore(DateTime.now());

  @override
  void didUpdateWidget(PollWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.poll != widget.poll || oldWidget.tid != widget.tid) {
      selected.removeWhere(
        (id) =>
            !widget.poll.pollOptionsMap.values.any((option) => option.id == id),
      );
      _votersScope = null;
      _initialVoters = null;
    }
  }

  void _observeVoteScope(DiscuzAndUserNotifier? account, Discuz? forum) {
    final active =
        account != null && forum != null && forum.isSameSite(account.discuz);
    final scope = active
        ? (
            account.sessionIdentity,
            (
              site: forum.siteIdentity,
              uid: account.userFor(forum)?.uid ?? 0,
              tid: widget.tid,
            ),
          )
        : null;
    if (_voteScope == scope) return;
    _voteScope = scope;
    selected.clear();
    _receipt = {};
    _alreadyVoted = false;
    _lookedUpVote = false;
    sending = false;
    _readingReceipt = scope != null && scope.$2.uid > 0;
    if (_readingReceipt) {
      unawaited(_loadReceipt(scope!));
    }
  }

  Future<void> _loadReceipt((Object, PollVoteKey) scope) async {
    var receipt = <int>{};
    try {
      receipt = await _voteStore.read(scope.$2);
    } catch (_) {
      // The forum remains the authority if device storage is unavailable.
    }
    if (!mounted || _voteScope != scope) return;
    setState(() {
      _receipt = receipt;
      if (receipt.isNotEmpty) selected.clear();
      _readingReceipt = false;
    });
  }

  Future<void> _restoreFromVoters(
    (Object, PollVoteKey) scope,
    Discuz forum,
    User user,
    List<int> options,
    int maximum,
    Future<PollVoterBatch> initial,
  ) async {
    bool current() =>
        mounted &&
        _voteScope == scope &&
        identical(
          context.read<DiscuzAndUserNotifier>().sessionIdentity,
          scope.$1,
        );
    try {
      final result = await findOwnPollVote(
        uid: user.uid,
        options: options,
        maximumChoices: maximum,
        isCurrent: current,
        load: (option, page) => option == options.first && page == 1
            ? initial
            : readPollVoters(forum, user, scope.$2.tid, option, page),
      );
      if (!current() ||
          result == null ||
          result.isEmpty ||
          _receipt.isNotEmpty) {
        return;
      }
      setState(() => _receipt = result);
      await _voteStore.save(scope.$2, result);
    } catch (_) {
      // A private or incomplete voter list cannot identify previous choices.
    }
  }

  Future<void> vote(int limit) async {
    if (sending ||
        _receipt.isNotEmpty ||
        _alreadyVoted ||
        _readingReceipt ||
        expired ||
        selected.isEmpty ||
        selected.length > limit) {
      return;
    }
    final account = context.read<DiscuzAndUserNotifier>();
    final discuz = widget.forum ?? account.discuz;
    final user = discuz == null ? null : account.userFor(discuz);
    final scope = _voteScope;
    if (discuz == null ||
        scope == null ||
        !identical(scope.$1, account.sessionIdentity) ||
        !widget.poll.allowVote ||
        widget.formhash.isEmpty) {
      return;
    }
    final choices = Set<int>.of(selected);
    final fid = widget.fid;
    final tid = widget.tid;
    final hash = widget.formhash;
    final strings = S.of(context);
    bool isCurrent() =>
        mounted &&
        _voteScope == scope &&
        identical(scope.$1, account.sessionIdentity);
    setState(() => sending = true);
    try {
      final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
      try {
        if (!mounted || !isCurrent()) return;
        final result = await MobileApiClient(
          dio,
          baseUrl: discuz.baseURL,
        ).votePoll(fid, tid, hash, choices.map((id) => '$id').toList());
        final message = result.errorResult;
        final code = forumMessageKey(message?.key ?? '');
        if (code == 'thread_poll_succeed' &&
            result.variables.member_uid == scope.$2.uid) {
          if (scope.$2.uid > 0) {
            var saved = false;
            try {
              saved = await _voteStore.save(scope.$2, choices);
            } catch (_) {
              // Keep the confirmed choices visible for this session.
            }
            if (!saved && isCurrent()) {
              EasyLoading.showInfo(strings.pollVoteDeviceSaveFailed);
            }
          }
          if (isCurrent()) {
            setState(() {
              _receipt = choices;
              selected.clear();
            });
            widget.onVoted?.call();
          }
          return;
        }
        if (!mounted || !isCurrent()) return;
        if (code == 'thread_poll_voted') {
          setState(() {
            _alreadyVoted = true;
            _lookedUpVote = false;
            _votersScope = null;
            _initialVoters = null;
            selected.clear();
          });
          widget.onVoted?.call();
          return;
        }
        await showForumActionError(
          context,
          code == 'thread_poll_succeed'
              ? forumRequestError(
                  strings,
                  const ForumApiException('account_changed', ''),
                )
              : forumResponseError(strings, result) ??
                    forumRequestError(
                      strings,
                      const FormatException(),
                      submitted: true,
                    ),
        );
      } finally {
        dio.close();
      }
    } catch (error) {
      if (mounted && isCurrent()) {
        await showForumActionError(
          context,
          forumRequestError(S.of(context), error, submitted: true),
        );
      }
    } finally {
      if (isCurrent()) setState(() => sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final poll = widget.poll;
    final options = poll.pollOptionsMap.values
        .where((option) => option.id > 0)
        .toList();
    if (options.length < 2) return const SizedBox.shrink();
    final strings = S.of(context);
    final limit = poll.multipleChoice
        ? (poll.maxChoice > 0
              ? poll.maxChoice.clamp(1, options.length)
              : options.length)
        : 1;
    final account = context.watch<DiscuzAndUserNotifier?>();
    final forum = widget.forum ?? account?.discuz;
    _observeVoteScope(account, forum);
    final canVote =
        poll.allowVote &&
        _receipt.isEmpty &&
        !_alreadyVoted &&
        !expired &&
        forum != null &&
        account != null &&
        forum.isSameSite(account.discuz) &&
        widget.formhash.isNotEmpty;
    if (poll.isResultVisible &&
        forum != null &&
        account != null &&
        forum.isSameSite(account.discuz) &&
        widget.tid > 0) {
      final scope = (
        account.sessionIdentity,
        forum.siteIdentity,
        widget.tid,
        options.first.id,
      );
      if (_votersScope != scope) {
        _votersScope = scope;
        _initialVoters = readPollVoters(
          forum,
          account.userFor(forum),
          widget.tid,
          options.first.id,
          1,
        );
      }
    }
    final scope = _voteScope;
    final initial = _initialVoters;
    final user = forum == null ? null : account?.userFor(forum);
    if (!_lookedUpVote &&
        !_readingReceipt &&
        !sending &&
        _receipt.isEmpty &&
        (!poll.allowVote || _alreadyVoted) &&
        poll.isResultVisible &&
        scope != null &&
        forum != null &&
        user != null &&
        initial != null) {
      _lookedUpVote = true;
      unawaited(
        _restoreFromVoters(
          scope,
          forum,
          user,
          options.map((option) => option.id).toList(),
          limit,
          initial,
        ),
      );
    }
    final showResults = poll.isResultVisible && !canVote;
    final total = options.fold(0, (sum, option) => sum + option.voteNumber);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final footer = [
      if (showResults && poll.votersCount > 0)
        strings.pollParticipantCount(poll.votersCount),
      if (expired)
        strings.pollFinished
      else if (poll.expiredAt.millisecondsSinceEpoch > 0)
        strings.pollExpireAt(
          TimeDisplayUtils.getLocaledTimeDisplay(context, poll.expiredAt),
        ),
      if (!canVote && !poll.isResultVisible) strings.pollResultsHidden,
    ];
    return PlatformCard(
      padding: const EdgeInsets.all(14),
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        label: strings.pollTitle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (canVote && poll.multipleChoice)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  strings.pollSelectUpTo(limit),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            for (final option in options) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: canVote
                    ? _PollChoiceRow(
                        label: parseFragment(option.name).text ?? option.name,
                        selected: selected.contains(option.id),
                        onTap:
                            sending ||
                                (limit > 1 &&
                                    selected.length >= limit &&
                                    !selected.contains(option.id))
                            ? null
                            : () => setState(() {
                                if (selected.remove(option.id)) return;
                                if (limit == 1) selected.clear();
                                selected.add(option.id);
                              }),
                      )
                    : _PollResultRow(
                        label: parseFragment(option.name).text ?? option.name,
                        voted: _receipt.contains(option.id),
                        share: showResults
                            ? total > 0
                                  ? (option.voteNumber / total).clamp(0.0, 1.0)
                                  : 0.0
                            : null,
                      ),
              ),
              if (forum != null)
                _PollImage(forum: forum, option: option, tid: widget.tid),
            ],
            if (canVote)
              PlatformElevatedButton(
                onPressed: sending || _readingReceipt || selected.isEmpty
                    ? null
                    : () => vote(limit),
                child: Text(strings.pollSubmit),
              ),
            if (footer.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 6, 2, 0),
                child: Text(
                  footer.join(' · '),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            if (poll.isResultVisible &&
                _initialVoters != null &&
                forum != null &&
                account != null)
              FutureBuilder<PollVoterBatch>(
                key: ValueKey(_votersScope),
                future: _initialVoters,
                builder: (context, snapshot) {
                  final batch = snapshot.data;
                  if (batch == null ||
                      _votersScope?.$1 != account.sessionIdentity) {
                    return const SizedBox.shrink();
                  }
                  return Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: PlatformTextButton(
                      onPressed: () => pushDetailPage(
                        context,
                        platformPageRoute(
                          context: context,
                          builder: (_) => PollVotersPage(
                            forum: forum,
                            user: account.userFor(forum),
                            tid: widget.tid,
                            options: options,
                            initial: batch,
                            session: _votersScope!.$1,
                          ),
                        ),
                      ),
                      child: Text(strings.pollVoterList),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _PollChoiceRow extends StatelessWidget {
  const _PollChoiceRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(16);
    final tile = Semantics(
      button: true,
      selected: selected,
      enabled: onTap != null,
      child: PlatformListTile(
        title: Text(label, textAlign: TextAlign.center),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        selectedColor: colors.onSurface,
        selected: selected,
        shape: RoundedRectangleBorder(borderRadius: radius),
        onTap: onTap,
      ),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        color: selected ? ThreadSelectionColors(colors).background : null,
        border: Border.fromBorderSide(
          BorderSide(
            color: onTap == null ? colors.outlineVariant : colors.primary,
          ),
        ),
      ),
      child: isMaterial(context)
          ? Material(
              type: MaterialType.transparency,
              borderRadius: radius,
              clipBehavior: Clip.antiAlias,
              child: tile,
            )
          : tile,
    );
  }
}

class _PollResultRow extends StatelessWidget {
  const _PollResultRow({required this.label, required this.voted, this.share});

  final String label;
  final bool voted;
  final double? share;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final fraction = share;
    final percentage = fraction == null ? null : fraction * 100;
    final ownResult = ThreadSelectionColors(colors).background;
    return ClipRRect(
      borderRadius: BorderRadius.circular(9),
      child: Stack(
        children: [
          if (fraction != null && fraction > 0)
            Positioned.fill(
              child: FractionallySizedBox(
                alignment: AlignmentDirectional.centerStart,
                widthFactor: fraction,
                child: ColoredBox(
                  color: voted ? ownResult : colors.surfaceContainerHigh,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(label, style: theme.textTheme.bodyMedium),
                      ),
                      if (voted)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(start: 6),
                          child: Icon(
                            PlatformIcons(context).checkMarkCircledSolid,
                            color: readableForumForeground(
                              colors.primary,
                              ownResult,
                            ),
                            size: 17,
                            semanticLabel: S.of(context).pollOwnVoteOption,
                          ),
                        ),
                    ],
                  ),
                ),
                if (percentage != null) ...[
                  const SizedBox(width: 10),
                  Text(
                    '${percentage.toStringAsFixed(percentage % 1 == 0 ? 0 : 1)}%',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PollImage extends StatelessWidget {
  const _PollImage({
    required this.forum,
    required this.option,
    required this.tid,
  });
  final Discuz forum;
  final PollOption option;
  final int tid;
  @override
  Widget build(BuildContext context) {
    final base = forumBaseUri(forum);
    final big = resolveForumImageUri(base, option.images['big'] ?? '');
    final thumb =
        resolveForumImageUri(base, option.images['small'] ?? '') ?? big;
    if (thumb == null) return const SizedBox.shrink();
    final image = ForumImage(
      forum: forum,
      threadId: tid,
      url: '$thumb',
      fallbackUrl: big?.toString(),
      loading: (_, __) =>
          const Center(child: PlatformCircularProgressIndicator()),
      error: (ctx) => Icon(PlatformIcons(ctx).error),
      fit: BoxFit.contain,
    );
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
        child: Semantics(
          button: big != null,
          label:
              '${S.of(context).viewPicture} · ${parseFragment(option.name).text ?? ''}',
          child: InkWell(
            onTap: big == null
                ? null
                : () => Navigator.push(
                    context,
                    platformPageRoute(
                      context: context,
                      iosTitle: S.of(context).viewPicture,
                      builder: (_) => FullImagePage(
                        '$big',
                        ['$big'],
                        forum: forum,
                        threadId: tid,
                      ),
                    ),
                  ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220, maxHeight: 140),
              child: image,
            ),
          ),
        ),
      ),
    );
  }
}
