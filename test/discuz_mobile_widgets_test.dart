import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:discuz_flutter/JsonResult/CheckPostResult.dart';
import 'package:discuz_flutter/entity/SpecialThread.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/widget/PostPermissionGate.dart';
import 'package:discuz_flutter/widget/SpecialThreadCard.dart';

Widget host(Widget child) => MaterialApp(
  localizationsDelegates: const [S.delegate],
  home: Scaffold(body: child),
);
void main() {
  testWidgets('denied reply silently hides editor and permission notice', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        PostPermissionGate(
          reply: true,
          load: () async => CheckPostResult.fromJson({
            'Variables': {
              'allowperm': {'allowreply': '0'},
            },
          }),
          child: const Text('editor'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('editor'), findsNothing);
    expect(find.text(S.current.replyPermissionDenied), findsNothing);
    expect(find.text(S.current.refresh), findsNothing);
    expect(tester.getSize(find.byType(PostPermissionGate)), Size.zero);
  });
  testWidgets(
    'missing permission and network errors do not grant editing access',
    (tester) async {
      await tester.pumpWidget(
        host(
          PostPermissionGate(
            reply: false,
            load: () async => CheckPostResult(),
            child: const Text('editor'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('editor'), findsNothing);
      expect(find.text(S.current.postPermissionUnknown), findsOneWidget);
    },
  );
  testWidgets(
    'special cards wrap long values and open only explicit callbacks',
    (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      int? selected;
      var webOpened = false;
      await tester.pumpWidget(
        host(
          SingleChildScrollView(
            child: SpecialThreadCard(
              reward: RewardInfo('10 credits', 99),
              activity: ActivityInfo.parse({
                'place': 'A very long meeting location that wraps across lines',
                'allapplynum': '3',
                'status': 'wait',
                'closed': '1',
              }),
              threadSort: ThreadSortInfo('Sale', [
                ThreadSortOption('Title', '<b>Example &amp; text</b>', ''),
              ]),
              onSelectPost: (pid) => selected = pid,
              onOpenWebsite: () => webOpened = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.textContaining('Example & text'), findsOneWidget);
      await tester.tap(find.text(S.current.specialBestAnswer));
      expect(selected, 99);
      await tester.ensureVisible(find.text(S.current.specialOpenWebsite).first);
      await tester.tap(find.text(S.current.specialOpenWebsite).first);
      expect(webOpened, true);
      expect(find.text(S.current.activityWaiting), findsOneWidget);
      expect(find.text(S.current.activityClosed), findsOneWidget);
    },
  );
  testWidgets('reward pill wraps long amounts and opens the best answer', (
    tester,
  ) async {
    int? selected;
    await tester.pumpWidget(
      host(
        Center(
          child: SizedBox(
            width: 230,
            child: ThreadRewardPill(
              reward: RewardInfo(
                '<b>100</b> forum reward credits with a long unit',
                99,
              ),
              onSelectPost: (pid) => selected = pid,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.textContaining('100 forum reward credits'), findsOneWidget);
    await tester.tap(find.text(S.current.specialBestAnswer));
    expect(selected, 99);
  });
}
