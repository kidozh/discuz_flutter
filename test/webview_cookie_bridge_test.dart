import 'dart:io';

import 'package:discuz_flutter/utility/DiscuzWebviewCookieManager.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.kidozh.discuz_flutter/webview_cookies');
  const manager = DiscuzWebviewCookieManager();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test(
    'reading preserves encoded auth, HttpOnly, Secure and expiration',
    () async {
      final expiry = DateTime.utc(2030, 1, 1);
      messenger.setMockMethodCallHandler(channel, (call) async {
        expect(call.method, 'getCookies');
        expect(call.arguments, {'url': 'https://forum.test/forum/thread.php'});
        return [
          {
            'name': 'discuz_auth',
            'value': 'encoded%3Dauth==',
            'domain': '.forum.test',
            'path': '/forum',
            'httpOnly': true,
            'secure': true,
            'expiresAt': expiry.millisecondsSinceEpoch,
          },
          {'name': 'invalid;name', 'value': 'ignored'},
          {'name': 'session', 'value': 'a=b=c'},
        ];
      });
      final cookies = await manager.getCookies(
        'https://forum.test/forum/thread.php',
      );
      expect(cookies.map((cookie) => cookie.name), ['discuz_auth', 'session']);
      final auth = cookies.first;
      expect(auth.value, 'encoded%3Dauth==');
      expect(auth.domain, '.forum.test');
      expect(auth.path, '/forum');
      expect(auth.httpOnly, isTrue);
      expect(auth.secure, isTrue);
      expect(auth.expires, expiry);
      expect(cookies.last.value, 'a=b=c');
      expect(cookies.last.domain, isNull);
      expect(cookies.last.expires, isNull);
    },
  );

  test(
    'writing keeps full Set-Cookie attributes instead of a four-field DTO',
    () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        expect(call.method, 'setCookies');
        final args = call.arguments as Map;
        expect(args['url'], 'https://forum.test/');
        final header = (args['cookies'] as List).single as String;
        expect(header, startsWith('discuz_auth=encoded=='));
        expect(header.toLowerCase(), contains('httponly'));
        expect(header.toLowerCase(), contains('secure'));
        expect(header.toLowerCase(), contains('expires='));
        expect(header.toLowerCase(), contains('path=/forum'));
        return null;
      });
      await manager.setCookies([
        Cookie('discuz_auth', 'encoded==')
          ..path = '/forum'
          ..domain = 'forum.test'
          ..secure = true
          ..httpOnly = true
          ..expires = DateTime.utc(2030, 1, 1),
      ], origin: 'https://forum.test/');
    },
  );

  test(
    'empty stores and clearing complete without a WebView controller',
    () async {
      final methods = <String>[];
      messenger.setMockMethodCallHandler(channel, (call) async {
        methods.add(call.method);
        return call.method == 'getCookies' ? <Object>[] : null;
      });
      expect(await manager.getCookies('https://forum.test'), isEmpty);
      await manager.clearCookies();
      expect(methods, ['getCookies', 'clearCookies']);
    },
  );

  test('non-HTTP origins never reach the native store', () async {
    messenger.setMockMethodCallHandler(
      channel,
      (_) async => fail('Unexpected native call'),
    );
    await expectLater(
      manager.getCookies('file:///private/data'),
      throwsArgumentError,
    );
    expect(
      () => manager.setCookies([], origin: 'javascript:alert(1)'),
      throwsArgumentError,
    );
  });
}
