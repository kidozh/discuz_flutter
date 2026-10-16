import 'dart:io';

import 'package:apple_post_translation/apple_post_translation.dart';
import 'package:flutter/services.dart';
import 'package:foundation_models_framework/foundation_models_framework.dart';

import 'OnDeviceAiService.dart';
import 'post_html_translation.dart';

class PostTranslationService {
  static bool get usesGoogleTranslation => Platform.isAndroid;
  static bool get usesAppleTranslation => Platform.isIOS || Platform.isMacOS;
  static bool get usesNativeTranslation =>
      usesAppleTranslation || Platform.isAndroid;
  static Future<bool> isForeignPost(
    String html, {
    required String language,
    bool Function()? shouldContinue,
  }) async {
    final text = PostHtmlTranslation.detectionText(html);
    final parts = text
        .split('\n')
        .where((part) => RegExp(r'\p{L}', unicode: true).hasMatch(part))
        .toList();
    if (parts.isEmpty) return false;
    final local = language.replaceAll('_', '-').split('-').first.toLowerCase();
    for (final part in parts) {
      if (shouldContinue != null && !shouldContinue()) return false;
      String detected;
      try {
        detected = await ApplePostTranslation.detectLanguage(part);
      } on PlatformException catch (error) {
        if (error.code == 'translation_source_undetected') return false;
        rethrow;
      }
      if (detected == 'und' || detected.split('-').first.toLowerCase() == local)
        return false;
    }
    return true;
  }

  static Future<void> _queue = Future.value();

  static Future<List<(String, String)>> languages({String? displayLocale}) =>
      ApplePostTranslation.languages(displayLocale: displayLocale);

  static Future<String> translate(
    String html, {
    required String language,
    GuardrailLevel guardrailLevel = GuardrailLevel.standard,
    bool Function()? shouldContinue,
  }) async {
    if (!usesNativeTranslation) {
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
      final sources = <String, String>{detectionText: source};
      Future<String> translateText(String text, String context) async {
        var blockSource = sources[context] ?? source;
        if (!sources.containsKey(context)) {
          // Short labels lack enough evidence; use the full body's language.
          if (RegExp(r'\p{L}', unicode: true).allMatches(context).length >= 8) {
            try {
              final detected = await ApplePostTranslation.detectLanguage(
                context,
              );
              if (detected != 'und') blockSource = detected;
            } on PlatformException catch (error) {
              if (error.code != 'translation_source_undetected') rethrow;
            }
          }
          sources[context] = blockSource;
        }
        final request = _queue.then((_) {
          if (shouldContinue != null && !shouldContinue()) {
            throw const OnDeviceAiException(
              'translation_cancelled',
              'Translation cancelled.',
            );
          }
          return ApplePostTranslation.translate(
            text,
            language,
            source: blockSource,
          );
        });
        _queue = request.then<void>(
          (_) {},
          onError: (Object _, StackTrace __) {},
        );
        return request;
      }

      return await PostHtmlTranslation.translate(
        html,
        (text) => translateText(text, detectionText),
        translateTextWithContext: translateText,
      );
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
