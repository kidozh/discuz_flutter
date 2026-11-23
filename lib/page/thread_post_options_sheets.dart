import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../client/thread_post_options.dart';
import '../generated/l10n.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../widget/post_settings_sheet.dart';

class ClassifiedPostSheet extends StatefulWidget {
  const ClassifiedPostSheet(
    this.sortId,
    this.name,
    this.form,
    this.initial, {
    super.key,
  });
  final int sortId;
  final String name;
  final ClassifiedPostingForm form;
  final ClassifiedPostDraft? initial;
  @override
  State<ClassifiedPostSheet> createState() => _ClassifiedPostSheetState();
}

class _ClassifiedPostSheetState extends State<ClassifiedPostSheet> {
  late final values = {
    for (final f in widget.form.fields)
      f.id: [...(widget.initial?.values[f.id] ?? f.initial)],
  };
  late final inputs = {
    for (final f in widget.form.fields)
      if (f.choices.isEmpty)
        f.id: TextEditingController(text: values[f.id]?.firstOrNull ?? ''),
  };
  late String expiration =
      widget.initial?.expiration ??
      widget.form.expirations.keys.firstOrNull ??
      '';
  Set<String> errors = {};
  @override
  void dispose() {
    for (final input in inputs.values) {
      input.dispose();
    }
    super.dispose();
  }

  void save() {
    final draft = ClassifiedPostDraft(widget.sortId, {
      for (final f in widget.form.fields)
        f.id: inputs.containsKey(f.id)
            ? [
                if (inputs[f.id]!.text.trim().isNotEmpty)
                  inputs[f.id]!.text.trim(),
              ]
            : values[f.id]!,
    }, expiration);
    if (!widget.form.accepts(draft)) {
      setState(
        () => errors = {
          for (final f in widget.form.fields)
            if (!f.accepts(draft.values[f.id]!)) f.id,
        },
      );
      return;
    }
    Navigator.pop(context, draft);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return PostSettingsSheet(
      title: widget.name,
      hasSave: true,
      onSave: save,
      children: [
        for (final f in widget.form.fields)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  f.required ? '${f.name} *' : f.name,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (inputs[f.id] case final input?)
                  PlatformTextField(
                    controller: input,
                    maxLines: f.type == ClassifiedInput.longText ? 3 : 1,
                    keyboardType: f.type == ClassifiedInput.number
                        ? const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          )
                        : TextInputType.text,
                    maxLength: f.maxLength,
                  )
                else
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final entry in f.choices.entries)
                        FilterChip(
                          label: Text(entry.value),
                          selected: values[f.id]!.contains(entry.key),
                          onSelected: (selected) => setState(() {
                            final current = values[f.id]!;
                            if (f.type != ClassifiedInput.multiple)
                              current.clear();
                            if (selected) {
                              current.add(entry.key);
                            } else {
                              current.remove(entry.key);
                            }
                          }),
                        ),
                    ],
                  ),
                if (errors.contains(f.id))
                  Text(
                    s.classifiedFieldInvalid(f.name),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            ),
          ),
        if (widget.form.expirations.isNotEmpty) ...[
          Text(s.classifiedExpiration),
          for (final entry in widget.form.expirations.entries)
            PlatformListTile(
              title: Text(entry.value),
              selected: expiration == entry.key,
              trailing: expiration == entry.key
                  ? Icon(PlatformIcons(context).checkMark)
                  : null,
              onTap: () => setState(() => expiration = entry.key),
            ),
        ],
      ],
    );
  }
}

class RushPostSheet extends StatefulWidget {
  const RushPostSheet(this.initial, this.creditLabel, {super.key});
  final RushPostDraft? initial;
  final String creditLabel;
  @override
  State<RushPostSheet> createState() => _RushPostSheetState();
}

class _RushPostSheetState extends State<RushPostSheet> {
  static const dateFormat = 'yyyy-MM-dd HH:mm';
  late final inputs = {
    for (final key in RushPostDraft.names)
      key: TextEditingController(text: widget.initial?.fields[key] ?? ''),
  };
  bool invalid = false;

