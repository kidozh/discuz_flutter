import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../client/thread_post_options.dart';
import '../entity/PollDraft.dart';
import '../generated/l10n.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../utility/reply_draft_store.dart';
import '../widget/post_settings_sheet.dart';

class PollComposerPage extends StatefulWidget {
  const PollComposerPage({
    super.key,
    this.initial,
    required this.rules,
    required this.store,
  });

  final PollDraft? initial;
  final PollPostingRules rules;
  final ReplyDraftStore store;

  @override
  State<PollComposerPage> createState() => _PollComposerPageState();
}

class _PollOption {
  _PollOption([String text = '', this.image])
    : controller = TextEditingController(text: text);
  final TextEditingController controller;
  ReplyDraftAttachment? image;
}

class _PollComposerPageState extends State<PollComposerPage> {
  late final options = widget.initial == null
      ? [_PollOption(), _PollOption()]
      : [
          for (final (i, label) in widget.initial!.options.indexed)
            _PollOption(label, widget.initial!.images[i]),
        ];
  late final choices = TextEditingController(
    text: '${widget.initial?.maxChoices ?? 1}',
  );
  late final days = TextEditingController(text: '${widget.initial?.days ?? 7}');
  late bool hideResults = widget.initial?.hideResults ?? false;
  late bool publicVoters = widget.initial?.publicVoters ?? false;
  bool picking = false;
  String? error;
  final added = <ReplyDraftAttachment>{};
  bool saved = false;

  @override
  void dispose() {
    for (final option in options) {
      option.controller.dispose();
    }
    choices.dispose();
    days.dispose();
    for (final item in added) {
      if (!saved || !options.any((option) => option.image == item)) {
        widget.store.file(item).then((file) => file.delete()).ignore();
      }
    }
    super.dispose();
  }

  Future<void> pick(_PollOption option) async {
    final s = S.of(context);
    setState(() => picking = true);
    try {
      final result = await FilePicker.pickFile(type: FileType.image);
      if (!mounted || result == null) return;
      final size = await result.length();
      if (size == null || !widget.rules.acceptsImage(result.name, size)) {
        if (mounted) setState(() => error = s.pollPictureRejected);
        return;
      }
      final item = await widget.store.add(
        name: result.name,
        bytes: result.readAsByteStream(),
        image: true,
      );
      if (!mounted) {
        await (await widget.store.file(item)).delete();
        return;
      }
      setState(() {
        added.add(item);
        option.image = item;
        error = null;
      });
    } catch (_) {
      if (mounted) setState(() => error = s.pollPictureRejected);
    } finally {
      if (mounted) setState(() => picking = false);
    }
  }

  void save() {
    final active = options
        .where((o) => o.controller.text.trim().isNotEmpty || o.image != null)
        .toList();
    final draft = PollDraft(
      active.map((o) => o.controller.text.trim()).toList(),
      int.tryParse(choices.text) ?? -1,
      int.tryParse(days.text) ?? -1,
      images: {
        for (final (i, o) in active.indexed)
          if (o.image case final image?) i: image,
      },
      hideResults: hideResults,
      publicVoters: publicVoters,
    );
    if (!widget.rules.accepts(draft)) {
      setState(() => error = S.of(context).pollInvalid);
      return;
    }
    saved = true;
    Navigator.pop(context, draft);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context), theme = Theme.of(context);
    final icons = PlatformIcons(context);
    return PostSettingsSheet(
      title: widget.initial == null ? s.createPoll : s.editPoll,
      hasSave: true,
      onSave: picking ? null : save,
      children: [
        Text(
          s.pollOptionLimit(widget.rules.maximum),
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        for (final (i, option) in options.indexed)
          Padding(
            key: ObjectKey(option),
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: PlatformTextField(
                        controller: option.controller,
                        hintText: s.editPostPollOption(i + 1),
                        maxLength: 80,
                      ),
                    ),
                    if (widget.rules.acceptsPictures)
                      PlatformIconButton(
                        icon: Icon(
                          icons.pick(
                            Icons.add_photo_alternate_outlined,
                            CupertinoIcons.photo_on_rectangle,
                          ),
                          semanticLabel: s.pollOptionPicture(i + 1),
                        ),
                        onPressed: picking ? null : () => pick(option),
                      ),
                    if (options.length > 2 || option.image != null)
                      PlatformIconButton(
                        icon: Icon(
                          icons.delete,
                          semanticLabel: option.image == null
                              ? s.removePollOption(i + 1)
                              : s.removeComposerImage(i + 1),
                        ),
                        onPressed: picking
                            ? null
                            : () {
                                setState(() {
                                  if (option.image != null) {
                                    option.image = null;
                                  } else {
                                    options.remove(option);
                                    WidgetsBinding.instance
                                        .addPostFrameCallback(
                                          (_) => option.controller.dispose(),
                                        );
                                  }
                                });
                              },
                      ),
                  ],
                ),
                if (option.image case final image?)
                  FutureBuilder<File>(
                    future: widget.store.file(image),
                    builder: (context, snapshot) => Row(
                      children: [
                        if (snapshot.hasData)
                          SizedBox(
                            width: 56,
                            height: 42,
                            child: Image.file(
                              snapshot.data!,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Icon(icons.warning),
                            ),
                          ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            image.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        if (options.length < widget.rules.maximum)
          PlatformTextButton(
            onPressed: picking
                ? null
                : () => setState(() => options.add(_PollOption())),
            child: Text(s.addPollOption),
          ),
        const SizedBox(height: 12),
        Text(s.pollChoicesHint),
        PlatformTextField(
          controller: choices,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        Text(s.pollDaysHint),
        PlatformTextField(controller: days, keyboardType: TextInputType.number),
        PlatformListTile(
          title: Text(s.pollHideResults),
          trailing: PlatformSwitch(
            value: hideResults,
            onChanged: (value) => setState(() => hideResults = value),
          ),
        ),
        PlatformListTile(
          title: Text(s.editPostPollVoterList),
          trailing: PlatformSwitch(
            value: publicVoters,
            onChanged: (value) => setState(() => publicVoters = value),
          ),
        ),
        if (error != null)
          Text(error!, style: TextStyle(color: theme.colorScheme.error)),
      ],
    );
  }
}
