import 'ForumInteractionWidgets.dart';
import 'forum_image.dart';

import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/Post.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/FullImagePage.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';

import '../utility/forum_image_session.dart';
import '../utility/forum_image_url.dart';
import 'forum_attachment_download.dart';

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
      return InkWell(
        child: PlatformCard(
          elevation: 8.0,
          child: ForumImage(
            forum: _discuz,
            threadId: tid,
            url: previewUrl.toString(),
            fallbackUrl: protectedImage?.toString(),
            fit: BoxFit.fill,
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
      );
    }

    final session = ForumImageSession.of(context, _discuz, threadId: tid);
    return PlatformCard(
      child: Column(
        children: [
          PlatformListTile(
            leading: Icon(PlatformIcons(context).attachment),
            title: Text(_attachment.filename),
            subtitle: Text(_attachment.attachmentSizeString),
            trailing: Badge(
              label: Text(
                _attachment.downloads.toString(),
                style: TextStyle(color: Colors.white),
              ),
              child: Icon(PlatformIcons(context).download),
            ),
          ),
          Wrap(
            alignment: WrapAlignment.start,
            spacing: 8,
            runSpacing: 8,
            children: [
              PlatformTextButton(
                onPressed: baseUrl == null || downloadUrl == null
                    ? null
                    : () => downloadAndOpenForumAttachment(
                        context,
                        downloadUrl,
                        forum: baseUrl,
                        session: session,
                        filename: _attachment.filename,
                      ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(PlatformIcons(context).download, size: 20),
                    const SizedBox(width: 6),
                    Text(S.of(context).downloadAttachment),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
