import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hive_ce/hive.dart';

class MissingEncryptedBoxKey extends StateError {
  MissingEncryptedBoxKey()
    : super('The existing encrypted database has no key');
}

class UnreadableEncryptedStore implements Exception {
  const UnreadableEncryptedStore();
}

bool isUnrecoverableEncryptionError(Object error) {
  if (error is MissingEncryptedBoxKey || error is FormatException) return true;
  if (error is HiveError) {
    return error.message.contains('box may be corrupted') ||
        error.message.contains('Wrong checksum in hive file');
  }
  if (error is! PlatformException) return false;
  // A locked device or an unavailable keychain can succeed on a later read.
  if (error.code == 'Unexpected security result code') {
    return error.details == -26275; // errSecDecode
  }
  if (error.code != 'Exception encountered') return false;
  final reason = '${error.message}\n${error.details}';
  return reason.contains('KeyPermanentlyInvalidatedException') ||
      reason.contains('AEADBadTagException') ||
      reason.contains('BadPaddingException') ||
      reason.contains('Migration failed after algorithm change') ||
      reason.contains('Key mismatch after algorithm change');
}

/// A missing key is only safe to create when no encrypted database exists.
Future<List<int>> readEncryptedBoxKey({
  required Future<String?> Function() read,
  required Future<void> Function(String) write,
  required Future<bool> Function() boxExists,
  required List<int> Function() generate,
}) async {
  final stored =
      await read(); // Propagate storage errors; never reset on error.
  if (stored != null) {
    final bytes = base64Url.decode(stored);
    if (bytes.length != 32) {
      throw const FormatException('Invalid encrypted database key length');
    }
    return bytes;
  }
  if (await boxExists()) {
    throw MissingEncryptedBoxKey();
  }
  final key = generate();
  await write(base64UrlEncode(key));
  return key;
}
