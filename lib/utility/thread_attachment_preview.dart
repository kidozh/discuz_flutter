import '../client/ForumInteractionClient.dart';
import '../entity/Discuz.dart';
import '../entity/ForumThread.dart';
import '../entity/Post.dart';
import '../entity/User.dart';
import 'NetworkUtils.dart';
import 'URLUtils.dart';
import 'discuz_json.dart';
import 'forum_image_url.dart';
import 'thread_attachments.dart';

typedef ThreadAttachmentPreviewUrls = ({Uri primary, Uri? fallback});

ThreadAttachmentPreviewUrls? threadAttachmentPreviewUrls(
  Discuz forum,
  AttachmentPreview attachment,
) {
  final base = forumBaseUri(forum);
  return _previewUrls(
    base,
    direct: _directPreviewUrl(base, attachment),
    signed: URLUtils.getAttachmentUrl(
      forum,
      attachment.aidEncode,
      preview: true,
    ),
    restricted: attachment.readPerm > 0 || attachment.price > 0,
  );
}

Uri? _directPreviewUrl(Uri? base, AttachmentPreview attachment) {
  final supplied = resolveForumImageUri(base, attachment.url);
  if (supplied != null && isForumAttachmentUrl(supplied)) return supplied;

  final path = attachment.attachment.trim();
  final reference = Uri.tryParse(path);
  final explicitPath =
      reference != null &&
      (reference.hasAuthority ||
          isForumAttachmentUrl(reference) ||
          (!attachment.remote &&
              (path.startsWith('/') ||
                  reference.normalizePath().path.startsWith(
                    'data/attachment/',
                  ))));
  if (explicitPath) return resolveForumImageUri(base, path);
  if (supplied != null) {
    return resolveForumAttachmentUri(base, path, attachment.url);
  }
  if (attachment.remote || path.isEmpty) return null;
  return resolveForumAttachmentUri(base, path, 'data/attachment/forum/');
}

ThreadAttachmentPreviewUrls? _previewUrls(
  Uri? forum, {
  required Uri? direct,
  required Uri? signed,
  required bool restricted,
}) {
  final authorized =
      signed ??
      (direct != null &&
              direct.origin == forum?.origin &&
              direct.path == forum?.resolve('forum.php').path &&
              isForumAttachmentUrl(direct)
          ? direct
          : null);
  final primary = restricted ? authorized : direct ?? authorized;
  return primary == null
      ? null
      : (primary: primary, fallback: primary == authorized ? null : authorized);
}

Future<ThreadAttachmentPreviewUrls?> loadThreadAttachmentPreview({
  required Discuz forum,
  required User? user,
  required int tid,
  required AttachmentPreview preview,
  required bool Function() isCurrent,
}) async {
  if (!isCurrent()) return null;
  final dio = await NetworkUtils.getDioWithPersistCookieJar(
    user,
    guestForum: forum.baseURL,
  );
  try {
    if (!isCurrent()) return null;
    final result = await ForumInteractionClient(
      dio,
      forum.baseURL,
    ).request('viewthread', {'tid': tid, 'viewpid': preview.pid});
    if (!isCurrent()) return null;
    result.requireData('postlist');
    final variables = result.variables;
    if (discuzInt(variables['member_uid']) != (user?.uid ?? 0) ||
        discuzInt(discuzMap(variables['thread'])['tid']) != tid) {
      return null;
    }
    final post = forumRows(variables['postlist'])
        .map((row) => Post.fromJson(discuzMap(row)))
        .where((post) => post.tid == tid && post.pid == preview.pid)
        .firstOrNull;
    if (post == null) return null;
    final base = forumBaseUri(forum);
    final path = Uri.tryParse(preview.attachment)?.pathSegments.join('/');
    for (final entry in ThreadAttachment.fromPost(forum, post)) {
      final attachment = entry.attachment;
      final direct = resolveForumImageUri(
        base,
        attachment.getAttachmentRealUrl(forum),
      );
      // Mobile API v4 puts inline images in the post body without their AIDs.
      final imagePath = direct?.pathSegments.join('/');
      final matchesInlineImage =
          entry.inlineThumbnail != null &&
          path != null &&
          path.isNotEmpty &&
          imagePath != null &&
          ('/$imagePath'.endsWith('/$path') ||
              '/$imagePath'.endsWith('/$path.thumb.jpg'));
      if (attachment.aid != preview.aid && !matchesInlineImage) continue;
      if (attachment.price > 0 && !attachment.payed) {
        return null;
      }
      return _previewUrls(
        base,
        direct: entry.inlineThumbnail ?? direct,
        signed: URLUtils.getAttachmentUrl(
          forum,
          attachment.aidEncode,
          preview: true,
        ),
        restricted:
            preview.price > 0 ||
            preview.readPerm > 0 ||
            attachment.price > 0 ||
            attachment.readPerm > 0,
      );
    }
    return null;
  } finally {
    dio.close();
  }
}
