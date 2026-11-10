import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/TimeDisplayUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_polls/flutter_polls.dart' as FlutterPolls;
import 'package:provider/provider.dart';

import '../JsonResult/ViewThreadResult.dart';

class PollWidget extends StatefulWidget {
  final Poll poll;
  final String formhash;
  final int tid;
  final int fid;

  const PollWidget(this.poll, this.formhash, this.tid, this.fid, {super.key});

  @override
  State<PollWidget> createState() => _PollState();
}

class _PollState extends State<PollWidget> {
  Future<bool> _vote(FlutterPolls.PollOption option) async {
    final id = option.id;
    if (id == null) return false;
    final account = context.read<DiscuzAndUserNotifier>();
    final discuz = account.discuz;
    final user = account.user;
    final session = account.sessionIdentity;
    final poll = widget.poll;
    final fid = widget.fid;
    final tid = widget.tid;
    final formhash = widget.formhash;
    bool isCurrent() =>
        mounted &&
        identical(poll, widget.poll) &&
        identical(session, account.sessionIdentity);
    if (discuz == null || user == null) return false;
    try {
      final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
      if (!isCurrent()) return false;
      final result = await MobileApiClient(
        dio,
        baseUrl: discuz.baseURL,
      ).votePoll(fid, tid, formhash, [id]);
      if (!isCurrent()) return false;
      final message = result.errorResult;
      if (message?.key != 'thread_poll_succeed') {
        EasyLoading.showError(result.getErrorString() ?? S.of(context).error);
        return false;
      }

      for (final option in poll.pollOptionsMap.values) {
        if (option.id.toString() == id) option.voteNumber++;
      }
      poll.allowVote = false;
      EasyLoading.showSuccess(message!.content);
      return true;
    } catch (_) {
      if (isCurrent()) EasyLoading.showError(S.of(context).error);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final poll = widget.poll;
    final options = poll.pollOptionsMap.values
        .map(
          (option) => FlutterPolls.PollOption(
            id: option.id.toString(),
            title: Text(option.name),
            votes: option.voteNumber,
          ),
        )
        .toList();
    if (options.length < 2) return const SizedBox.shrink();

    final leading = options.reduce((a, b) => a.votes >= b.votes ? a : b);
    final colors = Theme.of(context).colorScheme;
    final strings = S.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: FlutterPolls.FlutterPolls(
        // The poll package initializes its vote state and total once per key.
        key: ObjectKey(poll),
        pollId: widget.tid.toString(),
        onVoted: (option, _) => _vote(option),
        hasVoted: !poll.allowVote,
        userVotedOptionId: poll.allowVote ? null : leading.id,
        pollTitle: Text(
          poll.allowVote ? strings.pollTitle : strings.pollNotAllowed,
        ),
        pollOptions: options,
        pollEnded: poll.expiredAt.isBefore(DateTime.now()),
        votedBackgroundColor: colors.surface,
        votedProgressColor: colors.primary.withValues(alpha: 0.3),
        leadingVotedProgessColor: colors.primary.withValues(alpha: 0.6),
        votedCheckmark: Icon(
          AppPlatformIcons(context).checkCircleOutlined,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
        metaWidget: Text(
          ' · ${strings.pollExpireAt(TimeDisplayUtils.getLocaledTimeDisplay(context, poll.expiredAt))}',
        ),
      ),
    );
  }
}
