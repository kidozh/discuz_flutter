import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apple_post_translation/apple_post_translation.dart';
import 'package:discuz_flutter/utility/post_translation_service.dart';
import 'package:discuz_flutter/utility/OnDeviceAiService.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(
    () =>
        messenger.setMockMethodCallHandler(ApplePostTranslation.channel, null),
  );
  test(
    'detects from full visible body once and reuses source for short nodes',
    () async {
      final calls = <MethodCall>[];
      messenger.setMockMethodCallHandler(ApplePostTranslation.channel, (
        call,
      ) async {
        calls.add(call);
        return call.method == 'detectLanguage' ? 'en' : '译文';
      });
      await PostTranslationService.translate(
        '<p>This is the body of a post with enough English text.</p>'
        '<a href="https://example.com">OK</a><code>代码不参与检测</code>',
        language: 'zh-Hans',
      );
      final detection = calls.where((c) => c.method == 'detectLanguage').single;
      expect(detection.arguments['text'], contains('English text.'));
      expect(detection.arguments['text'], contains('OK'));
      expect(detection.arguments['text'], isNot(contains('代码')));
      expect(detection.arguments['text'], isNot(contains('https://')));
      final translations = calls.where((c) => c.method == 'translate').toList();
      expect(translations.length, 2);
      expect(translations.every((c) => c.arguments['source'] == 'en'), isTrue);
    },
    skip: !Platform.isMacOS && !Platform.isIOS,
  );
  test(
    'reads system languages and routes only text to Apple Translation',
    () async {
      final calls = <MethodCall>[];
      messenger.setMockMethodCallHandler(ApplePostTranslation.channel, (
        call,
      ) async {
        calls.add(call);
        if (call.method == 'detectLanguage') return 'en';
        if (call.method == 'languages')
          return [
            {'id': 'fr-Latn-FR', 'name': 'Français'},
          ];
        return 'Bonjour';
      });
      expect(await PostTranslationService.languages(), [
        ('fr-Latn-FR', 'Français'),
      ]);
      final output = await PostTranslationService.translate(
        '<p>Hello<img src="a.jpg"></p>',
        language: 'fr',
      );
      expect(output, contains('Bonjour'));
      expect(output, contains('src="a.jpg"'));
      expect(calls.last.arguments, {
        'text': 'Hello',
        'target': 'fr',
        'source': 'en',
      });
    },
    skip: !Platform.isMacOS && !Platform.isIOS,
  );
  test('simulator error is surfaced and subsequent requests recover', () async {
    messenger.setMockMethodCallHandler(ApplePostTranslation.channel, (_) async {
      throw PlatformException(code: 'translation_simulator');
    });
    await expectLater(
      PostTranslationService.translate('Hello', language: 'fr'),
      throwsA(
        isA<OnDeviceAiException>().having(
          (e) => e.code,
          'code',
          'translation_simulator',
        ),
      ),
    );
    messenger.setMockMethodCallHandler(
      ApplePostTranslation.channel,
      (call) async => call.method == 'detectLanguage' ? 'en' : 'Bonjour',
    );
    expect(
      await PostTranslationService.translate('Hello', language: 'fr'),
      'Bonjour',
    );
  }, skip: !Platform.isMacOS && !Platform.isIOS);
}
