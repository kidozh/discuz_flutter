import 'package:discuz_flutter/generated/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import 'PlatformAdaptiveWidgets.dart';
import 'VibrationUtils.dart';

class BugReportUtils {
  static final issueUri =
      Uri.parse('https://github.com/kidozh/discuz_flutter/issues/new/choose');

  static Future<void> openIssuePage(BuildContext context) async {
    VibrationUtils.vibrateWithClickIfPossible();
    try {
      if (await launchUrl(issueUri, mode: LaunchMode.externalApplication))
        return;
    } catch (_) {
      // Keep a failed browser launch from turning into another error screen.
    }
    if (!context.mounted) return;
    await showPlatformDialog<void>(
      context: context,
      builder: (context) => PlatformAlertDialog(
        title: Text(S.of(context).reportIssue),
        content: Text(S.of(context).reportIssueOpenFailed),
        actions: [
          PlatformDialogAction(
            child: Text(S.of(context).ok),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
