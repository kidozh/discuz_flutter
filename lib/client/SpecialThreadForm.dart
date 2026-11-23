import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html;

import '../utility/discuz_json.dart';
import 'ForumInteractionClient.dart';

enum SpecialThreadKind {
  reward(3),
  activity(4),
  debate(5);

  const SpecialThreadKind(this.id);
  final int id;
}

class SpecialThreadDraft {
  const SpecialThreadDraft(this.kind, this.fields);
  final SpecialThreadKind kind;
  final Map<String, String> fields;

  String encode() => jsonEncode({'kind': kind.name, 'fields': fields});

  static SpecialThreadDraft? decode(String value) {
    try {
      final data = discuzMap(jsonDecode(value));
      final kind = SpecialThreadKind.values.asNameMap()[data['kind']];
      if (kind == null) return null;
      return SpecialThreadDraft(
        kind,
        discuzMap(data['fields'])
            .map((key, value) => MapEntry(key, discuzString(value))),
      );
    } on FormatException {
      return null;
    }
  }
}

class RewardTerms {
  const RewardTerms(
    this.minimum,
    this.maximum,
    this.tax,
    this.credit,
    this.hint,
    this.balance,
  );
  final int minimum, maximum;
  final double tax;
  final String credit, hint;
  final int? balance;

  int total(int amount) => amount + (amount * tax).ceil();
  bool allows(int amount) =>
      amount >= minimum &&
      amount <= maximum &&
      (balance == null || total(amount) <= balance!);

  (int, int, double, String) get rules => (minimum, maximum, tax, credit);
}

class SpecialThreadForm {
  const SpecialThreadForm({
    this.formhash = '',
    this.reward,
    this.activityCategories = const [],
    this.registrationFields = const {},
    this.customFieldLimit = 0,
    this.credit = '',
    this.debateFields = const {},
  });

  final String formhash;
  final RewardTerms? reward;
  final List<String> activityCategories;
  final Map<String, String> registrationFields;
  final int customFieldLimit;
  final String credit;
  final Set<String> debateFields;

  Map<String, dynamic> submissionFields(SpecialThreadDraft draft) {
    final fields = draft.fields;
    if (draft.kind == SpecialThreadKind.reward) {
      return {'special': '3', 'rewardprice': fields['rewardprice']!};
    }
    if (draft.kind == SpecialThreadKind.debate) {
      return {
        'special': '5',
        for (final key in debateFields)
          if (fields[key]?.isNotEmpty == true)
            key: key == 'endtime' ? _discuzDate(fields[key]!) : fields[key]!,
      };
    }
    final hasEnd = fields['starttimeto']?.isNotEmpty == true;
    final profileFields = (fields['userfield'] ?? '')
        .split(',')
        .where((id) => id.isNotEmpty)
        .toList();
    return {
      'special': '4',
      'activitytime': hasEnd ? '1' : '0',
      'starttimefrom[${hasEnd ? 1 : 0}]': _discuzDate(fields['starttime']!),
      for (final key in ['starttimeto', 'activityexpiration'])
        if (fields[key]?.isNotEmpty == true) key: _discuzDate(fields[key]!),
      for (final key in [
        'activityplace',
        'activityclass',
        'activitynumber',
        'gender',
        'cost',
        'activitycredit',
        'extfield',
      ])
        if (fields[key]?.isNotEmpty == true) key: fields[key]!,
      if (profileFields.isNotEmpty) 'userfield[]': profileFields,
    };
  }

  static Future<SpecialThreadForm> load(
    ForumInteractionClient client,
    int fid,
    int uid,
    SpecialThreadKind kind,
  ) async {
    final permission = await client.request('newthread', {
      'fid': fid,
      'special': kind.id,
    });
    permission.requireData('formhash');
    final hash = discuzString(permission.variables['formhash']);
    if (discuzInt(permission.variables['member_uid']) != uid || hash.isEmpty) {
      throw const ForumApiException('account_changed', '');
    }
    final uri = website(client.endpoint.resolve('../../'), fid, kind);
    final response = await client.dio.getUri<String>(
      uri,
      options: Options(responseType: ResponseType.plain),
    );
    return parse(response.data ?? '', hash, kind);
  }

  static Uri website(Uri base, int fid, SpecialThreadKind kind) => base
      .resolve('forum.php')
      .replace(
        queryParameters: {
          'mod': 'post',
          'action': 'newthread',
          'fid': '$fid',
          'special': '${kind.id}',
          'mobile': 'no',
        },
      );

