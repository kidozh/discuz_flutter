import 'package:flutter/material.dart';

import '../entity/SpecialThread.dart';
import '../generated/l10n.dart';

String debateSideName(S strings, DebateSide side) => switch (side) {
  DebateSide.affirm => strings.debateAffirm,
  DebateSide.against => strings.debateAgainst,
  DebateSide.neutral => strings.debateNeutral,
};

Color debateSideColor(BuildContext context, DebateSide side) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  return switch (side) {
    DebateSide.affirm =>
      dark ? const Color(0xffff9aa6) : const Color(0xffa92342),
    DebateSide.against =>
      dark ? const Color(0xff9abdff) : const Color(0xff2455aa),
    DebateSide.neutral => Theme.of(context).colorScheme.onSurfaceVariant,
  };
}

class DebateSideLabel extends StatelessWidget {
  const DebateSideLabel(this.side, {super.key});
  final DebateSide side;

  @override
  Widget build(BuildContext context) {
    final color = debateSideColor(context, side);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: color.withValues(alpha: .12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Text(
          debateSideName(S.of(context), side),
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: color, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
