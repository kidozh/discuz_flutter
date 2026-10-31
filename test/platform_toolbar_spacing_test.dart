import 'package:adaptive_platform_ui/src/toolbar/hosted_top_toolbar.dart';
import 'package:adaptive_platform_ui/src/widgets/ios26/ios26_scaffold.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final style in [AppVisualStyle.cupertino, AppVisualStyle.material]) {
    for (final topInset in [0.0, 62.0]) {
      testWidgets('$style toolbar gives buttons room with inset $topInset', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(360, 780);
        tester.view.padding = FakeViewPadding(top: topInset);
        tester.view.viewPadding = FakeViewPadding(top: topInset);
        addTearDown(tester.view.reset);
        var taps = 0;
        PlatformIconButton button(String name, IconData icon) =>
            PlatformIconButton(
              widgetKey: ValueKey(name),
              padding: EdgeInsets.zero,
              icon: Icon(icon),
              onPressed: () => taps++,
            );
        await tester.pumpWidget(
          PlatformProvider(
            style: style,
            builder: (_) => PlatformApp(
              home: PlatformScaffold(
                iosContentPadding: true,
                appBar: PlatformAppBar(
                  backgroundColor: Colors.white,
                  title: const Text('Forum'),
                  leading: button('menu', CupertinoIcons.line_horizontal_3),
                  trailingActions: [
                    button('notifications', CupertinoIcons.bell),
                    button('switch', Icons.swap_horiz),
                  ],
                ),
                body: const SizedBox.expand(key: ValueKey('content')),
              ),
            ),
          ),
        );

        final cupertino = style == AppVisualStyle.cupertino;
        final bar = tester.getRect(
          find.byType(cupertino ? CupertinoNavigationBar : AppBar),
        );
        expect(bar.height, topInset + (cupertino ? 60 : 64));
        for (final name in ['menu', 'notifications', 'switch']) {
          final control = tester.getRect(find.byKey(ValueKey(name)));
          expect(control.top - topInset, greaterThanOrEqualTo(8));
          expect(bar.bottom - control.bottom, greaterThanOrEqualTo(8));
          expect(control.height, greaterThanOrEqualTo(44));
          // The bottom edge of the control remains part of its hit target.
          await tester.tapAt(Offset(control.center.dx, control.bottom - 1));
          await tester.pump();
        }
        expect(taps, 3);
        expect(
          tester.getTopLeft(find.byKey(const ValueKey('content'))).dy,
          bar.bottom,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('Cupertino keeps tab content below the padded toolbar', (
    tester,
  ) async {
    await tester.pumpWidget(
      PlatformProvider(
        style: AppVisualStyle.cupertino,
        builder: (_) => const PlatformApp(
          home: PlatformScaffold(
            iosContentPadding: true,
            appBar: PlatformAppBar(
              title: Text('Forum'),
              backgroundColor: Colors.white,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(36),
                child: SizedBox(height: 36, key: ValueKey('tabs')),
              ),
            ),
            body: SizedBox.expand(key: ValueKey('content')),
          ),
        ),
      ),
    );
    expect(tester.getTopLeft(find.byKey(const ValueKey('tabs'))).dy, 60);
    expect(tester.getTopLeft(find.byKey(const ValueKey('content'))).dy, 96);
    expect(tester.takeException(), isNull);
  });

  test('Liquid Glass host and page reserve the same 60-point toolbar', () {
    expect(kHostedToolbarHeight, 60);
    expect(kToolbarContentHeight, kHostedToolbarHeight);
  });
}
