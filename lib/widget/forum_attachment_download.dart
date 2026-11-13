import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../generated/l10n.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../utility/forum_image_session.dart';

Future<void> downloadAndOpenForumAttachment(
  BuildContext context,
  Uri url, {
  required Uri forum,
  ForumImageSession? session,
  String? filename,
}) async {
  final strings = S.of(context);
  try {
    final directory = await getApplicationDocumentsDirectory();
    if (!context.mounted) return;
    EasyLoading.show(status: strings.downloadingAttachment);
    final file =
        await (session?.downloadAttachment(
              url,
              directory,
              filename: filename,
            ) ??
            downloadForumAttachment(
              url,
              directory,
              forum: forum,
              filename: filename,
            ));
    await EasyLoading.dismiss();
    if (!context.mounted) return;
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
            final result = await OpenFilex.open(file.path);
            if (result.type != ResultType.done) {
              EasyLoading.showError(result.message);
            }
          },
        ),
      ],
    );
  } catch (_) {
    if (context.mounted) {
      await EasyLoading.showError(strings.attachmentDownloadFailed);
    } else {
      await EasyLoading.dismiss();
    }
  }
}
