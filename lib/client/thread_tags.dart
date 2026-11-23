import 'dart:convert';

String? forumThreadTags(String value) {
  final text = value.trim().replaceAll('，', ',').replaceAll('\u3000', ' ');
  if (text.isEmpty) return '';
  final tags =
      (text.contains(',') ? text.split(',') : text.split(RegExp(r'\s+')))
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toSet();
  final characters = RegExp(r'^[\w\s\-\u007f-\u{10ffff}]+$', unicode: true);
  if (tags.length > 5 ||
      tags.any((tag) {
        final size = utf8.encode(tag).length;
        return size < 2 || size > 20 || !characters.hasMatch(tag);
      })) {
    return null;
  }
  return tags.join(',');
}
