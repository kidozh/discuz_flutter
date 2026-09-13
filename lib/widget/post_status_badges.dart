import '../entity/SpecialThread.dart';
import 'package:html/parser.dart' show parseFragment;
import 'package:flutter/material.dart';

import '../generated/l10n.dart';
import '../utility/PlatformAdaptiveWidgets.dart';

/// Compact post moderation labels, shared by paginated and sliver readers.
class PostStatusBadges extends StatelessWidget {
  final bool blocked;
  final bool warned;
  final bool revised;
  final RewardInfo? reward;
  final ValueChanged<int>? onSelectPost;

  const PostStatusBadges({
    required this.blocked,
    required this.warned,
    required this.revised,
    this.reward,
    this.onSelectPost,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (!blocked && !warned && !revised && reward == null)
      return const SizedBox.shrink();
    final strings = S.of(context);
    final amount = parseFragment(reward?.price ?? '').text?.trim() ?? '';
    final rewardLabel =
        '${strings.specialReward}${amount.isEmpty ? '' : ' · $amount'}';
    final dark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            if (reward != null)
              _StatusBadge(
                label: rewardLabel,
                description: rewardLabel,
                icon: Icons.monetization_on_outlined,
                foreground: colors.onTertiaryContainer,
                background: colors.tertiaryContainer,
              ),
            if (reward != null && reward!.bestPid > 0 && onSelectPost != null)
              Semantics(
                button: true,
                onTap: () => onSelectPost!(reward!.bestPid),
                child: GestureDetector(
                  excludeFromSemantics: true,
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onSelectPost!(reward!.bestPid),
                  child: _StatusBadge(
                    label: strings.specialBestAnswer,
                    description: strings.specialBestAnswer,
                    icon: Icons.check_circle_outline,
                    foreground: colors.onPrimaryContainer,
                    background: colors.primaryContainer,
                  ),
                ),
              ),
            if (blocked)
              _StatusBadge(
                label: strings.postBlockedLabel,
                description: strings.blockedPost,
                icon: PlatformIcons(context).blocked,
                foreground: colors.onErrorContainer,
                background: colors.errorContainer,
              ),
            if (warned)
              _StatusBadge(
                label: strings.postWarnedLabel,
                description: strings.warnedPost,
                icon: PlatformIcons(context).warning,
                foreground: dark
                    ? const Color(0xFFFFDDB0)
                    : const Color(0xFF6B3E00),
                background: dark
                    ? const Color(0xFF503000)
                    : const Color(0xFFFFEBCB),
              ),
            if (revised)
              _StatusBadge(
                label: strings.postRevisedLabel,
                description: strings.revisedPost,
                icon: PlatformIcons(context).edit,
                foreground: colors.onSecondaryContainer,
                background: colors.secondaryContainer,
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final Color foreground;
  final Color background;

  const _StatusBadge({
    required this.label,
    required this.description,
    required this.icon,
    required this.foreground,
    required this.background,
  });

  @override
  Widget build(BuildContext context) => Tooltip(
    message: description,
    excludeFromSemantics: true,
    child: Semantics(
      label: description,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: background,
          shape: const StadiumBorder(),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: foreground),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
