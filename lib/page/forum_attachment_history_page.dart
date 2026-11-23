import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import '../entity/Discuz.dart';
import '../generated/l10n.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../utility/forum_attachment_history.dart';
import '../utility/forum_image_session.dart';
import '../utility/forum_image_url.dart';
import '../utility/forum_local_records.dart';
import '../widget/forum_attachment_download.dart';
import 'ViewThreadSliverPage.dart';

class ForumAttachmentHistoryPage extends StatelessWidget {
  const ForumAttachmentHistoryPage(this.forum, {super.key});

  final Discuz forum;

  @override
  Widget build(BuildContext context) {
    final account = context.watch<DiscuzAndUserNotifier>();
    final user = account.userFor(forum);
    final identity = account.sessionIdentity;
    bool current() => identical(identity, account.sessionIdentity);
    final history = ForumAttachmentHistory(forum, user);
    final s = S.of(context);
    return PlatformScaffold(
      iosContentPadding: true,
      iosContentBottomPadding: true,
      appBar: PlatformAppBar(title: Text(s.attachmentDownloadHistory)),
      body: ListenableBuilder(
        listenable: Listenable.merge([history.records, history.progress]),
        builder: (context, _) {
          final entries = history.records.value;
          if (entries.isEmpty) {
            return Center(child: Text(s.noAttachmentDownloads));
          }
          return ListView.separated(
            itemCount: entries.length,
            padding: const EdgeInsets.all(16),
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final entry = entries[index];
              final reference = ForumAttachmentReference.fromRecord(entry);
              final session = ForumImageSession.of(
                context,
                forum,
                threadId: reference.tid,
              );
              return _row(
                context,
                entry,
                active: history.progress.value.containsKey(reference.id),
                progress: history.progress.value[reference.id],
                onOpenThread: () => pushDetailPage<void>(
                  context,
                  platformPageRoute(
                    context: context,
                    builder: (_) => ViewThreadSliverPage(
                      forum,
                      user,
                      reference.tid,
                      initialPid: reference.pid > 0 ? reference.pid : null,
                    ),
                  ),
                ),
                onOpenFile: entry['state'] != 'complete'
                    ? null
                    : () async {
                        final file = await history.localFile(entry);
                        if (!current() || !context.mounted) return;
                        if (file == null) {
                          await history.records.put({
                            ...entry,
                            'folder': null,
                            'state': 'failed',
                          });
                          if (context.mounted && current()) {
                            EasyLoading.showInfo(s.attachmentLocalFileMissing);
                          }
                        } else {
                          await openDownloadedFile(context, file.path);
                        }
                      },
                onRetry: reference.pid <= 0
                    ? null
                    : () async {
                        final base = forumBaseUri(forum);
                        if (base == null || !current()) return;
                        try {
                          await history.start(
                            reference,
                            name: entry['filename'] as String,
                            isCurrent: current,
                            transfer: (directory, progress) async {
                              final url = await reference.reload(forum, user);
                              if (!current()) {
                                throw StateError('Forum account changed');
                              }
                              return session?.downloadAttachment(
                                    url,
                                    directory,
                                    filename: entry['filename'] as String,
                                    onProgress: progress,
                                  ) ??
                                  downloadForumAttachment(
                                    url,
                                    directory,
                                    forum: base,
                                    threadId: reference.tid,
                                    filename: entry['filename'] as String,
                                    onProgress: progress,
                                    isCurrent: current,
                                  );
                            },
                          );
                        } catch (_) {
                          if (context.mounted && current()) {
                            EasyLoading.showError(s.attachmentDownloadFailed);
                          }
                        }
                      },
              );
            },
          );
        },
      ),
    );
  }

  Widget _row(
    BuildContext context,
    ForumRecord entry, {
    required bool active,
    required double? progress,
    required VoidCallback onOpenThread,
    VoidCallback? onOpenFile,
    VoidCallback? onRetry,
  }) {
    final s = S.of(context);
    final icons = PlatformIcons(context);
    final status = active
        ? s.downloadingAttachment
        : onOpenFile == null
        ? s.attachmentDownloadFailed
        : s.attachmentDownloadComplete;
    final time = DateTime.fromMillisecondsSinceEpoch(entry['time'] as int);
    final material = MaterialLocalizations.of(context);
    return PlatformCard(
      margin: EdgeInsets.zero,
      elevation: 0,
      semanticContainer: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PlatformListTile(
            leading: Icon(
              icons.pick(Icons.insert_drive_file_outlined, CupertinoIcons.doc),
            ),
            title: Text(
              entry['filename'] as String,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text('$status · ${material.formatShortDate(time)}'),
            isThreeLine: true,
            onTap: active ? null : onOpenFile,
          ),
          if (active)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: isCupertino(context) && progress == null
                  ? const Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: PlatformCircularProgressIndicator(),
                    )
                  : LinearProgressIndicator(value: progress),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Wrap(
              alignment: WrapAlignment.end,
              children: [
                PlatformTextButton(
                  onPressed: onOpenThread,
                  child: Text(s.threadJumpToAttachmentPost),
                ),
                if (!active && onOpenFile != null)
                  PlatformTextButton(
                    onPressed: onOpenFile,
                    child: Text(s.openFileInExternalAppActionText),
                  )
                else if (!active && onRetry != null)
                  PlatformTextButton(onPressed: onRetry, child: Text(s.retry)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
