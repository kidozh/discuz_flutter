import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Native presentation for HTML block quotes and Discuz reply excerpts.
class DiscuzQuoteBlock extends StatelessWidget {
  final Widget child;

  const DiscuzQuoteBlock({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final background = isCupertino(context)
        ? CupertinoColors.tertiarySystemFill.resolveFrom(context)
        : colors.surfaceContainerHighest;
    return Semantics(
      container: true,
      child: Container(
        key: const ValueKey('discuz-quote-block'),
        margin: const EdgeInsets.only(top: 4, bottom: 2),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(10),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            PositionedDirectional(
              start: 0,
              top: 0,
              bottom: 0,
              child: ColoredBox(
                key: const ValueKey('discuz-quote-accent'),
                color: colors.primary.withValues(alpha: 0.65),
                child: const SizedBox(width: 3),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(13, 9, 12, 9),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
