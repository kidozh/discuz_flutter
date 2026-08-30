import 'package:discuz_flutter/entity/PrivateMessageCache.dart';
import 'package:hive_ce/hive.dart';

class PrivateMessageCacheDao {
  final Box<PrivateMessageCache> box;

  PrivateMessageCacheDao(this.box);

  List<PrivateMessageCache> findConversation({
    required String siteKey,
    required int ownerUid,
    required int peerUid,
  }) {
    final messages = box.values
        .where(
          (entry) =>
              entry.siteKey == siteKey &&
              entry.ownerUid == ownerUid &&
              entry.peerUid == peerUid,
        )
        .toList();
    messages.sort(_compareNewestFirst);
    return messages;
  }

  Future<void> upsertMessages(List<PrivateMessageCache> messages) async {
    if (messages.isEmpty) return;
    final first = messages.first;
    final existing = <String, PrivateMessageCache>{
      for (final entry in findConversation(
        siteKey: first.siteKey,
        ownerUid: first.ownerUid,
        peerUid: first.peerUid,
      ))
        entry.stableIdentity: entry,
    };

    for (final message in messages) {
      final old = existing[message.stableIdentity];
      if (old == null) {
        await box.add(message);
      } else {
        await box.put(old.key, message);
      }
    }
    await _trimConversation(
      siteKey: first.siteKey,
      ownerUid: first.ownerUid,
      peerUid: first.peerUid,
    );
  }

  Future<void> deleteExpired({
    Duration retention = const Duration(days: 30),
  }) async {
    final cutoff = DateTime.now().subtract(retention);
    final keys = box.values
        .where((entry) => entry.cachedAt.isBefore(cutoff))
        .map((entry) => entry.key)
        .toList();
    if (keys.isNotEmpty) await box.deleteAll(keys);
  }

  Future<void> _trimConversation({
    required String siteKey,
    required int ownerUid,
    required int peerUid,
    int maximumMessages = 300,
  }) async {
    final messages = findConversation(
      siteKey: siteKey,
      ownerUid: ownerUid,
      peerUid: peerUid,
    );
    if (messages.length <= maximumMessages) return;
    await box.deleteAll(
      messages.skip(maximumMessages).map((entry) => entry.key),
    );
  }

  int _compareNewestFirst(
    PrivateMessageCache left,
    PrivateMessageCache right,
  ) {
    if (left.pmId != 0 && right.pmId != 0 && left.pmId != right.pmId) {
      return right.pmId.compareTo(left.pmId);
    }
    return right.dateTimeString.compareTo(left.dateTimeString);
  }
}
