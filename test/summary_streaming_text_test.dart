import 'package:discuz_flutter/widget/summary_streaming_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(String text, {bool loading = true, double width = 180, Key? key}) =>
    MaterialApp(
      home: SingleChildScrollView(
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: width,
            child: SummaryStreamingText(key: key, text: text, loading: loading),
          ),
        ),
      ),
    );

String visibleText(WidgetTester tester) => tester
    .widget<Text>(
      find.descendant(
        of: find.byType(SummaryStreamingText),
        matching: find.byType(Text),
      ),
    )
    .textSpan!
    .toPlainText();

void main() {
  testWidgets(
    'initial output grows and revisions overwrite without collapsing',
    (tester) async {
      const original = '先前总结保留了整篇帖子的主要内容和细节，正在结合后续段落更新。';
      for (final text in ['先', '先前总结', original]) {
        await tester.pumpWidget(host(text));
        expect(visibleText(tester), text);
      }
      final previousHeight = tester
          .getSize(find.byType(SummaryStreamingText))
          .height;
      for (final replacement in ['新', '新的归纳', '新的归纳已覆盖更多细节']) {
        await tester.pumpWidget(host(replacement));
        expect(
          visibleText(tester),
          replacement +
              original.characters.skip(replacement.characters.length).join(),
        );
        expect(
          tester.getSize(find.byType(SummaryStreamingText)).height,
          greaterThanOrEqualTo(previousHeight),
        );
      }
      // Empty snapshots must not clear the existing draft either.
      final lastDraft = visibleText(tester);
      await tester.pumpWidget(host(''));
      expect(visibleText(tester), lastDraft);
      await tester.pumpWidget(host('最终结论。', loading: false));
      expect(visibleText(tester), '最终结论。');
      expect(
        tester.getSize(find.byType(SummaryStreamingText)).height,
        lessThan(previousHeight),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'replacement preserves emoji and combining-character boundaries',
    (tester) async {
      const original = '👨‍👩‍👧‍👦e\u0301🇨🇳一段总结';
      await tester.pumpWidget(host(original));
      await tester.pumpWidget(host('新'));
      expect(visibleText(tester), '新e\u0301🇨🇳一段总结');
      await tester.pumpWidget(host('新🧑🏽‍💻'));
      expect(visibleText(tester), '新🧑🏽‍💻🇨🇳一段总结');
      await tester.pumpWidget(host('新🧑🏽‍💻结论', loading: false));
      expect(visibleText(tester), '新🧑🏽‍💻结论');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'reserved height reflows on width changes and resets for a new post',
    (tester) async {
      final original = List.filled(15, '内容丰富的总结。').join();
      await tester.pumpWidget(host(original));
      final narrowHeight = tester
          .getSize(find.byType(SummaryStreamingText))
          .height;
      await tester.pumpWidget(host('更新', width: 500));
      expect(
        tester.getSize(find.byType(SummaryStreamingText)).height,
        lessThan(narrowHeight),
      );
      await tester.pumpWidget(host('另一篇', key: const ValueKey('another-post')));
      expect(visibleText(tester), '另一篇');
      expect(
        tester.getSize(find.byType(SummaryStreamingText)).height,
        lessThan(narrowHeight),
      );
      expect(tester.takeException(), isNull);
    },
  );
}
