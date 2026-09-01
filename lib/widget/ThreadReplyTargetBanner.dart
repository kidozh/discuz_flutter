import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';

/// The selected-post preview shown above the thread composer.
class ThreadReplyTargetBanner extends StatelessWidget {
  final String author;
  final String messageHtml;
  final String picturePlaceholder;
  final VoidCallback onDismiss;
  final bool embeddedInComposer;

  const ThreadReplyTargetBanner({
    required this.author,
    required this.messageHtml,
    required this.picturePlaceholder,
    required this.onDismiss,
    this.embeddedInComposer = false,
    super.key,
  });

  static String plainTextPreview(String html, String picturePlaceholder) {
    final source = html.replaceAll(
      RegExp(r'<img\b[^>]*>', caseSensitive: false, dotAll: true),
      picturePlaceholder,
    );
    final fragment = parseFragment(source);
    for (final element in fragment.querySelectorAll('script, style')) {
      element.remove();
    }
    return (fragment.text ?? '').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final preview = plainTextPreview(messageHtml, picturePlaceholder);

    final content = Row(
      children: [
        Icon(
          isCupertino(context)
              ? CupertinoIcons.reply_thick_solid
              : Icons.reply_rounded,
          size: 18,
          color: colors.primary,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (preview.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  preview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        PlatformIconButton(
          liquidGlassSymbol: 'xmark',
          liquidGlassButtonSize: 44,
          liquidGlassIconSize: 14,
          icon: Icon(
            isCupertino(context) ? CupertinoIcons.xmark : Icons.close_rounded,
            size: 18,
            color: colors.onSurfaceVariant,
            semanticLabel: MaterialLocalizations.of(context).closeButtonTooltip,
          ),
          onPressed: onDismiss,
        ),
      ],
    );

    if (embeddedInComposer) {
      return Container(
        key: const ValueKey('thread-reply-target-banner'),
        margin: const EdgeInsets.fromLTRB(3, 2, 3, 4),
        padding: const EdgeInsetsDirectional.fromSTEB(8, 5, 2, 5),
        decoration: BoxDecoration(
          color: colors.primary.withValues(
            alpha: theme.brightness == Brightness.dark ? 0.14 : 0.075,
          ),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: colors.primary.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.26 : 0.14,
            ),
            width: 0.7,
          ),
        ),
        child: content,
      );
    }

    return PlatformLiquidGlassCard(
      key: const ValueKey('thread-reply-target-banner'),
      margin: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      padding: const EdgeInsetsDirectional.fromSTEB(10, 7, 4, 7),
      borderRadius: BorderRadius.circular(20),
      tintColor: colors.primary,
      child: content,
    );
  }
}
