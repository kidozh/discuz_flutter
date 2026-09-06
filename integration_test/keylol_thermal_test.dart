import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' show FramePhase, FrameTiming;

import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/provider/SelectedTidNotifierProvider.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/widget/KeylolMobileTopicWidget.dart';
import 'package:discuz_flutter/widget/KeylolTopicTabs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'support/thermal_metrics.dart';

const _probe = MethodChannel('discuz.issue12/thermal');

/// Page-level benchmark in an isolated app, NOT the production startup flow.
/// The native probe and separate bundle ID must be supplied by the test build.
/// WARNING: On Flutter 3.47.2, LiveTestWidgetsFlutterBinding.handleDrawFrame
/// schedules another frame even with benchmarkLive. This legacy stress test
/// overstates idle CPU/render activity. Use keylol_thermal_native.dart for heat.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.benchmarkLive;
  testWidgets('issue 12: bounded real-device thermal scrolling',
      (tester) async {
    expect(kProfileMode, isTrue,
        reason: 'A physical iPhone profile build is required.');
    final status = ValueNotifier('正在加载其乐头条…');
    var userStopped = false;
    String? stopReason;
    final frames = <FrameTiming>[];
    final samples = <Map<String, dynamic>>[];
    final phases = <Map<String, dynamic>>[];
    final gestures = <Map<String, Object?>>[];
    final watch = Stopwatch()..start();
    var phase = 'setup';
    var lastLogSecond = -10;
    final report = <String, dynamic>{
      'completed': false,
      'mode': 'profile, physical iPhone, benchmarkLive',
      'validity_warning': 'Legacy harness forces idle frames in Flutter 3.47.2; '
          'do not interpret its CPU/thermal load as normal app usage.',
      'scope': 'Production KeylolMobileTopicWidget / ForumThreadWidget / '
          'native Liquid Glass navigation and category control; isolated page host. '
          'No production startup, signed-in account, ads or push initialization.',
      'scroll_input': 'timedDrag 60 Hz synthetic Flutter pointer events',
      'category_input':
          'production onValueChanged callback, not UIKit touch injection',
      'thermal_note':
          'System thermal pressure, not battery or case temperature in degrees.',
      'samples': samples,
      'phases': phases,
      'gestures': gestures,
    };
    binding.reportData = report;
    final previousPropagation = binding.shouldPropagateDevicePointerEvents;
    binding.shouldPropagateDevicePointerEvents = true;
    void collect(List<FrameTiming> batch) => frames.addAll(batch);
    binding.addTimingsCallback(collect);

    Future<Map<String, dynamic>> sample() async {
      final value = Map<String, dynamic>.from(
          (await _probe.invokeMapMethod<String, dynamic>('snapshot'))!);
      value.addAll({
        'elapsed_s': watch.elapsedMilliseconds / 1000,
        'wall_us': DateTime.now().microsecondsSinceEpoch,
        'phase': phase,
        'rss_bytes': ProcessInfo.currentRss,
      });
      samples.add(value);
      final severity = value['worstThermalRaw'] as int;
      if (severity >= 2) stopReason ??= 'thermal_${value['thermal']}';
      if (userStopped) stopReason ??= 'user_stop';
      if (binding.lifecycleState != null &&
          binding.lifecycleState != AppLifecycleState.resumed) {
        stopReason ??= 'app_not_foreground';
      }
      if (watch.elapsed.inSeconds - lastLogSecond >= 10) {
        lastLogSecond = watch.elapsed.inSeconds;
        debugPrint('ISSUE12_THERMAL ${jsonEncode(value)}');
      }
      return value;
    }

    try {
      final device = Map<String, dynamic>.from(
          (await _probe.invokeMapMethod<String, dynamic>('begin'))!);
      report['device'] = device;
      expect(device['appIdentifier'], 'com.kidozh.discuz-flutter.perftest');
      expect(device['isSimulator'], false);
      final refreshRate = (device['maximumFramesPerSecond'] as num).toDouble();
      expect(refreshRate, greaterThan(0),
          reason: 'The native display must be ready.');
      await Hive.initFlutter();
      await AppDatabase.initBoxes();
      final source = DiscuzAndUserNotifier()
        ..initDiscuz(Discuz(
            'https://keylol.com',
            'X3.2',
            'utf-8',
            4,
            '1.4.8',
            'register',
            true,
            'true',
            'true',
            '其乐 Keylol',
            '0',
            'https://keylol.com/uc_server',
            '161'));
      runApp(MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: source),
          ChangeNotifierProvider(create: (_) => SelectedTidNotifierProvider()),
        ],
        child: PlatformProvider(
          initialPlatform: TargetPlatform.iOS,
          builder: (_) => MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: const Locale('zh'),
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate
            ],
            supportedLocales: S.delegate.supportedLocales,
            theme: ThemeData(
                platform: TargetPlatform.iOS,
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)),
            home: PlatformScaffold(
              appBar: const PlatformAppBar(
                  liquidGlassTitle: '谈坛性能测试', automaticallyImplyLeading: false),
              body: Column(children: [
                const Expanded(child: KeylolMobileTopicWidget()),
                Material(
                    child: SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          child: Row(children: [
                            Expanded(
                                child: ValueListenableBuilder<String>(
                              valueListenable: status,
                              builder: (_, value, __) => Text(value,
                                  style: const TextStyle(fontSize: 12)),
                            )),
                            TextButton(
                                onPressed: () {
                                  userStopped = true;
                                  status.value = '已请求停止…';
                                },
                                child: const Text('停止测试',
                                    style: TextStyle(color: Colors.red))),
                          ]),
                        ))),
              ]),
            ),
          ),
        ),
      ));
      final tabs = find.byType(KeylolTopicTabs);
      final loading = Stopwatch()..start();
      while (tabs.evaluate().isEmpty) {
        await tester.pump(const Duration(milliseconds: 500));
        await sample();
        if (stopReason != null) return;
        if (loading.elapsed > const Duration(seconds: 90)) {
          fail('Live Keylol topics did not load within 90 seconds.');
        }
      }
      expect(usesLiquidGlass(tester.element(tabs)), isTrue);
      final categories = find.descendant(
          of: tabs, matching: find.byType(PlatformSegmentedControl));
      final list = find.descendant(of: tabs, matching: find.byType(ListView));
      ScrollPosition position() => tester
          .state<ScrollableState>(
              find.descendant(of: list, matching: find.byType(Scrollable)))
          .position;
      void verify() {
        expect(list, findsOneWidget);
        expect(
            find.descendant(of: categories, matching: find.byType(UiKitView)),
            findsOneWidget);
        expect(find.descendant(of: list, matching: find.byType(BackdropFilter)),
            findsNothing);
        expect(
            find.descendant(
                of: list, matching: find.byType(PlatformLiquidGlassCard)),
            findsWidgets);
        expect(tester.takeException(), isNull);
      }

      verify();
      final titles = tester.widget<PlatformSegmentedControl>(categories).labels;
      report['categories'] = titles;

      Future<void> runPhase(String name, String label, Duration duration,
          {bool scroll = false}) async {
        if (stopReason != null) return;
        phase = name;
        status.value = label;
        final stageWatch = Stopwatch()..start();
        final stage = <String, dynamic>{
          'name': name,
          'start_wall_us': DateTime.now().microsecondsSinceEpoch,
          'target_duration_s': duration.inSeconds
        };
        phases.add(stage);
        var lastCategorySlot = -1;
        try {
          await sample();
          while (stageWatch.elapsed < duration && stopReason == null) {
            if (scroll) {
              final slot = stageWatch.elapsed.inSeconds ~/ 20;
              if (slot != lastCategorySlot) {
                lastCategorySlot = slot;
                tester
                    .widget<PlatformSegmentedControl>(categories)
                    .onValueChanged(slot % titles.length);
                await tester.pump(const Duration(milliseconds: 500));
                verify();
              }
              final before = position().pixels;
              final extent = position().maxScrollExtent;
              expect(extent, greaterThan(50));
              final down = before < extent / 2;
              final travel = math.min(260.0, tester.getSize(list).height * .38);
              await tester.timedDrag(list, Offset(0, down ? -travel : travel),
                  const Duration(milliseconds: 700));
              final settle = Stopwatch()..start();
              while (position().isScrollingNotifier.value &&
                  settle.elapsed < const Duration(seconds: 3)) {
                await tester.pump(const Duration(milliseconds: 100));
              }
              final after = position().pixels;
              expect((after - before).abs(), greaterThan(20));
              gestures.add({
                'elapsed_s': watch.elapsedMilliseconds / 1000,
                'category': slot % titles.length,
                'before': before,
                'after': after
              });
              expect(tester.takeException(), isNull);
            } else {
              await tester.pump(const Duration(seconds: 1));
            }
            await sample();
          }
        } finally {
          stage['end_wall_us'] = DateTime.now().microsecondsSinceEpoch;
          stage['actual_duration_s'] = stageWatch.elapsedMilliseconds / 1000;
          debugPrint('ISSUE12_PHASE ${jsonEncode(stage)}');
        }
      }

      await runPhase('idle_before', '静置基线 · 30 秒', const Duration(seconds: 30));
      await runPhase(
          'scroll', '自动滑动 · 3 分钟\n明显发烫可随时停止', const Duration(minutes: 3),
          scroll: true);
      await runPhase(
          'idle_after', '滑动已结束 · 观察 30 秒', const Duration(seconds: 30));
      await tester.pump(const Duration(seconds: 1)); // Flush batched timings.
      for (final stage in phases) {
        final start = stage['start_wall_us'] as int;
        final end = stage['end_wall_us'] as int;
        stage['frames'] = summarizeThermalFrames(
            frames.where((frame) {
              final wall = frame
                  .timestampInMicroseconds(FramePhase.rasterFinishWallTime);
              return wall >= start && wall < end;
            }).toList(),
            refreshRate);
      }
      report['completed'] = stopReason == null && phases.length == 3;
      status.value = stopReason == null ? '测试完成' : '测试已停止：$stopReason';
    } catch (error) {
      report['error'] = error.toString();
      rethrow;
    } finally {
      report['stop_reason'] = stopReason;
      report['elapsed_s'] = watch.elapsedMilliseconds / 1000;
      report['raw_frames'] = frames
          .map((f) => {
                'wall_us':
                    f.timestampInMicroseconds(FramePhase.rasterFinishWallTime),
                'vsync_us': f.timestampInMicroseconds(FramePhase.vsyncStart),
                'build_us': f.buildDuration.inMicroseconds,
                'raster_us': f.rasterDuration.inMicroseconds,
                'total_us': f.totalSpan.inMicroseconds,
              })
          .toList();
      binding.removeTimingsCallback(collect);
      binding.shouldPropagateDevicePointerEvents = previousPropagation;
      try {
        final path =
            await _probe.invokeMethod<String>('saveReport', jsonEncode(report));
        debugPrint('ISSUE12_DEVICE_REPORT $path');
      } finally {
        await _probe.invokeMethod<void>('end');
      }
      debugPrint('ISSUE12_THERMAL_COMPLETE completed=${report['completed']} '
          'stop=$stopReason gestures=${gestures.length} frames=${frames.length}');
    }
  }, timeout: const Timeout(Duration(minutes: 8)));
}
