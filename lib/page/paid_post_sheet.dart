import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../client/paid_post.dart';
import '../generated/l10n.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../widget/post_settings_sheet.dart';

class PaidPostSheet extends StatefulWidget {
  const PaidPostSheet(this.rules, this.initial, this.files, {super.key});

  final PaidPostRules rules;
  final PaidPostDraft initial;
  final Map<String, String> files;

  @override
  State<PaidPostSheet> createState() => _PaidPostSheetState();
}

class _PaidPostSheetState extends State<PaidPostSheet> {
  late final thread = TextEditingController(
    text: initialPrice(widget.initial.thread),
  );
  late final files = {
    for (final id in widget.files.keys)
      id: TextEditingController(
        text: initialPrice(widget.initial.files[id] ?? 0),
      ),
  };

  static String initialPrice(int n) => n == 0 ? '' : '$n';

  @override
  void dispose() {
    thread.dispose();
    for (final field in files.values) {
      field.dispose();
    }
    super.dispose();
  }

  int price(TextEditingController field) =>
      field.text.trim().isEmpty ? 0 : int.tryParse(field.text) ?? -1;

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final rules = widget.rules;
    final draft = PaidPostDraft(
      thread: price(thread),
      files: {
        for (final e in files.entries)
          if (price(e.value) != 0) e.key: price(e.value),
      },
    );
    Widget field(
      String label,
      TextEditingController input,
      int? Function(int) estimate,
    ) {
      final amount = price(input);
      final net = amount > 0 && amount <= rules.maximum
          ? estimate(amount)
          : null;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 5,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleSmall),
            PlatformTextField(
              controller: input,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              hintText: '0',
              onChanged: (_) => setState(() {}),
            ),
            if (net != null) Text(strings.paidPostIncome('$net ${rules.unit}')),
          ],
        ),
      );
    }

    return PostSettingsSheet(
      title: strings.paidPostSettings,
      hasSave: true,
      onSave: rules.accepts(draft) ? () => Navigator.pop(context, draft) : null,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(strings.paidPostRange('${rules.maximum} ${rules.unit}')),
        ),
        field(strings.paidThreadPrice, thread, rules.threadNet),
        if (files.isNotEmpty)
          Text(
            strings.paidPostFilePrice,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        for (final e in files.entries)
          field(widget.files[e.key]!, e.value, rules.fileNet),
        if (!rules.accepts(draft)) Text(strings.paidPostInvalid),
      ],
    );
  }
}
