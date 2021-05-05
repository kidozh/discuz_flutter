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
  Future<LoginResult> sendLoginRequest(
      username, password, captchaHash, captchaType, verification) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = {
      'username': username,
      'password': password,
      'seccodehash': captchaHash,
      'seccodemodid': captchaType,
      'seccodeverify': verification
    };
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
  Future<String> sendLoginRequestInString(
      username, password, captchaHash, captchaType, verification) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = {
      'username': username,
      'password': password,
      'seccodehash': captchaHash,
      'seccodemodid': captchaType,
      'seccodeverify': verification
    };
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
                    '/api/mobile/index.php?version=4&module=viewthread&ppp=10',
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
    final _result = await _dio.fetch<String>(_setStreamType<String>(
        Options(method: 'GET', headers: <String, dynamic>{}, extra: _extra)
            .compose(_dio.options,
                '/api/mobile/index.php?version=4&module=viewthread&ppp=10',
                queryParameters: queryParameters, data: _data)
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data!;
    return value;
  }

  @override
  Future<String> sendReplyRaw(fid, tid, formhash, message, captchaHash,
      captchaType, verification) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = {
      'fid': fid,
      'tid': tid,
      'formhash': formhash,
      'message': message,
      'seccodehash': captchaHash,
      'seccodemodid': captchaType,
      'seccodeverify': verification
    };
    final _result = await _dio.fetch<String>(_setStreamType<String>(Options(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            contentType: 'application/x-www-form-urlencoded')
        .compose(_dio.options,
            '/api/mobile/index.php?version=4&module=sendreply&action=reply&replysubmit=yes&usesig=1&seccodemodid=forum::viewthread',
            queryParameters: queryParameters, data: _data)
        .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data!;
    return value;
  }

  @override
  Future<ApiResult> sendReplyResult(fid, tid, formhash, message, captchaHash,
      captchaType, verification) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = {
      'fid': fid,
      'tid': tid,
      'formhash': formhash,
      'message': message,
      'seccodehash': captchaHash,
      'seccodemodid': captchaType,
      'seccodeverify': verification
    };
    final _result = await _dio.fetch<Map<String, dynamic>>(_setStreamType<
        ApiResult>(Options(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            contentType: 'application/x-www-form-urlencoded')
        .compose(_dio.options,
            '/api/mobile/index.php?version=4&module=sendreply&action=reply&replysubmit=yes&usesig=1&seccodemodid=forum::viewthread',
            queryParameters: queryParameters, data: _data)
        .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = ApiResult.fromJson(_result.data!);
    return value;
  }

  @override
  Future<String> userNotificationRaw(page) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'page': page};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<String>(_setStreamType<String>(Options(
            method: 'GET', headers: <String, dynamic>{}, extra: _extra)
        .compose(
            _dio.options, '/api/mobile/index.php?version=4&module=mynotelist',
            queryParameters: queryParameters, data: _data)
        .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data!;
    return value;
  }

  @override
  Future<UserDiscuzNotificationResult> userNotificationResult(page) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'page': page};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<UserDiscuzNotificationResult>(
            Options(method: 'GET', headers: <String, dynamic>{}, extra: _extra)
                .compose(_dio.options,
                    '/api/mobile/index.php?version=4&module=mynotelist',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = UserDiscuzNotificationResult.fromJson(_result.data!);
    return value;
  }

  @override
  Future<String> hotThreadRaw(page) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'page': page};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<String>(_setStreamType<String>(Options(
            method: 'GET', headers: <String, dynamic>{}, extra: _extra)
        .compose(
            _dio.options, '/api/mobile/index.php?version=4&module=hotthread',
            queryParameters: queryParameters, data: _data)
        .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data!;
    return value;
  }

  @override
  Future<HotThreadResult> hotThreadResult(page) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'page': page};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<HotThreadResult>(
            Options(method: 'GET', headers: <String, dynamic>{}, extra: _extra)
                .compose(_dio.options,
                    '/api/mobile/index.php?version=4&module=hotthread',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = HotThreadResult.fromJson(_result.data!);
    return value;
  }

  @override
  Future<CaptchaResult> captchaResult(type) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'type': type};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<CaptchaResult>(Options(
                method: 'GET', headers: <String, dynamic>{}, extra: _extra)
            .compose(
                _dio.options, '/api/mobile/index.php?version=4&module=secure',
                queryParameters: queryParameters, data: _data)
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = CaptchaResult.fromJson(_result.data!);
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
