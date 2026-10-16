import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/forum_display_preferences.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
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
        locale: const Locale('en'),
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

CompactThreadListTile tile({
  String message = '',
  bool stats = true,
  Widget? thumbnail,
}) => CompactThreadListTile(
  leading: const SizedBox(width: 18, height: 18),
  title: const Text('A thread title', key: Key('subject'), maxLines: 2),
  metadata: const Text(
    'Author · 25 min ago',
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  ),
  statistics: stats
      ? const ThreadListStatistics(views: '208', replies: 3)
      : null,
  message: message,
  thumbnail: thumbnail,
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
  for (final style in [
    AppVisualStyle.material,
    AppVisualStyle.cupertino,
    AppVisualStyle.liquidGlass,
  ]) {
    testWidgets(
      'navigation preserves privacy without replacing the TabBar: $style',
      (tester) async {
        await tester.pumpWidget(
          host(
            ForumHomeTitle(
              discuz: discuz,
              user: user,
              preferences: const ForumDisplayPreferences(showForumName: false),
            ),
            style,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text(S.current.appName), findsOneWidget);
        expect(find.textContaining('Private'), findsNothing);
        expect(find.textContaining('12345'), findsNothing);
        expect(find.byIcon(Icons.expand_more), findsNothing);
        expect(find.byType(GestureDetector), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
    for (final scale in [1.0, 2.0]) {
      for (final message in [
        '',
        'A short summary that belongs under the title and can wrap across two lines.',
      ]) {
        testWidgets(
          'compact thread layout: $style scale=$scale message=${message.isNotEmpty}',
          (tester) async {
            await tester.pumpWidget(
              host(tile(message: message), style, scale: scale),
            );
            await tester.pumpAndSettle();
            final title = tester.getTopLeft(find.byKey(const Key('subject')));
            final metadata = tester.getTopLeft(
              find.text('Author · 25 min ago'),
            );
            expect(title.dy, greaterThan(metadata.dy));
            expect(title.dx, lessThan(metadata.dx));
            expect(
              tester.getBottomRight(find.byType(ThreadListStatistics)).dx,
              tester.getBottomRight(find.byType(CompactThreadListTile)).dx - 12,
            );
            expect(
              find.byKey(const ValueKey('thread-message-preview')),
              message.isEmpty ? findsNothing : findsOneWidget,
            );
            if (message.isNotEmpty) {
              final summary = tester.widget<Text>(
                find.byKey(const ValueKey('thread-message-preview')),
              );
              expect(summary.maxLines, 2);
              expect(
                tester
                    .getTopLeft(
                      find.byKey(const ValueKey('thread-message-preview')),
                    )
                    .dy,
                greaterThan(title.dy),
              );
            }
            if (scale == 1 && message.isEmpty) {
              expect(
                tester.getSize(find.byType(CompactThreadListTile)).height,
                lessThan(70),
              );
            }
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }

  testWidgets(
    'preview thumbnail is larger for summaries and compact for title-only rows',
    (tester) async {
      for (final message in ['', 'Article summary']) {
        await tester.pumpWidget(
          host(
            tile(
              message: message,
              thumbnail: const ColoredBox(
                key: Key('thumbnail'),
                color: Colors.blue,
              ),
            ),
            AppVisualStyle.material,
          ),
        );
        await tester.pumpAndSettle();
        expect(
          tester.getSize(find.byKey(const Key('thumbnail'))),
          message.isEmpty ? const Size(56, 48) : const Size(76, 72),
        );
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets('hiding statistics does not leave an empty footer', (
    tester,
  ) async {
    await tester.pumpWidget(host(tile(), AppVisualStyle.material));
    await tester.pumpAndSettle();
    final original = tester.getSize(find.byType(CompactThreadListTile));
    await tester.pumpWidget(host(tile(stats: false), AppVisualStyle.material));
    await tester.pumpAndSettle();
    expect(find.byType(ThreadListStatistics), findsNothing);
    expect(
      tester.getSize(find.byType(CompactThreadListTile)).height,
      original.height,
    );
  });

  testWidgets('compact statistics keep complete counts in accessibility', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        const ThreadListStatistics(views: '1250000', replies: 42000),
        AppVisualStyle.material,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('M'), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        '${S.current.threadView('1250000')} · ${S.current.threadReply(42000)}',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets(
    'private fields appear only when enabled and stay out of semantics when hidden',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          ForumHomeTitle(
            discuz: discuz,
            user: user,
            preferences: const ForumDisplayPreferences(showAccountInfo: true),
          ),
          AppVisualStyle.material,
          scale: 2,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('PrivateAccount (12345)'), findsOneWidget);
      await tester.pumpWidget(
        host(
          ForumHomeTitle(
            discuz: discuz,
            user: user,
            preferences: const ForumDisplayPreferences(showForumName: false),
          ),
          AppVisualStyle.material,
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.bySemanticsLabel(RegExp('PrivateAccount|12345|Private forum')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
      semantics.dispose();
    },
  );
}
