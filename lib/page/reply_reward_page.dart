import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../client/reply_reward_form.dart';
import '../generated/l10n.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../widget/post_settings_sheet.dart';

class ReplyRewardPage extends StatefulWidget {
  const ReplyRewardPage(this.form, this.initial, {super.key});
  final ReplyRewardForm form;
  final ReplyRewardDraft? initial;
  @override
  State<ReplyRewardPage> createState() => _State();
}

class _State extends State<ReplyRewardPage> {
  late final amount = TextEditingController(
    text: '${widget.initial?.amount ?? 1}',
  );
  late final times = TextEditingController(
    text: '${widget.initial?.times ?? 1}',
  );
  late int limit = widget.form.limits.contains(widget.initial?.perMember)
      ? widget.initial!.perMember
      : widget.form.limits.first;
  late int chance = widget.form.chances.contains(widget.initial?.chance)
      ? widget.initial!.chance
      : widget.form.chances.first;
  @override
  void dispose() {
    amount.dispose();
    times.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context), form = widget.form;
    final d = ReplyRewardDraft(
      int.tryParse(amount.text) ?? 0,
      int.tryParse(times.text) ?? 0,
      limit,
      chance,
    );
    Widget input(String label, TextEditingController ctrl) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        PlatformTextField(
          controller: ctrl,
          hintText: label,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
    Widget choice(
      String label,
      int current,
      List<int> options,
      ValueChanged<int> select,
    ) => PlatformListTile(
      title: Text(label),
      trailing: Icon(PlatformIcons(context).expandMore),
      onTap: () async {
        final result = await showPlatformModalSheet<int>(
          context: context,
          builder: (ctx) => SafeArea(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final v in options)
                  PlatformListTile(
                    title: Text('$v'),
                    selected: v == current,
                    onTap: () => Navigator.pop(ctx, v),
                  ),
              ],
            ),
          ),
        );
        if (result != null && mounted) setState(() => select(result));
      },
    );
    return PostSettingsSheet(
      title: s.replyCreditTitle,
      hasSave: true,
      onSave: form.accepts(d) ? () => Navigator.pop(context, d) : null,
      children: [
        input('${s.rewardPerReply} · ${form.unit}', amount),
        const SizedBox(height: 12),
        input(s.rewardPortions, times),
        choice(
          s.replyCreditPerMember(limit),
          limit,
          form.limits,
          (v) => limit = v,
        ),
        choice(
          s.replyCreditChance(chance == 0 ? 100 : chance),
          chance,
          form.chances,
          (v) => chance = v,
        ),
        if (d.valid) ...[
          Text(s.rewardTotal('${form.total(d)} ${form.unit}')),
          if (form.total(d) > form.balance) Text(s.forumCreditsInsufficient),
        ],
      ],
    );
  }
}
