import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/utility/ToastUtils.dart';
import 'package:discuz_flutter/widget/LoadingStateWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(AppVisualStyle style, Widget child, {bool toast = false}) =>
    PlatformProvider(
      style: style,
      builder: (_) => MaterialApp(
        theme: ThemeData.dark(),
        builder: toast ? ToastUtils.easyLoadingBuilder() : null,
        home: Scaffold(body: child),
      ),
    );

void main() {
  for (final style in [
    AppVisualStyle.cupertino,
    AppVisualStyle.liquidGlass,
    AppVisualStyle.material,
  ]) {
    final ios = style != AppVisualStyle.material;
    testWidgets('loading layout follows $style', (tester) async {
      await tester.pumpWidget(
        host(style, const LoadingStateWidget(hintText: 'Topic &amp; replies')),
      );
      expect(find.text('Topic & replies'), findsOneWidget);
      expect(
        find.byType(CupertinoActivityIndicator),
        ios ? findsOneWidget : findsNothing,
      );
      expect(
        find.byType(CircularProgressIndicator),
        ios ? findsNothing : findsOneWidget,
      );
      expect(find.byType(PlatformCard), ios ? findsNothing : findsOneWidget);
      expect(tester.takeException(), isNull);
    });
    testWidgets('determinate progress remains available in $style', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(style, const PlatformCircularProgressIndicator(value: .4)),
      );
      if (ios) {
        final indicator = tester.widget<CupertinoActivityIndicator>(
          find.byType(CupertinoActivityIndicator),
        );
        expect(indicator.progress, .4);
        expect(indicator.animating, false);
      } else {
        expect(
          tester
              .widget<CircularProgressIndicator>(
                find.byType(CircularProgressIndicator),
              )
              .value,
          .4,
        );
      }
    });
    testWidgets(
      'global loading overlay follows $style independently of glass',
      (tester) async {
        await tester.pumpWidget(host(style, const Text('Home'), toast: true));
        EasyLoading.show(status: 'Loading');
        await tester.pump(const Duration(milliseconds: 300));
        expect(
          find.byType(CupertinoActivityIndicator),
          ios ? findsOneWidget : findsNothing,
        );
        expect(
          find.byType(CircularProgressIndicator),
          ios ? findsNothing : findsOneWidget,
        );
        EasyLoading.dismiss();
        await tester.pumpAndSettle();
        await tester.pumpWidget(const SizedBox.shrink());
        expect(tester.takeException(), isNull);
      },
    );
  }
}
