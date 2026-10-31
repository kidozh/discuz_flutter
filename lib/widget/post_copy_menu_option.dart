import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../generated/l10n.dart';
import '../utility/AiPostText.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../utility/PostTextUtils.dart';
import '../utility/ToastUtils.dart';

/// Copy the displayed post independently of long-press selection gestures.
PopupMenuOption postCopyMenuOption(
  BuildContext context, {
  required String html,
}) {
  final strings = S.of(context);
  return PopupMenuOption(
    label: strings.postCopyText,
    onTap: (_) async {
      final text = AiPostText.plainText(
        PostTextUtils.getDecodedString(html, false),
      );
      if (text.isEmpty) {
        EasyLoading.showInfo(strings.postCopyEmpty);
        return;
      }
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) {
        ToastUtils.showSuccessfulToast(strings.postTextCopied);
      }
    },
  );
}
