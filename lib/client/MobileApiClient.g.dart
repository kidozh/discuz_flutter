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
    final _headers = <String, dynamic>{r'Content-Type': 'application/json'};
    _headers.removeWhere((k, v) => v == null);
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<CheckResult>(Options(
                method: 'GET',
                headers: _headers,
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
    final _headers = <String, dynamic>{r'Content-Type': 'application/json'};
    _headers.removeWhere((k, v) => v == null);
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<String>(_setStreamType<String>(Options(
            method: 'GET',
            headers: _headers,
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
    final _headers = <String, dynamic>{};
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
            headers: _headers,
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
    final _headers = <String, dynamic>{};
    final _data = {
      'username': username,
      'password': password,
      'seccodehash': captchaHash,
      'seccodemodid': captchaType,
      'seccodeverify': verification
    };
    final _result = await _dio.fetch<String>(_setStreamType<String>(Options(
            method: 'POST',
            headers: _headers,
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
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<DiscuzIndexResult>(
            Options(method: 'GET', headers: _headers, extra: _extra)
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
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<String>(_setStreamType<String>(Options(
            method: 'GET', headers: _headers, extra: _extra)
        .compose(
            _dio.options, '/api/mobile/index.php?version=4&module=forumindex',
            queryParameters: queryParameters, data: _data)
        .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data!;
    return value;
  }

  @override
  Future<DisplayForumResult> displayForumResult(fid, page, queries) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'fid': fid, r'page': page};
    queryParameters.addAll(queries);
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<DisplayForumResult>(
            Options(method: 'GET', headers: _headers, extra: _extra)
                .compose(_dio.options,
                    '/api/mobile/index.php?version=4&module=forumdisplay',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = DisplayForumResult.fromJson(_result.data!);
    return value;
  }

  @override
  Future<String> displayForumRaw(fid, page, queries) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'fid': fid, r'page': page};
    queryParameters.addAll(queries);
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<String>(_setStreamType<String>(Options(
            method: 'GET', headers: _headers, extra: _extra)
        .compose(
            _dio.options, '/api/mobile/index.php?version=4&module=forumdisplay',
            queryParameters: queryParameters, data: _data)
        .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data!;
    return value;
  }

  @override
  Future<ViewThreadResult> viewThreadResult(tid, page, queries) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'tid': tid, r'page': page};
    queryParameters.addAll(queries);
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<ViewThreadResult>(
            Options(method: 'GET', headers: _headers, extra: _extra)
                .compose(_dio.options,
                    '/api/mobile/index.php?version=4&module=viewthread&ppp=15',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = ViewThreadResult.fromJson(_result.data!);
    return value;
  }

  @override
  Future<String> viewThreadRaw(tid, page, queries) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'tid': tid, r'page': page};
    queryParameters.addAll(queries);
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<String>(_setStreamType<String>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(_dio.options,
                '/api/mobile/index.php?version=4&module=viewthread&ppp=15',
                queryParameters: queryParameters, data: _data)
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data!;
    return value;
  }

  @override
  Future<String> sendReplyRaw(fid, tid, formhash, message, captchaHash,
      captchaType, verification, queries) async {
    const _extra = <String, dynamic>{};
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
      'seccodeverify': verification
    };
    final _result = await _dio.fetch<String>(_setStreamType<String>(Options(
            method: 'POST',
            headers: _headers,
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
  Future<ApiResult> sendReplyResult(
      fid,
      tid,
      formhash,
      replyPostId,
      notifyTriPostMessage,
      message,
      captchaHash,
      captchaType,
      verification,
      queries) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
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
      'seccodeverify': verification
    };
    _data.removeWhere((k, v) => v == null);
    final _result = await _dio.fetch<Map<String, dynamic>>(_setStreamType<
        ApiResult>(Options(
            method: 'POST',
            headers: _headers,
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
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<String>(_setStreamType<String>(Options(
            method: 'GET', headers: _headers, extra: _extra)
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
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<UserDiscuzNotificationResult>(
            Options(method: 'GET', headers: _headers, extra: _extra)
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
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<String>(_setStreamType<String>(Options(
            method: 'GET', headers: _headers, extra: _extra)
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
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<HotThreadResult>(
            Options(method: 'GET', headers: _headers, extra: _extra)
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
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<CaptchaResult>(Options(
                method: 'GET', headers: _headers, extra: _extra)
            .compose(
                _dio.options, '/api/mobile/index.php?version=4&module=secure',
                queryParameters: queryParameters, data: _data)
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = CaptchaResult.fromJson(_result.data!);
    return value;
  }

  @override
  Future<ApiResult> votePoll(fid, tid, formHash, checkedOptionId) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'fid': fid, r'tid': tid};
    final _headers = <String, dynamic>{};
    final _data = {'formhash': formHash, 'pollanswers[]': checkedOptionId};
    final _result = await _dio.fetch<Map<String, dynamic>>(_setStreamType<
        ApiResult>(Options(
            method: 'POST',
            headers: _headers,
            extra: _extra,
            contentType: 'application/x-www-form-urlencoded')
        .compose(_dio.options,
            '/api/mobile/index.php?version=4&module=pollvote&pollsubmit=yes&action=votepoll',
            queryParameters: queryParameters, data: _data)
        .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = ApiResult.fromJson(_result.data!);
    return value;
  }

  @override
  Future<String> votePollRaw(fid, tid, formHash, checkedOptionId) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'fid': fid, r'tid': tid};
    final _headers = <String, dynamic>{};
    final _data = {'formhash': formHash, 'pollanswers[]': checkedOptionId};
    final _result = await _dio.fetch<String>(_setStreamType<String>(Options(
            method: 'POST',
            headers: _headers,
            extra: _extra,
            contentType: 'application/x-www-form-urlencoded')
        .compose(_dio.options,
            '/api/mobile/index.php?version=4&module=pollvote&pollsubmit=yes&action=votepoll',
            queryParameters: queryParameters, data: _data)
        .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data!;
    return value;
  }

  @override
  Future<CheckLoginResult> checkLoginResult() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<CheckLoginResult>(Options(
                method: 'GET', headers: _headers, extra: _extra)
            .compose(
                _dio.options, '/api/mobile/index.php?version=4&module=login',
                queryParameters: queryParameters, data: _data)
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = CheckLoginResult.fromJson(_result.data!);
    return value;
  }

  @override
  Future<UserProfileResult> userProfileResult(uid) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'uid': uid};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<UserProfileResult>(Options(
                method: 'GET', headers: _headers, extra: _extra)
            .compose(
                _dio.options, '/api/mobile/index.php?version=4&module=profile',
                queryParameters: queryParameters, data: _data)
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = UserProfileResult.fromJson(_result.data!);
    return value;
  }

  @override
  Future<String> userProfileResultRaw(uid) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'uid': uid};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<String>(_setStreamType<String>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
                _dio.options, '/api/mobile/index.php?version=4&module=profile',
                queryParameters: queryParameters, data: _data)
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data!;
    return value;
  }

  @override
  Future<SmileyResult> smileyResult() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<SmileyResult>(Options(
                method: 'GET', headers: _headers, extra: _extra)
            .compose(
                _dio.options, '/api/mobile/index.php?version=4&module=smiley',
                queryParameters: queryParameters, data: _data)
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = SmileyResult.fromJson(_result.data!);
    return value;
  }

  @override
  Future<PrivateMessagePortalResult> privateMessagePortalResult(page) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'page': page};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<PrivateMessagePortalResult>(
            Options(method: 'GET', headers: _headers, extra: _extra)
                .compose(
                    _dio.options, '/api/mobile/index.php?version=4&module=mypm',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = PrivateMessagePortalResult.fromJson(_result.data!);
    return value;
  }

  @override
  Future<PrivateMessageDetailResult> privateMessageDetailResult(
      toUid, page) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'touid': toUid, r'page': page};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<PrivateMessageDetailResult>(
            Options(method: 'GET', headers: _headers, extra: _extra)
                .compose(_dio.options,
                    '/api/mobile/index.php?version=4&module=mypm&subop=view',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = PrivateMessageDetailResult.fromJson(_result.data!);
    return value;
  }

  @override
  Future<ApiResult> sendPrivateMessageResult(formHash, message, toUid) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = {'formhash': formHash, 'message': message, 'touid': toUid};
    final _result = await _dio.fetch<Map<String, dynamic>>(_setStreamType<
        ApiResult>(Options(
            method: 'POST',
            headers: _headers,
            extra: _extra,
            contentType: 'application/x-www-form-urlencoded')
        .compose(_dio.options,
            '/api/mobile/index.php?version=4&ac=pm&op=send&daterange=0&module=sendpm&pmsubmit=yes',
            queryParameters: queryParameters, data: _data)
        .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = ApiResult.fromJson(_result.data!);
    return value;
  }

  @override
  Future<PublicMessagePortalResult> publicMessagePortalResult(page) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'page': page};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<PublicMessagePortalResult>(Options(
                method: 'GET', headers: _headers, extra: _extra)
            .compose(
                _dio.options, '/api/mobile/index.php?version=4&module=publicpm',
                queryParameters: queryParameters, data: _data)
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = PublicMessagePortalResult.fromJson(_result.data!);
    return value;
  }

  @override
  Future<FavoriteThreadResult> favoriteThreadResult(page) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'page': page};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<FavoriteThreadResult>(
            Options(method: 'GET', headers: _headers, extra: _extra)
                .compose(_dio.options,
                    '/api/mobile/index.php?version=4&module=myfavthread',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = FavoriteThreadResult.fromJson(_result.data!);
    return value;
  }

  @override
  Future<String> uploadImage(uid, uploadHash, file) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = FormData();
    _data.fields.add(MapEntry('uid', uid.toString()));
    _data.fields.add(MapEntry('hash', uploadHash));
    _data.files.add(MapEntry(
        'Filedata',
        MultipartFile.fromFileSync(file.path,
            filename: file.path.split(Platform.pathSeparator).last)));
    final _result = await _dio.fetch<String>(_setStreamType<String>(Options(
            method: 'POST',
            headers: _headers,
            extra: _extra,
            contentType: 'multipart/form-data')
        .compose(_dio.options,
            '/api/mobile/index.php?version=4&module=forumupload&type=image',
            queryParameters: queryParameters, data: _data)
        .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data!;
    return value;
  }

  @override
  Future<CheckPostResult> checkPost(fid, tid) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'fid': fid, r'tid': tid};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<CheckPostResult>(
            Options(method: 'GET', headers: _headers, extra: _extra)
                .compose(_dio.options,
                    '/api/mobile/index.php?version=4&module=checkpost',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = CheckPostResult.fromJson(_result.data!);
    return value;
  }

  @override
  Future<String> reportContent(
      formHash, report_select, message, rtype, rid) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = {
      'formhash': formHash,
      'report_select': report_select,
      'message': message,
      'rtype': rtype,
      'rid': rid
    };
    final _result = await _dio.fetch<String>(_setStreamType<String>(Options(
            method: 'POST',
            headers: _headers,
            extra: _extra,
            contentType: 'application/x-www-form-urlencoded')
        .compose(_dio.options,
            '/misc.php?mod=report&inajax=1&handlekey=miscreport120&reportsubmit=true',
            queryParameters: queryParameters, data: _data)
        .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data!;
    return value;
  }

  @override
  Future<ApiResult> favoriteThreadActionResult(formhash, tid) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = {'formhash': formhash, 'id': tid};
    final _result = await _dio.fetch<Map<String, dynamic>>(_setStreamType<
        ApiResult>(Options(
            method: 'POST',
            headers: _headers,
            extra: _extra,
            contentType: 'application/x-www-form-urlencoded')
        .compose(_dio.options,
            '/api/mobile/index.php?version=4&module=favthread&type=thread&ac=favorite&favoritesubmit=true',
            queryParameters: queryParameters, data: _data)
        .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = ApiResult.fromJson(_result.data!);
    return value;
  }

  @override
  Future<ApiResult> unfavoriteThreadActionResult(formhash, favid) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = {'formhash': formhash, 'favid': favid};
    final _result = await _dio.fetch<Map<String, dynamic>>(_setStreamType<
        ApiResult>(Options(
            method: 'POST',
            headers: _headers,
            extra: _extra,
            contentType: 'application/x-www-form-urlencoded')
        .compose(_dio.options,
            '/api/mobile/index.php?version=4&module=favthread&type=thread&ac=favorite&deletesubmit=true&op=delete',
            queryParameters: queryParameters, data: _data)
        .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = ApiResult.fromJson(_result.data!);
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
