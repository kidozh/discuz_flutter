import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../generated/l10n.dart';

/// Full-width titles; posts with text receive a two-line editorial preview.
class CompactThreadListTile extends StatelessWidget {
  const CompactThreadListTile({
    super.key,
    required this.title,
    required this.metadata,
    this.leading,
    this.statistics,
    this.badges = const [],
    this.message = '',
    this.previewColor,
    this.thumbnail,
    this.replyPreview,
  });
  final Widget title;
  final Widget metadata;
  final Widget? leading;
  final Widget? statistics;
  final List<Widget> badges;
  final String message;
  final Color? previewColor;
  final Widget? thumbnail;
  final Widget? replyPreview;

  @override
  Widget build(BuildContext context) {
    final hasMessage = message.trim().isNotEmpty;
    return Padding(
      key: ValueKey(hasMessage ? 'thread-with-message' : 'thread-title-only'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) => Row(
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 5)],
                Expanded(child: metadata),
                if (badges.isNotEmpty) ...[
                  const SizedBox(width: 5),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth * 0.2,
                    ),
                    child: Wrap(spacing: 4, children: badges),
                  ),
                ],
                if (statistics != null) ...[
                  const SizedBox(width: 7),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth * 0.45,
                    ),
                    child: statistics!,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    if (hasMessage) ...[
                      const SizedBox(height: 4),
                      Text(
                        message,
                        key: const ValueKey('thread-message-preview'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.3,
                          color:
                              previewColor ??
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (thumbnail != null) ...[
                const SizedBox(width: 10),
                SizedBox(
                  width: hasMessage ? 76 : 56,
                  height: hasMessage ? 72 : 48,
                  child: thumbnail,
                ),
              ],
            ],
          ),
          if (replyPreview != null) ...[
            const SizedBox(height: 4),
            replyPreview!,
          ],
        ],
      ),
    );
  }
}

class ThreadListStatistics extends StatelessWidget {
  const ThreadListStatistics({
    super.key,
    required this.views,
    required this.replies,
    this.color,
  });
  final String views;
  final int replies;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final format = NumberFormat.compact(
      locale: Localizations.localeOf(context).toString(),
    );
    final numericViews = num.tryParse(views.replaceAll(',', ''));
    final labelStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      fontSize: 11,
      color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
    );
    return Semantics(
      label: '${strings.threadView(views)} · ${strings.threadReply(replies)}',
      child: ExcludeSemantics(
        child: IconTheme.merge(
          data: IconThemeData(size: 12, color: labelStyle?.color),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.visibility_outlined),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  numericViews == null ? views : format.format(numericViews),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: labelStyle,
                ),
              ),
              const SizedBox(width: 7),
              const Icon(Icons.chat_bubble_outline),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  format.format(replies),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: labelStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
