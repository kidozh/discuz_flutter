import 'package:discuz_flutter/JsonResult/ChevertoUploadResult.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChevertoUploadResult', () {
    test('parses Chevereto v3 upload response', () {
      final result = ChevertoUploadResult.fromJson({
        'status_code': 200,
        'success': {
          'message': 'image uploaded',
          'code': 200,
        },
        'image': {
          'filename': 'photo.jpg',
          'url': 'https://img.example.com/photo.jpg',
          'display_url': 'https://img.example.com/display/photo.jpg',
          'thumb': {
            'url': 'https://img.example.com/thumb/photo.jpg',
          },
        },
        'status_txt': 'OK',
      });

      expect(result.isSuccess, isTrue);
      expect(result.imageUrl, 'https://img.example.com/photo.jpg');
      expect(result.errorMessage, isNull);
    });

    test('parses ImgBB-style upload response', () {
      final result = ChevertoUploadResult.fromJson({
        'success': true,
        'status': 200,
        'data': {
          'url': 'https://i.ibb.co/demo/photo.jpg',
          'display_url': 'https://i.ibb.co/demo/photo-display.jpg',
        },
      });

      expect(result.isSuccess, isTrue);
      expect(result.imageUrl, 'https://i.ibb.co/demo/photo.jpg');
    });

    test('parses upload error message', () {
      final result = ChevertoUploadResult.fromJson({
        'success': false,
        'status_code': 400,
        'error': {
          'message': 'Invalid API key',
        },
      });

      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, 'Invalid API key');
    });
  });
}
