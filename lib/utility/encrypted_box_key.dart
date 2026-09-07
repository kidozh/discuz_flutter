import 'dart:convert';

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
    throw StateError(
      'Encrypted database exists but its key is unavailable. '
      'Existing data has been preserved; secure storage recovery is required.',
    );
  }
  final key = generate();
  await write(base64UrlEncode(key));
  return key;
}
