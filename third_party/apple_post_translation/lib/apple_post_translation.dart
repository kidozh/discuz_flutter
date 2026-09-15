import 'package:flutter/services.dart';

class ApplePostTranslation {
  static const channel = MethodChannel('com.kidozh.discuz_flutter/translation');

  static Future<List<(String, String)>> languages(
      {String? displayLocale}) async {
    final values = await channel.invokeListMethod<dynamic>(
            'languages', {'displayLocale': displayLocale}) ??
        [];
    return values
        .map((value) => (value['id'] as String, value['name'] as String))
        .toList();
  }

  static Future<String> detectLanguage(String text) async {
    final source =
        await channel.invokeMethod<String>('detectLanguage', {'text': text});
    if (source == null || source.isEmpty) {
      throw PlatformException(code: 'translation_source_undetected');
    }
    return source;
  }

  static Future<String> translate(String text, String target,
      {required String source}) async {
    final result = await channel.invokeMethod<String>('translate', {
      'text': text,
      'target': target,
      'source': source,
    });
    if (result == null || result.trim().isEmpty) {
      throw PlatformException(code: 'empty_translation');
    }
    return result;
  }
}
