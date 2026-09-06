import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/provider/TypeSettingNotifierProvider.dart';
import 'package:discuz_flutter/widget/DiscuzAdaptiveTable.dart';
import 'package:discuz_flutter/widget/DiscuzCodeBlock.dart';
import 'package:discuz_flutter/widget/DiscuzHtmlWidget.dart';
import 'package:discuz_flutter/widget/DiscuzQuoteBlock.dart';
import 'package:discuz_flutter/widget/reading_glass_sliver_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _discuz = Discuz('https://example.com', 'X3.5', 'utf-8', 4, '', '', false,
    '0', '0', 'Example', '1', '', '0');

Widget _host(String html, ScrollController controller,
    {bool sliver = true,
    bool dark = false,
    double fontScale = 1,
    VoidCallback? onBodyReady}) {
  final body = DiscuzHtmlWidget(_discuz, html,
      asSliver: sliver, onBodyReady: onBodyReady);
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
          create: (_) =>
              TypeSettingNotifierProvider()..setScalingParameter(fontScale)),
      ChangeNotifierProvider(create: (_) => ThemeNotifierProvider()),
    ],
    child: MaterialApp(
      localizationsDelegates: const [S.delegate],
      theme: ThemeData(brightness: dark ? Brightness.dark : Brightness.light),
      home: Scaffold(
          body: CustomScrollView(controller: controller, slivers: [
        if (sliver)
          ReadingGlassSliverCard(
              sliver: SliverMainAxisGroup(slivers: [
            const SliverToBoxAdapter(child: Text('header')),
            body,
            const SliverToBoxAdapter(child: Text('footer')),
          ]))
        else
          SliverToBoxAdapter(child: body),
      ])),
    ),
  );
}

Future<void> _waitForHtml(WidgetTester tester) async {
  // The production renderer parses >10k HTML in an isolate. Let that real
  // future finish; fake pumpAndSettle alone can finish before the parse does.
  for (var attempt = 0; attempt < 50; attempt++) {
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pumpAndSettle();
    if (find
        .textContaining('paragraph-0', findRichText: true)
        .evaluate()
        .isNotEmpty) {
      return;
    }
  }
  fail('asynchronous HTML did not load');
}

