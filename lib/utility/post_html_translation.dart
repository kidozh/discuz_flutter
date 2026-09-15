import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'AiPostText.dart';

/// Translates text nodes only. Markup and all attributes stay outside the model.
class PostHtmlTranslation {
  static String detectionText(String source) =>
      _textNodes(parseFragment(source))
          .map((node) => node.data)
          .join('\n')
          .replaceAll(RegExp(r'(?:https?://|www\.)[^\s<>]+'), '')
          .trim();

  static List<Text> _textNodes(Node document) {
    final nodes = <Text>[];
    void visit(Node node) {
      if (node is Element) {
        if (const {
              'script',
              'style',
              'template',
              'code',
              'pre',
              'svg',
              'video',
              'audio',
              'iframe',
            }.contains(node.localName) ||
            node.attributes.containsKey('hidden') ||
            node.attributes['translate'] == 'no' ||
            RegExp(
              r'display\s*:\s*none|visibility\s*:\s*hidden',
              caseSensitive: false,
            ).hasMatch(node.attributes['style'] ?? ''))
          return;
      }
      if (node is Text && node.data.trim().isNotEmpty) nodes.add(node);
      for (final child in node.nodes) {
        visit(child);
      }
    }

    visit(document);
    return nodes;
  }

  static Future<String> translate(
    String source,
    Future<String> Function(String text) translateText,
  ) async {
    final document = parseFragment(source);
    final nodes = _textNodes(document);
    var changed = false;
    final cache = <String, String>{};
    final urls = RegExp(r'(?:https?://|www\.)[^\s<>]+');
    for (final node in nodes) {
      final original = node.data;
      final output = StringBuffer();
      var offset = 0;
      Future<void> appendText(String text) async {
        if (text.trim().isEmpty) {
          output.write(text);
          return;
        }
        final leading = RegExp(r'^\s*').stringMatch(text)!;
        final trailing = RegExp(r'\s*$').stringMatch(text)!;
        output.write(leading);
        final chunks = AiPostText.chunks(text.trim());
        for (var i = 0; i < chunks.length; i++) {
          final chunk = chunks[i];
          final translated = cache[chunk] ?? await translateText(chunk);
          if (translated.trim().isEmpty) throw StateError('Empty translation');
          cache[chunk] = translated;
          output.write(translated);
          if (i < chunks.length - 1) output.write(' ');
        }
        output.write(trailing);
      }

      for (final match in urls.allMatches(original)) {
        await appendText(original.substring(offset, match.start));
        output.write(match.group(0));
        offset = match.end;
      }
      await appendText(original.substring(offset));
      final result = output.toString();
      changed |= !AiPostText.sameText(original, result);
      node.data = result; // DOM serialization escapes model output as text.
    }
    if (!changed) throw const UnchangedPostTranslation();
    return document.outerHtml;
  }
}

class UnchangedPostTranslation implements Exception {
  const UnchangedPostTranslation();
}
