import 'dart:io';
import 'package:apple_post_translation/apple_post_translation.dart';
import 'package:flutter/services.dart';
import 'package:foundation_models_framework/foundation_models_framework.dart';
import 'OnDeviceAiService.dart';
import 'post_html_translation.dart';

class PostTranslationService {
  static bool get usesAppleTranslation => Platform.isIOS || Platform.isMacOS;
  static Future<void> _queue = Future.value();

  static Future<List<(String, String)>> languages({String? displayLocale}) =>
      ApplePostTranslation.languages(displayLocale: displayLocale);

  static Future<String> translate(
    String html, {
    required String language,
    GuardrailLevel guardrailLevel = GuardrailLevel.standard,
    bool Function()? shouldContinue,
  }) async {
    if (!usesAppleTranslation) {
      return OnDeviceAiService.translate(
        html,
        language: language,
        guardrailLevel: guardrailLevel,
      );
    }
    try {
      final detectionText = PostHtmlTranslation.detectionText(html);
      if (detectionText.isEmpty) throw const UnchangedPostTranslation();
      final source = await ApplePostTranslation.detectLanguage(detectionText);
      return await PostHtmlTranslation.translate(html, (text) async {
        final request = _queue.then((_) {
          if (shouldContinue != null && !shouldContinue()) {
            throw const OnDeviceAiException(
              'translation_cancelled',
              'Translation cancelled.',
            );
          }
          return ApplePostTranslation.translate(text, language, source: source);
        });
        _queue = request.then<void>(
          (_) {},
          onError: (Object _, StackTrace __) {},
        );
        return request;
      });
    } on UnchangedPostTranslation {
      throw const OnDeviceAiException(
        'translation_unchanged',
        'No translation was needed.',
      );
    } on PlatformException catch (error) {
      throw OnDeviceAiException.fromPlatformException(error);
    }
  }
}
