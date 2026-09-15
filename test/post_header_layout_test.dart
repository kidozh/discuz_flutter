import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/widget/post_header_layout.dart';

void main() {
  for (final width in [240.0, 320.0, 430.0, 800.0]) {
    testWidgets('header stays in one row and preserves overflow at $width', (
      tester,
    ) async {
      List<Widget> hidden = [];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: width,
              child: PostHeaderLayout(
                author: const SizedBox(
                  key: Key('author'),
                  height: 48,
                  child: Text('用户名'),
                ),
                overflowBuilder: (items) {
                  hidden = items;
                  return const SizedBox(
                    key: Key('more'),
                    width: 48,
                    height: 48,
                  );
                },
                actions: PlatformLiquidGlassToolbarGroup(
                  children: [
                    for (var i = 0; i < 4; i++)
                      SizedBox(key: Key('action$i'), width: 48, height: 48),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      final author = tester.getRect(find.byKey(const Key('author')));
      final more = find.byKey(Key(hidden.isEmpty ? 'action3' : 'more'));
      expect(tester.getRect(more).center.dy, author.center.dy);
      expect(tester.getRect(more).right, lessThanOrEqualTo(width));
      final visible = List.generate(
        3,
        (i) => find.byKey(Key('action$i')).evaluate().length,
      ).fold(0, (a, b) => a + b);
      expect(visible + hidden.length, 3);
      if (width < 430) expect(hidden, isNotEmpty);
      expect(tester.takeException(), isNull);
    });
  }
}
