import 'dart:async';

import 'package:discuz_flutter/utility/FoundationModelFrameworkUtils.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foundation_models_framework/foundation_models_framework.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const streamChannel = 'dev.flutter.pigeon.foundation_models_framework/stream';
  final methods = [
    'checkAvailability',
    'createSession',
    'startStream',
    'stopStream',
    'disposeSession',
  ];
  final calls = <String>[];
  late Completer<ChatStreamRequest> started;

  BasicMessageChannel<Object?> channel(
    String method,
  ) => BasicMessageChannel<Object?>(
    'dev.flutter.pigeon.foundation_models_framework.FoundationModelsApi.$method',
    FoundationModelsApi.pigeonChannelCodec,
  );

  setUp(() {
    calls.clear();
    started = Completer<ChatStreamRequest>();
    messenger.setMockMethodCallHandler(
      const MethodChannel(streamChannel),
      (_) async => null,
    );
    for (final method in methods) {
      messenger.setMockDecodedMessageHandler(channel(method), (message) async {
        calls.add(method);
        if (method == 'checkAvailability') {
          return [AvailabilityResponse(isAvailable: true, osVersion: '27.1')];
        }
        if (method == 'startStream') {
          started.complete((message as List).single as ChatStreamRequest);
        }
        return [null];
      });
    }
  });
  tearDown(() {
    for (final method in methods) {
      messenger.setMockDecodedMessageHandler(channel(method), null);
    }
    messenger.setMockMethodCallHandler(
      const MethodChannel(streamChannel),
      null,
    );
  });

  Future<void> emit(
    ChatStreamRequest request,
    String text, {
    bool finalChunk = false,
  }) => messenger.handlePlatformMessage(
    streamChannel,
    const StandardMethodCodec().encodeSuccessEnvelope({
      'streamId': request.streamId,
      'cumulative': text,
      'isFinal': finalChunk,
    }),
    (_) {},
  );

  test(
    'Apple summary delivers partial text before completion and bounds output',
    () async {
      final updates = <String>[];
      final pending = FoundationModelFrameworkUtils.generate(
        instructions: 'Summarize',
        prompt: 'Post',
        onPartial: updates.add,
        maximumResponseTokens: 512,
      );
      final request = await started.future;
      expect(request.options!.maximumResponseTokens, 512);
      await emit(request, 'First');
      await Future<void>.delayed(Duration.zero);
      expect(updates, ['First']);
      expect(calls, isNot(contains('disposeSession')));
      await emit(request, 'First answer', finalChunk: true);
      expect(await pending, 'First answer');
      expect(calls.last, 'disposeSession');
    },
  );

  test(
    'leaving a post stops its native stream and releases the model session',
    () async {
      var active = true;
      final pending = FoundationModelFrameworkUtils.generate(
        instructions: 'Summarize',
        prompt: 'Another post',
        onPartial: (_) {},
        shouldContinue: () => active,
      );
      final failure = expectLater(pending, throwsStateError);
      final request = await started.future;
      active = false;
      await emit(request, 'Stale answer');
      await failure;
      expect(calls, contains('stopStream'));
      expect(calls.last, 'disposeSession');
    },
  );
}
