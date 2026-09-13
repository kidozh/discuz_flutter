import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/JsonResult/ViewThreadResult.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' show parseFragment;

class PostCommentWidget extends StatelessWidget {
  final Comment _comment;
  final Color? textColor;

  const PostCommentWidget(this._comment, {super.key, this.textColor});

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: textColor ?? Theme.of(context).colorScheme.onSurface,
    );
    final author = parseFragment(_comment.author).text ?? '';
    final fallback = ColoredBox(
      color: CustomizeColor.getColorBackgroundById(_comment.authorId),
      child: Center(
        child: Text(
          author.isEmpty ? '?' : author.characters.first,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlatformLiquidGlassAvatar(
            size: 24,
            child: _comment.avatar.isEmpty
                ? fallback
                : CachedNetworkImage(
                    imageUrl: _comment.avatar,
                    fit: BoxFit.cover,
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) =>
                            PlatformCircularProgressIndicator(
                              material: (_, __) =>
                                  MaterialProgressIndicatorData(
                                    value: downloadProgress.progress,
                                  ),
                            ),
                    errorWidget: (context, url, error) => fallback,
                  ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              textAlign: TextAlign.start,
              text: TextSpan(
                style: textStyle,
                children: [
                  TextSpan(
                    text: author.isEmpty ? S.of(context).anonymous : author,
                    style: textStyle?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: ' · '),
                  TextSpan(text: parseFragment(_comment.dateline).text ?? ''),
                  const TextSpan(text: '  '),
                  TextSpan(text: parseFragment(_comment.comment).text ?? ''),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
