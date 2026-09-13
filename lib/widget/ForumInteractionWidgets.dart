import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../client/ForumInteractionClient.dart';
import '../entity/Discuz.dart';
import '../entity/User.dart';
import '../generated/l10n.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../utility/NetworkUtils.dart';
import '../utility/PlatformAdaptiveWidgets.dart';

class ForumActionButton extends StatefulWidget {
  final Discuz discuz;
  final int tid;
  final int? aid;
  final bool purchase;
  final bool positive, enabled;
  final IconData? icon;
  final ValueChanged<bool>? onBusyChanged;
  final ValueChanged<bool>? onFeedbackAccepted;
  final String formhash, label;
  final VoidCallback onChanged;
  final Future<ForumInteractionClient> Function(User)? createClient;
  const ForumActionButton({
    super.key,
    required this.discuz,
    required this.tid,
    this.aid,
    this.purchase = false,
    this.positive = true,
    this.enabled = true,
    this.icon,
    this.onBusyChanged,
    this.onFeedbackAccepted,
    this.formhash = '',
    required this.label,
    required this.onChanged,
    this.createClient,
  });
  @override
  State<ForumActionButton> createState() => _ForumActionButtonState();
}

class _ForumActionButtonState extends State<ForumActionButton> {
  bool busy = false;
  bool completed = false;
  String? completedAccount;
  bool sameAccount(User user) {
    final state = context.read<DiscuzAndUserNotifier>();
    return state.user?.uid == user.uid &&
        state.discuz?.baseURL == widget.discuz.baseURL &&
        state.user?.auth == user.auth;
  }

  Future<void> run() async {
    if (busy || completed || !widget.enabled) return;
    final s = S.of(context);
    final user = context.read<DiscuzAndUserNotifier>().user;
    if (user == null ||
        user.uid <= 0 ||
        user.discuz.baseURL != widget.discuz.baseURL) {
      await showPlatformAlert(
        context: context,
        title: s.forumSignInRequired,
        actions: [PlatformAlertAction(label: s.forumConfirm)],
      );
      return;
    }
    setState(() => busy = true);
    widget.onBusyChanged?.call(true);
    bool submitted = false;
    try {
      final client = widget.createClient != null
          ? await widget.createClient!(user)
          : ForumInteractionClient(
              await NetworkUtils.getDioWithPersistCookieJar(user),
              widget.discuz.baseURL,
            );
      if (!mounted || !sameAccount(user)) return;
      if (widget.purchase) {
        var quote = await client.quote(widget.tid, aid: widget.aid);
        while (mounted && sameAccount(user)) {
          if (quote.balance < 0 || quote.formhash.isEmpty) {
            throw ForumApiException(
              'invalid_quote',
              s.forumPurchaseUnavailable,
            );
          }
          if (!mounted) return;
          bool confirmed = false;
          await showPlatformAlert(
            context: context,
            title: s.forumConfirmPurchase,
            message:
                '${quote.filename.isEmpty ? widget.label : quote.filename}\n${s.forumPurchasePrice}: ${quote.price} ${quote.title} ${quote.unit}\n${s.forumBalanceAfterPurchase}: ${quote.balance} ${quote.title} ${quote.unit}',
            actions: [
              PlatformAlertAction(label: s.cancel, isCancelAction: true),
              PlatformAlertAction(
                label: s.forumConfirm,
                onPressed: () {
                  confirmed = true;
                },
              ),
            ],
          );
          if (!mounted || !confirmed || !sameAccount(user)) return;
          final fresh = await client.quote(widget.tid, aid: widget.aid);
          if (!mounted || !sameAccount(user)) return;
          if (!quote.sameTerms(fresh)) {
            quote = fresh;
            continue;
          }
          submitted = true;
          await client.purchase(widget.tid, fresh, aid: widget.aid);
          break;
        }
      } else {
        submitted = true;
        await client.recommend(
          widget.tid,
          widget.formhash,
          positive: widget.positive,
        );
      }
      if (mounted && sameAccount(user)) {
        completed = true;
        completedAccount = '${user.uid}:${user.auth}';
        if (!widget.purchase) widget.onFeedbackAccepted?.call(widget.positive);
        widget.onChanged();
      }
    } catch (error) {
      if (!mounted || !sameAccount(user)) return;
      if (error is ForumApiException &&
          {
            'attachment_yetpay',
            'credits_buy_thread',
            'recommend_duplicate',
          }.contains(error.code)) {
        completed = true;
        completedAccount = '${user.uid}:${user.auth}';
        widget.onChanged();
        return;
      }
      await showPlatformAlert(
        context: context,
        title: s.forumActionFailed,
        message: error is ForumApiException
            ? error.toString()
            : (submitted ? s.forumSubmissionUnknown : s.forumLoadFailed),
        actions: [PlatformAlertAction(label: s.forumConfirm)],
      );
    } finally {
      if (mounted) {
        setState(() => busy = false);
        widget.onBusyChanged?.call(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = context.watch<DiscuzAndUserNotifier>().user;
    if (completedAccount != null &&
        completedAccount != '${account?.uid}:${account?.auth}') {
      completed = false;
      completedAccount = null;
    }
    return PlatformTextButton(
      onPressed: busy || completed || !widget.enabled ? null : run,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.icon != null) ...[
            Icon(widget.icon, size: 20),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              busy
                  ? S.of(context).forumWorking
                  : completed
                  ? (widget.purchase
                        ? S.of(context).forumPurchased
                        : (widget.icon != null
                              ? widget.label
                              : S.of(context).forumFeedbackSent))
                  : widget.label,
            ),
          ),
        ],
      ),
    );
  }
}

