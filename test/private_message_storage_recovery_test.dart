import 'dart:convert';
import 'dart:io';

import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/PrivateMessageCache.dart';
import 'package:discuz_flutter/utility/SecureStorageUtils.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const originalName = 'discuz_flutter_private_message_cache_v2';
  const keyName = SecureStorageUtils.private_message_cache_storage_key;
  final originalKey = List<int>.generate(32, (index) => index);
  late Directory directory;

  PrivateMessageCache message(String text) => PrivateMessageCache(
    siteKey: 'https://example.test/',
    ownerUid: 1,
    peerUid: 2,
    plid: 1,
    pmId: 2,
    toUid: 1,
    msgFromId: 2,
    msgFromName: 'Tester',
    subject: 'Test subject',
    message: text,
    dateTimeString: '',
    cachedAt: DateTime.now(),
  );

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('disfly-private-cache-');
    Hive.init(directory.path);
    if (!Hive.isAdapterRegistered(PrivateMessageCacheAdapter().typeId)) {
      Hive.registerAdapter(PrivateMessageCacheAdapter());
    }
    SharedPreferences.setMockInitialValues({});
    final original = await Hive.openBox<PrivateMessageCache>(
      originalName,
      encryptionCipher: HiveAesCipher(originalKey),
    );
    await original.add(message('original'));
    await original.close();
  });

  tearDown(() async {
    AppDatabase.privateMessageCacheBox = null;
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test('opens an existing cache when the key is still readable', () async {
    FlutterSecureStorage.setMockInitialValues({
      keyName: base64UrlEncode(originalKey),
    });
    final dao = await AppDatabase.getPrivateMessageCacheDao();
    expect(dao.box.name, originalName);
    expect(dao.box.values.single.message, 'original');
    expect(await AppDatabase.pendingPrivateMessageRecoveryNotice(), isNull);
  });

  for (final badKey in [
    null,
    'invalid',
    base64UrlEncode(List<int>.filled(32, 255)),
  ]) {
    test(
      'recovers an unreadable cache once and preserves the original ($badKey)',
      () async {
        FlutterSecureStorage.setMockInitialValues({
          if (badKey != null) keyName: badKey,
        });
        final file = File('${directory.path}/$originalName.hive');
        final originalBytes = await file.readAsBytes();
        final results = await Future.wait([
          AppDatabase.getPrivateMessageCacheDao(),
          AppDatabase.getPrivateMessageCacheDao(),
        ]);
        final replacement = results.first.box;
        expect(results.last.box, same(replacement));
        expect(replacement.name, isNot(originalName));
        expect(replacement.isEmpty, isTrue);
        expect(await file.readAsBytes(), originalBytes);
        expect(await const FlutterSecureStorage().read(key: keyName), badKey);

        final notice = await AppDatabase.pendingPrivateMessageRecoveryNotice();
        expect(notice, isNotNull);
        await replacement.put('latest', message('replacement'));
        await replacement.close();
        final reopened = (await AppDatabase.getPrivateMessageCacheDao()).box;
        expect(reopened.name, replacement.name);
        expect(reopened.get('latest')?.message, 'replacement');
        expect(await AppDatabase.pendingPrivateMessageRecoveryNotice(), notice);
        await AppDatabase.acknowledgePrivateMessageRecovery(notice!);
        expect(await AppDatabase.pendingPrivateMessageRecoveryNotice(), isNull);
      },
    );
  }
}
