import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:discuz_flutter/utility/post_translation_service.dart';

/// Run on a Mac: flutter test integration_test/apple_translation_macos_test.dart -d macos
/// Apple's language download prompt may need to be accepted on first use.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'native macOS translation returns Chinese and preserves the image',
    (tester) async {
      if (!Platform.isMacOS) return;
      runApp(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Testing Apple Translation: English → 中文'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final languages = await PostTranslationService.languages();
      expect(languages, isNotEmpty);
      const source =
          '<p>The weather is beautiful today. Let us go for a walk in the park.</p><img src="test.jpg">';
      final translated = await PostTranslationService.translate(
        source,
        language: 'zh-Hans',
      );
      expect(translated, contains('src="test.jpg"'));
      expect(RegExp(r'[\u4e00-\u9fff]').hasMatch(translated), isTrue);
      debugPrint('APPLE_TRANSLATION_NATIVE_RESULT: $translated');
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
