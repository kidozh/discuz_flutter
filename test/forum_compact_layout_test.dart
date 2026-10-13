import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/forum_display_preferences.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/DashboardPreferences.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/widget/compact_thread_list_tile.dart';
import 'package:discuz_flutter/widget/forum_home_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(Widget child, AppVisualStyle style, {double scale = 1}) =>
    PlatformProvider(
      style: style,
      builder: (_) => MaterialApp(
        localizationsDelegates: const [
          S.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: Scaffold(
          body: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(width: 280, child: child),
            ),
          ),
        ),
      ),
    );

void main() {
  final discuz = Discuz(
    'https://keylol.com',
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
  final user = User('', '', 'PrivateAccount', '', 0, 12345, 0, discuz);
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
      'compact header hides private fields and switches categories: $style',
      (tester) async {
        await tester.pumpWidget(
          host(
            ForumHomeTitle(
              discuz: discuz,
              user: user,
              preferences: const ForumDisplayPreferences(showForumName: false),
              dashboard: true,
            ),
            style,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.textContaining('Private'), findsNothing);
        expect(find.textContaining('12345'), findsNothing);
        expect(find.text(S.current.newThread), findsOneWidget);
        await tester.tap(find.text(S.current.newThread));
        await tester.pumpAndSettle();
        await tester.tap(find.text(S.current.hotThread));
        await tester.pumpAndSettle();
        expect(DashboardPreferences.selectedSection.value, 'hot');
        expect(find.text(S.current.hotThread), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'compact selector fits inside a narrow platform app bar: $style',
      (tester) async {
        tester.view.physicalSize = const Size(320, 700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          PlatformProvider(
            style: style,
            builder: (_) => MaterialApp(
              localizationsDelegates: const [
                S.delegate,
                ...GlobalMaterialLocalizations.delegates,
              ],
              supportedLocales: S.delegate.supportedLocales,
              home: PlatformScaffold(
                appBar: PlatformAppBar(
                  automaticallyImplyLeading: false,
                  leading: const Icon(Icons.menu),
                  trailingActions: [
                    PlatformIconButton(
                      icon: const Icon(Icons.swap_horiz),
                      onPressed: () {},
                    ),
                  ],
                  title: ForumHomeTitle(
                    discuz: discuz,
                    user: user,
                    preferences: const ForumDisplayPreferences(),
                    dashboard: true,
                  ),
                ),
                body: const SizedBox.shrink(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.textContaining(S.current.newThread), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    for (final scale in [1.0, 2.0]) {
      testWidgets(
        'metadata and statistics share a row without overflow: $style scale=$scale',
        (tester) async {
          await tester.pumpWidget(
            host(
              CompactThreadListTile(
                leading: const SizedBox(width: 32, height: 32),
                title: const Text(
                  'A long thread title that wraps across several lines',
                  maxLines: 4,
                ),
                metadata: const Text(
                  'Author · 25 min ago',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                statistics: '208 views · 3 replies',
              ),
              style,
              scale: scale,
            ),
          );
          await tester.pumpAndSettle();
          expect(
            (tester.getTopLeft(find.text('Author · 25 min ago')).dy -
                    tester.getTopLeft(find.text('208 views · 3 replies')).dy)
                .abs(),
            lessThan(6),
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'private fields appear only when enabled; hidden fields stay out of semantics',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          ForumHomeTitle(
            discuz: discuz,
            user: user,
            preferences: const ForumDisplayPreferences(showAccountInfo: true),
            dashboard: false,
          ),
          AppVisualStyle.material,
          scale: 2,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('PrivateAccount (12345)'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(
        host(
          ForumHomeTitle(
            discuz: discuz,
            user: user,
            preferences: const ForumDisplayPreferences(showForumName: false),
            dashboard: true,
          ),
          AppVisualStyle.material,
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.bySemanticsLabel(RegExp('PrivateAccount|12345|Private forum')),
        findsNothing,
      );
      semantics.dispose();
    },
  );

  testWidgets('switching forums falls back from a Keylol-only category', (
    tester,
  ) async {
    DashboardPreferences.selectedSection.value = 'keylol';
    discuz.baseURL = 'https://forum.test';
    addTearDown(() => discuz.baseURL = 'https://keylol.com');
    await tester.pumpWidget(
      host(
        ForumHomeTitle(
          discuz: discuz,
          user: user,
          preferences: const ForumDisplayPreferences(showForumName: false),
          dashboard: true,
        ),
        AppVisualStyle.material,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(S.current.newThread), findsOneWidget);
  });
}
