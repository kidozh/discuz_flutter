import 'ForumInteractionWidgets.dart';
import 'forum_image.dart';

import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/Post.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/FullImagePage.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';

import '../utility/forum_image_session.dart';
import '../utility/forum_image_url.dart';
import '../utility/forum_voice.dart';
import 'forum_attachment_download.dart';
import 'forum_voice_message.dart';

class AttachmentWidget extends StatelessWidget {
  final Discuz _discuz;
  final Attachment _attachment;

  final VoidCallback? onContentChanged;
  final int? threadId;
  final bool isListedImage;

  const AttachmentWidget(
    this._discuz,
    this._attachment, {
    super.key,
    this.onContentChanged,
    this.threadId,
    this.isListedImage = false,
  });

  @override
  Widget build(BuildContext context) {
    final tid = _attachment.tid > 0 ? _attachment.tid : threadId;
    if (_attachment.price > 0 && !_attachment.payed) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_attachment.filename),
          ForumActionButton(
            discuz: _discuz,
            tid: tid ?? 0,
            aid: _attachment.aid,
            purchase: true,
            label: S.of(context).forumBuyAttachment,
            onChanged: onContentChanged ?? () {},
          ),
        ],
      );
    }
    final baseUrl = forumBaseUri(_discuz);
    final directUrl = resolveForumImageUri(
      baseUrl,
      _attachment.getAttachmentRealUrl(_discuz),
    );
    final attachmentUrl = URLUtils.getAttachmentUrl(
      _discuz,
      _attachment.aidEncode,
    );
    final downloadUrl = attachmentUrl ?? directUrl;

    const imageExtensions = {
      "jpg",
      "png",
      "svg",
      "bmp",
      "gif",
      "jpeg",
      "webp",
      "avif",
      "heic",
      "heif",
    };
    final isImage =
        isListedImage ||
        [
          _attachment.ext,
          _attachment.filename.split('.').last,
          directUrl?.pathSegments.lastOrNull?.split('.').last ?? '',
        ].any(
          (ext) => imageExtensions.contains(
            ext.trim().toLowerCase().replaceFirst(RegExp(r'^\.'), ''),
          ),
        );
    final protectedImage = URLUtils.getAttachmentUrl(
      _discuz,
      _attachment.aidEncode,
      preview: true,
    );
    final previewUrl = directUrl ?? protectedImage;
    if (isImage && previewUrl != null) {
      final original = protectedImage ?? previewUrl;
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          child: ForumImage(
            forum: _discuz,
            threadId: tid,
            url: previewUrl.toString(),
            fallbackUrl: protectedImage?.toString(),
            fit: BoxFit.contain,
            error: (context) => Icon(PlatformIcons(context).error),
            loading: (context, progress) => Container(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: PlatformCircularProgressIndicator(
                  material: (_, __) =>
                      MaterialProgressIndicatorData(value: progress),
                ),
              ),
            ),
          ),
          onTap: () {
            VibrationUtils.vibrateWithClickIfPossible();
            final url = original.toString();

            Navigator.push(
              context,
              platformPageRoute(
                context: context,
                iosTitle: S.of(context).viewPicture,
                builder: (context) => FullImagePage(
                  url,
                  [url],
                  forum: _discuz,
                  threadId: tid,
                  fallbackUrls: original == previewUrl
                      ? const {}
                      : {url: previewUrl.toString()},
                  filenames: {url: _attachment.filename},
                ),
              ),
            );
          },
        ),
      );
    }

    final session = ForumImageSession.of(context, _discuz, threadId: tid);
    if (!kIsWeb &&
        baseUrl != null &&
        downloadUrl != null &&
        (isForumAudioFile(_attachment.filename) ||
            isForumAudioFile('file.${_attachment.ext}'))) {
      return ForumVoiceMessage(
        key: ValueKey((downloadUrl, session?.cacheKey)),
        durationHint: forumVoiceDuration(_attachment.filename),
        load: () async {
          final temporary = await getTemporaryDirectory();
          return session?.downloadAttachment(
                downloadUrl,
                temporary,
                filename: _attachment.filename,
              ) ??
              downloadForumAttachment(
                downloadUrl,
                temporary,
                forum: baseUrl,
                filename: _attachment.filename,
              );
        },
        save: () => downloadAndOpenForumAttachment(
          context,
          downloadUrl,
          forum: baseUrl,
          session: session,
          filename: _attachment.filename,
        ),
      );
    }
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final icons = PlatformIcons(context);
    final cupertino = isCupertino(context);
    final shape = BorderRadius.circular(12);
    final surface = cupertino
        ? CupertinoColors.tertiarySystemFill.resolveFrom(context)
        : colors.surfaceContainerHighest;
    final downloadColor = theme.brightness == Brightness.dark
        ? colors.onSurface
        : colors.primary;
    final onDownload = baseUrl == null || downloadUrl == null
        ? null
        : () => downloadAndOpenForumAttachment(
            context,
            downloadUrl,
            forum: baseUrl,
            session: session,
            filename: _attachment.filename,
          );
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(
            icons.pick(Icons.insert_drive_file_outlined, CupertinoIcons.doc),
            size: 21,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _attachment.filename,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_attachment.attachmentSizeString.isNotEmpty)
                  Text(
                    _attachment.attachmentSizeString,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icons.download,
                size: 20,
                color: onDownload == null ? theme.disabledColor : downloadColor,
              ),
              if (_attachment.downloads > 0)
                Text(
                  _attachment.downloads.toString(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
    return MergeSemantics(
      child: Semantics(
        button: true,
        enabled: onDownload != null,
        hint: onDownload == null ? null : S.of(context).downloadAttachment,
        child: cupertino
            ? DecoratedBox(
                decoration: BoxDecoration(color: surface, borderRadius: shape),
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: onDownload,
                  child: row,
                ),
              )
            : Material(
                color: surface,
                borderRadius: shape,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onDownload,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 48),
                    child: row,
                  ),
                ),
              ),
      ),
    );
  }
}
