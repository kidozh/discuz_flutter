import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../generated/l10n.dart';
import '../utility/PlatformAdaptiveWidgets.dart';

Future<String?> showForumRecordDialog(BuildContext context, String title) =>
    showPlatformDialog<String>(
      context: context,
      builder: (_) => _ForumRecordDialog(title),
    );

class _ForumRecordDialog extends StatefulWidget {
  const _ForumRecordDialog(this.title);

  final String title;

  @override
  State<_ForumRecordDialog> createState() => _ForumRecordDialogState();
}

class _ForumRecordDialogState extends State<_ForumRecordDialog> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void submit() {
    final name = controller.text.trim();
    if (name.isNotEmpty) Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final input = PlatformTextField(
      controller: controller,
      autofocus: true,
      maxLength: 60,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => submit(),
    );
    if (isCupertino(context)) {
      return CupertinoAlertDialog(
        title: Text(widget.title),
        content: Padding(padding: const EdgeInsets.only(top: 12), child: input),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.cancel),
          ),
          CupertinoDialogAction(
            onPressed: submit,
            isDefaultAction: true,
            child: Text(strings.saveLocalRecord),
          ),
        ],
      );
    }
    return AlertDialog(
      title: Text(widget.title),
      content: input,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(strings.cancel),
        ),
        TextButton(onPressed: submit, child: Text(strings.saveLocalRecord)),
      ],
    );
  }
}
