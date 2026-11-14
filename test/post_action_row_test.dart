import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:discuz_flutter/widget/post_action_row.dart';

void main() {
  for (final width in [150.0, 240.0, 320.0, 430.0, 800.0]) {
    testWidgets('timestamp and actions share a row at width $width', (
      tester,
    ) async {
      List<Widget> hidden = [];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: width,
              child: PostActionRow(
                metadata: const Text(
                  '2026-11-11 08:30 · 已编辑',
                  key: Key('timestamp'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                overflowBuilder: (items) {
                  hidden = items;
                  return const SizedBox(
                    key: Key('more'),
                    width: 48,
                    height: 48,
                  );
                },
                actions: [
                  for (var i = 0; i < 4; i++)
                    SizedBox(key: Key('action$i'), width: 48, height: 48),
                ],
              ),
            ),
          ),
        ),
      );
      final timestamp = tester.getRect(find.byKey(const Key('timestamp')));
      final more = find.byKey(Key(hidden.isEmpty ? 'action3' : 'more'));
      expect(tester.getRect(more).center.dy, timestamp.center.dy);
      expect(tester.getRect(more).left, greaterThan(timestamp.right));
      expect(tester.getRect(more).right, lessThanOrEqualTo(width));
      final visible = List.generate(
        3,
        (i) => find.byKey(Key('action$i')).evaluate().length,
      ).fold(0, (a, b) => a + b);
      expect(visible + hidden.length, 3);
      if (width < 312) expect(hidden, isNotEmpty);
      expect(tester.takeException(), isNull);
    });
  }
}
