import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/widget/ThreadReplyTargetBanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('creates a safe single-line preview from reply HTML', () {
    expect(
      ThreadReplyTargetBanner.plainTextPreview(
        '<p>Hello <strong>world</strong><img src="x"></p>'
            '<script>ignored()</script>',
        '[图片]',
      ),
      'Hello world[图片]',
    );
  });

  testWidgets('reply target uses the adaptive glass card and can be dismissed',
      (tester) async {
    var dismissed = false;
    await tester.pumpWidget(
      PlatformProvider(
        initialPlatform: TargetPlatform.iOS,
        builder: (context) => MaterialApp(
          home: Scaffold(
            body: ThreadReplyTargetBanner(
              author: 'Alice',
              messageHtml: '<p>Quoted message</p>',
              picturePlaceholder: '[Image]',
              onDismiss: () => dismissed = true,
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('thread-reply-target-banner')),
      findsOneWidget,
    );
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Quoted message'), findsOneWidget);

    await tester.tap(find.byType(PlatformIconButton));
    expect(dismissed, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('embedded reply target reuses the composer glass surface',
      (tester) async {
    await tester.pumpWidget(
      PlatformProvider(
        initialPlatform: TargetPlatform.iOS,
        builder: (context) => MaterialApp(
          home: Scaffold(
            body: PlatformLiquidGlassCard(
              child: ThreadReplyTargetBanner(
                author: 'Bob',
                messageHtml: 'Inside composer',
                picturePlaceholder: '[Image]',
                embeddedInComposer: true,
                onDismiss: () {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(PlatformLiquidGlassCard), findsOneWidget);
    expect(
      find.byKey(const ValueKey('thread-reply-target-banner')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
