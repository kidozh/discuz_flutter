// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'MobileApiClient.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _MobileApiClient implements MobileApiClient {
  _MobileApiClient(this._dio, {this.baseUrl}) {
    baseUrl ??= 'https://keylol.com/';
  }

  final Dio _dio;

  String? baseUrl;

  @override
  Future<CheckResult> getCheckResult() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<CheckResult>(Options(
                method: 'GET',
                headers: <String, dynamic>{r'Content-Type': 'application/json'},
                extra: _extra,
                contentType: 'application/json')
            .compose(
                _dio.options, '/api/mobile/index.php?version=4&module=check',
                queryParameters: queryParameters, data: _data)
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = CheckResult.fromJson(_result.data!);
    return value;
  }

  @override
  Future<String> getCheckResultInString() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<String>(_setStreamType<String>(Options(
            method: 'GET',
            headers: <String, dynamic>{r'Content-Type': 'application/json'},
            extra: _extra,
            contentType: 'application/json')
        .compose(_dio.options, '/api/mobile/index.php?version=4&module=check',
            queryParameters: queryParameters, data: _data)
        .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data!;
    return value;
  }

  @override
  Future<LoginResult> sendLoginRequest(username, password) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = {'username': username, 'password': password};
    final _result = await _dio.fetch<Map<String, dynamic>>(_setStreamType<
        LoginResult>(Options(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            contentType: 'application/x-www-form-urlencoded')
        .compose(_dio.options,
            '/api/mobile/index.php?version=4&module=login&mod=logging&action=login&loginfield=username&loginsubmit=yes&cookietime=2592000',
            queryParameters: queryParameters, data: _data)
        .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = LoginResult.fromJson(_result.data!);
    return value;
  }

  @override
  Future<String> sendLoginRequestInString(username, password) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = {'username': username, 'password': password};
    final _result = await _dio.fetch<String>(_setStreamType<String>(Options(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            contentType: 'application/x-www-form-urlencoded')
        .compose(_dio.options,
            '/api/mobile/index.php?version=4&module=login&mod=logging&action=login&loginfield=username&loginsubmit=yes&cookietime=2592000',
            queryParameters: queryParameters, data: _data)
        .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data!;
    return value;
  }

  @override
  Future<DiscuzIndexResult> getDiscuzPortalResult() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<DiscuzIndexResult>(
            Options(method: 'GET', headers: <String, dynamic>{}, extra: _extra)
                .compose(_dio.options,
                    '/api/mobile/index.php?version=4&module=forumindex',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = DiscuzIndexResult.fromJson(_result.data!);
    return value;
  }

  @override
  Future<String> getDiscuzPortalRaw() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<String>(_setStreamType<String>(Options(
            method: 'GET', headers: <String, dynamic>{}, extra: _extra)
        .compose(
            _dio.options, '/api/mobile/index.php?version=4&module=forumindex',
            queryParameters: queryParameters, data: _data)
        .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data!;
    return value;
  }

  @override
  Future<DisplayForumResult> displayForumResult(fid, page) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'fid': fid, r'page': page};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<DisplayForumResult>(
            Options(method: 'GET', headers: <String, dynamic>{}, extra: _extra)
                .compose(_dio.options,
                    '/api/mobile/index.php?version=4&module=forumdisplay',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = DisplayForumResult.fromJson(_result.data!);
    return value;
  }

  @override
  Future<String> displayForumRaw(fid, page) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'fid': fid, r'page': page};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<String>(_setStreamType<String>(Options(
            method: 'GET', headers: <String, dynamic>{}, extra: _extra)
        .compose(
            _dio.options, '/api/mobile/index.php?version=4&module=forumdisplay',
            queryParameters: queryParameters, data: _data)
        .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data!;
    return value;
  }

  @override
  Future<ViewThreadResult> viewThreadResult(tid, page) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'tid': tid, r'page': page};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<ViewThreadResult>(
            Options(method: 'GET', headers: <String, dynamic>{}, extra: _extra)
                .compose(_dio.options,
                    '/api/mobile/index.php?version=4&module=viewthread',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = ViewThreadResult.fromJson(_result.data!);
    return value;
  }

  @override
  Future<String> viewThreadRaw(tid, page) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'tid': tid, r'page': page};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<String>(_setStreamType<String>(Options(
            method: 'GET', headers: <String, dynamic>{}, extra: _extra)
        .compose(
            _dio.options, '/api/mobile/index.php?version=4&module=viewthread',
            queryParameters: queryParameters, data: _data)
        .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data!;
    return value;
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
}