  @override
  void dispose() {
    for (final input in inputs.values) {
      input.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final labels = {
      'rushreplyfrom': s.activityStarts,
      'rushreplyto': s.activityEnds,
      'rewardfloor': s.rushReplyRewardFloors,
      'stopfloor': s.rushStopFloorInput,
      'replylimit': s.rushReplyLimitInput,
      'creditlimit': widget.creditLabel.isEmpty
          ? s.rushReplyMinimum
          : widget.creditLabel,
    };
    return PostSettingsSheet(
      title: s.rushReplyTitle,
      hasSave: true,
      onSave: () {
        final values = {
          for (final e in inputs.entries) e.key: e.value.text.trim(),
        };
        values['rewardfloor'] = values['rewardfloor']!
            .replaceAll(RegExp(r'\s+'), '')
            .replaceAll('，', ',');
        final draft = RushPostDraft(values);
        if (!draft.valid) {
          setState(() => invalid = true);
          return;
        }
        Navigator.pop(context, draft);
      },
      children: [
        Text(s.rushForumTimeHint, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 10),
        for (final key in RushPostDraft.names)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(labels[key]!),
                PlatformTextField(
                  controller: inputs[key],
                  hintText: key.startsWith('rushreply') ? dateFormat : null,
                  keyboardType:
                      key.startsWith('rushreply') || key == 'rewardfloor'
                      ? TextInputType.datetime
                      : const TextInputType.numberWithOptions(signed: true),
                ),
                if (key == 'rewardfloor')
                  Text(
                    s.rushFloorsHint,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        if (invalid)
          Text(
            s.rushSettingsInvalid,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
      ],
    );
  }
}

class ExtraThreadOptionsSheet extends StatefulWidget {
  const ExtraThreadOptionsSheet(this.form, this.initial, {super.key});

  final ExtraThreadOptions form;
  final Map<String, String> initial;

  @override
  State<ExtraThreadOptionsSheet> createState() =>
      _ExtraThreadOptionsSheetState();
}

class _ExtraThreadOptionsSheetState extends State<ExtraThreadOptionsSheet> {
  late final Map<String, String> values = {
    for (final entry in widget.initial.entries)
      if (widget.form.available.contains(entry.key)) entry.key: entry.value,
  };
  final _dateFormat = DateFormat('yyyy-MM-dd HH:mm');
  late final TextEditingController publishAt = TextEditingController(
    text: _initialPublicationText(),
  );
  late final TextEditingController access = TextEditingController(
    text: values['readperm'],
  );
  late final tags = TextEditingController(text: values['tags']);
  bool invalid = false;

  String _initialPublicationText() {
    final date = DateTime.tryParse(values['cronpublishdate'] ?? '')?.toLocal();
    return date == null ? '' : _dateFormat.format(date);
  }

  @override
  void dispose() {
    publishAt.dispose();
    access.dispose();
    tags.dispose();
    super.dispose();
  }

  void save() {
    final readingAccess = access.text.trim();
    final publication = publishAt.text.trim();
    values.remove('readperm');
    values.remove('cronpublishdate');
    values.remove('tags');
    if (widget.form.available.contains('tags') && tags.text.trim().isNotEmpty) {
      values['tags'] = tags.text;
    }
    if (widget.form.available.contains('readperm') &&
        readingAccess.isNotEmpty) {
      values['readperm'] = readingAccess;
    }
    if (widget.form.available.contains('cronpublishdate') &&
        publication.isNotEmpty) {
      final parsed = _dateFormat.tryParseStrict(publication);
      if (parsed == null) {
        setState(() => invalid = true);
        return;
      }
      values['cronpublishdate'] = parsed.toUtc().toIso8601String();
    }
    if (widget.form.submission(values, DateTime.now()) == null) {
      setState(() => invalid = true);
      return;
    }
    Navigator.pop(context, values);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return PostSettingsSheet(
      title: s.morePostSettings,
      onSave: save,
      hasSave: true,
      children: [
        for (final (name, label) in [
          ('allownoticeauthor', s.postNotifyReplies),
          ('isanonymous', s.postAnonymous),
        ])
          if (widget.form.available.contains(name))
            PlatformListTile(
              title: Text(label),
              trailing: PlatformSwitch(
                value: values[name] == '1',
                onChanged: (checked) => setState(() {
                  if (checked) {
                    values[name] = '1';
                  } else {
                    values.remove(name);
                  }
                }),
              ),
            ),
        if (widget.form.available.contains('readperm'))
          PlatformTextField(
            controller: access,
            hintText: s.postReadPermission,
            keyboardType: TextInputType.number,
          ),
        if (widget.form.available.contains('cronpublishdate'))
          PlatformTextField(
            controller: publishAt,
            hintText: s.postScheduleTime,
            keyboardType: TextInputType.datetime,
          ),
        if (widget.form.available.contains('tags'))
          PlatformTextField(controller: tags, hintText: s.forumThreadTagsHint),
        if (widget.form.available.isEmpty || invalid)
          Text(s.postSettingsChanged),
      ],
    );
  }
}
