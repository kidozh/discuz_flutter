import 'dart:convert';
import 'dart:io';

import 'package:discuz_flutter/dao/ai_conversation_dao.dart';
import 'package:discuz_flutter/entity/ai_conversation.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/ai_chat_page.dart';
import 'package:discuz_flutter/page/ai_chat_history_page.dart';
import 'package:discuz_flutter/provider/UserPreferenceNotifierProvider.dart';
import 'package:discuz_flutter/utility/OnDeviceAiService.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:provider/provider.dart';

class FailingSaveDao extends AiConversationDao {
  FailingSaveDao(super.box);
  bool failSave = true;

  @override
  Future<void> save(AiConversation conversation) async {
    if (failSave) throw StateError('Storage unavailable');
    await super.save(conversation);
  }
}

void main() {
  late Directory directory;
  late Box<String> box;
  late AiConversationDao dao;
  late HiveCipher cipher;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('ai_chat_test_');
    Hive.init(directory.path);
    cipher = HiveAesCipher(Hive.generateSecureKey());
    box = await Hive.openBox<String>('chats', encryptionCipher: cipher);
    dao = AiConversationDao(box);
  });

  tearDown(() async {
    await box.close();
    await directory.delete(recursive: true);
  });

  AiConversation conversation(String id, int day) => AiConversation(
    id: id,
    updatedAt: DateTime(2026, 10, day),
    turns: [AiChatTurn(question: 'Question $id', answer: 'Answer $id')],
  );

  test(
    'encrypted history survives reopening, updates one chat, sorts and deletes',
    () async {
      await dao.save(conversation('a', 1));
      await dao.save(conversation('b', 2));
      await box.close();
      box = await Hive.openBox<String>('chats', encryptionCipher: cipher);
      dao = AiConversationDao(box);
      expect(dao.getAll().map((chat) => chat.id), ['b', 'a']);
      expect(dao.getAll().last.turns.single.answer, 'Answer a');
      await dao.save(
        dao.getAll().last.append(
          const AiChatTurn(question: 'Follow up', answer: 'Second answer'),
        ),
      );
      expect(dao.getAll().length, 2);
      expect(dao.getAll().first.id, 'a');
      expect(dao.getAll().first.turns.length, 2);
      await dao.delete('a');
      expect(dao.getAll().single.id, 'b');
    },
  );

  test(
    'chat context keeps complete recent turns and the latest user request',
    () {
      final prompt = jsonDecode(
        OnDeviceAiService.chatPrompt([
          AiChatTurn(question: 'old', answer: List.filled(5000, '文').join()),
          const AiChatTurn(question: 'recent', answer: 'recent answer'),
        ], 'follow up'),
      ) as Map;
      expect(prompt['latestUserMessage'], 'follow up');
      expect(prompt['previousTurns'], [
        {'question': 'recent', 'answer': 'recent answer'},
      ]);
    },
  );

  test(
    'chat context budget includes JSON overhead across many short turns',
    () {
      final prompt = OnDeviceAiService.chatPrompt(
        List.generate(
          500,
          (index) => AiChatTurn(question: '$index', answer: 'OK'),
        ),
        'Follow up',
      );
      expect(prompt.runes.length, lessThanOrEqualTo(2400));
      final turns = (jsonDecode(prompt) as Map)['previousTurns'] as List;
      expect(turns.last['question'], '499');
    },
  );

  Future<void> showChat(
    WidgetTester tester,
    AiChatReply reply, {
    AiConversation? existing,
    AiConversationDao? store,
    UserPreferenceNotifierProvider? preferences,
  }) async {
    final provider =
        preferences ??
        (UserPreferenceNotifierProvider()
          ..setAppleIntelligenceAvailability(true)
          ..setAppleIntelligenceEnabled(true));
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: PlatformProvider(
          style: AppVisualStyle.material,
          builder: (_) => MaterialApp(
            localizationsDelegates: const [
              S.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            home: AiChatPage(
              dao: store ?? dao,
              conversation: existing,
              reply: reply,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> send(WidgetTester tester, String message) async {
    await tester.enterText(find.byType(TextField), message);
    await tester.pump();
    await tester.runAsync(() async {
      await tester.tap(find.byIcon(Icons.send));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
  }

  testWidgets(
    'saves replies and continues an existing conversation with context',
    (tester) async {
      final existing = conversation('a', 1);
      await tester.runAsync(() => dao.save(existing));
      await showChat(tester, (chat, question) async {
        expect(chat.turns.single.answer, 'Answer a');
        expect(question, 'Follow up');
        return 'Second answer';
      }, existing: existing);
      await send(tester, 'Follow up');
      expect(dao.getAll().single.turns.length, 2);
      expect(find.text('Second answer'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '',
      );
    },
  );

  testWidgets('failed generation keeps input and retry creates only one turn', (
    tester,
  ) async {
    var attempts = 0;
    await showChat(tester, (_, _) async {
      if (++attempts == 1) throw StateError('Model busy');
      return 'Reply';
    });
    await send(tester, 'Hello');
    expect(dao.getAll(), isEmpty);
    expect(find.text(S.current.aiChatRequestFailed), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Hello',
    );
    await send(tester, 'Hello');
    expect(dao.getAll().single.turns.length, 1);
  });

  testWidgets('storage retry reuses the generated reply', (tester) async {
    final store = FailingSaveDao(box);
    var generations = 0;
    await showChat(tester, (_, _) async {
      generations++;
      return 'Reply';
    }, store: store);
    await send(tester, 'Hello');
    expect(find.text(S.current.aiChatSaveFailed), findsOneWidget);
    store.failSave = false;
    await send(tester, 'Hello');
    expect(generations, 1);
    expect(dao.getAll().single.turns.single.answer, 'Reply');
  });

  testWidgets('history stays readable while inference is unavailable', (
    tester,
  ) async {
    await showChat(
      tester,
      (_, _) async => throw StateError('Must not generate'),
      existing: conversation('a', 1),
      preferences: UserPreferenceNotifierProvider(),
    );
    expect(find.text('Answer a'), findsOneWidget);
    expect(find.text(S.current.aiChatUnavailable), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, false);
  });

  for (final style in [AppVisualStyle.material, AppVisualStyle.cupertino]) {
    testWidgets('history opens saved chats without a model: $style', (
      tester,
    ) async {
      await tester.runAsync(() => dao.save(conversation('a', 1)));
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: UserPreferenceNotifierProvider(),
          child: PlatformProvider(
            style: style,
            builder: (_) => MaterialApp(
              localizationsDelegates: const [
                S.delegate,
                ...GlobalMaterialLocalizations.delegates,
              ],
              home: AiChatHistoryPage(loadHistory: () async => dao),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Question a'), findsOneWidget);
      await tester.tap(find.text('Question a'));
      await tester.pumpAndSettle();
      expect(find.text('Answer a'), findsOneWidget);
      expect(find.text(S.current.aiChatUnavailable), findsOneWidget);
    });
  }
}
