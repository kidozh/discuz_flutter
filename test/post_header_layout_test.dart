import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/widget/post_header_layout.dart';

void main() {
  for (final width in [320.0, 430.0, 800.0]) {
    testWidgets('author and four actions fit at $width', (tester) async {
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
                actions: PlatformLiquidGlassToolbarGroup(
                  wrap: true,
                  children: [
                    for (var i = 0; i < 4; i++)
                      SizedBox(
                        key: Key('action$i'),
                        width: 48,
                        height: 48,
                        child: Text('$i'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      final author = tester.getRect(find.byKey(const Key('author')));
      final action = tester.getRect(find.byKey(const Key('action0')));
      if (width >= 430) {
        expect(action.center.dy, author.center.dy);
        expect(action.left, greaterThan(author.right));
      } else {
        expect(action.top, greaterThanOrEqualTo(author.bottom));
      }
      for (var i = 0; i < 4; i++) {
        expect(
          tester.getRect(find.byKey(Key('action$i'))).right,
          lessThanOrEqualTo(width),
        );
      }
      expect(tester.takeException(), isNull);
    });
  }
}
