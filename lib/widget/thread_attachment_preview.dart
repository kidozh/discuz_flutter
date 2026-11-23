import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../entity/Discuz.dart';
import '../entity/ForumThread.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../utility/thread_attachment_preview.dart';
import 'forum_image.dart';

class ThreadAttachmentPreview extends StatelessWidget {
  const ThreadAttachmentPreview({
    super.key,
    required this.forum,
    required this.threadId,
    required this.attachment,
    required this.loading,
    required this.error,
  });

  final Discuz forum;
  final int threadId;
  final AttachmentPreview attachment;
  final Widget Function(BuildContext, double?) loading;
  final WidgetBuilder error;

  Widget _image(ThreadAttachmentPreviewUrls urls, WidgetBuilder onError) =>
      ForumImage(
        forum: forum,
        threadId: threadId,
        url: urls.primary.toString(),
        fallbackUrl: urls.fallback?.toString(),
        fit: BoxFit.cover,
        loading: loading,
        error: onError,
      );

  @override
  Widget build(BuildContext context) {
    final account = context.watch<DiscuzAndUserNotifier?>();
    final identity = account?.sessionIdentity;
    final user = account?.userFor(forum);
    if (attachment.tid > 0 && attachment.tid != threadId) {
      return error(context);
    }

    final urls = threadAttachmentPreviewUrls(forum, attachment);
    Widget recover(BuildContext context) {
      if (account == null ||
          !forum.isSameSite(account.discuz) ||
          threadId <= 0 ||
          attachment.pid <= 0 ||
          attachment.aid <= 0) {
        return error(context);
      }
      return _PreviewLookup(
        key: ValueKey((
          forum.siteIdentity,
          identity,
          threadId,
          attachment.pid,
          attachment.aid,
          attachment.attachment,
          urls,
        )),
        load: () => loadThreadAttachmentPreview(
          forum: forum,
          user: user,
          tid: threadId,
          preview: attachment,
          isCurrent: () => identical(account.sessionIdentity, identity),
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return loading(context, null);
          }
          final resolved = snapshot.data;
          return resolved == null || resolved == urls
              ? error(context)
              : _image(resolved, error);
        },
      );
    }

    return urls == null ? recover(context) : _image(urls, recover);
  }
}

class _PreviewLookup extends StatefulWidget {
  const _PreviewLookup({
    required super.key,
    required this.load,
    required this.builder,
  });

  final Future<ThreadAttachmentPreviewUrls?> Function() load;
  final AsyncWidgetBuilder<ThreadAttachmentPreviewUrls?> builder;

  @override
  State<_PreviewLookup> createState() => _PreviewLookupState();
}

class _PreviewLookupState extends State<_PreviewLookup> {
  late final _image = widget.load();

  @override
  Widget build(BuildContext context) =>
      FutureBuilder(future: _image, builder: widget.builder);
}
