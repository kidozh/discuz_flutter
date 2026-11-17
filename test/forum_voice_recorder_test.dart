import 'dart:async';
import 'dart:io';

import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/forum_voice.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/widget/forum_voice_recorder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
// Redirect real temporary recordings to isolated test storage.
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _Paths extends PathProviderPlatform {
  _Paths(this.path);
  final String path;
  @override
  Future<String?> getTemporaryPath() async => path;
}

class _Capture implements ForumVoiceCapture {
  Completer<bool>? permission;
  Completer<void>? startGate;
  bool failOnStart = false;
  int starts = 0, stops = 0;
  String? path;
  @override
  Future<bool> hasPermission() async =>
      await (permission?.future ?? Future.value(true));
  @override
  Future<void> start(String path, VoidCallback onError) async {
    starts++;
    this.path = path;
    // Synchronous I/O avoids fake async retaining filesystem completions.
    File(path).writeAsBytesSync([1, 2, 3]);
    if (failOnStart) onError();
    await startGate?.future;
  }

  @override
  Future<String?> stop() async {
    stops++;
    return path;
  }

  @override
  Future<void> dispose() async {}
}

Future<void> flush(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump();
  }
}

void main() {
  late Directory directory;
  late PathProviderPlatform previousPaths;
  setUp(() {
    directory = Directory.systemTemp.createTempSync('voice_controls_');
    previousPaths = PathProviderPlatform.instance;
    PathProviderPlatform.instance = _Paths(directory.path);
  });
  tearDown(() {
    PathProviderPlatform.instance = previousPaths;
    if (directory.existsSync()) directory.deleteSync(recursive: true);
  });

  Future<void> mount(
    WidgetTester tester,
    _Capture capture,
    List<String> events, {
    bool reply = true,
    int maxSeconds = 60,
    AppVisualStyle style = AppVisualStyle.material,
    double width = 390,
    double textScale = 1,
    Completer<void>? saveGate,
  }) async {
    var open = true;
    await tester.pumpWidget(
      PlatformProvider(
        style: style,
        builder: (_) => MaterialApp(
          theme: ThemeData(brightness: Brightness.dark),
          localizationsDelegates: const [
            S.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          builder: EasyLoading.init(),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: width,
                child: MediaQuery(
                  data: MediaQueryData(
                    textScaler: TextScaler.linear(textScale),
                  ),
                  child: StatefulBuilder(
                    builder: (context, update) => !open
                        ? const SizedBox.shrink()
                        : ForumVoiceRecorder(
                            options: (
                              format: ForumVoiceFormat.mp3,
                              maxSeconds: maxSeconds,
                            ),
                            capture: capture,
                            onRecorded: (voice) async {
                              expectSync(voice.file.existsSync(), true);
                              expectSync(
                                voice.duration.inSeconds,
                                inInclusiveRange(1, maxSeconds),
                              );
                              await saveGate?.future;
                              events.add('saved');
                              return false;
                            },
                            onClosed: () {
                              events.add('closed');
                              update(() => open = false);
                            },
                            onSend: reply ? () => events.add('sent') : null,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await flush(tester);
  }

  Finder control(String action) => find.byKey(ValueKey('voice-$action'));

  Future<void> recordSecond(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 1100)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> cleanup(WidgetTester tester) async {
    unawaited(EasyLoading.dismiss());
    await tester.pumpWidget(const SizedBox.shrink());
    await flush(tester);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'opening records immediately; send persists before sending once',
    (tester) async {
      final capture = _Capture();
      final events = <String>[];
      final saved = Completer<void>();
      await mount(tester, capture, events, saveGate: saved);
      expect(capture.starts, 1);
      expect(find.text('Hold to talk'), findsNothing);
      expect(tester.widget<IconButton>(control('send')).onPressed, isNull);
      await recordSecond(tester);
      await tester.tap(control('send'));
      await flush(tester);
      expect(events, isEmpty);
      expect(tester.widget<IconButton>(control('send')).onPressed, isNull);
      await tester.tap(control('send'));
      saved.complete();
      await flush(tester);
      expect(events, ['saved', 'closed', 'sent']);
      expect(capture.stops, 1);
      expect(File(capture.path!).existsSync(), false);
      await cleanup(tester);
    },
  );

  testWidgets('cancel discards the recording and closes without sending', (
    tester,
  ) async {
    final capture = _Capture();
    final events = <String>[];
    await mount(tester, capture, events, style: AppVisualStyle.cupertino);
    await tester.tap(control('cancel'));
    await flush(tester);
    expect(events, ['closed']);
    expect(capture.stops, 1);
    expect(File(capture.path!).existsSync(), false);
    await cleanup(tester);
  });

  for (final stage in ['permission', 'capture']) {
    testWidgets(
      'cancel during delayed $stage cannot leave a recording running',
      (tester) async {
        final capture = _Capture();
        if (stage == 'permission') {
          capture.permission = Completer<bool>();
        } else {
          capture.startGate = Completer<void>();
        }
        final events = <String>[];
        await mount(tester, capture, events);
        await tester.tap(control('cancel'));
        await tester.pump();
        capture.permission?.complete(true);
        capture.startGate?.complete();
        await flush(tester);
        expect(events, ['closed']);
        expect(capture.starts, stage == 'permission' ? 0 : 1);
        if (capture.path != null) {
          expect(capture.stops, 1);
          expect(File(capture.path!).existsSync(), false);
        }
        await cleanup(tester);
      },
    );
  }

  testWidgets('permission refusal closes without starting capture', (
    tester,
  ) async {
    final capture = _Capture()
      ..permission = (Completer<bool>()..complete(false));
    final events = <String>[];
    await mount(tester, capture, events);
    expect(capture.starts, 0);
    expect(events, ['closed']);
    await cleanup(tester);
  });

  testWidgets('short recording never saves or sends', (tester) async {
    final capture = _Capture();
    final events = <String>[];
    await mount(tester, capture, events);
    await tester.tap(control('stop'));
    await flush(tester);
    expect(events, ['closed']);
    expect(File(capture.path!).existsSync(), false);
    await cleanup(tester);
  });

  testWidgets('native startup failure closes and removes temporary files', (
    tester,
  ) async {
    final capture = _Capture()..failOnStart = true;
    final events = <String>[];
    await mount(tester, capture, events);
    expect(events, ['closed']);
    expect(capture.stops, 1);
    expect(File(capture.path!).existsSync(), false);
    await cleanup(tester);
  });

  testWidgets('stop keeps a playable reply draft without sending', (
    tester,
  ) async {
    final capture = _Capture();
    final events = <String>[];
    await mount(tester, capture, events);
    await recordSecond(tester);
    await tester.tap(control('stop'));
    await flush(tester);
    expect(events, ['saved', 'closed']);
    await cleanup(tester);
  });

  testWidgets('backgrounding saves a completed recording without sending', (
    tester,
  ) async {
    final capture = _Capture();
    final events = <String>[];
    await mount(tester, capture, events);
    await recordSecond(tester);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await flush(tester);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    expect(events, ['saved', 'closed']);
    await cleanup(tester);
  });

  testWidgets('backgrounding during send preparation only keeps the draft', (
    tester,
  ) async {
    final capture = _Capture();
    final events = <String>[];
    final saved = Completer<void>();
    await mount(tester, capture, events, saveGate: saved);
    await recordSecond(tester);
    await tester.tap(control('send'));
    await flush(tester);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    saved.complete();
    await flush(tester);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    expect(events, ['saved', 'closed']);
    await cleanup(tester);
  });

  testWidgets('forum duration limit stops and saves once without sending', (
    tester,
  ) async {
    final capture = _Capture();
    final events = <String>[];
    await mount(tester, capture, events, maxSeconds: 1);
    await recordSecond(tester);
    await flush(tester);
    expect(events, ['saved', 'closed']);
    expect(capture.stops, 1);
    await cleanup(tester);
  });

  testWidgets(
    'topic stop attaches voice and retains manual post confirmation',
    (tester) async {
      final capture = _Capture();
      final events = <String>[];
      await mount(tester, capture, events, reply: false);
      expect(control('send'), findsNothing);
      await recordSecond(tester);
      await tester.tap(control('stop'));
      await flush(tester);
      expect(events, ['saved', 'closed']);
      await cleanup(tester);
    },
  );

  for (final style in [AppVisualStyle.material, AppVisualStyle.cupertino]) {
    testWidgets(
      'recording controls stay aligned on a narrow screen with large text ($style)',
      (tester) async {
        final capture = _Capture();
        final events = <String>[];
        await mount(
          tester,
          capture,
          events,
          style: style,
          width: 280,
          textScale: 2,
        );
        final bar = find.byKey(const ValueKey('voice-recording-bar'));
        final center = tester.getCenter(bar).dy;
        expect(tester.getSize(bar).height, 44);
        for (final action in ['cancel', 'stop', 'send']) {
          expect(tester.getCenter(control(action)).dy, center);
          expect(tester.getSize(control(action)), const Size(44, 44));
        }
        expect(tester.takeException(), isNull);
        await tester.tap(control('cancel'));
        await cleanup(tester);
      },
    );
  }
}
