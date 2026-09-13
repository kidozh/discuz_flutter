import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/widget/post_status_badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpBadges(
    WidgetTester tester, {
    required double width,
    required double scale,
    required bool dark,
  }) async {
    await tester.pumpWidget(
      PlatformProvider(
        style: dark ? AppVisualStyle.cupertino : AppVisualStyle.material,
        builder: (_) => MaterialApp(
          theme: dark ? ThemeData.dark() : ThemeData.light(),
          locale: const Locale('zh', 'CN'),
          supportedLocales: S.delegate.supportedLocales,
          localizationsDelegates: [
            S.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          home: Scaffold(
            body: Builder(
              builder: (context) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(scale)),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: width,
                    child: const PostStatusBadges(
                      blocked: true,
                      warned: true,
                      revised: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('status badges share a row when space permits', (tester) async {
    await pumpBadges(tester, width: 600, scale: 1, dark: false);
    final blocked = tester.getTopLeft(find.text('已屏蔽'));
    final warned = tester.getTopLeft(find.text('已警告'));
    final revised = tester.getTopLeft(find.text('审核后编辑'));
    expect(blocked.dy, warned.dy);
    expect(warned.dy, revised.dy);
    expect(warned.dx, greaterThan(blocked.dx));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'large text wraps badges without overflow and retains explanations',
    (tester) async {
      await pumpBadges(tester, width: 160, scale: 2, dark: true);
      expect(
        tester.getTopLeft(find.text('已警告')).dy,
        greaterThan(tester.getTopLeft(find.text('已屏蔽')).dy),
      );
      expect(find.text('审核后编辑'), findsOneWidget);
      expect(find.byTooltip('帖子审核后再编辑，以防重复加分。'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
