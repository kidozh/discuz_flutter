import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/JsonResult/ViewThreadResult.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';

class PostCommentWidget extends StatelessWidget {
  Comment _comment;

  PostCommentWidget(this._comment);

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        );
    return PlatformListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      leading: PlatformLiquidGlassAvatar(
        size: 32,
        child: CachedNetworkImage(
          imageUrl: _comment.avatar,
          fit: BoxFit.cover,
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              PlatformCircularProgressIndicator(
            material: (_, __) => MaterialProgressIndicatorData(
              value: downloadProgress.progress,
            ),
          ),
          errorWidget: (context, url, error) => ColoredBox(
            color: CustomizeColor.getColorBackgroundById(_comment.authorId),
            child: Center(
              child: Text(
                _comment.author.isNotEmpty
                    ? _comment.author[0].toUpperCase()
                    : S.of(context).anonymous,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
      title: RichText(
        textAlign: TextAlign.start,
        text: TextSpan(
          style: textStyle,
          children: [
            TextSpan(
              text: _comment.author,
              style: textStyle?.copyWith(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: ' · '),
            TextSpan(text: _comment.dateline.replaceAll('&nbsp;', '')),
            const TextSpan(text: '  '),
            TextSpan(text: _comment.comment),
          ],
        ),
      ),
      onTap: VibrationUtils.vibrateWithClickIfPossible,
    );
  }
}
