import 'package:html/dom.dart';
import 'package:html/parser.dart';

/// API previews may be plain text or HTML, including an edit-status wrapper.
String forumThreadPreview(String source) {
  final fragment = parseFragment(source);
  for (final element in fragment.querySelectorAll('script, style')) {
    element.remove();
  }
  for (final element in fragment.querySelectorAll('.pstatus')) {
    if (element.text.trim().startsWith('本帖最后由') &&
        element.text.contains('编辑')) {
      element.remove();
    }
  }
  const blocks = {'p', 'div', 'li', 'blockquote', 'br'};
  final text = StringBuffer();
  void collect(Node node) {
    if (node is Text) {
      text.write(node.data);
    } else {
      if (node is Element && blocks.contains(node.localName)) text.write(' ');
      for (final child in node.nodes) {
        collect(child);
      }
      if (node is Element && blocks.contains(node.localName)) text.write(' ');
    }
  }

  collect(fragment);
  return text.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
}
