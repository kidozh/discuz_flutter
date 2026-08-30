import 'dart:io';

import 'package:discuz_flutter/dao/PrivateMessageCacheDao.dart';
import 'package:discuz_flutter/entity/PrivateMessageCache.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late Directory temporaryDirectory;
  late Box<PrivateMessageCache> box;
  late PrivateMessageCacheDao dao;

  setUpAll(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'discuz_private_message_cache_test_',
    );
    Hive.init(temporaryDirectory.path);
    Hive.registerAdapter(PrivateMessageCacheAdapter());
    box = await Hive.openBox<PrivateMessageCache>('messages');
    dao = PrivateMessageCacheDao(box);
  });

  tearDown(() async => box.clear());

  tearDownAll(() async {
    await box.close();
    await temporaryDirectory.delete(recursive: true);
  });

  PrivateMessageCache message({
    required String siteKey,
    required int ownerUid,
    required int peerUid,
    required int pmId,
    String contents = 'hello',
    DateTime? cachedAt,
  }) {
    return PrivateMessageCache(
      siteKey: siteKey,
      ownerUid: ownerUid,
      peerUid: peerUid,
      plid: pmId,
      pmId: pmId,
      toUid: peerUid,
      msgFromId: ownerUid,
      msgFromName: 'owner',
      subject: '',
      message: contents,
      dateTimeString: '2026-08-29 23:30',
      cachedAt: cachedAt ?? DateTime.now(),
    );
  }

  test('isolates conversations by site, owner, and peer', () async {
    await dao.upsertMessages([
      message(siteKey: 'https://a.example', ownerUid: 1, peerUid: 2, pmId: 1),
      message(siteKey: 'https://a.example', ownerUid: 3, peerUid: 2, pmId: 2),
      message(siteKey: 'https://b.example', ownerUid: 1, peerUid: 2, pmId: 3),
    ]);

    final conversation = dao.findConversation(
      siteKey: 'https://a.example',
      ownerUid: 1,
      peerUid: 2,
    );
    expect(conversation.map((entry) => entry.pmId), [1]);
  });

  test('upserts the same server message instead of duplicating it', () async {
    await dao.upsertMessages([
      message(siteKey: 'https://a.example', ownerUid: 1, peerUid: 2, pmId: 8),
    ]);
    await dao.upsertMessages([
      message(
        siteKey: 'https://a.example',
        ownerUid: 1,
        peerUid: 2,
        pmId: 8,
        contents: 'updated',
      ),
    ]);

    final conversation = dao.findConversation(
      siteKey: 'https://a.example',
      ownerUid: 1,
      peerUid: 2,
    );
    expect(conversation, hasLength(1));
    expect(conversation.single.message, 'updated');
  });

  test('removes messages outside the retention period', () async {
    await dao.upsertMessages([
      message(
        siteKey: 'https://a.example',
        ownerUid: 1,
        peerUid: 2,
        pmId: 10,
        cachedAt: DateTime.now().subtract(const Duration(days: 31)),
      ),
    ]);

    await dao.deleteExpired();
    expect(box.values, isEmpty);
  });
}
