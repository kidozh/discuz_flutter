import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Cupertino pane back uses the same control as a pushed page', (
    tester,
  ) async {
    var explicitBack = false;
    await tester.pumpWidget(
      PlatformProvider(
        style: AppVisualStyle.cupertino,
        builder: (_) => PlatformApp(
          home: PlatformScaffold(
            iosContentPadding: true,
            appBar: const PlatformAppBar(title: Text('Forum')),
            body: Builder(
              builder: (context) => CupertinoButton(
                child: const Text('Open thread'),
                onPressed: () => Navigator.of(context).push(
                  CupertinoPageRoute<void>(
                    title: 'Thread',
                    builder: (_) => PlatformScaffold(
                      appBar: PlatformAppBar(
                        title: const Text('Thread'),
                        leading: explicitBack
                            ? const PlatformBackButton(
                                previousPageTitle: 'Forum',
                              )
                            : null,
                        cupertino: (_, _) => CupertinoNavigationBarData(
                          previousPageTitle: 'Forum',
                        ),
                      ),
                      body: const Text('Thread content'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    Rect? automaticBounds;
    for (final explicit in [false, true]) {
      explicitBack = explicit;
      await tester.tap(find.text('Open thread'));
      await tester.pumpAndSettle();
      final back = find.byType(CupertinoNavigationBarBackButton);
      expect(back, findsOneWidget);
      final bounds = tester.getRect(back);
      automaticBounds ??= bounds;
      expect(bounds, automaticBounds);
      expect(find.text('Forum'), findsOneWidget);
      await tester.tap(back);
      await tester.pumpAndSettle();
      expect(find.text('Open thread'), findsOneWidget);
      expect(find.text('Thread content'), findsNothing);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('Cupertino back closes its pane through the supplied callback', (
    tester,
  ) async {
    var closed = false;
    await tester.pumpWidget(
      PlatformProvider(
        style: AppVisualStyle.cupertino,
        builder: (_) => PlatformApp(
          home: PlatformScaffold(
            appBar: PlatformAppBar(
              automaticallyImplyLeading: false,
              leading: PlatformBackButton(
                previousPageTitle: 'Forum',
                onPressed: () => closed = true,
              ),
              title: const Text('Thread'),
            ),
            body: const Text('Pane content'),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(CupertinoNavigationBarBackButton));
    await tester.pumpAndSettle();
    expect(closed, isTrue);
    expect(find.text('Pane content'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
