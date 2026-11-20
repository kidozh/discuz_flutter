import 'dart:async';

import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html;

import '../entity/reply_benefits.dart';
import '../generated/l10n.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import 'post_status_badges.dart';

class ReplyBenefitsCard extends StatelessWidget {
  const ReplyBenefitsCard({
    super.key,
    required this.pool,
    required this.credit,
    required this.rush,
    required this.closed,
    this.creditName,
  });

  final int pool;
  final ReplyCreditRule? credit;
  final RushReplyInfo? rush;
  final bool closed;
  final String? creditName;

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);
    final rule = credit;
    final event = rush;
    final showCredit = pool > 0 && rule != null && rule.amount > 0;
    if (!showCredit && event == null) return const SizedBox.shrink();
    final unit = creditName?.trim();
    final creditUnit = unit == null || unit.isEmpty ? strings.credit : unit;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DefaultTextStyle.merge(
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6,
          children: [
            if (showCredit) ...[
              Wrap(
                spacing: 10,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ForumRewardBadge(
                    label:
                        '${strings.replyCreditTitle} · ${rule.amount} $creditUnit',
                    description:
                        '${strings.replyCreditTitle} · ${strings.replyCreditEach(rule.amount, creditUnit)}',
                    icon: PlatformIcons(context).replyReward,
                  ),
                  Text(
                    strings.replyCreditRemaining(
                      rule.remaining ?? pool ~/ rule.amount,
                    ),
                  ),
                ],
              ),
              if (rule.perMember > 0 || (rule.chance > 0 && rule.chance < 100))
                Text(
                  [
                    if (rule.perMember > 0)
                      strings.replyCreditPerMember(rule.perMember),
                    if (rule.chance > 0 && rule.chance < 100)
                      strings.replyCreditChance(rule.chance),
                  ].join(' · '),
                ),
            ],
            if (event != null) _RushRules(event: event, closed: closed),
          ],
        ),
      ),
    );
  }
}

class _RushRules extends StatefulWidget {
  const _RushRules({required this.event, required this.closed});
  final RushReplyInfo event;
  final bool closed;

  @override
  State<_RushRules> createState() => _RushRulesState();
}

class _RushRulesState extends State<_RushRules> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final icons = PlatformIcons(context);
    final event = widget.event;
    String plain(String value) => html.parseFragment(value).text?.trim() ?? '';
    final details = [
      if (event.startsAt.isNotEmpty)
        '${s.activityStarts} · ${plain(event.startsAt)}',
      if (event.endsAt.isNotEmpty) '${s.activityEnds} · ${plain(event.endsAt)}',
      if (event.stopFloor > 0) s.rushReplyStopFloor(event.stopFloor),
      if (event.perMember > 0) s.rushReplyPerMember(event.perMember),
      if (event.creditLimit.isNotEmpty)
        '${s.rushReplyMinimum} · ${plain('${event.creditLimit} ${event.creditName}').trim()}',
    ];
    final heading = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icons.flag, size: 16),
        const SizedBox(width: 5),
        Flexible(child: Text(s.rushReplyTitle)),
        if (details.isNotEmpty) ...[
          const SizedBox(width: 3),
          RotatedBox(
            quarterTurns: expanded ? 2 : 0,
            child: Icon(icons.expandMore, size: 16),
          ),
        ],
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (details.isEmpty)
              heading
            else
              Semantics(
                expanded: expanded,
                child: PlatformTextButton(
                  alignment: AlignmentDirectional.centerStart,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  onPressed: () => setState(() => expanded = !expanded),
                  child: heading,
                ),
              ),
            if (event.rewardFloors.isNotEmpty)
              Text('${s.rushReplyRewardFloors} · ${plain(event.rewardFloors)}'),
            if (widget.closed && event.timerType != 'start')
              Text(s.threadIsClosed)
            else if (event.deadline case final deadline?)
              if (event.timerType == 'start' || event.timerType == 'end')
                _RushCountdown(
                  key: ValueKey((deadline, event.timerType)),
                  deadline: deadline,
                  starts: event.timerType == 'start',
                ),
          ],
        ),
        if (expanded && details.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Wrap(
              spacing: 14,
              runSpacing: 4,
              children: [for (final line in details) Text(line)],
            ),
          ),
      ],
    );
  }
}

class _RushCountdown extends StatefulWidget {
  const _RushCountdown({
    super.key,
    required this.deadline,
    required this.starts,
  });

  final DateTime deadline;
  final bool starts;

  @override
  State<_RushCountdown> createState() => _RushCountdownState();
}

class _RushCountdownState extends State<_RushCountdown> {
  Timer? timer;

  @override
  void initState() {
    super.initState();
    if (widget.deadline.isAfter(DateTime.now())) {
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {});
        if (!widget.deadline.isAfter(DateTime.now())) timer.cancel();
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.deadline.difference(DateTime.now()).inSeconds;
    if (remaining <= 0) return const SizedBox.shrink();
    final date = Duration(seconds: remaining);
    final s = S.of(context);
    final time = date.inDays > 0
        ? '${date.inDays}${s.day} ${date.inHours % 24}${s.hour}'
        : [
            date.inHours,
            date.inMinutes % 60,
            date.inSeconds % 60,
          ].map((value) => value.toString().padLeft(2, '0')).join(':');
    return Text(
      widget.starts ? s.rushReplyStartsIn(time) : s.rushReplyEndsIn(time),
    );
  }
}
