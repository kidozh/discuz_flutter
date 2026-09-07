import 'dart:convert';
import 'dart:io';

import 'package:discuz_flutter/JsonResult/SmileyResult.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/Smiley.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/SmileyListScreen.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _site = Discuz('https://example.com', 'X3.5', 'utf-8', 4, '', '', false,
    '0', '0', 'Example', '1', '', '0');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory temporaryDirectory;
  late Box<Smiley> box;
  late DiscuzAndUserNotifier notifier;

  setUpAll(() async {
    temporaryDirectory =
        await Directory.systemTemp.createTemp('smiley_tabs_test_');
    Hive.init(temporaryDirectory.path);
    box = await Hive.openBox<Smiley>('smileys');
    AppDatabase.smileyBox = box;
  });
  tearDownAll(() async {
    AppDatabase.smileyBox = null;
    await box.close();
    await temporaryDirectory.delete(recursive: true);
  });
  setUp(() {
    notifier = DiscuzAndUserNotifier()..discuz = _site;
    final result = SmileyResult()
      ..variables =
          (SmileyVariables()..smilies = List.generate(7, (_) => <Smiley>[]));
    SharedPreferences.setMockInitialValues({
      'discuz_simley_caches_${_site.baseURL}': jsonEncode(result.toJson()),
    });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('haptic_feedback'), (_) async => false);
  });
  tearDown(() {
    notifier.dispose();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('haptic_feedback'), null);
  });

  Widget host(
          {AppVisualStyle style = AppVisualStyle.cupertino,
          double textScale = 1,
          TextDirection direction = TextDirection.ltr,
          List<SmileyPanelAction> actions = const []}) =>
      PlatformProvider(
        style: style,
        builder: (_) => MaterialApp(
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: Scaffold(
            body: ChangeNotifierProvider.value(
              value: notifier,
              child: MediaQuery(
                data: MediaQueryData(
                    size: const Size(320, 900),
                    textScaler: TextScaler.linear(textScale)),
                child: Directionality(
                  textDirection: direction,
                  child: Center(
                      child: SizedBox(
                    width: 320,
                    child: SmileyListScreen((_) {}, recentActions: actions),
                  )),
                ),
              ),
            ),
          ),
        ),
      );

  for (final direction in TextDirection.values) {
    testWidgets(
        'Cupertino smiley tabs sync taps, swipes and scrolling ($direction)',
        (tester) async {
      await tester.pumpWidget(host(direction: direction));
      await tester.pumpAndSettle();
      final finder = find.byType(PlatformSegmentedControl);
      PlatformSegmentedControl control() =>
          tester.widget<PlatformSegmentedControl>(finder);
      expect(find.byType(CupertinoSlidingSegmentedControl<int>), findsOneWidget);
      expect(find.byType(PlatformLiquidGlassCard), findsNothing);
      expect(find.byType(TabBar), findsNothing);
      expect(control().labels, hasLength(8));
      expect(control().selectedIndex, 1);
      expect(find.text(control().labels[1]).hitTestable(), findsWidgets);
      final tabScroller = find.ancestor(
          of: finder, matching: find.byType(SingleChildScrollView));
      final tabController =
          tester.widget<SingleChildScrollView>(tabScroller).controller!;
      final initialOffset = tabController.offset;
      await tester.drag(
          tabScroller, Offset(direction == TextDirection.ltr ? -220 : 220, 0));
      await tester.pumpAndSettle();
      expect(tabController.offset, greaterThan(initialOffset));
      expect(control().selectedIndex, 1);
      await Scrollable.ensureVisible(
          tester.element(find.text(control().labels[2]).first),
          alignment: 0.5);
      await tester.pumpAndSettle();
      await tester.tap(find.text(control().labels[2]).hitTestable().first);
      await tester.pumpAndSettle();
      final pages = tester.widget<PageView>(find.byType(PageView));
      expect(pages.controller!.page, 2);
      await tester.drag(find.byType(PageView),
          Offset(direction == TextDirection.ltr ? -280 : 280, 0));
      await tester.pumpAndSettle();
      expect(control().selectedIndex, 3);

      // A distant page selection must reveal its segment even at large text.
      pages.controller!.jumpToPage(7);
      await tester.pumpAndSettle();
      expect(control().selectedIndex, 7);
      expect(find.text(control().labels.last).hitTestable(), findsWidgets);
      await tester.pumpWidget(host(direction: direction, textScale: 2));
      await tester.pumpAndSettle();
      expect(control().selectedIndex, 7);
      expect(find.text(control().labels.last).hitTestable(), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Material smiley tabs retain TabBar and swipeable pages',
      (tester) async {
    await tester.pumpWidget(host(style: AppVisualStyle.material));
    await tester.pumpAndSettle();
    expect(find.byType(TabBar), findsOneWidget);
    expect(find.byType(TabBarView), findsOneWidget);
    expect(find.byType(PlatformSegmentedControl), findsNothing);
    await tester.drag(find.byType(TabBarView), const Offset(-280, 0));
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(TabBar));
    expect(DefaultTabController.of(context).index, 2);
    expect(tester.takeException(), isNull);
  });

  for (final scale in [1.0, 2.0]) {
    testWidgets(
        'Cupertino photo actions fit narrow screens at text scale $scale',
        (tester) async {
      var picked = false;
      var captured = false;
      await tester.pumpWidget(host(textScale: scale, actions: [
        SmileyPanelAction(
            icon: CupertinoIcons.photo,
            label: 'Photo',
            onPressed: () => picked = true),
        SmileyPanelAction(
            icon: CupertinoIcons.camera,
            label: 'Camera',
            onPressed: () => captured = true),
      ]));
      await tester.pumpAndSettle();
      expect(find.byType(PlatformLiquidGlassCard), findsNothing);
      expect(find.text('Photo').hitTestable(), findsOneWidget);
      await tester.tap(find.text('Photo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Camera'));
      await tester.pumpAndSettle();
      expect(picked, isTrue);
      expect(captured, isTrue);
      expect(tester.takeException(), isNull);
    });
  }
}
