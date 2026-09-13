import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html;
import 'package:intl/intl.dart';
import '../entity/SpecialThread.dart';
import '../generated/l10n.dart';
import '../utility/PlatformAdaptiveWidgets.dart';

/// Only server-returned public fields are shown; forms are handled by the site.
class SpecialThreadCard extends StatelessWidget {
  final RewardInfo? reward;
  final ActivityInfo? activity;
  final ThreadSortInfo? threadSort;
  final ValueChanged<int> onSelectPost;
  final VoidCallback onOpenWebsite;
  final VoidCallback? onActivityRegistration;
  const SpecialThreadCard({
    super.key,
    this.reward,
    this.activity,
    this.threadSort,
    required this.onSelectPost,
    required this.onOpenWebsite,
    this.onActivityRegistration,
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
              child: Text(s.specialBestAnswer),
            ),
        ]),
      );
    final activity = this.activity;
    if (activity != null) {
      final status = switch (activity.status) {
        'wait' => s.activityWaiting,
        'joined' => s.activityJoined,
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
          if (onActivityRegistration != null && !activity.closed)
            PlatformTextButton(
              onPressed: onActivityRegistration,
              child: Text(s.activityRegistration),
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
    final colors = Theme.of(context).colorScheme;
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
            DecoratedBox(
              decoration: ShapeDecoration(
                color: colors.tertiaryContainer.withValues(alpha: 0.65),
                shape: const StadiumBorder(),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.monetization_on_outlined,
                      size: 16,
                      color: colors.onTertiaryContainer,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '${S.of(context).specialReward}${amount.isEmpty ? '' : ' · $amount'}',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: colors.onTertiaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (reward.bestPid > 0)
              Material(
                type: MaterialType.transparency,
                child: TextButton.icon(
                  onPressed: () => onSelectPost(reward.bestPid),
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: Text(S.of(context).specialBestAnswer),
                  style: TextButton.styleFrom(
                    shape: const StadiumBorder(),
                    visualDensity: VisualDensity.compact,
                    foregroundColor: colors.primary,
                    backgroundColor: colors.primaryContainer.withValues(
                      alpha: 0.45,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
