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
  final bool isBestAnswer;
  final ValueChanged<int>? onSelectPost;

  const PostStatusBadges({
    required this.blocked,
    required this.warned,
    required this.revised,
    this.reward,
    this.isBestAnswer = false,
    this.onSelectPost,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (!blocked && !warned && !revised && reward == null && !isBestAnswer)
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
            if (isBestAnswer)
              _StatusBadge(
                label: strings.specialBestAnswer,
                description: strings.specialBestAnswer,
                icon: Icons.verified_outlined,
                laurel: true,
                foreground: dark
                    ? const Color(0xFFFFD980)
                    : const Color(0xFF765000),
                background: dark
                    ? const Color(0xFF463619)
                    : const Color(0xFFFFF0C7),
              ),
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
  final bool laurel;
  final Color foreground;
  final Color background;

  const _StatusBadge({
    required this.label,
    required this.description,
    required this.icon,
    this.laurel = false,
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
              if (laurel)
                CustomPaint(
                  size: const Size(22, 22),
                  painter: _LaurelPainter(foreground),
                )
              else
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

/// Symmetrical leafy branches frame a small award star.
class _LaurelPainter extends CustomPainter {
  final Color color;
  const _LaurelPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);
    final paint = Paint()..color = color;
    for (final side in [-1.0, 1.0]) {
      canvas.save();
      canvas.translate(12, 0);
      canvas.scale(side, 1);
      final stem = Path()
        ..moveTo(1, 21)
        ..quadraticBezierTo(12, 16, 7, 3);
      canvas.drawPath(
        stem,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      for (var i = 0; i < 5; i++) {
        final y = 5.0 + i * 3;
        final x = i == 4 ? 5.0 : 8.0;
        final leaf = Path()
          ..moveTo(x, y + 3)
          ..quadraticBezierTo(x + 5, y + 1, x + 2, y - 2)
          ..quadraticBezierTo(x - 1, y, x, y + 3);
        canvas.drawPath(leaf, paint);
      }
      canvas.restore();
    }
    final star = Path()
      ..moveTo(12, 7)
      ..lineTo(13.3, 10)
      ..lineTo(16.5, 10.3)
      ..lineTo(14, 12.4)
      ..lineTo(14.8, 15.5)
      ..lineTo(12, 13.8)
      ..lineTo(9.2, 15.5)
      ..lineTo(10, 12.4)
      ..lineTo(7.5, 10.3)
      ..lineTo(10.7, 10)
      ..close();
    canvas.drawPath(star, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LaurelPainter oldDelegate) => oldDelegate.color != color;
}
