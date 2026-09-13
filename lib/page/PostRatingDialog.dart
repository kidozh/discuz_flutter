import '../utility/rating_allowance_cache.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../client/PostReviewClient.dart';
import '../client/ForumInteractionClient.dart';
import '../generated/l10n.dart';
import '../utility/PlatformAdaptiveWidgets.dart';

class PostRatingDialog extends StatefulWidget {
  final PostReviewClient client;
  final String? quotaKey;
  final int tid, pid, uid;
  final bool Function() sameAccount;
  const PostRatingDialog({
    super.key,
    required this.client,
    this.quotaKey,
    required this.tid,
    required this.pid,
    required this.uid,
    required this.sameAccount,
  });
  @override
  State<PostRatingDialog> createState() => _PostRatingDialogState();
}

class _PostRatingDialogState extends State<PostRatingDialog> {
  RatingForm? form;
  final controllers = <String, TextEditingController>{};
  final reason = TextEditingController();
  bool busy = true, notify = false;
  String? error;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      await widget.client.validate(
        widget.tid,
        widget.pid,
        widget.uid,
        widget.sameAccount,
      );
      final result = await widget.client.ratingForm(widget.tid, widget.pid);
      if (!mounted || !widget.sameAccount()) return;
      form = result;
      if (widget.quotaKey != null)
        RatingAllowanceCache.remember(widget.quotaKey!, result);
      for (final credit in result.credits) {
        controllers[credit.field] = TextEditingController(text: '0');
      }
    } catch (_) {
      if (mounted) error = S.of(context).postRatingUnavailable;
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> submit() async {
    if (busy || form == null) return;
    final scores = <String, int>{};
    for (final c in form!.credits) {
      final score = int.tryParse(controllers[c.field]!.text.trim());
      if (score == null ||
          (score != 0 &&
              (score < c.min || score > c.max || score.abs() > c.remaining))) {
        setState(() => error = S.of(context).postRatingInvalid);
        return;
      }
      scores[c.field] = score;
    }
    if (!scores.values.any((v) => v != 0)) {
      setState(() => error = S.of(context).postRatingInvalid);
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.client.validate(
        widget.tid,
        widget.pid,
        widget.uid,
        widget.sameAccount,
      );
      final fresh = await widget.client.ratingForm(widget.tid, widget.pid);
      if (!mounted || !widget.sameAccount()) return;
      if (widget.quotaKey != null)
        RatingAllowanceCache.remember(widget.quotaKey!, fresh);
      if (!form!.sameTerms(fresh)) {
        for (final c in fresh.credits) {
          controllers.putIfAbsent(
            c.field,
            () => TextEditingController(text: '0'),
          );
        }
        setState(() {
          form = fresh;
          error = S.of(context).postRatingChanged;
        });
        return;
      }
      await widget.client.rate(
        widget.tid,
        widget.pid,
        fresh,
        scores,
        reason.text.trim(),
        notify,
      );
      if (mounted && widget.sameAccount()) {
        if (widget.quotaKey != null)
          RatingAllowanceCache.remember(widget.quotaKey!, fresh, used: scores);
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted)
        setState(
          () => error = e is ForumApiException && e.message.isNotEmpty
              ? e.message
              : S.of(context).forumSubmissionUnknown,
        );
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  void dispose() {
    for (final c in controllers.values) {
      c.dispose();
    }
    reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return PopScope(
      canPop: !busy,
      child: PlatformAlertDialog(
        glassBackgroundColor: CupertinoColors.systemBackground
            .resolveFrom(context)
            .withValues(alpha: .72),
        title: Text(s.postRate),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (busy) const PlatformCircularProgressIndicator(),
            if (form != null) ...[
              for (final c in form!.credits)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${c.title}\n${c.min} ~ ${c.max} · ${s.postRatingRemaining}: ${c.remaining}',
                        ),
                      ),
                      SizedBox(
                        width: 72,
                        child: PlatformTextField(
                          controller: controllers[c.field],
                          enabled: !busy,
                          keyboardType: const TextInputType.numberWithOptions(
                            signed: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (form!.notice.isNotEmpty) Text(form!.notice),
              const SizedBox(height: 8),
              PlatformTextField(
                controller: reason,
                enabled: !busy,
                hintText: s.postRatingReason,
                maxLines: 2,
              ),
              Row(
                children: [
                  Expanded(child: Text(s.postRatingNotify)),
                  PlatformSwitch(
                    value: notify || form!.notifyRequired,
                    onChanged: busy || form!.notifyRequired
                        ? null
                        : (value) => setState(() => notify = value),
                  ),
                ],
              ),
            ],
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(error!),
              ),
          ],
        ),
        actions: [
          PlatformDialogAction(
            onPressed: busy ? null : () => Navigator.pop(context),
            child: Text(s.cancel),
          ),
          PlatformDialogAction(
            onPressed: busy || form == null ? null : submit,
            child: Text(s.forumConfirm),
          ),
        ],
      ),
    );
  }
}
