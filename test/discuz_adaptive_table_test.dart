import 'package:discuz_flutter/utility/PostTextUtils.dart';
import 'package:discuz_flutter/widget/DiscuzAdaptiveTable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';

void main() {
  const malformedTable = '''
<table class="dzcode_table" cellspacing="0"bgcolor="White">
  <tr><td><strong>游戏</strong></td></tr>
  <td>促销价</td></tr>
  <td>最低价</td></tr>
  <tr><td><a href="https://example.com/game">Example Game</a></td></tr>
  <td><font color="#ff0000">73.62</font></td></tr>
  <td>88.2</td></tr>
</table>
''';

  test('repairs Discuz rows that close after every cell', () {
    final normalized = DiscuzTableNormalizer.normalizeHtml(malformedTable);
    final table = parseFragment(normalized).querySelector('table')!;
    final rows = table.querySelectorAll('tr');

    expect(rows, hasLength(2));
    expect(_cells(rows[0]), hasLength(3));
    expect(_cells(rows[1]), hasLength(3));
    expect(_cells(rows[0]).map((cell) => cell.text.trim()), [
      '游戏',
      '促销价',
      '最低价',
    ]);
    expect(_cells(rows[1]).map((cell) => cell.text.trim()), [
      'Example Game',
      '73.62',
      '88.2',
    ]);
  });

  test('leaves a valid table unchanged', () {
    const valid = '<table><tr><td>A</td><td>B</td></tr></table>';
    expect(DiscuzTableNormalizer.normalizeHtml(valid), valid);
  });

  test('repairs rows before the app link preprocessor parses the HTML', () {
    final repairedSource = DiscuzTableNormalizer.normalizeHtml(malformedTable);
    final decoded = PostTextUtils.getDecodedString(repairedSource, false);
    final rows = parseFragment(decoded).querySelectorAll('tr');

    expect(rows, hasLength(2));
    expect(_cells(rows[0]), hasLength(3));
    expect(_cells(rows[1]), hasLength(3));
    expect(rows[1].querySelector('a')?.attributes['href'],
        'https://example.com/game');
  });

  testWidgets('renders repaired tables at phone and tablet widths',
      (tester) async {
    final normalized = DiscuzTableNormalizer.normalizeHtml(malformedTable);
    final table = parseFragment(normalized).querySelector('table')!;

    Future<void> pumpAtWidth(double width, dom.Element tableElement) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(colorSchemeSeed: Colors.indigo),
          darkTheme: ThemeData(
            colorSchemeSeed: Colors.indigo,
            brightness: Brightness.dark,
          ),
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: width,
                child: DiscuzAdaptiveTable(
                  element: tableElement,
                  textStyle: const TextStyle(fontSize: 15),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    await pumpAtWidth(390, table);
    expect(find.byType(Scrollbar), findsOneWidget);
    await pumpAtWidth(820, table);
    expect(find.byType(Scrollbar), findsNothing);

    final twoColumnTable = parseFragment(
      '<table><tr><th>Name</th><th>Value</th></tr>'
      '<tr><td>Region</td><td>China</td></tr></table>',
    ).querySelector('table')!;
    await pumpAtWidth(390, twoColumnTable);
    expect(find.byType(Scrollbar), findsNothing);

    final spanningTable = parseFragment(
      '<table><tr><th colspan="2">Header</th></tr>'
      '<tr><td>A</td><td>B</td></tr></table>',
    ).querySelector('table')!;
    await pumpAtWidth(390, spanningTable);
  });
}

List<dom.Element> _cells(dom.Element row) => row.children
    .where((child) => child.localName == 'td' || child.localName == 'th')
    .toList(growable: false);
