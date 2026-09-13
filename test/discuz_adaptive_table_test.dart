import 'package:easy_refresh/easy_refresh.dart';
import 'package:discuz_flutter/utility/PostTextUtils.dart';
import 'package:discuz_flutter/widget/DiscuzAdaptiveTable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';

void main() {
  testWidgets('table edges do not inherit refresh physics or trigger loading', (
    tester,
  ) async {
    var refreshes = 0, loads = 0;
    final table = parseFragment(
      '<table><tr><td>A</td><td>B</td><td>C</td></tr></table>',
    ).querySelector('table')!;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            child: EasyRefresh(
              onRefresh: () {
                refreshes++;
              },
              onLoad: () {
                loads++;
              },
              child: ListView(
                children: [
                  DiscuzAdaptiveTable(
                    element: table,
                    textStyle: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 1000),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final horizontal = find.byType(SingleChildScrollView);
    final scroll = tester.widget<SingleChildScrollView>(horizontal).controller!;
    await tester.drag(horizontal, const Offset(350, 0));
    await tester.pumpAndSettle();
    expect(scroll.offset, 0);
    await tester.drag(horizontal, const Offset(-1500, 0));
    await tester.pumpAndSettle();
    expect(scroll.offset, scroll.position.maxScrollExtent);
    expect(refreshes, 0);
    expect(loads, 0);
    expect(
      scroll.position.physics.toString(),
      isNot(contains('ERScrollPhysics')),
    );
    // The enclosing post still supports intentional vertical pull-to-refresh.
    await tester.dragFrom(const Offset(150, 250), const Offset(0, 500));
    await tester.pumpAndSettle();
    expect(refreshes, 1);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('row repaint isolation preserves original image and link taps', (
    tester,
  ) async {
    const src =
        'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jB1kAAAAASUVORK5CYII=';
    final images = <String>[];
    final links = <String>[];
    final table = parseFragment(
      '<table><tr><td><img src="$src" width="120" height="80" alt="original picture"></td>'
      '<td><a href="https://example.com/game">Open game</a></td></tr>'
      '<tr><td>second row</td><td>value</td></tr></table>',
    ).querySelector('table')!;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 390,
              child: DiscuzAdaptiveTable(
                element: table,
                textStyle: const TextStyle(fontSize: 15),
                onTapImage: images.add,
                onTapUrl: (url) {
                  links.add(url);
                  return true;
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final boundaries = find.descendant(
      of: find.byType(DiscuzAdaptiveTable),
      matching: find.byType(RepaintBoundary),
    );
    expect(boundaries, findsNWidgets(2));
    await tester.tap(find.byType(Image));
    await tester.tap(find.text('Open game', findRichText: true));
    await tester.pumpAndSettle();
    expect(images, [src]);
    expect(links, ['https://example.com/game']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('horizontal table scrolling survives rebuilding row boundaries', (
    tester,
  ) async {
    final table = parseFragment(
      '<table><tr><td>A</td><td>B</td><td>C</td></tr>'
      '<tr><td>D</td><td>E</td><td>F</td></tr></table>',
    ).querySelector('table')!;
    Widget host() => MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 320,
            child: DiscuzAdaptiveTable(
              element: table,
              textStyle: const TextStyle(fontSize: 15),
            ),
          ),
        ),
      ),
    );
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    final scroll = find.byType(SingleChildScrollView);
    final rows = tester
        .renderObjectList<RenderRepaintBoundary>(
          find.descendant(
            of: find.byType(DiscuzAdaptiveTable),
            matching: find.byType(RepaintBoundary),
          ),
        )
        .toList();
    for (final row in rows) {
      row.debugResetMetrics();
    }
    await tester.drag(scroll, const Offset(-160, 0));
    await tester.pumpAndSettle();
    expect(rows.every((row) => row.debugSymmetricPaintCount == 0), isTrue);
    expect(rows.any((row) => row.debugAsymmetricPaintCount > 0), isTrue);
    final controller = tester.widget<SingleChildScrollView>(scroll).controller!;
    final offset = controller.offset;
    expect(offset, greaterThan(0));
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    expect(
      tester.widget<SingleChildScrollView>(scroll).controller,
      same(controller),
    );
    expect(controller.offset, offset);
    expect(tester.takeException(), isNull);
  });
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
    expect(
      rows[1].querySelector('a')?.attributes['href'],
      'https://example.com/game',
    );
  });

  testWidgets('renders repaired tables at phone and tablet widths', (
    tester,
  ) async {
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
