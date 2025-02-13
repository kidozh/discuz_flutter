// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'MobileApiClient.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations

class _MobileApiClient implements MobileApiClient {
  _MobileApiClient(this._dio, {this.baseUrl, this.errorLogger}) {
    baseUrl ??= 'https://keylol.com/';
  }

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<CheckResult> getCheckResult() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'Content-Type': 'application/json'};
    _headers.removeWhere((k, v) => v == null);
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<CheckResult>(
      Options(
        method: 'GET',
        headers: _headers,
        extra: _extra,
        contentType: 'application/json',
      )
          .compose(
            _dio.options,
            '/api/mobile/index.php?version=4&module=check',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late CheckResult _value;
    try {
      _value = CheckResult.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<String> getCheckResultInString() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'Content-Type': 'application/json'};
    _headers.removeWhere((k, v) => v == null);
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<String>(
      Options(
        method: 'GET',
        headers: _headers,
        extra: _extra,
        contentType: 'application/json',
      )
          .compose(
            _dio.options,
            '/api/mobile/index.php?version=4&module=check',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<String>(_options);
    late String _value;
    try {
      _value = _result.data!;
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<LoginResult> sendLoginRequest(
    String username,
    String password,
    String captchaHash,
    String captchaType,
    String verification,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = {
      'username': username,
      'password': password,
      'seccodehash': captchaHash,
      'seccodemodid': captchaType,
      'seccodeverify': verification,
    };
    final _options = _setStreamType<LoginResult>(
      Options(
        method: 'POST',
        headers: _headers,
        extra: _extra,
        contentType: 'application/x-www-form-urlencoded',
      )
          .compose(
            _dio.options,
            '/api/mobile/index.php?version=4&module=login&mod=logging&action=login&loginfield=username&loginsubmit=yes&cookietime=2592000',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late LoginResult _value;
    try {
      _value = LoginResult.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<String> sendLoginRequestInString(
    String username,
    String password,
    String captchaHash,
    String captchaType,
    String verification,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = {
      'username': username,
      'password': password,
      'seccodehash': captchaHash,
      'seccodemodid': captchaType,
      'seccodeverify': verification,
    };
    final _options = _setStreamType<String>(
      Options(
        method: 'POST',
        headers: _headers,
        extra: _extra,
        contentType: 'application/x-www-form-urlencoded',
      )
          .compose(
            _dio.options,
            '/api/mobile/index.php?version=4&module=login&mod=logging&action=login&loginfield=username&loginsubmit=yes&cookietime=2592000',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<String>(_options);
    late String _value;
    try {
      _value = _result.data!;
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<DiscuzIndexResult> getDiscuzPortalResult() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<DiscuzIndexResult>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/mobile/index.php?version=4&module=forumindex',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late DiscuzIndexResult _value;
    try {
      _value = DiscuzIndexResult.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<String> getDiscuzPortalRaw() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<String>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/mobile/index.php?version=4&module=forumindex',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<String>(_options);
    late String _value;
    try {
      _value = _result.data!;
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<DisplayForumResult> displayForumResult(
    String fid,
    int page,
    Map<String, dynamic> queries,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'fid': fid, r'page': page};
    queryParameters.addAll(queries);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<DisplayForumResult>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/mobile/index.php?version=4&module=forumdisplay',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late DisplayForumResult _value;
    try {
      _value = DisplayForumResult.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<String> displayForumRaw(
    String fid,
    int page,
    Map<String, dynamic> queries,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'fid': fid, r'page': page};
    queryParameters.addAll(queries);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<String>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/mobile/index.php?version=4&module=forumdisplay',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<String>(_options);
    late String _value;
    try {
      _value = _result.data!;
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ViewThreadResult> viewThreadResult(
    int tid,
    int page,
    Map<String, dynamic> queries,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'tid': tid, r'page': page};
    queryParameters.addAll(queries);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<ViewThreadResult>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/mobile/index.php?version=4&module=viewthread&ppp=15',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ViewThreadResult _value;
    try {
      _value = ViewThreadResult.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<String> viewThreadRaw(
    int tid,
    int page,
    Map<String, dynamic> queries,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'tid': tid, r'page': page};
    queryParameters.addAll(queries);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<String>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/mobile/index.php?version=4&module=viewthread&ppp=15',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<String>(_options);
    late String _value;
    try {
      _value = _result.data!;
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<String> sendReplyRaw(
    int fid,
    int tid,
    String formhash,
    String message,
    String captchaHash,
    String captchaType,
    String verification,
    Map<String, dynamic> queries,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.addAll(queries);
    final _headers = <String, dynamic>{};
    final _data = {
      'fid': fid,
      'tid': tid,
      'formhash': formhash,
      'message': message,
      'seccodehash': captchaHash,
      'seccodemodid': captchaType,
      'seccodeverify': verification,
    };
    final _options = _setStreamType<String>(
      Options(
        method: 'POST',
        headers: _headers,
        extra: _extra,
        contentType: 'application/x-www-form-urlencoded',
      )
          .compose(
            _dio.options,
            '/api/mobile/index.php?version=4&module=sendreply&action=reply&replysubmit=yes&usesig=1&seccodemodid=forum::viewthread',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<String>(_options);
    late String _value;
    try {
      _value = _result.data!;
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ApiResult> sendReplyResult(
    int fid,
    int tid,
    String formhash,
    int? replyPostId,
    int? replyPId,
    String? notifyTriPostMessage,
    String message,
    String captchaHash,
    String captchaType,
    String verification,
    Map<String, dynamic> queries,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'repquote': replyPId};
    queryParameters.addAll(queries);
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = {
      'fid': fid,
      'tid': tid,
      'formhash': formhash,
      'reppid': replyPostId,
      'noticetrimstr': notifyTriPostMessage,
      'message': message,
      'seccodehash': captchaHash,
      'seccodemodid': captchaType,
      'seccodeverify': verification,
    };
    _data.removeWhere((k, v) => v == null);
    final _options = _setStreamType<ApiResult>(
      Options(
        method: 'POST',
        headers: _headers,
        extra: _extra,
        contentType: 'application/x-www-form-urlencoded',
      )
          .compose(
            _dio.options,
            '/api/mobile/index.php?version=4&module=sendreply&action=reply&replysubmit=yes&usesig=1&seccodemodid=forum::viewthread',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResult _value;
    try {
      _value = ApiResult.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<String> userNotificationRaw(int page) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'page': page};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<String>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/mobile/index.php?version=4&module=mynotelist',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<String>(_options);
    late String _value;
    try {
      _value = _result.data!;
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<UserDiscuzNotificationResult> userNotificationResult(int page) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'page': page};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<UserDiscuzNotificationResult>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/mobile/index.php?version=4&module=mynotelist',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late UserDiscuzNotificationResult _value;
    try {
      _value = UserDiscuzNotificationResult.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<String> hotThreadRaw(int page) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'page': page};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<String>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/mobile/index.php?version=4&module=hotthread',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<String>(_options);
    late String _value;
    try {
      _value = _result.data!;
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<HotThreadResult> hotThreadResult(int page) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'page': page};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<HotThreadResult>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/mobile/index.php?version=4&module=hotthread',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late HotThreadResult _value;
    try {
      _value = HotThreadResult.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<CaptchaResult> captchaResult(String type) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'type': type};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<CaptchaResult>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/mobile/index.php?version=4&module=secure',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late CaptchaResult _value;
    try {
      _value = CaptchaResult.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ApiResult> votePoll(
    int fid,
    int tid,
    String formHash,
    List<String> checkedOptionId,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'fid': fid, r'tid': tid};
    final _headers = <String, dynamic>{};
    final _data = {'formhash': formHash, 'pollanswers[]': checkedOptionId};
    final _options = _setStreamType<ApiResult>(
      Options(
        method: 'POST',
        headers: _headers,
        extra: _extra,
        contentType: 'application/x-www-form-urlencoded',
      )
          .compose(
            _dio.options,
            '/api/mobile/index.php?version=4&module=pollvote&pollsubmit=yes&action=votepoll',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResult _value;
    try {
      _value = ApiResult.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<String> votePollRaw(
    int fid,
    int tid,
    String formHash,
    List<int> checkedOptionId,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'fid': fid, r'tid': tid};
    final _headers = <String, dynamic>{};
    final _data = {'formhash': formHash, 'pollanswers[]': checkedOptionId};
    final _options = _setStreamType<String>(
      Options(
        method: 'POST',
        headers: _headers,
        extra: _extra,
        contentType: 'application/x-www-form-urlencoded',
      )
          .compose(
            _dio.options,
            '/api/mobile/index.php?version=4&module=pollvote&pollsubmit=yes&action=votepoll',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<String>(_options);
    late String _value;
    try {
      _value = _result.data!;
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<CheckLoginResult> checkLoginResult() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<CheckLoginResult>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/mobile/index.php?version=4&module=login',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late CheckLoginResult _value;
    try {
      _value = CheckLoginResult.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<UserProfileResult> userProfileResult(int uid) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'uid': uid};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<UserProfileResult>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/mobile/index.php?version=4&module=profile',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late UserProfileResult _value;
    try {
      _value = UserProfileResult.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<String> userProfileResultRaw(int uid) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'uid': uid};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<String>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/mobile/index.php?version=4&module=profile',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<String>(_options);
    late String _value;
    try {
      _value = _result.data!;
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<SmileyResult> smileyResult() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<SmileyResult>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/mobile/index.php?version=4&module=smiley',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late SmileyResult _value;
    try {
      _value = SmileyResult.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<PrivateMessagePortalResult> privateMessagePortalResult(
    int page,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'page': page};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<PrivateMessagePortalResult>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/mobile/index.php?version=4&module=mypm',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late PrivateMessagePortalResult _value;
    try {
      _value = PrivateMessagePortalResult.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<PrivateMessageDetailResult> privateMessageDetailResult(
    int toUid,
    int page,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'touid': toUid, r'page': page};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<PrivateMessageDetailResult>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/mobile/index.php?version=4&module=mypm&subop=view',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late PrivateMessageDetailResult _value;
    try {
      _value = PrivateMessageDetailResult.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ApiResult> sendPrivateMessageResult(
    String formHash,
    String message,
    int toUid,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = {'formhash': formHash, 'message': message, 'touid': toUid};
    final _options = _setStreamType<ApiResult>(
      Options(
        method: 'POST',
        headers: _headers,
        extra: _extra,
        contentType: 'application/x-www-form-urlencoded',
      )
          .compose(
            _dio.options,
            '/api/mobile/index.php?version=4&ac=pm&op=send&daterange=0&module=sendpm&pmsubmit=yes',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResult _value;
    try {
      _value = ApiResult.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<PublicMessagePortalResult> publicMessagePortalResult(int page) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'page': page};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<PublicMessagePortalResult>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/mobile/index.php?version=4&module=publicpm',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late PublicMessagePortalResult _value;
    try {
      _value = PublicMessagePortalResult.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<FavoriteThreadResult> favoriteThreadResult(int page) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'page': page};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<FavoriteThreadResult>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/mobile/index.php?version=4&module=myfavthread',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late FavoriteThreadResult _value;
    try {
      _value = FavoriteThreadResult.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<String> uploadImage(int uid, String uploadHash, File file) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = FormData();
    _data.fields.add(MapEntry('uid', uid.toString()));
    _data.fields.add(MapEntry('hash', uploadHash));
    _data.files.add(
      MapEntry(
        'Filedata',
        MultipartFile.fromFileSync(
          file.path,
          filename: file.path.split(Platform.pathSeparator).last,
        ),
      ),
    );
    final _options = _setStreamType<String>(
      Options(
        method: 'POST',
        headers: _headers,
        extra: _extra,
        contentType: 'multipart/form-data',
      )
          .compose(
            _dio.options,
            '/api/mobile/index.php?version=4&module=forumupload&type=image',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<String>(_options);
    late String _value;
    try {
      _value = _result.data!;
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<CheckPostResult> checkPost(int? fid, int? tid) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'fid': fid, r'tid': tid};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<CheckPostResult>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/mobile/index.php?version=4&module=checkpost',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late CheckPostResult _value;
    try {
      _value = CheckPostResult.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<String> reportContent(
    String formHash,
    String report_select,
    String message,
    String rtype,
    int rid,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = {
      'formhash': formHash,
      'report_select': report_select,
      'message': message,
      'rtype': rtype,
      'rid': rid,
    };
    final _options = _setStreamType<String>(
      Options(
        method: 'POST',
        headers: _headers,
        extra: _extra,
        contentType: 'application/x-www-form-urlencoded',
      )
          .compose(
            _dio.options,
            '/misc.php?mod=report&inajax=1&handlekey=miscreport120&reportsubmit=true',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<String>(_options);
    late String _value;
    try {
      _value = _result.data!;
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ApiResult> favoriteThreadActionResult(String formhash, int tid) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = {'formhash': formhash, 'id': tid};
    final _options = _setStreamType<ApiResult>(
      Options(
        method: 'POST',
        headers: _headers,
        extra: _extra,
        contentType: 'application/x-www-form-urlencoded',
      )
          .compose(
            _dio.options,
            '/api/mobile/index.php?version=4&module=favthread&type=thread&ac=favorite&favoritesubmit=true',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResult _value;
    try {
      _value = ApiResult.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ApiResult> unfavoriteThreadActionResult(
    String formhash,
    int favid,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = {'formhash': formhash, 'favid': favid};
    final _options = _setStreamType<ApiResult>(
      Options(
        method: 'POST',
        headers: _headers,
        extra: _extra,
        contentType: 'application/x-www-form-urlencoded',
      )
          .compose(
            _dio.options,
            '/api/mobile/index.php?version=4&module=favthread&type=thread&ac=favorite&deletesubmit=true&op=delete',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResult _value;
    try {
      _value = ApiResult.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<FavoriteForumResult> favoriteForumResult(int page) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'page': page};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<FavoriteForumResult>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/mobile/index.php?version=4&module=myfavforum',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late FavoriteForumResult _value;
    try {
      _value = FavoriteForumResult.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ApiResult> favoriteForumActionResult(String formhash, int fid) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = {'formhash': formhash, 'id': fid};
    final _options = _setStreamType<ApiResult>(
      Options(
        method: 'POST',
        headers: _headers,
        extra: _extra,
        contentType: 'application/x-www-form-urlencoded',
      )
          .compose(
            _dio.options,
            '/api/mobile/index.php?version=4&module=favforum&type=thread&ac=favorite&favoritesubmit=true',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResult _value;
    try {
      _value = ApiResult.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ApiResult> unfavoriteForumActionResult(
    String formhash,
    int favid,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = {'formhash': formhash, 'favid': favid};
    final _options = _setStreamType<ApiResult>(
      Options(
        method: 'POST',
        headers: _headers,
        extra: _extra,
        contentType: 'application/x-www-form-urlencoded',
      )
          .compose(
            _dio.options,
            '/api/mobile/index.php?version=4&module=favforum&type=thread&ac=favorite&deletesubmit=true&op=delete',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResult _value;
    try {
      _value = ApiResult.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<NewThreadResult> newThreadsResult(String fids, int start) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'fids': fids, r'start': start};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<NewThreadResult>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/mobile/index.php?version=4&module=newthreads&limit=20',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late NewThreadResult _value;
    try {
      _value = NewThreadResult.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<PushTokenListResult> getPushTokenListResult() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<PushTokenListResult>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/plugin.php?id=dhpush:token',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late PushTokenListResult _value;
    try {
      _value = PushTokenListResult.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<PostTokenResult> sendToken(
    String formHash,
    String token,
    String deviceName,
    String packageId,
    String pushChannel,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = {
      'formhash': formHash,
      'token': token,
      'deviceName': deviceName,
      'packageId': packageId,
      'channel': pushChannel,
    };
    final _options = _setStreamType<PostTokenResult>(
      Options(
        method: 'POST',
        headers: _headers,
        extra: _extra,
        contentType: 'application/x-www-form-urlencoded',
      )
          .compose(
            _dio.options,
            '/plugin.php?id=dhpush:token',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late PostTokenResult _value;
    try {
      _value = PostTokenResult.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ApiResult> postNewThread(
    String formhash,
    int fid,
    String typeId,
    String subject,
    String message,
    String captchaHash,
    String captchaType,
    String verification,
    List<String> attachAid,
    Map<String, dynamic> formMap,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.addAll(formMap);
    final _headers = <String, dynamic>{};
    final _data = {
      'formhash': formhash,
      'fid': fid,
      'typeid': typeId,
      'subject': subject,
      'message': message,
      'seccodehash': captchaHash,
      'seccodemodid': captchaType,
      'seccodeverify': verification,
      'unused[]': attachAid,
    };
    final _options = _setStreamType<ApiResult>(
      Options(
        method: 'POST',
        headers: _headers,
        extra: _extra,
        contentType: 'application/x-www-form-urlencoded',
      )
          .compose(
            _dio.options,
            '/api/mobile/index.php?version=4&module=newthread&topicsubmit=yes&usesig=1',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResult _value;
    try {
      _value = ApiResult.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ApiResult> mobileSignResult(String formhash) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = {'hash': formhash};
    final _options = _setStreamType<ApiResult>(
      Options(
        method: 'POST',
        headers: _headers,
        extra: _extra,
        contentType: 'application/x-www-form-urlencoded',
      )
          .compose(
            _dio.options,
            '/api/mobile/index.php?version=4&module=mobilesign&type=thread&ac=favorite&deletesubmit=true&op=delete',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResult _value;
    try {
      _value = ApiResult.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ApiResult> warnPostResult(
    String formhash,
    int fid,
    int tid,
    List<int> pids,
    int warned,
    String reason,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = {
      'formhash': formhash,
      'fid': fid,
      'tid': tid,
      'topiclist[]': pids,
      'warned': warned,
      'reason': reason,
    };
    final _options = _setStreamType<ApiResult>(
      Options(
        method: 'POST',
        headers: _headers,
        extra: _extra,
        contentType: 'application/x-www-form-urlencoded',
      )
          .compose(
            _dio.options,
            '/api/mobile/index.php?version=4&module=topicadmin&action=warn&modsubmit=yes&sendreasonpm=on',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResult _value;
    try {
      _value = ApiResult.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ApiResult> banPostResult(
    String formhash,
    int fid,
    int tid,
    List<int> pids,
    int banned,
    String reason,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = {
      'formhash': formhash,
      'fid': fid,
      'tid': tid,
      'topiclist[]': pids,
      'banned': banned,
      'reason': reason,
    };
    final _options = _setStreamType<ApiResult>(
      Options(
        method: 'POST',
        headers: _headers,
        extra: _extra,
        contentType: 'application/x-www-form-urlencoded',
      )
          .compose(
            _dio.options,
            '/api/mobile/index.php?version=4&module=topicadmin&action=banpost&modsubmit=yes&sendreasonpm=on',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResult _value;
    try {
      _value = ApiResult.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ApiResult> deletePostResult(
    String formhash,
    int fid,
    int tid,
    List<int> pids,
    int warned,
    String reason,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = {
      'formhash': formhash,
      'fid': fid,
      'tid': tid,
      'topiclist[]': pids,
      'warned': warned,
      'reason': reason,
    };
    final _options = _setStreamType<ApiResult>(
      Options(
        method: 'POST',
        headers: _headers,
        extra: _extra,
        contentType: 'application/x-www-form-urlencoded',
      )
          .compose(
            _dio.options,
            '/api/mobile/index.php?version=4&module=topicadmin&action=delpost&modsubmit=yes&sendreasonpm=on',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResult _value;
    try {
      _value = ApiResult.fromJson(_result.data!);
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
