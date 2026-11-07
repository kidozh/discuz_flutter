import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/forum_display_preferences.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/DashboardPreferences.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/widget/dashboard_tabs.dart';
import 'package:discuz_flutter/widget/forum_home_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Discuz forum(String url) => Discuz(
  url,
  'X3.4',
  'utf-8',
  4,
  '',
  '',
  false,
  '',
  '',
  'Private forum',
  '0',
  '',
  '',
);

void main() {
  setUp(() {
    DashboardPreferences.order.value = List.of(DashboardPreferences.defaults);
    DashboardPreferences.selectedSection.value = null;
  });

  for (final style in [
    AppVisualStyle.material,
    AppVisualStyle.cupertino,
    AppVisualStyle.liquidGlass,
  ]) {
    testWidgets(
      'merged home categories stay in sync and respect forum scope: $style',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(390, 844);
        addTearDown(tester.view.reset);
        var display = const ForumDisplayPreferences(showForumName: false);
        Discuz? discuz = forum('https://keylol.com');
        var dashboard = true;
        late StateSetter update;
        await tester.pumpWidget(
          PlatformProvider(
            style: style,
            builder: (_) => MaterialApp(
              locale: const Locale('en'),
              localizationsDelegates: const [
                S.delegate,
                ...GlobalMaterialLocalizations.delegates,
              ],
              supportedLocales: S.delegate.supportedLocales,
              home: StatefulBuilder(
                builder: (context, setState) {
                  update = setState;
                  final strings = S.of(context);
                  String label(String id) => switch (id) {
                    'new' => strings.newThread,
                    'hot' => strings.hotThread,
                    _ => strings.keylolPortal,
                  };
                  return PlatformScaffold(
                    appBar: PlatformAppBar(
                      liquidGlassUseNativeToolbar:
                          !(discuz != null &&
                              dashboard &&
                              display.mergeHomeNavigation),
                      automaticallyImplyLeading: false,
                      title: ForumHomeTitle(
                        discuz: discuz,
                        user: null,
                        preferences: display,
                        dashboard: dashboard,
                      ),
                    ),
                    body: ValueListenableBuilder<List<String>>(
                      valueListenable: DashboardPreferences.order,
                      builder: (context, order, _) =>
                          ValueListenableBuilder<String?>(
                            valueListenable:
                                DashboardPreferences.selectedSection,
                            builder: (context, _, _) {
                              final ids = DashboardPreferences.visible(
                                order,
                                keylol: DashboardPreferences.isKeylol(
                                  discuz?.baseURL ?? '',
                                ),
                              );
                              return DashboardTabs(
                                ids: ids,
                                labels: ids.map(label).toList(),
                                selectedId: DashboardPreferences.activeSection(
                                  ids,
                                ),
                                onSelected: (id) =>
                                    DashboardPreferences.selectedSection.value =
                                        id,
                                sectionBuilder: (id) =>
                                    Center(child: Text('body-$id')),
                                showNavigation: !display.mergeHomeNavigation,
                              );
                            },
                          ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final strings = S.current;
        expect(find.byIcon(Icons.expand_more), findsNothing);
        expect(find.text(strings.appName), findsOneWidget);
        if (style == AppVisualStyle.material) {
          await tester.tap(find.byIcon(Icons.whatshot));
        } else {
          await tester.tap(find.text(strings.hotThread));
        }
        await tester.pumpAndSettle();
        expect(find.text('body-hot'), findsOneWidget);

        update(() => display = display.copyWith(mergeHomeNavigation: true));
        await tester.pumpAndSettle();
        expect(find.byType(TabBar), findsNothing);
        expect(find.byType(PlatformSegmentedControl), findsNothing);
        expect(
          find.text('${strings.appName} · ${strings.hotThread}'),
          findsOneWidget,
        );
        expect(find.text('body-hot'), findsOneWidget);
        expect(find.textContaining('Private'), findsNothing);
        await tester.tap(find.byIcon(Icons.expand_more));
        await tester.pumpAndSettle();
        await tester.tap(find.text(strings.keylolPortal));
        await tester.pumpAndSettle();
        expect(DashboardPreferences.selectedSection.value, 'keylol');
        expect(find.text('body-keylol'), findsOneWidget);
        expect(
          find.text('${strings.appName} · ${strings.keylolPortal}'),
          findsOneWidget,
        );
        if (style == AppVisualStyle.material) {
          await tester.drag(find.byType(TabBarView), const Offset(260, 0));
          await tester.pumpAndSettle();
          expect(DashboardPreferences.selectedSection.value, 'hot');
          expect(
            find.text('${strings.appName} · ${strings.hotThread}'),
            findsOneWidget,
          );
        }

        DashboardPreferences.order.value = ['hot', 'new', 'keylol'];
        DashboardPreferences.selectedSection.value = 'keylol';
        update(() => discuz = forum('https://example.com'));
        await tester.pumpAndSettle();
        expect(find.text('body-hot'), findsOneWidget);
        expect(
          find.text('${strings.appName} · ${strings.hotThread}'),
          findsOneWidget,
        );
        await tester.tap(find.byIcon(Icons.expand_more));
        await tester.pumpAndSettle();
        expect(find.text(strings.keylolPortal), findsNothing);
        expect(
          tester.getTopLeft(find.text(strings.hotThread)).dy,
          lessThan(tester.getTopLeft(find.text(strings.newThread)).dy),
        );
        await tester.tap(find.text(strings.newThread));
        await tester.pumpAndSettle();
        expect(find.text('body-new'), findsOneWidget);

        update(() => display = display.copyWith(mergeHomeNavigation: false));
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.expand_more), findsNothing);
        expect(find.text('body-new'), findsOneWidget);
        expect(
          style == AppVisualStyle.material
              ? find.byType(TabBar)
              : find.byType(PlatformSegmentedControl),
          findsOneWidget,
        );
        update(() {
          display = display.copyWith(mergeHomeNavigation: true);
          dashboard = false;
        });
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.expand_more), findsNothing);
        update(() {
          dashboard = true;
          discuz = null;
        });
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.expand_more), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
