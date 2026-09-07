import 'package:discuz_flutter/utility/app_motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('routes retain native types and honor reduced motion', () {
    final route = AppMaterialPageRoute<void>(
      builder: (_) => const SizedBox(), reduceMotion: false);
    expect(route, isA<MaterialPageRoute<void>>());
    expect(route.transitionDuration.inMilliseconds, 280);
    expect(route.reverseTransitionDuration.inMilliseconds, 220);
    final reduced = AppMaterialPageRoute<void>(
      builder: (_) => const SizedBox(), reduceMotion: true);
    expect(reduced.transitionDuration, Duration.zero);
    expect(reduced.reverseTransitionDuration, Duration.zero);
    final ios = AppCupertinoPageRoute<void>(
      builder: (_) => const SizedBox(), reduceMotion: true);
    expect(ios.transitionDuration, Duration.zero);
    expect(ios.reverseTransitionDuration, Duration.zero);
    route.dispose();
    reduced.dispose();
    ios.dispose();
  });

  for (final reduced in [false, true]) {
    testWidgets('content switch keeps one subtree, reduced=$reduced', (tester) async {
      Widget host(String value) => MaterialApp(home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduced),
        child: AppContentTransition(child: Text(value, key: ValueKey(value))),
      ));
      await tester.pumpWidget(host('link'));
      await tester.pumpWidget(host('preview'));
      await tester.pump();
      expect(find.text('link'), findsNothing);
      expect(find.text('preview'), findsOneWidget);
      final switcher = tester.widget<AnimatedSwitcher>(find.byType(AnimatedSwitcher));
      expect(switcher.duration.inMilliseconds, reduced ? 0 : 180);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