/// Discuz exposes whether feedback exists, but not its direction for this user.
class ThreadFeedbackBar extends StatefulWidget {
  final Discuz discuz;
  final int tid, positiveCount, negativeCount;
  final int sessionUid;
  final String formhash;
  final bool voted;
  final VoidCallback onChanged;
  const ThreadFeedbackBar({
    super.key,
    required this.discuz,
    required this.tid,
    required this.formhash,
    required this.voted,
    required this.sessionUid,
    required this.positiveCount,
    required this.negativeCount,
    required this.onChanged,
  });
  @override
  State<ThreadFeedbackBar> createState() => _ThreadFeedbackBarState();
}

class _ThreadFeedbackBarState extends State<ThreadFeedbackBar> {
  bool busy = false, sent = false;
  bool? acceptedDirection;
  String? accountKey;
  @override
  Widget build(BuildContext context) {
    final account = context.watch<DiscuzAndUserNotifier>();
    final user = account.user;
    final nextKey = '${user?.uid}:${user?.auth}';
    if (nextKey != accountKey) {
      accountKey = nextKey;
      busy = false;
      sent = false;
      acceptedDirection = null;
    }
    if (user == null ||
        user.uid <= 0 ||
        widget.sessionUid != user.uid ||
        widget.formhash.isEmpty ||
        account.discuz?.baseURL != widget.discuz.baseURL ||
        user.discuz.baseURL != widget.discuz.baseURL)
      return const SizedBox.shrink();
    final s = S.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              for (final positive
                  in acceptedDirection == null
                      ? [true, false]
                      : [acceptedDirection!])
                Expanded(
                  child: ForumActionButton(
                    key: ValueKey('$nextKey:$positive'),
                    discuz: widget.discuz,
                    tid: widget.tid,
                    formhash: widget.formhash,
                    positive: positive,
                    enabled: !busy && !sent && !widget.voted,
                    icon: positive
                        ? CupertinoIcons.hand_thumbsup
                        : CupertinoIcons.hand_thumbsdown,
                    label: acceptedDirection != null
                        ? (positive
                              ? s.forumRecommended
                              : s.forumNotRecommended)
                        : '${positive ? s.forumRecommend : s.forumDisrecommend} (${positive ? widget.positiveCount : widget.negativeCount})',
                    onFeedbackAccepted: (direction) {
                      setState(() => acceptedDirection = direction);
                    },
                    onBusyChanged: (value) {
                      if (mounted) setState(() => busy = value);
                    },
                    onChanged: () {
                      setState(() => sent = true);
                      widget.onChanged();
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
