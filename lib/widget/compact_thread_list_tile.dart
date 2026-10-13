import 'package:flutter/material.dart';

/// Statistics share the author line and never reserve a separate footer.
class CompactThreadListTile extends StatelessWidget {
  const CompactThreadListTile({
    super.key,
    required this.title,
    required this.metadata,
    this.leading,
    this.statistics,
    this.badges = const [],
    this.preview,
  });
  final Widget title;
  final Widget metadata;
  final Widget? leading;
  final String? statistics;
  final List<Widget> badges;
  final Widget? preview;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 8)],
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(child: metadata),
                      if (statistics != null) ...[
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            statistics!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (badges.isNotEmpty) ...[
          const SizedBox(height: 4),
          Wrap(spacing: 8, runSpacing: 4, children: badges),
        ],
        if (preview != null) ...[const SizedBox(height: 6), preview!],
      ],
    ),
  );
}
