import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:html/parser.dart' as html;
import 'package:intl/intl.dart';

import '../entity/SpecialThread.dart';
import '../generated/l10n.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../utility/best_answer_style.dart';
import 'post_status_badges.dart';
import 'debate_side_label.dart';

/// Thread details and actions based on the current forum response.
class SpecialThreadCard extends StatelessWidget {
  final RewardInfo? reward;
  final DebateInfo? debate;
  final ActivityInfo? activity;
  final ThreadSortInfo? threadSort;
  final List<TradeItem> tradeItems;
  final ValueChanged<int>? onOpenTrade;
  final DebateSide? debateFilter;
  final ValueChanged<DebateSide?>? onFilterDebate;
  final ValueChanged<DebateSide>? onSupportDebate;
  final ValueChanged<int> onSelectPost;
  final VoidCallback onOpenWebsite;
  final VoidCallback? onActivityRegistration, onActivityReview;
  const SpecialThreadCard({
    super.key,
    this.reward,
    this.debate,
    this.activity,
    this.threadSort,
    this.tradeItems = const [],
    this.onOpenTrade,
    this.debateFilter,
    this.onFilterDebate,
    this.onSupportDebate,
    required this.onSelectPost,
    required this.onOpenWebsite,
    this.onActivityRegistration,
    this.onActivityReview,
  });

