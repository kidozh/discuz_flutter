import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/utility/DiscuzCookieSessionManager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory temporaryDirectory;
  late DiscuzCookieSessionManager manager;

  setUp(() async {
    temporaryDirectory =
        await Directory.systemTemp.createTemp('discuz_cookie_sessions_');
    manager = DiscuzCookieSessionManager(
      documentsDirectoryProvider: () async => temporaryDirectory,
    );
  });

  tearDown(() async {
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('reuses one persistent jar for concurrent requests of an account',
      () async {
    final user = _user('https://Example.com/', 42);

    final jars = await Future.wait(
      List.generate(8, (_) => manager.getJar(user)),
    );

    expect(jars.every((jar) => identical(jar, jars.first)), isTrue);
    expect(
      manager.sessionKeyFor(user),
      manager.sessionKeyFor(_user('https://example.com', 42)),
    );
  });

  test('migrates valid cookies from the legacy ignore-expires store', () async {
    final user = _user('https://example.com', 7);
    final origin = Uri.parse(user.discuz.baseURL);
    final legacyPath =
        '${temporaryDirectory.path}/v_cookie_${user.discuz.baseURL}_${user.uid}';
    final legacyJar = PersistCookieJar(
      storage: FileStorage(legacyPath),
      ignoreExpires: true,
    );
    await legacyJar.saveFromResponse(origin, [
      Cookie('auth', 'valid-session')..path = '/',
      Cookie('expired', 'old-session')
        ..path = '/'
        ..expires = DateTime.now().subtract(const Duration(days: 1)),
    ]);

    final jar = await manager.getJar(user);
    final cookies = await jar.loadForRequest(origin);

    expect(cookies.map((cookie) => cookie.name), contains('auth'));
    expect(cookies.map((cookie) => cookie.name), isNot(contains('expired')));
  });

  test('relogin replaces stale cookies and account deletion clears them',
      () async {
    final user = _user('https://example.com', 9);
    final origin = Uri.parse(user.discuz.baseURL);
    final jar = await manager.getJar(user);
    await jar.saveFromResponse(origin, [Cookie('stale', 'value')..path = '/']);

    await manager.replaceCookies(
      user,
      origin,
      [Cookie('auth', 'fresh-session')..path = '/'],
    );
    final replaced = await jar.loadForRequest(origin);
    expect(replaced.map((cookie) => cookie.name), contains('auth'));
    expect(replaced.map((cookie) => cookie.name), isNot(contains('stale')));

    await manager.clear(user);
    final reopened = await manager.getJar(user);
    expect(await reopened.loadForRequest(origin), isEmpty);
  });

  test('resets malformed persisted cookie data instead of throwing', () async {
    final user = _user('https://example.com', 11);
    final origin = Uri.parse(user.discuz.baseURL);
    final storagePath =
        '${temporaryDirectory.path}/v_cookie_${user.discuz.baseURL}_${user.uid}';
    final jar = PersistCookieJar(
      storage: FileStorage(storagePath),
      ignoreExpires: false,
    );
    await jar.saveFromResponse(
      origin,
      [Cookie('auth', 'session')..path = '/'],
    );
    await File('$storagePath/ie0_ps1/example.com')
        .writeAsString('not valid cookie json');

    final recoveredJar = await manager.getJar(user);

    expect(await recoveredJar.loadForRequest(origin), isEmpty);
  });
}

User _user(String baseUrl, int uid) {
  final discuz = Discuz(
    baseUrl,
    'X3.5',
    'utf-8',
    4,
    '',
    '',
    false,
    '0',
    '0',
    'Test Forum',
    '',
    '',
    '2',
    trueDiscuzVersion: 'X3.5',
  );
  return User('', '', 'tester', '', 10, uid, 10, discuz);
}
