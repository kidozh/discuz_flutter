import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/UserPreferenceNotifierProvider.dart';
import 'package:discuz_flutter/utility/OnDeviceAiService.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/widget/PostSummaryWidget.dart';
import 'package:discuz_flutter/widget/post_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foundation_models_framework/foundation_models_framework.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const streamChannel = 'dev.flutter.pigeon.foundation_models_framework/stream';
  const methods = [
    'checkAvailability',
    'createSession',
    'startStream',
    'stopStream',
    'disposeSession',
  ];
  final requests = <ChatStreamRequest>[];
  late UserPreferenceNotifierProvider preferences;

  BasicMessageChannel<Object?> channel(
    String method,
  ) => BasicMessageChannel<Object?>(
    'dev.flutter.pigeon.foundation_models_framework.FoundationModelsApi.$method',
    FoundationModelsApi.pigeonChannelCodec,
  );

  setUp(() {
    requests.clear();
    preferences = UserPreferenceNotifierProvider()
      ..setAppleIntelligenceAvailability(true)
      ..setAppleIntelligenceEnabled(true);
    messenger.setMockMethodCallHandler(
      const MethodChannel(streamChannel),
      (_) async => null,
    );
    for (final method in methods) {
      messenger.setMockDecodedMessageHandler(channel(method), (message) async {
        if (method == 'checkAvailability') {
          return [AvailabilityResponse(isAvailable: true, osVersion: '27.1')];
        }
        if (method == 'startStream') {
          final request = (message as List).single as ChatStreamRequest;
          requests.add(request);
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
    preferences.dispose();
  });

  void emit(ChatStreamRequest request, String text, {bool done = false}) {
    messenger.handlePlatformMessage(
      streamChannel,
      const StandardMethodCodec().encodeSuccessEnvelope({
        'streamId': request.streamId,
        'cumulative': text,
        'isFinal': done,
      }),
      null,
    );
  }

  Future<ChatStreamRequest> nextRequest(
    WidgetTester tester, {
    int count = 1,
  }) async {
    for (var frame = 0; frame < 20 && requests.length < count; frame++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(const Duration(milliseconds: 10));
    }
    expect(
      requests.length,
      count,
      reason: tester
          .widgetList<Text>(find.byType(Text))
          .map((w) => w.data)
          .join('|'),
    );
    return requests.last;
  }

  Future<void> flushModelMessages(WidgetTester tester) async {
    // Native stream delivery and the widget binding use different async zones.
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump();
    }
  }

  Widget host(String html, {bool visible = true}) =>
      ChangeNotifierProvider.value(
        value: preferences,
        child: PlatformProvider(
          style: AppVisualStyle.material,
          builder: (_) => MaterialApp(
            locale: const Locale('zh', 'CN'),
            supportedLocales: S.delegate.supportedLocales,
            localizationsDelegates: const [
              S.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            home: Scaffold(
              body: SingleChildScrollView(
                child: SizedBox(
                  width: 300,
                  child: TickerMode(
                    enabled: visible,
                    child: PostSummaryWidget(html: html),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  testWidgets(
    'summaries stream in place and retain completed answers when hidden',
    (tester) async {
      final html = '<p>${List.filled(110, 'some facts ').join()}</p>';
      await tester.pumpWidget(host(html));
      await tester.pump();
      final request = await nextRequest(tester);
      for (final draft in ['这', '这是一', '这是一份未完成的总结']) {
        emit(request, draft);
        await flushModelMessages(tester);
        expect(find.text(draft, findRichText: true), findsOneWidget);
        expect(find.text('正在总结…'), findsNothing);
        expect(find.text('AI 生成可能有误，请以原文为准。'), findsNothing);
      }
      const answer = '这是一份完整总结。';
      emit(request, answer, done: true);
      await flushModelMessages(tester);
      await tester.pumpAndSettle();
      expect(find.text(answer), findsOneWidget);
      expect(find.text('正在总结…'), findsNothing);
      expect(
        tester.widget<PostSummaryCard>(find.byType(PostSummaryCard)).active,
        isFalse,
      );
      final disclaimer = tester.widget<Text>(find.text('AI 生成可能有误，请以原文为准。'));
      expect(disclaimer.maxLines, 1);

      preferences.adExemptHost = 'example.com';
      await tester.pump();
      await tester.pumpWidget(host(html, visible: false));
      expect(find.text(answer), findsNothing);
      await tester.pumpWidget(host(html));
      // Check the very first visible frame, before any completed Future could
      // subscribe again and replace a transient loading placeholder.
      expect(find.text(answer), findsOneWidget);
      expect(find.text('正在总结…'), findsNothing);
      expect(requests, hasLength(1));
      expect(tester.takeException(), isNull);

      // The same reader switches to a long post requiring two model passages.
      final longPost = '<p>${List.filled(2000, '文').join()}</p>';
      await tester.pumpWidget(host(longPost));
      await tester.pump();
      final first = await nextRequest(tester, count: 2);
      const firstDraft = '第一段草稿包含了前半篇帖子的主要内容和若干细节，等待后续内容一起归纳。';
      emit(first, firstDraft, done: true);
      await flushModelMessages(tester);
      final second = await nextRequest(tester, count: 3);
      expect(find.text(firstDraft, findRichText: true), findsOneWidget);
      final draftHeight = tester.getSize(find.byType(PostSummaryCard)).height;
      emit(second, '新');
      await flushModelMessages(tester);
      expect(
        find.text(
          '新${firstDraft.characters.skip(1).join()}',
          findRichText: true,
        ),
        findsOneWidget,
      );
      expect(
        tester.getSize(find.byType(PostSummaryCard)).height,
        greaterThanOrEqualTo(draftHeight),
      );
      expect(find.text('正在总结…'), findsNothing);
      emit(second, '新的合并总结');
      await flushModelMessages(tester);
      expect(
        find.text(
          '新的合并总结${firstDraft.characters.skip(6).join()}',
          findRichText: true,
        ),
        findsOneWidget,
      );
      expect(
        tester.getSize(find.byType(PostSummaryCard)).height,
        greaterThanOrEqualTo(draftHeight),
      );
      emit(second, '涵盖整篇长帖的最终总结。', done: true);
      await flushModelMessages(tester);
      await tester.pumpAndSettle();
      expect(find.text('涵盖整篇长帖的最终总结。'), findsOneWidget);
      expect(find.text('正在总结…'), findsNothing);
      expect(requests, hasLength(3));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
    skip: !OnDeviceAiService.isApplePlatform,
  );
}
