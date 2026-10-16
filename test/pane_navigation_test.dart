import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/utility/TwoPaneScaffold.dart';
import 'package:discuz_flutter/utility/TwoPaneUtils.dart';
import 'package:discuz_flutter/utility/pane_navigation.dart';
import 'package:dual_screen/dual_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class DetailPage extends StatefulWidget {
  final String title;
  const DetailPage(this.title, {super.key});
  @override
  State<DetailPage> createState() => DetailPageState();
}

class DetailPageState extends State<DetailPage> {
  final draft = TextEditingController();
  @override
  void dispose() {
    draft.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.title)),
    body: Column(
      children: [
        TextField(controller: draft),
        TextButton(
          onPressed: () => Navigator.of(context).push(
            platformPageRoute<void>(
              context: context,
              builder: (_) => const DetailPage('Profile'),
            ),
          ),
          child: const Text('Open profile'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).push(
            platformPageRoute<void>(
              context: context,
              builder: (_) => const DetailPage('Settings'),
            ),
          ),
          child: const Text('Open settings'),
        ),
      ],
    ),
  );
}

class PaneHost extends StatefulWidget {
  final bool selected;
  const PaneHost({super.key, this.selected = true});
  @override
  State<PaneHost> createState() => PaneHostState();
}

class PaneHostState extends State<PaneHost> {
  late int tid = widget.selected ? 1 : 0;
  final scroll = ScrollController();
  int closes = 0;
  int selectionRevision = 0;
  BuildContext? master;
  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  void select(int value) => setState(() {
    tid = value;
    selectionRevision++;
  });

