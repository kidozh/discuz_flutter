import 'package:html/parser.dart' show parseFragment;

import '../entity/Discuz.dart';
import '../entity/Post.dart';
import '../widget/forum_image.dart';
import 'forum_image_url.dart';

class ThreadAttachment {
  final Post post;
  final Attachment attachment;
  final bool isListedImage;
  final Uri? inlineThumbnail;
  final String key;

  const ThreadAttachment({
    required this.post,
    required this.attachment,
    required this.key,
    this.isListedImage = false,
    this.inlineThumbnail,
  });

  static Iterable<ThreadAttachment> fromPost(Discuz forum, Post post) sync* {
    final originals = <Uri?>{};
    final base = forumBaseUri(forum);
    for (final entry in post.attachmentMapper.entries) {
      final attachment = entry.value;
      if ((attachment.pid > 0 && attachment.pid != post.pid) ||
          (attachment.tid > 0 && attachment.tid != post.tid)) {
        continue;
      }
      originals.add(
        resolveForumImageUri(base, attachment.getAttachmentRealUrl(forum)),
      );
      yield ThreadAttachment(
        post: post,
        attachment: attachment,
        key:
            '${post.pid}:aid:${attachment.aid > 0 ? attachment.aid : entry.key}',
        isListedImage:
            post.imageIdList.contains(entry.key) ||
            post.imageIdList.contains('${attachment.aid}'),
      );
    }

    // Mobile API v4 moves inline image attachments out of the attachment map
    // and marks the generated image with the containing post's PID.
    if (!post.message.contains('attach=')) return;
    for (final image in parseFragment(post.message).querySelectorAll('img')) {
      if (image.attributes['attach'] != '${post.pid}') continue;
      final thumbnail = resolveForumImageUri(
        base,
        forumHtmlImageSource(image) ?? '',
      );
      final original =
          resolveForumImageUri(
            base,
            forumHtmlImageSource(image, original: true) ?? '',
          ) ??
          thumbnail;
      if (original == null || !originals.add(original)) continue;
      final filename = original.pathSegments.lastOrNull ?? '';
      yield ThreadAttachment(
        post: post,
        attachment: Attachment()
          ..pid = post.pid
          ..tid = post.tid
          ..url = original.toString()
          ..filename = filename,
        key: '${post.pid}:image:$original',
        isListedImage: true,
        inlineThumbnail: thumbnail,
      );
    }
  }
}
