import 'dart:convert';

class PollDraft {
  final List<String> options;
  final int maxChoices, days;
  const PollDraft(this.options, this.maxChoices, this.days);
  bool get valid =>
      options.length >= 2 &&
      options.length <= 20 &&
      options.every((s) => s.trim().isNotEmpty && s.length <= 80) &&
      options.toSet().length == options.length &&
      maxChoices >= 1 &&
      maxChoices <= options.length &&
      days >= 0 &&
      days <= 3650;
  Map<String, String> get fields => {
    'special': '1',
    'tpolloption': '2',
    'polloptions': options.join('\n'),
    'maxchoices': '$maxChoices',
    'expiration': '$days',
    'overt': '0',
  };
  String encode() =>
      jsonEncode({'options': options, 'maxChoices': maxChoices, 'days': days});
  static PollDraft? decode(String value) {
    if (value.isEmpty) return null;
    try {
      final json = jsonDecode(value);
      final draft = PollDraft(
        List<String>.from(json['options']),
        json['maxChoices'],
        json['days'],
      );
      return draft.valid ? draft : null;
    } catch (_) {
      return null;
    }
  }
}
