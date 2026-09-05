import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/provider/TypeSettingNotifierProvider.dart';
import 'package:discuz_flutter/widget/DiscuzCodeBlock.dart';
import 'package:discuz_flutter/widget/DiscuzHtmlWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart';
import 'package:provider/provider.dart';

void main() {
  test('extracts preserved code and language metadata', () {
    final pre = parseFragment(
      '<pre><code class="language-dart">\n'
      'void main() {\n  print(&quot;hi&quot;);\n}\n'
      '</code></pre>',
    ).querySelector('pre')!;

    expect(
      DiscuzCodeBlock.extractCode(pre),
      'void main() {\n  print("hi");\n}',
    );
    expect(DiscuzCodeBlock.extractLanguage(pre), 'dart');
  });

  test('extracts Discuz numbered blockcode without copy label', () {
    final block = parseFragment(
      '<div class="blockcode"><ol><li>first();</li><li>second();</li></ol>'
      '<em>复制代码</em></div>',
    ).querySelector('.blockcode')!;

    expect(DiscuzCodeBlock.extractCode(block), 'first();\nsecond();');
    expect(DiscuzCodeBlock.extractLanguage(block), isNull);
  });

  testWidgets('renders long code as a selectable horizontal code card',
      (tester) async {
    const longLine =
        'final message = "This deliberately long line should scroll horizontally instead of wrapping inside the post body";';

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(colorSchemeSeed: Colors.indigo),
        home: const Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 320,
              child: DiscuzCodeBlock(
                code: longLine,
                language: 'dart',
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('discuz-code-block')), findsOneWidget);
    expect(find.byKey(const ValueKey('discuz-code-text')), findsOneWidget);
    expect(find.text('DART'), findsOneWidget);
    expect(find.byType(Scrollbar), findsOneWidget);
    final codeText = tester.widget<SelectableText>(
      find.byKey(const ValueKey('discuz-code-text')),
    );
    expect(codeText.style?.fontFamily, 'monospace');
    final horizontalScroller = tester.widget<SingleChildScrollView>(
      find.byType(SingleChildScrollView),
    );
    expect(horizontalScroller.controller?.position.maxScrollExtent,
        greaterThan(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Discuz HTML replaces pre with the adaptive code card',
      (tester) async {
    final discuz = Discuz(
      'https://example.com',
      'X3.5',
      'utf-8',
      4,
      '1.4.8',
      'register',
      false,
      '0',
      '0',
      'Example',
      '1',
      'https://example.com/uc_server',
      '0',
      trueDiscuzVersion: 'X3.5',
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TypeSettingNotifierProvider()),
          ChangeNotifierProvider(create: (_) => ThemeNotifierProvider()),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: DiscuzHtmlWidget(
              discuz,
              '<p>Before <code>inline()</code></p>'
              '<pre><code class="language-kotlin">val answer = 42</code></pre>',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DiscuzCodeBlock), findsOneWidget);
    expect(find.text('KOTLIN'), findsOneWidget);
    expect(find.text('val answer = 42'), findsOneWidget);
    expect(find.text('inline()', findRichText: true), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
