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

  static Future<String> translate(String text, String target) async {
    final result = await channel.invokeMethod<String>('translate', {
      'text': text,
      'target': target,
    });
    if (result == null || result.trim().isEmpty) {
      throw PlatformException(code: 'empty_translation');
    }
    return result;
  }
}
