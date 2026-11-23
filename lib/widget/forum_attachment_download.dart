import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../entity/Discuz.dart';
import '../generated/l10n.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../utility/forum_attachment_history.dart';
import '../utility/forum_image_session.dart';
import '../utility/forum_image_url.dart';

Future<void> openDownloadedFile(BuildContext context, String path) async {
  final strings = S.of(context);
  try {
    final result = await OpenFilex.open(path);
    if (result.type == ResultType.done || !context.mounted) return;
    if (result.type == ResultType.noAppToOpen) {
      final box = context.findRenderObject();
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(path)],
          sharePositionOrigin: box is RenderBox && box.hasSize
              ? box.localToGlobal(Offset.zero) & box.size
              : null,
        ),
      );
      return;
    }
    EasyLoading.showError(strings.downloadedFileOpenFailed);
  } catch (_) {
    if (context.mounted) {
      EasyLoading.showError(strings.downloadedFileOpenFailed);
    }
  }
}

Future<void> downloadAndOpenForumAttachment(
  BuildContext context,
  Uri url, {
  required Discuz forum,
  ForumImageSession? session,
  ForumAttachmentReference? reference,
  String? filename,
}) async {
  final strings = S.of(context);
  final base = forumBaseUri(forum);
  if (base == null) return;
  final account = context.read<DiscuzAndUserNotifier?>();
  final identity = account?.sessionIdentity;
  final user = account?.userFor(forum);
  bool current() => identical(identity, account?.sessionIdentity);

  try {
    final item = reference;
    Future<File> transfer(
      Directory directory, {
      AttachmentProgress? progress,
    }) =>
        session?.downloadAttachment(
          url,
          directory,
          filename: filename,
          onProgress: progress,
        ) ??
        downloadForumAttachment(
          url,
          directory,
          forum: base,
          filename: filename,
          threadId: item?.tid,
          onProgress: progress,
          isCurrent: current,
        );
    final file = item == null
        ? await transfer(await getApplicationDocumentsDirectory())
        : await ForumAttachmentHistory(forum, user).start(
            item,
            name: filename ?? strings.downloadAttachment,
            isCurrent: current,
            transfer: (directory, progress) =>
                transfer(directory, progress: progress),
          );
    if (file == null || !context.mounted || !current()) return;
    await showPlatformAlert(
      context: context,
      title: strings.successfullyDownloadFiles(file.uri.pathSegments.last),
      message: strings.openFileInExternalAppContent,
      actions: [
        PlatformAlertAction(label: strings.cancel, isCancelAction: true),
        PlatformAlertAction(
          label: strings.openFileInExternalAppActionText,
          isDefaultAction: true,
          onPressed: () async {
            if (context.mounted && current()) {
              await openDownloadedFile(context, file.path);
            }
          },
        ),
      ],
    );
  } catch (_) {
    if (context.mounted && current()) {
      await EasyLoading.showError(strings.attachmentDownloadFailed);
    }
  }
}
