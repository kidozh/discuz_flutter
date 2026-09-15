import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:discuz_flutter/widget/summary_sweep.dart';

void main() {
  testWidgets('sweep stops on completion and respects reduced motion', (
    tester,
  ) async {
    Widget app(bool active, bool reduced) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduced),
        child: SummarySweep(active: active, child: const Text('Summary')),
      ),
    );
    await tester.pumpWidget(app(true, false));
    expect(find.byType(ShaderMask), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpWidget(app(false, false));
    await tester.pumpAndSettle();
    expect(find.byType(ShaderMask), findsNothing);
    await tester.pumpWidget(app(true, true));
    await tester.pumpAndSettle();
    expect(find.byType(ShaderMask), findsNothing);
  });
}
