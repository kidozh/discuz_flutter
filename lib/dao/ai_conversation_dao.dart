import 'dart:convert';

import 'package:hive_ce/hive.dart';

import '../entity/ai_conversation.dart';
import '../utility/SecureStorageUtils.dart';
import '../utility/encrypted_box_key.dart';

class AiConversationDao {
  AiConversationDao(this.box);

  final Box<String> box;
  static Future<AiConversationDao>? _opening;
  static const _boxName = 'discuz_flutter_ai_conversations_v1';

  static Future<AiConversationDao> open() async {
    if (Hive.isBoxOpen(_boxName)) {
      return AiConversationDao(Hive.box<String>(_boxName));
    }
    final pending = _opening;
    if (pending != null) return pending;
    final opening = _open();
    _opening = opening;
    try {
      return await opening;
    } finally {
      _opening = null;
    }
  }

  static Future<AiConversationDao> _open() async {
    final storage = SecureStorageUtils.getFlutterSecureStorage();
    const keyName = 'ai_conversations_storage_key';
    final key = await readEncryptedBoxKey(
      read: () => storage.read(key: keyName),
      write: (value) => storage.write(key: keyName, value: value),
      boxExists: () => Hive.boxExists(_boxName),
      generate: Hive.generateSecureKey,
    );
    return AiConversationDao(
      await Hive.openBox<String>(
        _boxName,
        encryptionCipher: HiveAesCipher(key),
        crashRecovery: false,
      ),
    );
  }

  List<AiConversation> getAll() {
    final conversations = box.values
        .map((value) => AiConversation.fromJson(jsonDecode(value)))
        .toList();
    conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return conversations;
  }

  Future<void> save(AiConversation conversation) =>
      box.put(conversation.id, jsonEncode(conversation.toJson()));

  Future<void> delete(String id) => box.delete(id);
}
