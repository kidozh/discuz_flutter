// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CheveretoApiClient.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations

class _CheveretoApiClient implements CheveretoApiClient {
  _CheveretoApiClient(this._dio, {this.baseUrl, this.errorLogger}) {
    baseUrl ??= 'https://sm.ms';
  }

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<ChevertoUploadResult> uploadImageToChevereto(
    String apiToken,
    String base64String,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'X-API-Key': apiToken};
    _headers.removeWhere((k, v) => v == null);
    final _data = {'source': base64String};
    final _options = _setStreamType<ChevertoUploadResult>(
      Options(
        method: 'POST',
        headers: _headers,
        extra: _extra,
        contentType: 'application/x-www-form-urlencoded',
      )
          .compose(
            _dio.options,
            '/api/1/upload/',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ChevertoUploadResult _value;
    try {
      _value = ChevertoUploadResult.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  String _combineBaseUrls(String dioBaseUrl, String? baseUrl) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final url = Uri.parse(baseUrl);

    if (url.isAbsolute) {
      return url.toString();
    }

    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}
