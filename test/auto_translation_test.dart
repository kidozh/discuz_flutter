import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apple_post_translation/apple_post_translation.dart';
import 'package:discuz_flutter/utility/post_translation_service.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/utility/AiPostText.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(
    () =>
        messenger.setMockMethodCallHandler(ApplePostTranslation.channel, null),
  );
  test('automatic translation defaults on and remembers opting out', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await UserPreferencesUtils.getAutoTranslateEnabled(), true);
    await UserPreferencesUtils.putAutoTranslateEnabled(false);
    expect(await UserPreferencesUtils.getAutoTranslateEnabled(), false);
  });
  test(
    'foreign-only text translates but local and mixed posts do not',
    () async {
      messenger.setMockMethodCallHandler(ApplePostTranslation.channel, (
        call,
      ) async {
        expect(call.method, 'detectLanguage');
        return (call.arguments['text'] as String).contains('你好')
            ? 'zh-Hans'
            : 'en';
      });
      expect(
        await PostTranslationService.isForeignPost(
          '<p>Hello world</p>',
          language: 'zh-CN',
        ),
        true,
      );
      expect(
        await PostTranslationService.isForeignPost(
          '<p>你好世界</p>',
          language: 'zh-TW',
        ),
        false,
      );
      expect(
        await PostTranslationService.isForeignPost(
          '<p>Hello</p><p>你好</p>',
          language: 'zh-Hans',
        ),
        false,
      );
      expect(
        await PostTranslationService.isForeignPost(
          '<img src="https://example.com">',
          language: 'zh',
        ),
        false,
      );
      expect(
        await PostTranslationService.isForeignPost(
          '<p>Hello</p>',
          language: 'zh',
          shouldContinue: () => false,
        ),
        false,
      );
    },
  );
  test('larger summary chunks reduce calls without discarding text', () {
    final text = List.filled(3600, '文').join();
    final chunks = AiPostText.chunks(text, limit: 1200);
    expect(chunks.length, 3);
    expect(chunks.join(), text);
  });
}
