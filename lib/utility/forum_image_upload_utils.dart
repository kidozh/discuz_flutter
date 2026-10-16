import 'dart:io';

import 'package:discuz_flutter/JsonResult/CheckPostResult.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

typedef ImageCompressor = Future<File?> Function(
  File source,
  String targetPath, {
  required int quality,
  required int minWidth,
  required int minHeight,
  required CompressFormat format,
});

/// Keeps the original bytes whenever the forum accepts them. Otherwise tries
/// progressively smaller images and only returns a file that passes both the
/// per-type and remaining daily upload limits.
Future<File?> prepareForumImageUpload(
  File source,
  AllowPerm permission, {
  ImageCompressor? compressor,
  Directory? temporaryDirectory,
}) async {
  if (permission.validateUpload(source.path, await source.length()) == null) {
    return source;
  }
  if (permission.uploadHash.isEmpty || permission.attachRemain.count == 0) {
    return null;
  }

  final limits = permission.allowUpload.limits;
  final extension = ['jpg', 'jpeg', 'png'].where((type) {
    final limit = limits[type];
    return limit != null && (limit == -1 || limit > 0);
  }).firstOrNull;
  if (extension == null) return null;

  final format = extension == 'png' ? CompressFormat.png : CompressFormat.jpeg;
  final compress = compressor ?? _compressImage;
  final directory = temporaryDirectory ?? await getTemporaryDirectory();
  final stamp = DateTime.now().microsecondsSinceEpoch;
  final attempts = <(int, int)>[
    (85, 1920),
    (70, 1920),
    (55, 1600),
    (40, 1280),
    (35, 960),
    (30, 640),
  ];
  for (var index = 0; index < attempts.length; index++) {
    final (quality, width) = attempts[index];
    final target = '${directory.path}/discuz-upload-$stamp-$index.$extension';
    final candidate = await compress(
      source,
      target,
      quality: quality,
      minWidth: width,
      minHeight: width,
      format: format,
    );
    if (candidate == null) continue;
    if (permission.validateUpload(candidate.path, await candidate.length()) ==
        null) {
      return candidate;
    }
    await candidate.delete();
  }
  return null;
}

Future<File?> _compressImage(
  File source,
  String targetPath, {
  required int quality,
  required int minWidth,
  required int minHeight,
  required CompressFormat format,
}) async {
  final compressed = await FlutterImageCompress.compressAndGetFile(
    source.path,
    targetPath,
    quality: quality,
    minWidth: minWidth,
    minHeight: minHeight,
    format: format,
  );
  return compressed == null ? null : File(compressed.path);
}
