import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../client/SpecialThreadForm.dart';
import '../generated/l10n.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../widget/post_settings_sheet.dart';

class SpecialThreadComposerPage extends StatefulWidget {
  const SpecialThreadComposerPage({
    super.key,
    required this.kind,
    required this.form,
    this.initial,
  });
  final SpecialThreadKind kind;
  final SpecialThreadForm form;
  final SpecialThreadDraft? initial;

  @override
  State<SpecialThreadComposerPage> createState() =>
      _SpecialThreadComposerState();
}

class _SpecialThreadComposerState extends State<SpecialThreadComposerPage> {
  final fields = <String, TextEditingController>{};
  late final Set<String> profileFields =
      (widget.initial?.fields['userfield'] ?? '')
          .split(',')
          .where((id) => id.isNotEmpty)
          .toSet();
  late String gender = widget.initial?.fields['gender'] ?? '0';
  bool invalid = false;

  TextEditingController controller(String key, {String initial = ''}) =>
      fields.putIfAbsent(
        key,
        () =>
            TextEditingController(text: widget.initial?.fields[key] ?? initial),
      );

  @override
  void dispose() {
    for (final field in fields.values) {
      field.dispose();
    }
    super.dispose();
  }

  Widget field(
    String key,
    String label, {
    bool number = false,
    int lines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        PlatformTextField(
          controller: controller(key),
          keyboardType: number ? TextInputType.number : TextInputType.text,
          maxLines: lines,
        ),
      ],
    ),
  );

  Widget dateField(String key, String label) {
    final input = controller(key);
    final selected = DateTime.tryParse(input.text)?.toLocal();
    return PlatformListTile(
      title: Text(label),
      subtitle: selected == null
          ? null
          : Text(DateFormat('yyyy-MM-dd HH:mm').format(selected)),
      trailing: input.text.isNotEmpty && key != 'starttime'
          ? PlatformIconButton(
              icon: Icon(
                PlatformIcons(context).closeCircled,
                semanticLabel: S.of(context).clearActivityDate,
              ),
              onPressed: () => setState(input.clear),
            )
          : Icon(
              PlatformIcons(context).pick(Icons.event, CupertinoIcons.calendar),
            ),
      onTap: () async {
        final now = DateTime.now();
        final initial = selected ?? now;
        if (isCupertino(context)) {
          var picked = initial;
          final result = await showPlatformModalSheet<DateTime>(
            context: context,
            builder: (sheetContext) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 220,
                    child: CupertinoDatePicker(
                      initialDateTime: initial,
                      onDateTimeChanged: (value) => picked = value,
                    ),
                  ),
                  PlatformTextButton(
                    onPressed: () => Navigator.pop(sheetContext, picked),
                    child: Text(S.of(context).forumConfirm),
                  ),
                ],
              ),
            ),
          );
          if (result != null && mounted) {
            setState(() => input.text = result.toUtc().toIso8601String());
          }
          return;
        }
        final date = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: DateTime(now.year - 1),
          lastDate: DateTime(now.year + 10),
        );
        if (date == null || !mounted) return;
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(initial),
        );
        if (time == null || !mounted) return;
        setState(() {
          input.text = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          ).toUtc().toIso8601String();
        });
      },
    );
  }

  void save() {
    final values = fields.map((key, value) => MapEntry(key, value.text.trim()));
    if (widget.kind == SpecialThreadKind.activity) {
      values['gender'] = gender;
      values['userfield'] = profileFields.join(',');
      values['extfield'] = (values['extfield'] ?? '')
          .split('\n')
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toSet()
          .join('\n');
    }
    final draft = SpecialThreadDraft(widget.kind, values);
    if (!widget.form.accepts(draft)) {
      setState(() => invalid = true);
      return;
    }
    Navigator.pop(context, draft);
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final reward = widget.form.reward;
    final rewardInput = reward == null
        ? null
        : controller('rewardprice', initial: '${reward.minimum}');
    return PostSettingsSheet(
      title: switch (widget.kind) {
        SpecialThreadKind.activity => strings.createActivity,
        SpecialThreadKind.reward => strings.createReward,
        SpecialThreadKind.debate => strings.debateCreate,
      },
      hasSave: true,
      onSave: save,
      children: [
        if (reward != null) ...[
          field('rewardprice', strings.specialRewardAmount, number: true),
          if (reward.hint.isNotEmpty) Text(reward.hint),
          ValueListenableBuilder(
            valueListenable: rewardInput!,
            builder: (context, value, _) {
              final amount = int.tryParse(value.text);
              return amount != null && reward.allows(amount)
                  ? Text(
                      strings.rewardTotal(
                        '${reward.total(amount)} ${reward.credit}'.trim(),
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),
        ] else if (widget.kind == SpecialThreadKind.debate) ...[
          field('affirmpoint', strings.debateAffirm, lines: 3),
          field('negapoint', strings.debateAgainst, lines: 3),
          if (widget.form.debateFields.contains('endtime'))
            dateField('endtime', strings.activityEndsAt),
          if (widget.form.debateFields.contains('umpire'))
            field('umpire', strings.debateJudge),
        ] else ...[
          dateField('starttime', strings.activityStartsAt),
          dateField('starttimeto', strings.activityEndsAt),
          dateField('activityexpiration', strings.activityDeadline),
          field('activityplace', strings.activityLocation),
          field('activityclass', strings.activityCategory),
          if (widget.form.activityCategories.isNotEmpty)
            Wrap(
              spacing: 8,
              children: [
                for (final name in widget.form.activityCategories)
                  PlatformTextButton(
                    onPressed: () => controller('activityclass').text = name,
                    child: Text(name),
                  ),
              ],
            ),
          field('activitynumber', strings.activityCapacity, number: true),
          Text(strings.activityGender),
          for (final (id, label) in [
            ('0', strings.activityAnyone),
            ('1', strings.activityMen),
            ('2', strings.activityWomen),
          ])
            PlatformListTile(
              title: Text(label),
              selected: gender == id,
              trailing: gender == id
                  ? Icon(PlatformIcons(context).checkMarkCircledSolid)
                  : null,
              onTap: () => setState(() => gender = id),
            ),
          field('cost', strings.activityCost, number: true),
          if (widget.form.credit.isNotEmpty)
            field(
              'activitycredit',
              '${strings.activityCredits} · ${widget.form.credit}',
              number: true,
            ),
          if (widget.form.registrationFields.isNotEmpty)
            Text(strings.activityRegistrationFields),
          for (final entry in widget.form.registrationFields.entries)
            PlatformListTile(
              title: Text(entry.value),
              trailing: PlatformSwitch(
                value: profileFields.contains(entry.key),
                onChanged: (selected) => setState(() {
                  selected
                      ? profileFields.add(entry.key)
                      : profileFields.remove(entry.key);
                }),
              ),
            ),
          if (widget.form.customFieldLimit > 0)
            field(
              'extfield',
              strings.activityCustomFields(widget.form.customFieldLimit),
              lines: 3,
            ),
        ],
        if (invalid)
          Text(
            reward == null
                ? strings.activityDraftInvalid
                : strings.rewardAmountInvalid,
          ),
      ],
    );
  }
}
