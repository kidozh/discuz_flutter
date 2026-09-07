import 'package:discuz_flutter/utility/steam_store_link.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('store and embed URLs share app ID parsing', () {
    for (final url in [
      'https://store.steampowered.com/app/123/Some_Title/',
      'https://store.steampowered.com/widget/123/',
      '//store.steampowered.com/widget/123/?l=schinese',
      'http://store.steampowered.com/app/123?snr=456',
    ]) {
      expect(steamAppId(url), '123');
    }
  });
  test('does not confuse package IDs or other hosts with apps', () {
    for (final url in [
      null,
      '',
      'https://store.steampowered.com/sub/123/',
      'https://store.steampowered.com/bundle/123/',
      'https://store.steampowered.com/app/',
      'https://store.steampowered.com/app/0/',
      'https://store.steampowered.com/app/no-id/?id=123',
      'https://store.steampowered.com.example.com/app/123/',
    ]) {
      expect(steamAppId(url), isNull);
    }
  });
}
