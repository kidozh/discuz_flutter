import 'dart:convert';

import '../utility/reply_draft_store.dart';

class PollDraft {
  final List<String> options;
  final int maxChoices, days;
  final Map<int, ReplyDraftAttachment> images;
  final bool hideResults;
  const PollDraft(
    this.options,
    this.maxChoices,
    this.days, {
    this.images = const {},
    this.hideResults = false,
  });
  bool get valid =>
      options.length >= 2 &&
      images.keys.every((i) => i >= 0 && i < options.length) &&
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
    if (hideResults) 'visibilitypoll': '1',
  };
  String encode() => jsonEncode({
    'options': options,
    'maxChoices': maxChoices,
    'days': days,
    'hideResults': hideResults,
    'images': {for (final e in images.entries) '${e.key}': e.value.toJson()},
  });
  static PollDraft? decode(String value) {
    if (value.isEmpty) return null;
    try {
      final json = jsonDecode(value);
      final draft = PollDraft(
        List<String>.from(json['options']),
        json['maxChoices'],
        json['days'],
        hideResults: json['hideResults'] == true,
        images: {
          if (json['images'] is Map)
            for (final entry in (json['images'] as Map).entries)
              if (int.tryParse('${entry.key}') case final index?)
                if (ReplyDraftAttachment.fromJson(entry.value)
                    case final image?)
                  if (image.image) index: image,
        },
      );
      return draft.valid ? draft : null;
    } catch (_) {
      return null;
    }
  }
}
