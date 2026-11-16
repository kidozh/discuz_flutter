import 'package:dio/dio.dart';
import 'package:discuz_flutter/JsonResult/CheckPostResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/utility/forum_attachment_upload.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ordinary files respect type, size and daily limits', () {
    AllowPerm permission({int count = -1, int size = -1}) =>
        AllowPerm.fromJson({
          'uploadhash': 'hash',
          'allowupload': {'pdf': '4096'},
          'attachremain': {'count': count, 'size': size},
        });
    expect(permission().validateUpload('GUIDE.PDF', 4096), isNull);
    expect(permission().validateUpload('pdf', 1), UploadRestriction.type);
    expect(
      permission().validateUpload('Guide.pdf', 4097),
      UploadRestriction.fileSize,
    );
    expect(
      permission(size: 3000).validateUpload('Guide.pdf', 3001),
      UploadRestriction.dailySize,
    );
    expect(
      permission(count: 0).validateUpload('Guide.pdf', 1),
      UploadRestriction.count,
    );
    expect(
      permission(size: -2).validateUpload('Guide.pdf', 1),
      UploadRestriction.dailySize,
    );
  });

  test(
    'file upload targets the forum and streams the original bytes',
    () async {
      final dio = Dio();
      addTearDown(dio.close);
      final bytes = <int>[
        0xFF,
        0xD8,
        0xFF,
        0xD9,
        0,
        0,
        0,
        8,
        102,
        116,
        121,
        112,
      ];
      final name = Uri.encodeComponent('动态照片.JPG');
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) async {
            if (request.method == 'POST') {
              expect(request.uri.path, '/bbs/api/mobile/index.php');
              expect(request.uri.queryParameters, {
                'version': '4',
                'module': 'forumupload',
                'simple': '1',
                'fid': '7',
              });
              final form = request.data as FormData;
              expect(Map.fromEntries(form.fields), {
                'uid': '12',
                'hash': 'hash',
              });
              final entry = form.files.single;
              expect(entry.key, 'Filedata');
              expect(entry.value.filename, name);
              expect(
                await entry.value.finalize().expand((chunk) => chunk).toList(),
                bytes,
              );
            }
            handler.resolve(
              Response(requestOptions: request, data: 'DISCUZUPLOAD|0|73|-1|0'),
            );
          },
        ),
      );
      final client = MobileApiClient(dio, baseUrl: 'https://forum.test/bbs');
      final response = await client.uploadAttachment(
        7,
        12,
        'hash',
        MultipartFile.fromBytes(bytes, filename: name),
      );
      expect(ForumUploadResult.parse(response).aid, 73);
    },
  );

  test('upload results require an explicit valid attachment ID', () {
    for (final response in [
      '73',
      'DISCUZUPLOAD|0|73|0|0',
      'DISCUZUPLOAD|0|0|73|0||guide.pdf|0',
      '{"Variables":{"code":"0","ret":{"aId":"73"}}}',
    ]) {
      final result = ForumUploadResult.parse(response);
      expect(result.aid, 73, reason: response);
      expect(result.errorCode, isNull, reason: response);
    }
    for (final response in [
      '',
      '0',
      '<html>73</html>',
      'DISCUZUPLOAD|0|0|0|0',
      '{"Variables":{"ret":{"aId":73}}}',
      '{"Variables":{"code":0,"ret":{"aId":73.5}}}',
    ]) {
      expect(ForumUploadResult.parse(response).aid, isNull, reason: response);
    }
    for (final response in ['-5', 'DISCUZUPLOAD|5|73|0|0']) {
      final result = ForumUploadResult.parse(response);
      expect(result.aid, isNull, reason: response);
      expect(result.errorCode, 5, reason: response);
    }
  });
}
