import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../client/forum_web_features.dart';
import '../utility/PlatformAdaptiveWidgets.dart';

/// Each search hit keeps its title, excerpt and forum metadata distinct.
class ForumSearchResultCard extends StatelessWidget {
  const ForumSearchResultCard({
    required this.hit,
    required this.keyword,
    required this.onTap,
    super.key,
  });
  final ForumSearchHit hit;
  final String keyword;
  final VoidCallback onTap;

  Widget _highlight(
    BuildContext context,
    String text,
    TextStyle? style, {
    required int maxLines,
  }) {
    final colors = Theme.of(context).colorScheme;
    final terms =
        keyword
            .trim()
            .split(RegExp(r'\s+'))
            .where(
              (word) =>
                  word.isNotEmpty &&
                  !{'AND', 'OR'}.contains(word.toUpperCase()),
            )
            .toList()
          ..sort((a, b) => b.length.compareTo(a.length));
    final spans = <TextSpan>[];
    var end = 0;
    if (terms.isNotEmpty) {
      final pattern = RegExp(
        terms.map(RegExp.escape).join('|'),
        caseSensitive: false,
      );
      for (final match in pattern.allMatches(text)) {
        if (match.start > end) {
          spans.add(TextSpan(text: text.substring(end, match.start)));
        }
        spans.add(
          TextSpan(
            text: match.group(0),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: colors.onSecondaryContainer,
              backgroundColor: colors.secondaryContainer,
            ),
          ),
        );
        end = match.end;
      }
    }
    if (end < text.length) spans.add(TextSpan(text: text.substring(end)));
    return Text.rich(
      TextSpan(children: spans),
      style: style,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondary = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          if (hit.board.isNotEmpty)
            Row(
              children: [
                Icon(
                  PlatformIcons(context)
                      .pick(Icons.folder_outlined, CupertinoIcons.folder),
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    hit.board,
                    style: secondary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          _highlight(
            context,
            hit.title,
            theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            maxLines: 3,
          ),
          if (hit.excerpt.isNotEmpty)
            _highlight(
              context,
              hit.excerpt,
              theme.textTheme.bodyMedium,
              maxLines: 3,
            ),
          if (hit.attribution.isNotEmpty)
            Text(hit.attribution, style: secondary),
          if (hit.details.isNotEmpty) Text(hit.details, style: secondary),
        ],
      ),
    );
    return PlatformCard(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: isCupertino(context)
          ? CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onTap,
              child: content,
            )
          : InkWell(onTap: onTap, child: content),
    );
  }
}
