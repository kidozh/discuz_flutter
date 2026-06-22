import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/JsonResult/ChevertoUploadResult.dart';

class CheveretoApiClient {
  CheveretoApiClient(this._dio, {required this.baseUrl});

  final Dio _dio;
  final String baseUrl;

  Future<ChevertoUploadResult> uploadImageToCheveretoByBase64(
    String apiToken,
    String base64String, {
    String sourceFieldName = 'source',
  }) async {
    final response = await _dio.post<dynamic>(
      _uploadUrl,
      data: {
        'key': apiToken,
        'format': 'json',
        sourceFieldName: base64String,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: _apiHeaders(apiToken),
        responseType: ResponseType.json,
        validateStatus: (_) => true,
      ),
    );
    return _parseResponse(response);
  }

  Future<ChevertoUploadResult> uploadImageToCheveretoByBinaryFile(
    String apiToken,
    File source, {
    String sourceFieldName = 'source',
  }) async {
    final formData = FormData.fromMap({
      'key': apiToken,
      'format': 'json',
      sourceFieldName: await MultipartFile.fromFile(
        source.path,
        filename: source.path.split(Platform.pathSeparator).last,
      ),
    });

    final response = await _dio.post<dynamic>(
      _uploadUrl,
      data: formData,
      options: Options(
        headers: _apiHeaders(apiToken),
        responseType: ResponseType.json,
        validateStatus: (_) => true,
      ),
    );
    return _parseResponse(response);
  }

  String get _uploadUrl {
    final normalizedBaseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    return Uri.parse(normalizedBaseUrl).resolve('upload').toString();
  }

  Map<String, String> _apiHeaders(String apiToken) {
    return {'X-API-Key': apiToken};
  }

  ChevertoUploadResult _parseResponse(Response<dynamic> response) {
    final data = response.data;
    final Map<String, dynamic>? json;
    if (data is String) {
      final decoded = jsonDecode(data);
      json = _mapValue(decoded);
    } else {
      json = _mapValue(data);
    }

    if (json != null) {
      json.putIfAbsent('status', () => response.statusCode);
      json.putIfAbsent('status_txt', () => response.statusMessage);
      return ChevertoUploadResult.fromJson(json);
    }

    throw FormatException('Unexpected Chevereto upload response: $data');
  }

  Map<String, dynamic>? _mapValue(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }
}
