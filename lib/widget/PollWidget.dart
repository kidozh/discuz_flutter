import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:html/parser.dart' show parseFragment;
import 'package:provider/provider.dart';

import '../JsonResult/ViewThreadResult.dart';
import '../client/MobileApiClient.dart';
import '../generated/l10n.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../utility/NetworkUtils.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../utility/TimeDisplayUtils.dart';
import '../utility/forum_error.dart';
import 'ErrorCard.dart';

class PollWidget extends StatefulWidget {
  final Poll poll;
  final String formhash;
  final int tid;
  final int fid;
  final VoidCallback? onVoted;

  const PollWidget(
    this.poll,
    this.formhash,
    this.tid,
    this.fid, {
    super.key,
    this.onVoted,
  });

  @override
  State<PollWidget> createState() => _PollState();
}

class _PollState extends State<PollWidget> {
  final Set<int> selected = {};
  bool sending = false;
  bool voted = false;

  bool get expired =>
      widget.poll.expiredAt.millisecondsSinceEpoch > 0 &&
      widget.poll.expiredAt.isBefore(DateTime.now());

  @override
  void didUpdateWidget(PollWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.poll != widget.poll || oldWidget.tid != widget.tid) {
      selected.clear();
      sending = false;
      voted = false;
    }
  }

  Future<void> vote(int limit) async {
    if (sending ||
        voted ||
        expired ||
        selected.isEmpty ||
        selected.length > limit) {
      return;
    }
    final account = context.read<DiscuzAndUserNotifier>();
    final discuz = account.discuz;
    final user = account.user;
    final session = account.sessionIdentity;
    final poll = widget.poll;
    if (discuz == null || !poll.allowVote || widget.formhash.isEmpty) return;
    final choices = selected.map((id) => '$id').toList();
    bool isCurrent() =>
        mounted &&
        identical(poll, widget.poll) &&
        identical(session, account.sessionIdentity);
    setState(() => sending = true);
    try {
      final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
      try {
        if (!mounted || !isCurrent()) return;
        final result = await MobileApiClient(
          dio,
          baseUrl: discuz.baseURL,
        ).votePoll(widget.fid, widget.tid, widget.formhash, choices);
        if (!mounted || !isCurrent()) return;
        final strings = S.of(context);
        final message = result.errorResult;
        if (forumMessageKey(message?.key ?? '') != 'thread_poll_succeed') {
          await showForumActionError(
            context,
            forumResponseError(strings, result) ??
                forumRequestError(
                  strings,
                  const FormatException(),
                  submitted: true,
                ),
          );
          return;
        }
        setState(() {
          voted = true;
          if (poll.isResultVisible) {
            for (final option in poll.pollOptionsMap.values) {
              if (selected.contains(option.id)) option.voteNumber++;
            }
          }
        });
        EasyLoading.showSuccess(
          message!.content.trim().isEmpty ? strings.ok : message.content,
        );
        widget.onVoted?.call();
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
    final canVote =
        poll.allowVote &&
        !voted &&
        !expired &&
        account?.discuz != null &&
        widget.formhash.isNotEmpty;
    final total = options.fold(0, (sum, option) => sum + option.voteNumber);
    final icons = PlatformIcons(context);
    return PlatformCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            strings.pollTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (canVote) Text(strings.pollSelectUpTo(limit)),
          if (poll.expiredAt.millisecondsSinceEpoch > 0)
            Text(
              strings.pollExpireAt(
                TimeDisplayUtils.getLocaledTimeDisplay(context, poll.expiredAt),
              ),
            ),
          for (final option in options)
            PlatformListTile(
              title: Text(parseFragment(option.name).text ?? option.name),
              selected: selected.contains(option.id),
              leading: canVote
                  ? Icon(
                      selected.contains(option.id)
                          ? icons.checkMarkCircledSolid
                          : icons.pick(
                              Icons.radio_button_unchecked,
                              CupertinoIcons.circle,
                            ),
                    )
                  : null,
              trailing: poll.isResultVisible && (!canVote || voted)
                  ? Text(
                      '${(total == 0 ? 0.0 : 100 * option.voteNumber / total).toStringAsFixed(1)}%',
                    )
                  : null,
              onTap:
                  !canVote ||
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
            ),
          if (canVote)
            PlatformElevatedButton(
              onPressed: sending || selected.isEmpty ? null : () => vote(limit),
              child: Text(strings.pollSubmit),
            )
          else if (!poll.isResultVisible)
            Text(voted ? strings.pollVoted : strings.pollResultsHidden),
        ],
      ),
    );
  }
}
