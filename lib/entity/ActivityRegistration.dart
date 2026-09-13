import 'dart:convert';
import '../utility/discuz_json.dart';

class ActivityJoinField {
  final String id, title, type;
  final List<String> choices;
  const ActivityJoinField(this.id, this.title, this.type, this.choices);
}

class ActivityRegistration {
  final Map<String, dynamic> raw;
  final List<ActivityJoinField> fields;
  final bool supported;
  ActivityRegistration._(this.raw, this.fields, this.supported);
  static const reserved = {
    'action',
    'module',
    'tid',
    'fid',
    'formhash',
    'version',
    'payment',
    'payvalue',
    'message',
    'activitysubmit',
    'activitycancel',
    't',
  };
  factory ActivityRegistration.fromJson(Object? value) {
    final raw = discuzMap(value);
    final fields = <ActivityJoinField>[];
    var supported = raw.isNotEmpty;
    final keys = <String>{};
    void add(String id, String title, String type, Object? choices) {
      if (id.isEmpty ||
          reserved.contains(id) ||
          id.contains(RegExp(r'[\[\]&=]')) ||
          !keys.add(id) ||
          !{'text', 'textarea', 'select', 'radio', 'checkbox'}.contains(type)) {
        supported = false;
        return;
      }
      final options = choices is Map
          ? choices.values.map(discuzString).toList()
          : choices is List
          ? choices.map(discuzString).toList()
          : discuzString(
              choices,
            ).split(RegExp(r'\r?\n')).where((s) => s.isNotEmpty).toList();
      if ({'select', 'radio', 'checkbox'}.contains(type) && options.isEmpty)
        supported = false;
      fields.add(
        ActivityJoinField(id, title.isEmpty ? id : title, type, options),
      );
    }

    for (final entry in discuzMap(raw['joinfield']).entries) {
      final field = discuzMap(entry.value);
      final id = discuzString(field['fieldid']).isEmpty
          ? entry.key
          : discuzString(field['fieldid']);
      add(
        id,
        discuzString(field['title']),
        discuzString(field['formtype']),
        field['choices'],
      );
    }
    final ufield = discuzMap(raw['ufield']);
    final expected = discuzIds(ufield['userfield']);
    if (expected.any((id) => !keys.contains(id))) supported = false;
    for (final name in discuzIds(ufield['extfield'])) {
      add(name, name, 'text', null);
    }
    if (raw['ufield'] is String && discuzString(raw['ufield']).isNotEmpty)
      supported = false;
    return ActivityRegistration._(raw, fields, supported);
  }
  String get button => discuzString(raw['button']);
  bool get closed => discuzPermission(raw['closed']) == true;
  String get cost => discuzString(raw['cost']);
  String get creditCost => discuzString(raw['creditcost']);
  String get terms => jsonEncode([
    button,
    closed,
    cost,
    creditCost,
    raw['expiration'],
    raw['number'],
    fields.map((f) => [f.id, f.type, f.choices]).toList(),
    supported,
  ]);
  Map<String, dynamic> form(
    Map<String, String> values,
    String message,
    String? contribution,
  ) {
    if ((!supported && button != 'cancel') ||
        closed ||
        !{'join', 'cancel'}.contains(button))
      throw const FormatException('Unavailable activity');
    if (button == 'join' &&
        fields.any((f) => (values[f.id] ?? '').trim().isEmpty))
      throw const FormatException('Required field');
    final amount = contribution == null ? null : int.tryParse(contribution);
    if (contribution != null && (amount == null || amount < 0))
      throw const FormatException('Invalid contribution');
    return {
      button == 'cancel' ? 'activitycancel' : 'activitysubmit': 'yes',
      'message': message,
      if (button == 'join') ...{
        'payment': contribution == null ? '0' : '1',
        'payvalue': '${amount ?? 0}',
        for (final field in fields) field.id: values[field.id] ?? '',
      },
    };
  }
}
