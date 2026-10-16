import 'dart:async';

import 'package:discuz_flutter/utility/post_summary_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foundation_models_framework/foundation_models_framework.dart';

class FakeSummaryModel {
  final passages = <String>[];
  final successfulPassages = <String>[];
  Completer<String>? response;
  void Function(String)? update;
  void Function()? onGenerate;
  int? contextLimit;
  bool fail = false;

  Future<String> generate({
    required String instructions,
    required String prompt,
    required GuardrailLevel guardrailLevel,
    required void Function(String) onPartial,
    required bool Function() shouldContinue,
  }) async {
    final passage = prompt.split('Next passage:\n').last;
    passages.add(passage);
    update = onPartial;
    if (fail) throw StateError('Model unavailable');
    if (contextLimit != null && passage.runes.length > contextLimit!) {
      throw PlatformException(code: 'contextSizeExceeded');
    }
    successfulPassages.add(passage);
    onGenerate?.call();
    return response == null ? 'A useful summary.' : await response!.future;
  }
}

void main() {
  test('ordinary long Latin text uses one model request instead of 1200-character passes', () async {
    final model = FakeSummaryModel();
    final service = PostSummaryService(generate: model.generate);
    final text = List.filled(1000, 'facts ').join();
    await service.summarize(text, language: 'en');
    expect(model.passages, [text]);
  });

  test(
    'CJK and emoji passages retain all source text within the input budget',
    () async {
      final model = FakeSummaryModel();
      final service = PostSummaryService(generate: model.generate);
      final text = List.filled(1000, '中文😀。').join();
      await service.summarize(text, language: 'zh-CN');
      expect(model.passages.length, greaterThan(1));
      expect(model.passages.join(), text);
      expect(model.passages.any((part) => part.contains('\uFFFD')), isFalse);
    },
  );

  test('completed summaries are cached by text, language and policy', () async {
    final model = FakeSummaryModel();
    final service = PostSummaryService(generate: model.generate);
    await service.summarize('post', language: 'zh-CN');
    await service.summarize('post', language: 'zh-CN');
    expect(model.passages.length, 1);
    await service.summarize('post', language: 'en');
    await service.summarize('edited post', language: 'en');
    await service.summarize(
      'post',
      language: 'en',
      guardrailLevel: GuardrailLevel.strict,
    );
    expect(model.passages.length, 4);
  });

  test('duplicate requests share inference and stream to the remaining active reader', () async {
    final model = FakeSummaryModel()..response = Completer<String>();
    final service = PostSummaryService(generate: model.generate);
    var firstActive = true;
    final firstUpdates = <String>[];
    final secondUpdates = <String>[];
    final first = service.summarize(
      'post',
      language: 'zh-CN',
      shouldContinue: () => firstActive,
      onPartial: firstUpdates.add,
    );
    final second = service.summarize(
      'post',
      language: 'zh-CN',
      onPartial: secondUpdates.add,
    );
    firstActive = false;
    model.update!('Partial answer');
    expect(firstUpdates, isEmpty);
    expect(secondUpdates, ['Partial answer']);
    expect(model.passages.length, 1);
    model.response!.complete('Complete answer');
    expect(await first, 'Complete answer');
    expect(await second, 'Complete answer');
  });

  test('leaving a post cancels remaining passages and does not cache incomplete work', () async {
    final model = FakeSummaryModel();
    var active = true;
    model.onGenerate = () => active = false;
    final service = PostSummaryService(generate: model.generate);
    final text = List.filled(3000, '文').join();
    await expectLater(
      service.summarize(text, language: 'zh-CN', shouldContinue: () => active),
      throwsStateError,
    );
    expect(model.passages.length, 1);
    model.onGenerate = null;
    await service.summarize(text, language: 'zh-CN');
    expect(model.passages.length, greaterThan(1));
  });

  test(
    'native context overflow retries smaller passages without losing text',
    () async {
      final model = FakeSummaryModel()..contextLimit = 1000;
      final service = PostSummaryService(generate: model.generate);
      final text = List.filled(1400, '文').join();
      expect(await service.summarize(text, language: 'zh-CN'), isNotEmpty);
      expect(model.passages.length, 3);
      expect(model.successfulPassages.join(), text);
    },
  );

  test('failures are not cached or retried as context errors', () async {
    final model = FakeSummaryModel()..fail = true;
    final service = PostSummaryService(generate: model.generate);
    await expectLater(
      service.summarize('post', language: 'en'),
      throwsStateError,
    );
    expect(model.passages.length, 1);
    model.fail = false;
    await service.summarize('post', language: 'en');
    expect(model.passages.length, 2);
  });

  test('cache evicts the least recently used summary', () async {
    final model = FakeSummaryModel();
    final service = PostSummaryService(generate: model.generate, cacheSize: 2);
    for (final text in ['a', 'b', 'a', 'c', 'a']) {
      await service.summarize(text, language: 'en');
    }
    expect(model.passages, ['a', 'b', 'c']);
    await service.summarize('b', language: 'en');
    expect(model.passages, ['a', 'b', 'c', 'b']);
  });
}
