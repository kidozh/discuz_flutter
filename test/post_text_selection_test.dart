import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/provider/TypeSettingNotifierProvider.dart';
import 'package:discuz_flutter/widget/DiscuzHtmlWidget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _discuz = Discuz(
  'https://example.com',
  'X3.5',
  'utf-8',
  4,
  '',
  '',
  false,
  '0',
  '0',
  'Example',
  '1',
  '',
  '0',
);

Widget _host({required bool sliver}) {
  final body = DiscuzHtmlWidget(
    _discuz,
    '<p>Before selected <b>words</b> after.</p>'
    '<blockquote><p>Quoted passage here.</p></blockquote>'
    '<table><tr><td>Table content here.</td></tr></table>',
    asSliver: sliver,
  );
  final scrollView = CustomScrollView(
    slivers: [
      const SliverToBoxAdapter(child: SizedBox(height: 100)),
      if (sliver) body else SliverToBoxAdapter(child: body),
    ],
  );
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => TypeSettingNotifierProvider()),
      ChangeNotifierProvider(create: (_) => ThemeNotifierProvider()),
    ],
    child: MaterialApp(
      localizationsDelegates: const [S.delegate],
      theme: ThemeData(platform: defaultTargetPlatform),
      home: Scaffold(
        // The sliver uses the page's region; boxed HTML creates its own.
        body: sliver ? SelectionArea(child: scrollView) : scrollView,
      ),
    ),
  );
}

RenderParagraph _paragraph(WidgetTester tester, String text) =>
    tester.renderObject<RenderParagraph>(find.text(text, findRichText: true));

Offset _textPosition(RenderParagraph paragraph, int offset) =>
    paragraph.localToGlobal(
      paragraph.getOffsetForCaret(TextPosition(offset: offset), Rect.zero) +
          Offset(1, paragraph.preferredLineHeight / 2),
    );

void main() {
  for (final sliver in [false, true]) {
    testWidgets(
      '${sliver ? 'Sliver' : 'Boxed'} HTML supports partial copy, quotes and tables',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        String? copied;
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (call) async {
            if (call.method == 'Clipboard.setData') {
              copied = (call.arguments as Map)['text'] as String;
            }
            if (call.method == 'Clipboard.hasStrings') {
              return {'value': copied?.isNotEmpty ?? false};
            }
            return null;
          },
        );
        addTearDown(
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            SystemChannels.platform,
            null,
          ),
        );
        await tester.pumpWidget(_host(sliver: sliver));
        await tester.pumpAndSettle();
        // Nested quotes share the region so they don't trap the selection.
        expect(find.byType(SelectionArea), findsOneWidget);
        final paragraph = _paragraph(tester, 'Before selected words after.');
        await tester.longPressAt(_textPosition(paragraph, 10));
        await tester.pumpAndSettle();
        expect(
          paragraph.selections.single,
          const TextSelection(baseOffset: 7, extentOffset: 15),
        );
        expect(find.text('Copy'), findsOneWidget);

        // Extend the selection over an inline formatting boundary, then use
        // the real platform-adaptive toolbar rather than copying the post.
        Offset handlePosition(int offset) {
          final position = TextPosition(offset: offset);
          return paragraph.localToGlobal(
            paragraph.getOffsetForCaret(position, Rect.zero) +
                Offset(2, paragraph.getFullHeightForCaret(position) + 2),
          );
        }

        final start = handlePosition(15);
        await tester.timedDragFrom(
          start,
          handlePosition(21) - start,
          const Duration(milliseconds: 500),
        );
        await tester.pumpAndSettle();
        expect(
          paragraph.selections.single,
          const TextSelection(baseOffset: 7, extentOffset: 21),
        );
        await tester.tap(find.text('Copy'));
        await tester.pumpAndSettle();
        expect(copied, 'selected words');

        for (final target in [
          ('Quoted passage here.', 9, 'passage'),
          ('Table content here.', 8, 'content'),
        ]) {
          // Clear the previous selection, including persistent iOS handles.
          await tester.tapAt(const Offset(20, 60));
          await tester.pumpAndSettle();
          await tester.longPressAt(
            _textPosition(_paragraph(tester, target.$1), target.$2),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.text('Copy'));
          await tester.pumpAndSettle();
          expect(copied, target.$3);
        }
        expect(tester.takeException(), isNull);
      },
      variant: TargetPlatformVariant({
        TargetPlatform.android,
        TargetPlatform.iOS,
      }),
    );
  }
}
