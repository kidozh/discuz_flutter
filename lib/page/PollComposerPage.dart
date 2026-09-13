import 'package:flutter/material.dart';
import '../entity/PollDraft.dart';
import '../generated/l10n.dart';
import '../utility/PlatformAdaptiveWidgets.dart';

class PollComposerPage extends StatefulWidget {
  final PollDraft? initial;
  const PollComposerPage({super.key, this.initial});
  @override
  State<PollComposerPage> createState() => _PollComposerPageState();
}

class _PollComposerPageState extends State<PollComposerPage> {
  late final TextEditingController options = TextEditingController(
    text: widget.initial?.options.join('\n') ?? '',
  );
  late final TextEditingController choices = TextEditingController(
    text: '${widget.initial?.maxChoices ?? 1}',
  );
  late final TextEditingController days = TextEditingController(
    text: '${widget.initial?.days ?? 7}',
  );
  bool invalid = false;
  @override
  void dispose() {
    options.dispose();
    choices.dispose();
    days.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return PlatformScaffold(
      appBar: PlatformAppBar(title: Text(s.createPoll)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(s.pollOptionsHint),
            PlatformTextField(controller: options, minLines: 4, maxLines: 10),
            const SizedBox(height: 12),
            Text(s.pollChoicesHint),
            PlatformTextField(
              controller: choices,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Text(s.pollDaysHint),
            PlatformTextField(
              controller: days,
              keyboardType: TextInputType.number,
            ),
            if (invalid) Text(s.pollInvalid),
            PlatformTextButton(
              onPressed: () {
                final draft = PollDraft(
                  options.text
                      .split('\n')
                      .map((s) => s.trim())
                      .where((s) => s.isNotEmpty)
                      .toList(),
                  int.tryParse(choices.text) ?? -1,
                  int.tryParse(days.text) ?? -1,
                );
                if (!draft.valid) {
                  setState(() => invalid = true);
                  return;
                }
                Navigator.pop(context, draft);
              },
              child: Text(s.forumConfirm),
            ),
          ],
        ),
      ),
    );
  }
}