void main() {
  testWidgets(
      'asynchronous box body signals readiness after real content exists',
      (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    var ready = false;
    final html =
        List.generate(180, (i) => '<p>paragraph-$i ${'reading text ' * 8}</p>')
            .join();
    await tester
        .pumpWidget(_host(html, controller, sliver: false, onBodyReady: () {
      expect(find.textContaining('paragraph-0', findRichText: true),
          findsOneWidget);
      ready = true;
    }));
    expect(ready, isFalse);
    await _waitForHtml(tester);
    expect(ready, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty box body also releases a pending restoration',
      (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    var ready = false;
    await tester.pumpWidget(
        _host('', controller, sliver: false, onBodyReady: () => ready = true));
    await tester.pumpAndSettle();
    expect(ready, isTrue);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'long asynchronous HTML lays out nearby blocks, not the whole post',
      (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    final html =
        List.generate(180, (i) => '<p>paragraph-$i ${'reading text ' * 8}</p>')
            .join();
    expect(html.length, greaterThan(10000));
    await tester.pumpWidget(_host(html, controller));
    await _waitForHtml(tester);
    final initiallyBuilt = find.byType(RichText).evaluate().length;
    expect(initiallyBuilt, lessThan(40));
    expect(
        find.textContaining('paragraph-179', findRichText: true), findsNothing);
    expect(find.byType(Scrollable), findsOneWidget);
    expect(find.byType(BackdropFilter), findsNothing);
    await tester.scrollUntilVisible(find.text('footer'), 450,
        scrollable: find.byType(Scrollable), maxScrolls: 120);
    await tester.pumpAndSettle();
    expect(find.textContaining('paragraph-179', findRichText: true),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('short box rendering remains the default', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
        _host('<p>unchanged short post</p>', controller, sliver: false));
    await tester.pumpAndSettle();
    expect(
        find.text('unchanged short post', findRichText: true), findsOneWidget);
    expect(find.byType(SliverList), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty and refreshed HTML use valid sliver placeholders',
      (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(_host('', controller));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(_host('<p>old content</p>', controller));
    await tester.pumpAndSettle();
    expect(find.text('old content', findRichText: true), findsOneWidget);
    await tester.pumpWidget(_host('<p>refreshed content</p>', controller));
    await tester.pumpAndSettle();
    expect(find.text('old content', findRichText: true), findsNothing);
    expect(find.text('refreshed content', findRichText: true), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('restoring an offset returns to the same visible text',
      (tester) async {
    final controller = ScrollController();
    final restored = ScrollController(initialScrollOffset: 1800);
    addTearDown(controller.dispose);
    addTearDown(restored.dispose);
    final html =
        List.generate(100, (i) => '<h2>section-$i</h2>text<br>more text<br>')
            .join();
    List<Object> visible() => [
          for (final element in find.byType(RichText).evaluate())
            if ((element.widget as RichText)
                    .text
                    .toPlainText()
                    .startsWith('section-') &&
                tester.getTopLeft(find.byWidget(element.widget)).dy >= 0 &&
                tester.getTopLeft(find.byWidget(element.widget)).dy < 600)
              [
                (element.widget as RichText).text.toPlainText(),
                tester.getTopLeft(find.byWidget(element.widget)).dy
              ],
        ];
    await tester.pumpWidget(_host(html, controller));
    await tester.pumpAndSettle();
    expect(find.text('section-99', findRichText: true), findsNothing);
    controller.jumpTo(1800);
    await tester.pumpAndSettle();
    final before = visible();
    expect(before, isNotEmpty);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(_host(html, restored));
    await tester.pumpAndSettle();
    expect(restored.offset, 1800);
    expect(visible(), before);
    expect(tester.takeException(), isNull);
  });

  testWidgets('quotes, code and tables stay atomic in dark mode and large text',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(_host(
        '<blockquote><p>quoted source</p></blockquote>'
        '<pre><code class="language-dart">first();\n  second();</code></pre>'
        '<table><tr><th>Name</th><th>Price</th><th>Info</th></tr>'
        '<tr><td>Game</td><td>42</td><td>Details</td></tr></table>',
        controller,
        dark: true,
        fontScale: 1.5));
    await tester.pumpAndSettle();
    expect(find.byType(DiscuzQuoteBlock), findsOneWidget);
    expect(find.text('quoted source', findRichText: true), findsOneWidget);
    expect(tester.widget<DiscuzCodeBlock>(find.byType(DiscuzCodeBlock)).code,
        'first();\n  second();');
    expect(find.byType(DiscuzAdaptiveTable), findsOneWidget);
    expect(find.byType(BackdropFilter), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('expanded content stays expanded after leaving the viewport',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('haptic_feedback'), (_) async => false);
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('haptic_feedback'), null));
    final controller = ScrollController();
    addTearDown(controller.dispose);
    final paragraphs =
        List.generate(100, (i) => '<p>paragraph-$i some reading text</p>')
            .join();
    final html =
        '<collapse title="details"><p>expanded content</p></collapse>$paragraphs';
    await tester.pumpWidget(_host(html, controller));
    await tester.pumpAndSettle();
    await tester.tap(find.text('details'));
    await tester.pumpAndSettle();
    final expansion = tester.state(find.byType(ExpansionTile));
    expect(find.text('expanded content', findRichText: true), findsOneWidget);
    controller.jumpTo(2500);
    await tester.pumpAndSettle();
    controller.jumpTo(0);
    await tester.pumpAndSettle();
    expect(tester.state(find.byType(ExpansionTile)), same(expansion));
    expect(find.text('expanded content', findRichText: true), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('image gallery still includes images outside the viewport', () {
    final widget = DiscuzHtmlWidget(
        _discuz,
        '<p><img src="https://example.com/first.png"></p>'
        '${'<p>long body</p>' * 100}'
        '<p><img src="https://example.com/last.png"></p>',
        asSliver: true);
    expect(widget.getAllImageSrcList(),
        ['https://example.com/first.png', 'https://example.com/last.png']);
  });
}
