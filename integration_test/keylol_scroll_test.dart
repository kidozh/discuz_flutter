import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/main.dart' as app;
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/DashboardScreen.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/widget/KeylolTopicTabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

/// Requires an iOS 26+ test simulator already set up with Keylol in anonymous
/// Cupertino mode. Never auto-accept terms, log in, or change user preferences.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('issue 12: real iOS Keylol lists scroll and restore offsets',
      (tester) async {
    expect(Platform.isIOS, isTrue, reason: 'Run on an iOS 26+ simulator.');
    final steps = <Map<String, Object?>>[];
    binding.reportData = {
      'os': Platform.operatingSystemVersion,
      'mode': 'debug simulator; not a real-device performance benchmark',
      'category_input': 'PlatformSegmentedControl.onValueChanged callback',
      'scroll_input': 'WidgetTester.timedDrag, verified using ScrollPosition',
      'steps': steps,
      'completed': false,
    };
    app.main();
    final dashboard = find.byType(CupertinoDashboardScreen);
    await _waitFor(tester, () => dashboard.evaluate().isNotEmpty,
        'Prepare the simulator: accept terms, add Keylol, use Cupertino mode.');
    final context = tester.element(dashboard.first);
    final source = context.read<DiscuzAndUserNotifier>();
    expect(source.discuz?.host, 'keylol.com');
    expect(source.user, isNull, reason: 'Use an anonymous test simulator.');
    expect(usesLiquidGlass(context), isTrue);

    final portalLabel = S.of(context).keylolPortal;
    final dashboardControl = find.byWidgetPredicate((widget) =>
        widget is PlatformSegmentedControl &&
        widget.labels.contains(portalLabel));
    expect(dashboardControl, findsOneWidget);
    final control = tester.widget<PlatformSegmentedControl>(dashboardControl);
    control.onValueChanged(control.labels.indexOf(portalLabel));
    await _waitFor(
        tester,
        () => find.byType(KeylolTopicTabs).evaluate().isNotEmpty,
        'Keylol topics did not load from the public website.');
    final tabs = find.byType(KeylolTopicTabs);
    final categories = find.descendant(
        of: tabs, matching: find.byType(PlatformSegmentedControl));
    final titles = tester.widget<PlatformSegmentedControl>(categories).labels;
    expect(titles.length, greaterThanOrEqualTo(2));
    binding.reportData!['categories'] = titles;
    await _pumpFor(tester, const Duration(seconds: 1));

    final list = find.descendant(of: tabs, matching: find.byType(ListView));
    ScrollPosition position() {
      expect(list, findsOneWidget, reason: 'Only the active topic is mounted.');
      return tester
          .state<ScrollableState>(
              find.descendant(of: list, matching: find.byType(Scrollable)))
          .position;
    }

    void verifySurface() {
      final nativeControl =
          find.descendant(of: categories, matching: find.byType(UiKitView));
      expect(nativeControl, findsOneWidget,
          reason: 'The integration test must retain the real UIKit control.');
      final box = tester.renderObject<RenderBox>(nativeControl);
      expect(box.constraints.hasBoundedWidth, isTrue);
      expect(box.constraints.hasBoundedHeight, isTrue);
      expect(box.size.width.isFinite && box.size.height.isFinite, isTrue);
      expect(
          find.descendant(
              of: list, matching: find.byType(PlatformLiquidGlassCard)),
          findsWidgets);
      expect(find.descendant(of: list, matching: find.byType(BackdropFilter)),
          findsNothing);
      expect(tester.takeException(), isNull);
    }

    Future<void> select(int index) async {
      // integration_test does not inject UIKit touches. Retain the native view
      // while exercising the exact production callback and its state update.
      tester.widget<PlatformSegmentedControl>(categories).onValueChanged(index);
      await _pumpFor(tester, const Duration(milliseconds: 450));
      expect(tester.widget<PlatformSegmentedControl>(categories).selectedIndex,
          index);
      verifySurface();
    }

    Future<void> swipe({required bool towardEnd}) async {
      final before = position().pixels;
      final travel = math.min(300.0, tester.getSize(list).height * 0.42);
      await tester.timedDrag(list, Offset(0, towardEnd ? -travel : travel),
          const Duration(milliseconds: 500));
      await _waitFor(tester, () => !position().isScrollingNotifier.value,
          'The list did not finish scrolling.',
          timeout: const Duration(seconds: 5));
      final after = position().pixels;
      if (towardEnd) {
        expect(after, greaterThan(before + 20),
            reason: 'Upward drag must advance the list.');
      } else {
        expect(after, lessThan(before - 20),
            reason: 'Downward drag must return toward the top.');
      }
      final step = <String, Object?>{
        'category':
            tester.widget<PlatformSegmentedControl>(categories).selectedIndex,
        'direction': towardEnd ? 'up' : 'down',
        'before': before,
        'after': after,
        'max_extent': position().maxScrollExtent,
      };
      steps.add(step);
      debugPrint('ISSUE12_SCROLL ${jsonEncode(step)}');
      verifySurface();
    }

    verifySurface();
    await binding.takeScreenshot('01_headlines_before_scroll');
    await swipe(towardEnd: true);
    final firstOffset = position().pixels;
    await binding.takeScreenshot('02_headlines_after_scroll');
    await select(1);
    expect(position().pixels, closeTo(0, 1));
    await swipe(towardEnd: true);
    final secondOffset = position().pixels;
    await select(0);
    expect(position().pixels, closeTo(firstOffset, 1));
    await binding.takeScreenshot('03_headlines_restored_offset');
    await select(1);
    expect(position().pixels, closeTo(secondOffset, 1));
    binding.reportData!['restored_offsets'] = [firstOffset, secondOffset];

    // Three complete down/up cycles for every real category, without retaining
    // hidden lists. Use real pointer events rather than ScrollController jumps.
    for (var category = 0; category < titles.length; category++) {
      await select(category);
      expect(position().maxScrollExtent, greaterThan(50));
      for (var round = 0; round < 3; round++) {
        // The first two categories already have saved offsets. Starting toward
        // the nearer end keeps every asserted swipe away from a boundary.
        final towardEnd = position().pixels < position().maxScrollExtent / 2;
        await swipe(towardEnd: towardEnd);
        await swipe(towardEnd: !towardEnd);
      }
    }
    await select(0);
    binding.reportData!['completed'] = true;
    debugPrint('ISSUE12_COMPLETE ${steps.length} verified scroll gestures');
  }, timeout: const Timeout(Duration(minutes: 4)));
}

Future<void> _pumpFor(WidgetTester tester, Duration duration) async {
  final watch = Stopwatch()..start();
  while (watch.elapsed < duration) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _waitFor(WidgetTester tester, bool Function() ready, String reason,
    {Duration timeout = const Duration(seconds: 45)}) async {
  final watch = Stopwatch()..start();
  do {
    await tester.pump(const Duration(milliseconds: 100));
    if (ready()) return;
  } while (watch.elapsed < timeout);
  fail(reason);
}
