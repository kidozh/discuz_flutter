import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../generated/l10n.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../utility/forum_web_location.dart';

/// Lives outside the WebView so the notice remains visible while scrolling.
class ForumWebLocationBanner extends StatelessWidget {
  const ForumWebLocationBanner({
    required this.forumUrl,
    required this.pageUrl,
    super.key,
  });

  final String forumUrl;
  final String pageUrl;

  @override
  Widget build(BuildContext context) {
    if (pageUrl.isEmpty || isForumWebLocation(forumUrl, pageUrl)) {
      return const SizedBox.shrink();
    }
    final ios = isCupertino(context);
    final theme = Theme.of(context);
    final accent = ios
        ? CupertinoColors.systemOrange.resolveFrom(context)
        : theme.colorScheme.tertiary;
    final foreground = ios
        ? CupertinoColors.label.resolveFrom(context)
        : theme.colorScheme.onSurface;
    final secondary = ios
        ? CupertinoColors.secondaryLabel.resolveFrom(context)
        : theme.colorScheme.onSurfaceVariant;
    final address = forumWebLocationLabel(pageUrl);
    return Semantics(
      container: true,
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: accent.withValues(alpha: .10),
          border: Border(
            bottom: BorderSide(color: accent.withValues(alpha: .22)),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(
                ios ? CupertinoIcons.info_circle : Icons.info_outline,
                color: accent,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      S.of(context).browserOutsideForum,
                      style: TextStyle(
                        color: foreground,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      address,
                      textDirection: TextDirection.ltr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: secondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
