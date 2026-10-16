import 'dart:io';

import 'package:discuz_flutter/JsonResult/CheckPostResult.dart';
import 'package:discuz_flutter/utility/forum_image_upload_utils.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('forum_image_upload_');
  });
  tearDown(() async {
    await directory.delete(recursive: true);
  });

  AllowPerm permission({int fileLimit = 100, int dailyLimit = 100}) {
    return AllowPerm()
      ..uploadHash = 'upload-token'
      ..allowUpload = AllowUpload({'jpg': fileLimit})
      ..attachRemain = (AttachRemain()
        ..size = dailyLimit
        ..count = 2);
  }

  test(
    'uploads original bytes when the original fits the forum limits',
    () async {
      final original = File('${directory.path}/photo.jpg')
        ..writeAsBytesSync(List.filled(80, 1));
      var compressions = 0;
      final selected = await prepareForumImageUpload(
        original,
        permission(),
        temporaryDirectory: directory,
        compressor:
            (
              _,
              __, {
              required quality,
              required minWidth,
              required minHeight,
              required CompressFormat format,
            }) async {
              compressions++;
              return null;
            },
      );
      expect(selected?.path, original.path);
      expect(selected?.readAsBytesSync(), original.readAsBytesSync());
      expect(compressions, 0);
    },
  );

  test('compresses until both the type and daily limits are met', () async {
    final original = File('${directory.path}/photo.jpg')
      ..writeAsBytesSync(List.filled(200, 1));
    final producedSizes = [110, 70];
    var compressions = 0;
    final selected = await prepareForumImageUpload(
      original,
      permission(fileLimit: 150, dailyLimit: 80),
      temporaryDirectory: directory,
      compressor:
          (
            _,
            target, {
            required quality,
            required minWidth,
            required minHeight,
            required CompressFormat format,
          }) async {
            final size = producedSizes[compressions++];
            return File(target)..writeAsBytesSync(List.filled(size, 2));
          },
    );
    expect(compressions, 2);
    expect(await selected!.length(), 70);
    expect(await original.length(), 200);
  });

  test(
    'does not upload a compressed image that remains over the limit',
    () async {
      final original = File('${directory.path}/photo.jpg')
        ..writeAsBytesSync(List.filled(200, 1));
      final selected = await prepareForumImageUpload(
        original,
        permission(fileLimit: 100, dailyLimit: 50),
        temporaryDirectory: directory,
        compressor: (
          _,
          target, {
          required quality,
          required minWidth,
          required minHeight,
          required CompressFormat format,
        }) async => File(target)..writeAsBytesSync(List.filled(60, 2)),
      );
      expect(selected, isNull);
    },
  );
}
