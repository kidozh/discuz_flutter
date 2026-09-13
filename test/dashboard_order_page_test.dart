import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/page/DashboardOrderPage.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/utility/DashboardPreferences.dart';

void main() {
  for (final keylol in [false, true]) {
    testWidgets('dashboard reorder auto-saves; installed Keylol=$keylol', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      await DashboardPreferences.load();
      await DashboardPreferences.save(['new', 'hot', 'keylol']);
      await tester.pumpWidget(
        PlatformProvider(
          style: AppVisualStyle.cupertino,
          builder: (_) => MaterialApp(
            localizationsDelegates: const [
              S.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            home: DashboardOrderPage(
              loadSites: () async => keylol
                  ? [
                      Discuz(
                        'https://keylol.com',
                        'X3.5',
                        'utf-8',
                        4,
                        '',
                        '',
                        false,
                        '',
                        '',
                        'Keylol',
                        '',
                        '',
                        '',
                      ),
                    ]
                  : [],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(S.current.keylolPortal),
        keylol ? findsOneWidget : findsNothing,
      );
      final list = tester.widget<ReorderableListView>(
        find.byType(ReorderableListView),
      );
      list.onReorder!(1, 0);
      await tester.pumpAndSettle();
      expect(DashboardPreferences.order.value.first, 'hot');
      expect(find.text(S.current.forumConfirm), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