  @override
  Widget build(BuildContext context) => TwoPaneScaffold(
    type: TwoPaneType.foldable,
    detailIdentity: (tid, selectionRevision),
    onCloseDetail: () {
      closes++;
      select(0);
    },
    child: TwoPane(
      panePriority: tid == 0 ? TwoPanePriority.start : TwoPanePriority.end,
      startPane: Builder(
        builder: (context) {
          master = context;
          return Scaffold(
            body: Column(
              children: [
                const Text('Master'),
                TextButton(
                  onPressed: () => pushDetailPage<void>(
                    context,
                    platformPageRoute<void>(
                      context: context,
                      builder: (_) => const DetailPage('Settings'),
                    ),
                  ),
                  child: const Text('Master settings'),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scroll,
                    itemCount: 50,
                    itemBuilder: (_, i) =>
                        SizedBox(height: 50, child: Text('row $i')),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      endPane: tid == 0
          ? const Center(child: Text('Placeholder'))
          : DetailPage('Thread $tid', key: ValueKey(tid)),
    ),
  );
}

void main() {
  for (final style in [AppVisualStyle.material, AppVisualStyle.cupertino]) {
    testWidgets(
      'detail navigation stays right and preserves the thread: $style',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(1000, 800);
        addTearDown(tester.view.reset);
        final semantics = tester.ensureSemantics();
        try {
          final root = GlobalKey<NavigatorState>();
          final host = GlobalKey<PaneHostState>();
          await tester.pumpWidget(
            PlatformProvider(
              style: style,
              builder: (_) => MaterialApp(
                navigatorKey: root,
                home: PaneHost(key: host),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final thread = tester.state<DetailPageState>(find.byType(DetailPage));
          thread.draft.text = 'unsent thread reply';
          host.currentState!.scroll.jumpTo(350);
          await tester.tap(find.text('Open settings'));
          await tester.pumpAndSettle();
          expect(find.text('Master'), findsOneWidget);
          expect(tester.getSemantics(find.text('Master')).label, 'Master');
          expect(root.currentState!.canPop(), isFalse);
          expect(tester.getRect(find.text('Settings')).left, greaterThan(350));
          expect(
            PaneNavigationScope.maybeOf(tester.element(find.text('Settings')))!
                .isDetail,
            isTrue,
          );
          await tester.tap(find.text('Open profile'));
          await tester.pumpAndSettle();
          expect(find.text('Master'), findsOneWidget);
          expect(tester.getRect(find.text('Profile')).left, greaterThan(350));
          await root.currentState!.maybePop();
          await tester.pumpAndSettle();
          expect(find.text('Settings'), findsOneWidget);
          expect(host.currentState!.closes, 0);
          await root.currentState!.maybePop();
          await tester.pumpAndSettle();
          expect(find.text('Thread 1'), findsOneWidget);
          expect(tester.state(find.byType(DetailPage)), same(thread));
          expect(thread.draft.text, 'unsent thread reply');
          expect(host.currentState!.scroll.offset, 350);
          expect(tester.takeException(), isNull);
        } finally {
          semantics.dispose();
        }
      },
    );
  }

  testWidgets(
    'master destinations retain their stack across folding with no selected thread',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1000, 800);
      addTearDown(tester.view.reset);
      final root = GlobalKey<NavigatorState>();
      final host = GlobalKey<PaneHostState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: root,
          home: PaneHost(key: host, selected: false),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Master settings'));
      await tester.pumpAndSettle();
      final settings = tester.state<DetailPageState>(find.byType(DetailPage));
      settings.draft.text = 'pending preferences';
      await tester.tap(find.text('Open profile'));
      await tester.pumpAndSettle();
      final profile = tester.state<DetailPageState>(find.byType(DetailPage));
      tester.view.physicalSize = const Size(390, 844);
      await tester.pumpAndSettle();
      expect(find.text('Master'), findsNothing);
      expect(tester.state(find.byType(DetailPage)), same(profile));
      await root.currentState!.maybePop();
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);
      expect(settings.draft.text, 'pending preferences');
      tester.view.physicalSize = const Size(1000, 800);
      await tester.pumpAndSettle();
      expect(find.text('Master'), findsOneWidget);
      expect(tester.state(find.byType(DetailPage)), same(settings));
      await root.currentState!.maybePop();
      await tester.pumpAndSettle();
      expect(find.text('Placeholder'), findsOneWidget);
      expect(host.currentState!.closes, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'compact entry and back return through detail pages before the master',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.reset);
      final root = GlobalKey<NavigatorState>();
      final host = GlobalKey<PaneHostState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: root,
          home: PaneHost(key: host, selected: false),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Master settings'));
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Master'), findsNothing);
      await root.currentState!.maybePop();
      await tester.pumpAndSettle();
      expect(find.text('Master'), findsOneWidget);
      host.currentState!.select(1);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open profile'));
      await tester.pumpAndSettle();
      await root.currentState!.maybePop();
      await tester.pumpAndSettle();
      expect(find.text('Thread 1'), findsOneWidget);
      expect(host.currentState!.closes, 0);
      await root.currentState!.maybePop();
      await tester.pumpAndSettle();
      expect(find.text('Master'), findsOneWidget);
      expect(host.currentState!.closes, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'selecting or reselecting a thread clears subpages and keeps the master scroll',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1000, 800);
      addTearDown(tester.view.reset);
      final host = GlobalKey<PaneHostState>();
      await tester.pumpWidget(MaterialApp(home: PaneHost(key: host)));
      await tester.pumpAndSettle();
      host.currentState!.scroll.jumpTo(300);
      final thread = tester.state<DetailPageState>(find.byType(DetailPage));
      thread.draft.text = 'keep this reply';
      await tester.tap(find.text('Open settings'));
      await tester.pumpAndSettle();
      host.currentState!.select(1);
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsNothing);
      expect(tester.state(find.byType(DetailPage)), same(thread));
      expect(thread.draft.text, 'keep this reply');
      await tester.tap(find.text('Open settings'));
      await tester.pumpAndSettle();
      host.currentState!.select(2);
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsNothing);
      expect(find.text('Thread 2'), findsOneWidget);
      expect(host.currentState!.scroll.offset, 300);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Cupertino back swipes pop the detail stack in wide and compact layouts',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1000, 800);
      addTearDown(tester.view.reset);
      final root = GlobalKey<NavigatorState>();
      final host = GlobalKey<PaneHostState>();
      await tester.pumpWidget(
        PlatformProvider(
          style: AppVisualStyle.cupertino,
          builder: (_) => MaterialApp(
            navigatorKey: root,
            home: PaneHost(key: host),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open settings'));
      await tester.pumpAndSettle();
      final settingsBounds = tester.getRect(find.byType(DetailPage).last);
      await tester.dragFrom(
        Offset(settingsBounds.left + 8, 300),
        const Offset(360, 0),
      );
      await tester.pumpAndSettle();
      expect(find.text('Thread 1'), findsOneWidget);
      expect(find.text('Master'), findsOneWidget);
      await tester.tap(find.text('Open profile'));
      await tester.pumpAndSettle();
      tester.view.physicalSize = const Size(390, 844);
      await tester.pumpAndSettle();
      await tester.dragFrom(const Offset(8, 300), const Offset(250, 0));
      await tester.pumpAndSettle();
      expect(find.text('Thread 1'), findsOneWidget);
      expect(host.currentState!.closes, 0);
      expect(root.currentState!.canPop(), isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'detail routing outside a pane uses the existing navigator and result',
    (tester) async {
      final root = GlobalKey<NavigatorState>();
      late BuildContext source;
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: root,
          home: Builder(
            builder: (context) {
              source = context;
              return const Scaffold(body: Text('Home'));
            },
          ),
        ),
      );
      final result = pushDetailPage<int>(
        source,
        MaterialPageRoute<int>(
          builder: (_) => const Scaffold(body: Text('Destination')),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Destination'), findsOneWidget);
      root.currentState!.pop(42);
      await tester.pumpAndSettle();
      expect(await result, 42);
      expect(find.text('Home'), findsOneWidget);
    },
  );
}
