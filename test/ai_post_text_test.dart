import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:discuz_flutter/utility/AiPostText.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';

void main() {
  test('unchanged translation ignores whitespace but detects translated content', () {
    expect(AiPostText.sameText('Hello world', 'Hello\nworld'), isTrue);
    expect(AiPostText.sameText('Hello world', '你好世界'), isFalse);
    expect(AiPostText.sameText('Hello!', 'Hello?'), isFalse);
  });
  test('HTML attributes and scripts do not enter model input', () {
    expect(
      AiPostText.plainText(
        '<p title="secret">Hello &amp; hi</p>'
        '<script>bad()</script><style>css</style><div hidden>hidden</div>'
        '<p>世界</p>',
      ),
      'Hello & hi\n世界',
    );
  });
  test('chunks preserve all text including emoji and CJK', () {
    final input = List.filled(1000, '你好😀. A\n').join();
    final chunks = AiPostText.chunks(input);
    expect(chunks.join(), input);
    expect(chunks.every((chunk) => chunk.runes.length <= 600), isTrue);
    expect(chunks.any((chunk) => chunk.contains('\uFFFD')), isFalse);
    expect(AiPostText.chunks(''), isEmpty);
  });
  test('automatic summary defaults on and remembers opting out', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await UserPreferencesUtils.getAutoSummarizeEnabled(), isTrue);
    await UserPreferencesUtils.putAutoSummarizeEnabled(false);
    expect(await UserPreferencesUtils.getAutoSummarizeEnabled(), isFalse);
  });
}
