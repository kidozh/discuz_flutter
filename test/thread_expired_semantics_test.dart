import 'package:easy_refresh/easy_refresh.dart';
import 'package:discuz_flutter/utility/EasyRefreshUtils.dart';
import 'package:discuz_flutter/entity/DiscuzError.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'expired session card remains accessible while scrolling and refreshing',
    (tester) async {
      final semantics = tester.ensureSemantics();
      final expired = ValueNotifier(false);
      await tester.pumpWidget(
        PlatformProvider(
          style: AppVisualStyle.cupertino,
          builder: (_) => PlatformTheme(
            materialLightTheme: ThemeData.light(),
            materialDarkTheme: ThemeData.dark(),
            cupertinoLightTheme: const CupertinoThemeData(),
            cupertinoDarkTheme: const CupertinoThemeData(),
            builder: (_) => PlatformApp(
              locale: const Locale('zh', 'CN'),
              localizationsDelegates: const [
                S.delegate,
                ...GlobalMaterialLocalizations.delegates,
              ],
              supportedLocales: S.delegate.supportedLocales,
              home: PlatformScaffold(
                body: ValueListenableBuilder<bool>(
                  valueListenable: expired,
                  builder: (context, value, _) => EasyRefresh(
                    header: EasyRefreshUtils.i18nClassicHeader(
                      context,
                      position: IndicatorPosition.locator,
                      safeArea: false,
                    ),
                    footer: EasyRefreshUtils.i18nClassicFooter(context),
                    refreshOnStart: true,
                    onRefresh: () async {
                      await Future<void>.delayed(
                        const Duration(milliseconds: 100),
                      );
                      expired.value = true;
                      return IndicatorResult.success;
                    },
                    onLoad: () async => IndicatorResult.noMore,
                    child: CustomScrollView(
                      slivers: [
                        const HeaderLocator.sliver(),
                        if (value)
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, _) => ErrorCard(
                                DiscuzError(
                                  'expired',
                                  S.of(context).userExpiredSubtitle,
                                  errorType: ErrorType.userExpired,
                                ),
                                () {},
                                largeSize: false,
                                errorType: ErrorType.userExpired,
                              ),
                              childCount: 1,
                            ),
                          ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, index) => SizedBox(
                              height: 120,
                              child: Text('Post $index'),
                            ),
                            childCount: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      for (var i = 0; i < 4; i++) {
        expired.value = !expired.value;
        await tester.pump();
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
        await tester.pumpAndSettle();
        await tester.drag(find.byType(CustomScrollView), const Offset(0, 500));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox.shrink());
      semantics.dispose();
      expired.dispose();
    },
  );
}
