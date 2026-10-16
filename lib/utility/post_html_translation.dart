import 'package:html/dom.dart';
import 'package:html/parser.dart';

import 'AiPostText.dart';

/// Translates text nodes only. Markup and all attributes stay outside the model.
class PostHtmlTranslation {
  static String detectionText(String source) =>
      _textGroups(parseFragment(source)).values
          .map((nodes) => nodes.map((node) => node.data).join())
          .join('\n')
          .replaceAll(RegExp(r'(?:https?://|www\.)[^\s<>]+'), '')
          .trim();

  // Group contiguous inline text in document order. Block elements and line
  // breaks are boundaries; formatting and whitespace inside a sentence are not.
  static Map<Node, List<Text>> _textGroups(Node document) {
    final groups = <Node, List<Text>>{};
    var current = <Text>[];
    void visit(Node node) {
      var boundary = false;
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
            ).hasMatch(node.attributes['style'] ?? '')) {
          return;
        }
        boundary = const {
          'br',
          'p',
          'div',
          'li',
          'blockquote',
          'td',
          'th',
          'h1',
          'h2',
          'h3',
          'h4',
          'h5',
          'h6',
        }.contains(node.localName);
      }
      if (boundary) current = <Text>[];
      if (node is Text && node.data.isNotEmpty) {
        if (current.isEmpty) groups[node] = current;
        current.add(node);
      }
      for (final child in node.nodes) {
        visit(child);
      }
      if (boundary) current = <Text>[];
    }

    visit(document);
    return groups;
  }

  static Future<String> translate(
    String source,
    Future<String> Function(String text) translateText, {
    Future<String> Function(String text, String context)?
    translateTextWithContext,
  }) async {
    final document = parseFragment(source);
    final groups = _textGroups(document);
    final nodes = groups.values.expand((group) => group);
    final contexts = <Text, String>{};
    if (translateTextWithContext != null) {
      for (final group in groups.values) {
        final context = group
            .map((node) => node.data)
            .join()
            .replaceAll(RegExp(r'(?:https?://|www\.)[^\s<>]+'), '')
            .trim();
        for (final node in group) {
          contexts[node] = context;
        }
      }
    }
    var changed = false;
    final cache = <(String, String?), String>{};
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
          final context = contexts[node];
          final key = (chunk, context);
          final translated =
              cache[key] ??
              await (translateTextWithContext == null
                  ? translateText(chunk)
                  : translateTextWithContext(chunk, context!));
          if (translated.trim().isEmpty) throw StateError('Empty translation');
          cache[key] = translated;
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
