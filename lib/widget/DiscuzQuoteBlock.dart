import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Native quote presentation for HTML `blockquote` and Discuz `.quote` nodes.
class DiscuzQuoteBlock extends StatelessWidget {
  final Widget child;

  const DiscuzQuoteBlock({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final borderRadius = BorderRadius.circular(16);
    final borderColor = colors.onSurface.withValues(
      alpha: dark ? 0.24 : 0.13,
    );
    final accentColor = colors.primary.withValues(alpha: dark ? 0.86 : 0.74);

    final quoteContent = ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        children: [
          PositionedDirectional(
            start: 0,
            top: 0,
            bottom: 0,
            child: Container(
              key: const ValueKey('discuz-quote-accent'),
              width: 3.5,
              color: accentColor,
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(15, 12, 14, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.primary.withValues(
                      alpha: dark ? 0.20 : 0.10,
                    ),
                    border: Border.all(
                      color: colors.primary.withValues(
                        alpha: dark ? 0.34 : 0.20,
                      ),
                      width: 0.7,
                    ),
                  ),
                  child: Icon(
                    isCupertino(context)
                        ? CupertinoIcons.quote_bubble
                        : Icons.format_quote_rounded,
                    size: 17,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );

    final insideGlass = isInsidePlatformLiquidGlassContainer(context);
    final surface = usesAppleTranslucentSurface(context) && !insideGlass
        ? PlatformLiquidGlassCard(
            borderRadius: borderRadius,
            tintColor: colors.primary,
            child: quoteContent,
          )
        : Container(
            decoration: BoxDecoration(
              color: usesAppleTranslucentSurface(context)
                  ? colors.surface.withValues(alpha: dark ? 0.20 : 0.30)
                  : Color.alphaBlend(
                      colors.primary.withValues(alpha: dark ? 0.10 : 0.045),
                      colors.surfaceContainerLow,
                    ),
              borderRadius: borderRadius,
              border: Border.all(color: borderColor, width: 0.8),
              boxShadow: dark || insideGlass
                  ? null
                  : [
                      BoxShadow(
                        color: colors.shadow.withValues(alpha: 0.045),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: quoteContent,
          );

    return Semantics(
      container: true,
      child: Container(
        key: const ValueKey('discuz-quote-block'),
        margin: const EdgeInsets.symmetric(vertical: 9),
        child: surface,
      ),
    );
  }
}
