import 'package:html/parser.dart' as html;
import 'package:html/dom.dart' show Text;

/// Removes markup before sending post content to the on-device model.
class AiPostText {
  static const summaryThreshold = 500;

  static double _tokenCost(int rune) => rune <= 0x7f
      ? 1 / 3
      : rune > 0xffff
      ? 4
      : 2;

  static int estimatedTokens(String text) => text.runes
      .fold<double>(0, (total, rune) => total + _tokenCost(rune))
      .ceil();

  static int summaryPassageEnd(List<int> runes, int start, int budget) {
    var end = start;
    var cost = 0.0;
    while (end < runes.length && cost + _tokenCost(runes[end]) <= budget) {
      cost += _tokenCost(runes[end++]);
    }
    if (end == runes.length) return end;
    for (var i = end - 1; i > start + (end - start) ~/ 2; i--) {
      if ('\n 。！？.!?'.runes.contains(runes[i])) return i + 1;
    }
    return end;
  }

  static bool sameText(String source, String result) =>
      source.replaceAll(RegExp(r'\s+'), '') ==
      result.replaceAll(RegExp(r'\s+'), '');

  static String plainText(String source) {
    final document = html.parse(source);
    for (final node in document.querySelectorAll(
      'script, style, template, [hidden]',
    )) {
      node.remove();
    }
    for (final node in document.querySelectorAll(
      'br, p, div, li, blockquote, tr, h1, h2, h3, pre',
    )) {
      node.nodes.add(Text('\n'));
    }
    return (document.body?.text ?? '')
        .replaceAll(RegExp(r'[^\S\n]+'), ' ')
        .replaceAll(RegExp(r'\n\s*\n+'), '\n')
        .trim();
  }

  /// Conservative character budget, including for CJK. Never splits a surrogate pair.
  static List<String> chunks(String text, {int limit = 600}) {
    if (limit <= 0) throw ArgumentError.value(limit, 'limit');
    final runes = text.runes.toList();
    final result = <String>[];
    for (var start = 0; start < runes.length;) {
      var end = (start + limit).clamp(0, runes.length);
      if (end < runes.length) {
        for (var i = end - 1; i > start + limit ~/ 2; i--) {
          if ('\n 。！？.!?'.runes.contains(runes[i])) {
            end = i + 1;
            break;
          }
        }
      }
      result.add(String.fromCharCodes(runes.sublist(start, end)));
      start = end;
    }
    return result;
  }
}
