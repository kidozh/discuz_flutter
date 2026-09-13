import 'package:flutter/cupertino.dart' show CupertinoIcons;
import '../utility/PlatformAdaptiveWidgets.dart';
import '../generated/l10n.dart';
import 'package:flutter/material.dart';

/// Compact embedded rating summary. The sliver path keeps long lists lazy.
class PostRatingsCard extends StatelessWidget {
  final String total;
  final List<String> rows;
  final bool asSliver;
  const PostRatingsCard({
    super.key,
    required this.total,
    required this.rows,
    this.asSliver = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final style = theme.textTheme.bodySmall?.copyWith(
      color: colors.onSurfaceVariant,
      fontSize: 12,
      height: 1.5,
    );
    final decoration = BoxDecoration(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: colors.outlineVariant.withValues(alpha: .5),
        width: .7,
      ),
    );
    Widget item(BuildContext context, int index) {
      if (index == 0) {
        final summary = total.replaceAll(RegExp(r'\s+'), ' ').trim();
        final spans = <TextSpan>[];
        var end = 0;
        for (final match in RegExp(
          r'[+\-−]\s*\d+(?:\.\d+)?',
        ).allMatches(summary)) {
          spans.add(TextSpan(text: summary.substring(end, match.start)));
          spans.add(
            TextSpan(
              text: match.group(0),
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
          end = match.end;
        }
        spans.add(TextSpan(text: summary.substring(end)));
        return Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
          child: Tooltip(
            message: summary,
            child: Row(
              children: [
                Icon(
                  isCupertino(context)
                      ? CupertinoIcons.star_fill
                      : Icons.star_rounded,
                  size: 16,
                  color: colors.primary,
                  semanticLabel: S.of(context).postRate,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: style?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      children: spans,
                    ),
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      final text = rows[index - 1];
      return Padding(
        padding: EdgeInsets.fromLTRB(14, 3, 14, index == rows.length ? 12 : 3),
        child: Tooltip(
          message: text,
          child: Text(
            text,
            style: style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    const margin = EdgeInsets.symmetric(horizontal: 8, vertical: 6);
    if (asSliver) {
      return SliverPadding(
        padding: margin,
        sliver: DecoratedSliver(
          decoration: decoration,
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              item,
              childCount: rows.length + 1,
            ),
          ),
        ),
      );
    }
    return Container(
      margin: margin,
      decoration: decoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [for (var i = 0; i <= rows.length; i++) item(context, i)],
      ),
    );
  }
}