  String _text(String value) => html.parseFragment(value).text ?? '';
  String _time(String value) {
    final seconds = int.tryParse(value);
    if (seconds == null) return _text(value);
    if (seconds <= 0 || seconds > 8640000000000) return '';
    return DateFormat.yMd().add_Hm().format(
      DateTime.fromMillisecondsSinceEpoch(seconds * 1000),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final sections = <Widget>[];
    Widget line(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text('$label：${_text(value)}', softWrap: true),
    );
    Widget section(String title, List<Widget> children) => Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          ...children,
        ],
      ),
    );
    final reward = this.reward;
    if (reward != null)
      sections.add(
        section(s.specialReward, [
          if (reward.price.isNotEmpty)
            line(s.specialRewardAmount, reward.price),
          if (reward.bestPid > 0)
            PlatformTextButton(
              onPressed: () => onSelectPost(reward.bestPid),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    PlatformIcons(context).bestAnswerSeal,
                    size: 18,
                    color: bestAnswerForeground(context),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      s.specialBestAnswer,
                      style: TextStyle(color: bestAnswerForeground(context)),
                    ),
                  ),
                ],
              ),
            ),
        ]),
      );
    if (debate case final d?) {
      sections.add(
        section(s.forumFilterSpecialTypeDebate, [
          for (final (side, point, votes) in [
            (DebateSide.affirm, d.affirm, d.affirmVotes),
            (DebateSide.against, d.against, d.againstVotes),
          ])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: debateSideColor(context, side).withValues(alpha: .065),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          DebateSideLabel(side),
                          const Spacer(),
                          if (votes != null)
                            Text(
                              s.debateVoteCount(votes),
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: debateSideColor(context, side),
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Text(_text(point)),
                      if (onSupportDebate != null)
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: PlatformTextButton(
                            alignment: AlignmentDirectional.centerEnd,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            onPressed: () => onSupportDebate!(side),
                            child: Text(
                              s.debateSupport,
                              style: TextStyle(
                                color: debateSideColor(context, side),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          if (onFilterDebate != null) ...[
            const SizedBox(height: 8),
            Text(
              s.debateFilterReplies,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                for (final side in <DebateSide?>[null, ...DebateSide.values])
                  PlatformChoiceChip(
                    label: Text(
                      side == null ? s.forumAll : debateSideName(s, side),
                    ),
                    selected: debateFilter == side,
                    onSelected: (_) => onFilterDebate!(side),
                  ),
              ],
            ),
          ],
          if (d.end.isNotEmpty && d.end != '0')
            line(s.activityEnds, _time(d.end)),
          if (d.verdict.isNotEmpty) line(s.debateVerdict, d.verdict),
        ]),
      );
    }
    final activity = this.activity;
    if (activity != null) {
      final joinBlockedByCapacity = activity.status == 'join' && activity.full;
      final status = switch (activity.status) {
        'wait' => s.activityWaiting,
        'joined' => s.activityJoined,
        'join' when joinBlockedByCapacity => s.activityFull,
        'join' => s.activityCanJoin,
        'complete' => s.activityComplete,
        _ => '',
      };
      sections.add(
        section(s.specialActivity, [
          if (activity.place.isNotEmpty) line(s.activityPlace, activity.place),
          if (_time(activity.startsAt).isNotEmpty)
            line(s.activityStarts, _time(activity.startsAt)),
          if (_time(activity.endsAt).isNotEmpty)
            line(s.activityEnds, _time(activity.endsAt)),
          if (activity.applicants != null)
            line(s.activityApplicants, '${activity.applicants}'),
          if (activity.cost.isNotEmpty) line(s.activityCost, activity.cost),
          if (status.isNotEmpty) Text(status),
          if (activity.closed) Text(s.activityClosed),
          if (onActivityRegistration != null &&
              !activity.closed &&
              !joinBlockedByCapacity)
            PlatformTextButton(
              onPressed: onActivityRegistration,
              child: Text(s.activityRegistration),
            ),
          if (onActivityReview != null)
            PlatformTextButton(
              onPressed: onActivityReview,
              child: Text(s.activityReview),
            ),
          PlatformTextButton(
            onPressed: onOpenWebsite,
            child: Text(s.specialOpenWebsite),
          ),
        ]),
      );
    }
    final sort = threadSort;
    if (sort != null)
      sections.add(
        section(sort.name.isEmpty ? s.specialClassified : _text(sort.name), [
          for (final option in sort.options)
            line(_text(option.title), '${option.value} ${option.unit}'.trim()),
          PlatformTextButton(
            onPressed: onOpenWebsite,
            child: Text(s.specialOpenWebsite),
          ),
        ]),
      );
    if (tradeItems.isNotEmpty)
      sections.add(
        section(s.tradeItems, [
          for (final item in tradeItems)
            PlatformListTile(
              leading: Icon(
                PlatformIcons(context)
                    .pick(Icons.shopping_bag_outlined, CupertinoIcons.bag),
              ),
              title: Text(_text(item.title)),
              subtitle: Text(
                [
                  if (item.price.isNotEmpty) '¥${item.price}',
                  if (item.credit.isNotEmpty) '${item.credit} ${s.credit}',
                  if (item.stock != null) '${s.tradeStock} ${item.stock}',
                  if (item.days == -1) s.tradeExpired,
                  if ((item.days ?? 0) > 0 || (item.hours ?? 0) > 0)
                    '${s.tradeExpires} · ${Duration(days: item.days ?? 0, hours: item.hours ?? 0).inHours} h',
                ].join(' · '),
              ),
              trailing: Icon(
                PlatformIcons(context).forward,
                semanticLabel: s.tradeOpenItem,
              ),
              onTap: onOpenTrade == null ? null : () => onOpenTrade!(item.pid),
            ),
        ]),
      );
    if (sections.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: PlatformCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: sections,
        ),
      ),
    );
  }
}

/// Compact public reward summary shown directly after the opening post.
class ThreadRewardPill extends StatelessWidget {
  final RewardInfo reward;
  final ValueChanged<int> onSelectPost;
  const ThreadRewardPill({
    super.key,
    required this.reward,
    required this.onSelectPost,
  });

  @override
  Widget build(BuildContext context) {
    final amount = (html.parseFragment(reward.price).text ?? '').trim();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ForumRewardBadge(
              label:
                  '${S.of(context).specialReward}${amount.isEmpty ? '' : ' · $amount'}',
              icon: PlatformIcons(context).bounty,
            ),
            if (reward.bestPid > 0)
              PlatformTextButton(
                onPressed: () => onSelectPost(reward.bestPid),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                color: isMaterial(context)
                    ? bestAnswerBackground(context)
                    : null,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PlatformIcons(context).bestAnswerSeal,
                      size: 18,
                      color: bestAnswerForeground(context),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        S.of(context).specialBestAnswer,
                        style: TextStyle(color: bestAnswerForeground(context)),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
