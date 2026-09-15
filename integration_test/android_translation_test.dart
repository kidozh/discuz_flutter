import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:discuz_flutter/utility/post_translation_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'ML Kit translates body without Nano',
    (tester) async {
      final languages = await PostTranslationService.languages(
        displayLocale: 'zh-CN',
      );
      expect(languages.any((value) => value.$1 == 'zh'), true);
      final result = await PostTranslationService.translate(
        '<p>The weather is beautiful today. Let us take a walk in the park.</p><a href="https://example.com">Read more</a>',
        language: 'zh-CN',
      );
      expect(result, contains('href="https://example.com"'));
      expect(result, isNot(contains('The weather is beautiful today')));
    },
    skip: !Platform.isAndroid,
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
