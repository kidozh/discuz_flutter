import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart';
import 'package:discuz_flutter/utility/post_html_translation.dart';

void main() {
  test(
    'translates link labels while preserving image, URL, structure and code',
    () async {
      final inputs = <String>[];
      final output = await PostHtmlTranslation.translate(
        '<p>Hello <a href="https://example.com/a?q=1&amp;x=2">Visit here</a>'
        '<img src="photo.jpg" alt="photo"></p><pre>let x = 1;</pre>'
        '<span hidden>secret</span><p>https://example.com/path</p>',
        (text) async {
          inputs.add(text);
          return '译:$text';
        },
      );
      final document = parseFragment(output);
      expect(inputs, ['Hello', 'Visit here']);
      expect(
        document.querySelector('a')!.attributes['href'],
        'https://example.com/a?q=1&x=2',
      );
      expect(document.querySelector('a')!.text, '译:Visit here');
      expect(document.querySelector('img')!.attributes, {
        'src': 'photo.jpg',
        'alt': 'photo',
      });
      expect(document.querySelector('pre')!.text, 'let x = 1;');
      expect(document.querySelector('[hidden]')!.text, 'secret');
      expect(
        document.querySelectorAll('p').last.text,
        'https://example.com/path',
      );
    },
  );
  test('model output is escaped, never interpreted as HTML', () async {
    final output = await PostHtmlTranslation.translate(
      '<p>Hello</p>',
      (_) async => '<img src="evil">',
    );
    expect(parseFragment(output).querySelector('img'), isNull);
    expect(parseFragment(output).text, '<img src="evil">');
  });
  test(
    'unchanged output is explicit and failures do not return partial HTML',
    () async {
      await expectLater(
        PostHtmlTranslation.translate('<p>Hello</p>', (s) async => s),
        throwsA(isA<UnchangedPostTranslation>()),
      );
      await expectLater(
        PostHtmlTranslation.translate('<p>Hello</p><p>World</p>', (s) async {
          if (s == 'World') throw StateError('failed');
          return '你好';
        }),
        throwsStateError,
      );
    },
  );
}