  static SpecialThreadForm parse(
    String source,
    String formhash,
    SpecialThreadKind kind,
  ) {
    const unavailable = ForumApiException('special_post_form_unavailable', '');
    final document = html.parse(source);
    final form = document.querySelector('form#postform');
    if (form == null ||
        form.querySelector('input[name="formhash"]')?.attributes['value'] !=
            formhash) {
      throw unavailable;
    }
    if (kind == SpecialThreadKind.reward) {
      final input = form.querySelector('#rewardprice');
      if (input == null) throw unavailable;
      final scripts = form
          .querySelectorAll('script')
          .map((script) => script.text)
          .join('\n');
      final limits = RegExp(r'price\s*<\s*(\d+)\s*\|\|\s*\((\d*)\s*>\s*0')
          .firstMatch(scripts);
      final tax = RegExp(r'price\s*\*\s*(\d+(?:\.\d+)?)\s*\)')
          .firstMatch(scripts);
      if (limits == null || tax == null) throw unavailable;
      final max = int.tryParse(limits[2]!) ?? 0;
      final title = _followingLabel(input)
          .trim()
          .split(RegExp(r'[,，]'))
          .first
          .trim();
      final hint =
          input.parent
              ?.querySelector('.xg1')
              ?.text
              .trim()
              .replaceAll(RegExp(r'\s+'), ' ') ??
          '';
      final balanceSuffix = title.isEmpty
          ? null
          : RegExp(r'(-?\d+)\s*' + RegExp.escape(title) + r'\s*$')
                .firstMatch(hint);
      return SpecialThreadForm(
        formhash: formhash,
        reward: RewardTerms(
          int.parse(limits[1]!).clamp(1, 32767),
          max == 0 ? 32767 : max.clamp(1, 32767),
          double.parse(tax[1]!),
          title,
          hint,
          int.tryParse(balanceSuffix?.group(1) ?? ''),
        ),
      );
    }

    if (kind == SpecialThreadKind.debate) {
      final fields = {
        for (final name in ['affirmpoint', 'negapoint', 'endtime', 'umpire'])
          if (form.querySelector('[name="$name"]:not([disabled])') != null)
            name,
      };
      if (!fields.containsAll({'affirmpoint', 'negapoint'})) throw unavailable;
      return SpecialThreadForm(formhash: formhash, debateFields: fields);
    }

    if (form.querySelector('#activityplace') == null ||
        form.querySelector('#activityclass') == null) {
      throw unavailable;
    }
    final fields = <String, String>{};
    for (final field in form.querySelectorAll('input[name="userfield[]"]')) {
      final id = field.attributes['value'];
      final label = field.parent?.text.trim() ?? '';
      if (id != null && id.isNotEmpty) fields[id] = label.isEmpty ? id : label;
    }
    final custom = form.querySelector('#extfield');
    final limit =
        int.tryParse(
          RegExp(r'\d+')
                  .allMatches(custom?.parent?.text ?? '')
                  .lastOrNull
                  ?.group(0) ??
              '',
        ) ??
        0;
    final credit = form.querySelector('#activitycredit');
    return SpecialThreadForm(
      formhash: formhash,
      activityCategories: form
          .querySelectorAll('#activitytypelist li')
          .map((item) => item.text.trim())
          .where((item) => item.isNotEmpty)
          .toList(),
      registrationFields: fields,
      customFieldLimit: limit,
      credit: credit == null ? '' : _followingLabel(credit),
    );
  }

  bool accepts(SpecialThreadDraft draft) {
    final fields = draft.fields;
    if (draft.kind == SpecialThreadKind.reward) {
      return reward?.allows(int.tryParse(fields['rewardprice'] ?? '') ?? 0) ==
          true;
    }
    if (draft.kind == SpecialThreadKind.debate) {
      final ending = fields['endtime'];
      return debateFields.containsAll({'affirmpoint', 'negapoint'}) &&
          fields['affirmpoint']?.trim().isNotEmpty == true &&
          fields['negapoint']?.trim().isNotEmpty == true &&
          fields.entries.every(
            (entry) => entry.value.isEmpty || debateFields.contains(entry.key),
          ) &&
          (ending == null ||
              ending.isEmpty ||
              DateTime.tryParse(ending)?.isAfter(DateTime.now()) == true);
    }
    if (fields['activityclass']?.trim().isNotEmpty != true ||
        fields['activityplace']?.trim().isNotEmpty != true) {
      return false;
    }
    final start = DateTime.tryParse(fields['starttime'] ?? '');
    final end = DateTime.tryParse(fields['starttimeto'] ?? '');
    if (start == null ||
        (fields['starttimeto']?.isNotEmpty == true && end == null) ||
        (end != null && end.isBefore(start)) ||
        (fields['activityexpiration']?.isNotEmpty == true &&
            DateTime.tryParse(fields['activityexpiration']!) == null)) {
      return false;
    }
    for (final key in ['cost', 'activitycredit', 'activitynumber']) {
      final value = fields[key];
      if (value != null &&
          value.isNotEmpty &&
          (int.tryParse(value) ?? -1) < 0) {
        return false;
      }
    }
    final custom = (fields['extfield'] ?? '')
        .split('\n')
        .where((name) => name.isNotEmpty)
        .toSet();
    final profileFields = (fields['userfield'] ?? '').split(',');
    return custom.length <= customFieldLimit &&
        profileFields
            .where((id) => id.isNotEmpty)
            .every(registrationFields.containsKey) &&
        (credit.isNotEmpty ||
            (int.tryParse(fields['activitycredit'] ?? '') ?? 0) == 0);
  }
}

String _discuzDate(String value) =>
    DateTime.parse(value).toUtc().toIso8601String();

String _followingLabel(Element input) {
  final siblings = input.parent?.nodes;
  if (siblings == null) return '';
  final next = siblings.skip(siblings.indexOf(input) + 1).firstOrNull;
  return next is Text || (next is Element && next.localName == 'span')
      ? next?.text?.trim() ?? ''
      : '';
}
