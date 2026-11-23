import 'dart:convert';

import 'package:html/dom.dart';

import '../utility/discuz_json.dart';

class PaidPostDraft {
  const PaidPostDraft({this.thread = 0, this.files = const {}});

  final int thread;
  final Map<String, int> files;

  bool get empty => thread == 0 && files.isEmpty;

  PaidPostDraft retainFiles(Set<String> ids) => PaidPostDraft(
    thread: thread,
    files: {
      for (final e in files.entries)
        if (ids.contains(e.key)) e.key: e.value,
    },
  );

  Map<String, Object> toJson() => {'thread': thread, 'files': files};

  static PaidPostDraft restore(String saved) {
    if (saved.isEmpty) return const PaidPostDraft();
    try {
      final map = discuzMap(discuzMap(jsonDecode(saved))['paid']);
      final thread = discuzInt(map['thread']);
      return PaidPostDraft(
        thread: thread > 0 ? thread : 0,
        files: {
          for (final e in discuzMap(map['files']).entries)
            if (discuzInt(e.value) > 0) e.key: discuzInt(e.value),
        },
      );
    } on FormatException {
      return const PaidPostDraft();
    }
  }

  Map<String, String> submission(Map<String, int> uploaded) {
    if (files.keys.any((key) => (uploaded[key] ?? 0) <= 0)) {
      throw const FormatException('Priced attachment missing');
    }
    return {
      if (thread > 0) 'price': '$thread',
      for (final file in files.entries)
        'attachnew[${uploaded[file.key]}][price]': '${file.value}',
    };
  }
}

class PaidPostRules {
  const PaidPostRules({
    required this.maximum,
    required this.unit,
    required this.tax,
  });

  final int maximum;
  final String unit;
  final double? tax;

  static PaidPostRules? parse(Element form) {
    final section = form.querySelector('#extra_price_c');
    final price = section?.querySelector('input[name=price]:not([disabled])');
    if (section == null || price == null) return null;
    final hash =
        form.querySelector('input[name=formhash]')?.attributes['value'] ?? '';
    final limit = section.children
        .where((child) => child.classes.contains('xg1'))
        .firstOrNull;
    final matches = RegExp(r'[0-9]+').allMatches(limit?.text ?? '').toList();
    final max =
        int.tryParse(
          price.attributes['max'] ??
              price.attributes['data-max'] ??
              (matches.length == 1 ? matches.single.group(0)! : ''),
        ) ??
        0;
    final currency = section.nodes
        .skipWhile((node) => !identical(node, price))
        .skip(1)
        .takeWhile((node) => node is! Element)
        .whereType<Text>()
        .map((text) => text.data)
        .join()
        .trim();
    if (hash.isEmpty || currency.isEmpty || max <= 0) return null;

    var root = form;
    while (root.parent != null) {
      root = root.parent!;
    }
    final taxes = {
      for (final script in root.querySelectorAll('script:not([src])'))
        for (final quote in RegExp(
          r'\bvar\s+creditstax\s*=\s*(\d+(?:\.\d+)?)\s*;',
        ).allMatches(script.text))
          double.parse(quote.group(1)!),
    };
    final tax = taxes.length == 1 ? taxes.single : null;
    return PaidPostRules(
      maximum: max,
      unit: currency,
      tax: tax != null && tax >= 0 && tax <= 1 ? tax : null,
    );
  }

  int? threadNet(int price) =>
      tax == null ? null : (price * (1 - tax!)).floor();
  int? fileNet(int price) => tax == null ? null : (price * (1 - tax!)).round();

  bool accepts(PaidPostDraft draft) =>
      draft.thread >= 0 &&
      draft.thread <= maximum &&
      (draft.thread == 0 || (threadNet(draft.thread) ?? 1) > 0) &&
      draft.files.values.every((price) => price > 0 && price <= maximum);

  bool sameTerms(PaidPostRules other) =>
      other.maximum == maximum &&
      other.unit == unit &&
      other.tax == tax;
}
