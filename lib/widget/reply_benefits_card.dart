import 'dart:async';

import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html;

import '../entity/reply_benefits.dart';
import '../generated/l10n.dart';
import '../utility/PlatformAdaptiveWidgets.dart';

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
    final titleStyle = Theme.of(context).textTheme.titleMedium;
    final rule = credit;
    final event = rush;
    final showCredit = pool > 0 && rule != null && rule.amount > 0;
    if (!showCredit && event == null) return const SizedBox.shrink();

    String plain(String value) => html.parseFragment(value).text?.trim() ?? '';
    Widget row(String name, String value) => Text('$name · ${plain(value)}');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: PlatformCard(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 5,
            children: [
              if (showCredit) ...[
                Text(strings.replyCreditTitle, style: titleStyle),
                Text(
                  strings.replyCreditEach(
                    rule.amount,
                    creditName?.isNotEmpty == true
                        ? creditName!
                        : strings.credit,
                  ),
                ),
                Text(
                  strings.replyCreditRemaining(
                    rule.remaining ?? pool ~/ rule.amount,
                  ),
                ),
                if (rule.perMember > 0)
                  Text(strings.replyCreditPerMember(rule.perMember)),
                if (rule.chance > 0 && rule.chance < 100)
                  Text(strings.replyCreditChance(rule.chance)),
              ],
              if (showCredit && event != null) const Divider(),
              if (event != null) ...[
                Text(strings.rushReplyTitle, style: titleStyle),
                if (event.startsAt.isNotEmpty)
                  row(strings.activityStarts, event.startsAt),
                if (event.endsAt.isNotEmpty)
                  row(strings.activityEnds, event.endsAt),
                if (event.deadline case final deadline?)
                  if (event.timerType == 'start' || event.timerType == 'end')
                    _RushCountdown(
                      key: ValueKey((deadline, event.timerType)),
                      deadline: deadline,
                      starts: event.timerType == 'start',
                    ),
                if (event.stopFloor > 0)
                  Text(strings.rushReplyStopFloor(event.stopFloor)),
                if (event.perMember > 0)
                  Text(strings.rushReplyPerMember(event.perMember)),
                if (event.rewardFloors.isNotEmpty)
                  row(strings.rushReplyRewardFloors, event.rewardFloors),
                if (event.creditLimit.isNotEmpty)
                  row(
                    strings.rushReplyMinimum,
                    '${event.creditLimit} ${event.creditName}'.trim(),
                  ),
                if (closed && event.timerType != 'start')
                  Text(strings.threadIsClosed),
              ],
            ],
          ),
        ),
      ),
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
    final time = [
      date.inHours.toString(),
      (date.inMinutes % 60).toString().padLeft(2, '0'),
      (date.inSeconds % 60).toString().padLeft(2, '0'),
    ].join(':');
    final s = S.of(context);
    return Text(
      widget.starts ? s.rushReplyStartsIn(time) : s.rushReplyEndsIn(time),
    );
  }
}
