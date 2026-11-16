import 'dart:convert';
import 'dart:typed_data';

/// Returns the embedded ISO media file from a JPEG Motion Photo or null.
Uint8List? motionPhotoVideo(Uint8List bytes) {
  if (bytes.length < 16 || bytes[0] != 0xff || bytes[1] != 0xd8) return null;
  final data = ByteData.sublistView(bytes);
  final offsets = <int>{};
  var cursor = 2;
  while (cursor + 4 <= bytes.length && bytes[cursor] == 0xff) {
    final marker = bytes[cursor + 1];
    if (marker == 0xff) {
      cursor++;
      continue;
    }
    if (marker == 0xda || marker == 0xd9) break;
    final length = data.getUint16(cursor + 2);
    final end = cursor + 2 + length;
    if (length < 2 || end > bytes.length) break;
    if (marker == 0xe1) {
      final xmp = utf8.decode(
        Uint8List.sublistView(bytes, cursor + 4, end),
        allowMalformed: true,
      );
      final legacy = RegExp(r'''\bMicroVideoOffset\s*=\s*["'](\d+)["']''')
          .firstMatch(xmp);
      if (legacy != null) {
        final offset = int.tryParse(legacy[1]!);
        if (offset != null) offsets.add(bytes.length - offset);
      }
      for (final tag in RegExp(r'<[^<>]+>').allMatches(xmp)) {
        final item = tag[0]!;
        if (!RegExp(r'''\bSemantic\s*=\s*["']MotionPhoto["']''').hasMatch(item))
          continue;
        final size = RegExp(r'''\bLength\s*=\s*["'](\d+)["']''')
            .firstMatch(item);
        final offset = int.tryParse(size?[1] ?? '');
        if (offset != null) offsets.add(bytes.length - offset);
      }
    }
    cursor = end;
  }

  for (final offset in offsets) {
    final video = _isoVideo(bytes, data, offset);
    if (video != null) return video;
  }

  // Samsung JPEGs store the clip in a trailer named MotionPhoto_Data.
  const samsung = 'MotionPhoto_Data';
  for (
    var start = cursor;
    start + samsung.length + 12 <= bytes.length;
    start++
  ) {
    if (bytes[start] != 0x4d || !_matches(bytes, start, samsung)) continue;
    final video = _isoVideo(bytes, data, start + samsung.length);
    if (video != null) return video;
  }
  return null;
}

bool _matches(Uint8List bytes, int start, String value) {
  if (start < 0 || start + value.length > bytes.length) return false;
  for (var index = 0; index < value.length; index++) {
    if (bytes[start + index] != value.codeUnitAt(index)) return false;
  }
  return true;
}

Uint8List? _isoVideo(Uint8List bytes, ByteData data, int start) {
  if (start < 4 ||
      start + 12 > bytes.length ||
      !_matches(bytes, start + 4, 'ftyp'))
    return null;
  var cursor = start;
  var end = start;
  var hasMovie = false;
  var hasMedia = false;
  const boxTypes = [
    'ftyp',
    'moov',
    'mdat',
    'free',
    'skip',
    'wide',
    'sidx',
    'moof',
    'mfra',
    'styp',
    'prft',
    'uuid',
    'pdin',
    'meta',
  ];
  while (cursor + 8 <= bytes.length &&
      boxTypes.any((type) => _matches(bytes, cursor + 4, type))) {
    final size32 = data.getUint32(cursor);
    final header = size32 == 1 ? 16 : 8;
    if (cursor + header > bytes.length) return null;
    final size = switch (size32) {
      0 => bytes.length - cursor,
      1 => data.getUint64(cursor + 8),
      _ => size32,
    };
    if (size < header || size > bytes.length - cursor) return null;
    hasMovie |= _matches(bytes, cursor + 4, 'moov');
    hasMedia |= _matches(bytes, cursor + 4, 'mdat');
    cursor += size;
    end = cursor;
  }
  return hasMovie && hasMedia ? Uint8List.sublistView(bytes, start, end) : null;
}
