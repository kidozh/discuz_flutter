import 'dart:convert';
import 'package:discuz_flutter/utility/SecureStorageUtils.dart';
import 'package:discuz_flutter/utility/encrypted_box_key.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final key = List<int>.generate(32, (index) => index);
  test('v9 password stores keep their location during the v10 migration', () {
    final legacy = SecureStorageUtils.migrationAndroidOptions(null).toMap();
    expect(legacy['encryptedSharedPreferences'], 'true');
    expect(legacy['sharedPreferencesName'], '');
    expect(legacy['migrateWithBackup'], 'false');

    final named = SecureStorageUtils.migrationAndroidOptions('passwords_1')
        .toMap();
    expect(named['encryptedSharedPreferences'], 'true');
    expect(named['sharedPreferencesName'], 'passwords_1');
    expect(named['migrateWithBackup'], 'false');

    for (final options in [legacy, named]) {
      expect(options['migrateOnAlgorithmChange'], 'true');
      expect(options['resetOnError'], 'false');
    }
    final cache = SecureStorageUtils.getFlutterSecureStorage().aOptions.toMap();
    expect(cache, legacy);
  });

  test('uses the existing key without overwriting it', () async {
    expect(
        await readEncryptedBoxKey(
          read: () async => base64UrlEncode(key),
          write: (_) async => fail('must not write'),
          boxExists: () async => true,
          generate: () => throw StateError('must not generate'),
        ),
        key);
  });
  test('a missing key with an existing database never generates a replacement',
      () async {
    await expectLater(
        readEncryptedBoxKey(
          read: () async => null,
          write: (_) async => fail('must not write'),
          boxExists: () async => true,
          generate: () => throw StateError('must not generate'),
        ),
        throwsStateError);
  });
  test('storage errors propagate without generating or writing a key',
      () async {
    await expectLater(
        readEncryptedBoxKey(
          read: () async => throw PlatformException(code: 'decrypt_failed'),
          write: (_) async => fail('must not write'),
          boxExists: () async => false,
          generate: () => throw StateError('must not generate'),
        ),
        throwsA(isA<PlatformException>()));
  });
  test('creates a key only for a new database', () async {
    String? written;
    expect(
        await readEncryptedBoxKey(
          read: () async => null,
          write: (value) async {
            written = value;
          },
          boxExists: () async => false,
          generate: () => key,
        ),
        key);
    expect(written, base64UrlEncode(key));
  });
  test('invalid key lengths are rejected without writing', () async {
    await expectLater(
        readEncryptedBoxKey(
          read: () async => base64UrlEncode([1, 2]),
          write: (_) async => fail('must not write'),
          boxExists: () async => true,
          generate: () => key,
        ),
        throwsFormatException);
  });
}
