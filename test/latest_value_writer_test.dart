import 'dart:async';

import 'package:discuz_flutter/utility/latest_value_writer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('continuous updates checkpoint the latest value every interval',
      (tester) async {
    final values = <int>[];
    final writer = LatestValueWriter<int>(
        write: (value) async => values.add(value), onError: (_, __) {});
    for (var i = 0; i < 30; i++) {
      writer.schedule(i);
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(values, isEmpty);
    await tester.pump(const Duration(milliseconds: 20));
    expect(values, [29]);
    for (var i = 30; i < 60; i++) {
      writer.schedule(i);
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pump(const Duration(milliseconds: 20));
    expect(values, [29, 59]);
    await writer.close();
  });

  testWidgets('idle flush saves immediately without a duplicate timer write',
      (tester) async {
    final values = <int>[];
    final writer = LatestValueWriter<int>(
        write: (value) async => values.add(value), onError: (_, __) {});
    writer.schedule(1);
    writer.schedule(2);
    await writer.flush();
    expect(values, [2]);
    await tester.pump(const Duration(seconds: 1));
    expect(values, [2]);
    await writer.close();
  });

  testWidgets('close flushes the last value and ignores late notifications',
      (tester) async {
    final values = <int>[];
    final writer = LatestValueWriter<int>(
        write: (value) async => values.add(value), onError: (_, __) {});
    writer.schedule(7);
    await writer.close();
    writer.schedule(8);
    await tester.pump(const Duration(seconds: 1));
    expect(values, [7]);
  });

  testWidgets('slow writes are serialized and flush awaits the latest value',
      (tester) async {
    final gate = Completer<void>();
    final values = <int>[];
    final writer = LatestValueWriter<int>(
        write: (value) async {
          values.add(value);
          if (value == 1) await gate.future;
        },
        onError: (_, __) {});
    writer.schedule(1);
    final first = writer.flush();
    writer.schedule(2);
    writer.schedule(3);
    final last = writer.close();
    expect(values, [1]);
    gate.complete();
    await first;
    await last;
    expect(values, [1, 3]);
    await tester.pump(const Duration(seconds: 1));
    expect(values, [1, 3]);
  });

  testWidgets('a failed write is reported and does not block later values',
      (tester) async {
    final values = <int>[];
    final errors = <Object>[];
    final writer = LatestValueWriter<int>(
        write: (value) async {
          if (value == 1) throw StateError('write failed');
          values.add(value);
        },
        onError: (error, _) => errors.add(error));
    writer.schedule(1);
    await writer.flush();
    writer.schedule(2);
    await writer.close();
    expect(errors, hasLength(1));
    expect(values, [2]);
  });

  testWidgets('flush is an ordering barrier before a cache clear',
      (tester) async {
    final actions = <String>[];
    final writer = LatestValueWriter<String>(
        write: (value) async => actions.add(value), onError: (_, __) {});
    writer.schedule('old-position');
    await writer.flush();
    actions.add('clear');
    await tester.pump(const Duration(seconds: 1));
    expect(actions, ['old-position', 'clear']);
    await writer.close();
  });
}
