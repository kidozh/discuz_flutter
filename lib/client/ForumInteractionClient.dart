import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parse;

import '../utility/discuz_json.dart';

Iterable<dynamic> forumRows(Object? value) => value is Map
    ? value.values
    : value is List
    ? value
    : const [];

class ForumApiException implements Exception {
  final String code;
  final String message;
  final bool fromForum;
  const ForumApiException(this.code, this.message, {this.fromForum = false});
  @override
  String toString() => message.isEmpty ? code : message;
}

class ForumReply {
  final Map<String, dynamic> variables;
  final String code, message;
  static ForumReply decode(Object? data) => ForumReply(decodePayload(data));

  static Map<String, dynamic> decodePayload(Object? data) {
    if (data is String) {
      var source = data.trim().replaceFirst(RegExp(r'^\uFEFF'), '').trim();
      // Some installations wrap the mobile result in Discuz's AJAX envelope.
      final envelope = RegExp(
        r'^(?:<\?xml[^>]*>\s*)?<root>\s*<!\[CDATA\[([\s\S]*?)\]\]>\s*</root>$',
      ).firstMatch(source);
      if (envelope != null) source = envelope[1]!.trim();
      try {
        data = jsonDecode(source);
      } on FormatException {
        if (isSecurityChallenge(source)) {
          throw const ForumApiException(
            'forum_security_challenge',
            '',
            fromForum: true,
          );
        }
        // Never infer success from HTML text or repeat a write after a bad reply.
        throw ForumApiException(
          source.isEmpty
              ? 'empty_response'
              : source.startsWith('<')
              ? 'unexpected_markup_response'
              : 'invalid_response_format',
          '',
        );
      }
    }
    if (data is! Map) throw const ForumApiException('invalid_response', '');
    return discuzMap(data);
  }

  ForumReply._(this.variables, this.code, this.message);

  factory ForumReply(Object? data) {
    final response = discuzMap(data);
    final message = discuzMap(response['Message']);
    final code = discuzString(message['messageval']).trim();
    return ForumReply._(
      discuzMap(response['Variables']),
      code.isEmpty ? discuzString(response['error']).trim() : code,
      discuzString(message['messagestr']),
    );
  }

  ForumApiException? get serverError =>
      code.isEmpty ? null : ForumApiException(code, message, fromForum: true);

  static ForumApiException? tryServerError(Object? data) {
    if (data == null) return null;
    try {
      final payload = decodePayload(data);
      final code = discuzString(discuzMap(payload['Message'])['messageval'])
          .split('//')
          .first
          .trim()
          .toLowerCase();
      // A success message cannot explain a model decoding failure.
      if (code.endsWith('_succeed') || code.endsWith('_success')) return null;
      return ForumReply(payload).serverError;
    } on ForumApiException {
      return null;
    }
  }

  static bool isSecurityChallenge(Object? data) {
    if (data is! String) return false;
    final page = data.toLowerCase();
    return page.contains('eo_bot_ssid') ||
        page.contains('/cdn-cgi/challenge-platform/') ||
        page.contains('请求已被站点的安全策略拦截') ||
        (page.trimLeft().startsWith('<') && page.contains('tencentedgeone'));
  }

  void requireSuccess(Set<String> codes) {
    if (!codes.contains(code)) {
      throw serverError ?? const ForumApiException('invalid_response', '');
    }
  }

  void requireData(String field) {
    if (code.isNotEmpty || !variables.containsKey(field)) {
      throw serverError ?? const ForumApiException('invalid_response', '');
    }
  }
}

class PurchaseQuote {
  final int price, balance;
  final String title, unit, filename, formhash;
  PurchaseQuote._(
    this.price,
    this.balance,
    this.title,
    this.unit,
    this.filename,
    this.formhash,
  );
  factory PurchaseQuote.fromJson(Map<String, dynamic> json) {
    final price = int.tryParse(discuzString(json['price']));
    final balance = int.tryParse(discuzString(json['balance']));
    final credit = discuzMap(json['credit']);
    if (price == null ||
        price <= 0 ||
        balance == null ||
        discuzString(credit['title']).isEmpty) {
      throw const FormatException('Invalid purchase quote');
    }
    return PurchaseQuote._(
      price,
      balance,
      discuzString(credit['title']),
      discuzString(credit['unit']),
      discuzString(json['filename']),
      discuzString(json['formhash']),
    );
  }
  bool sameTerms(PurchaseQuote other) =>
      price == other.price &&
      balance == other.balance &&
      title == other.title &&
      unit == other.unit &&
      filename == other.filename;
}

/// Uses the same authenticated Dio as MobileApiClient. Mutations are never retried.
class ForumInteractionClient {
  final Dio dio;
  final Uri endpoint;
  ForumInteractionClient(this.dio, String baseUrl)
    : endpoint = Uri.parse('${baseUrl.replaceAll(RegExp(r'/+$'), '')}/')
          .resolve('api/mobile/index.php');

  Future<ForumReply> request(
    String module,
    Map<String, dynamic> params, {
    Object? body,
  }) async {
    final response = await dio.requestUri(
      endpoint.replace(
        queryParameters: {
          'version': '4',
          'module': module,
          ...params.map((k, v) => MapEntry(k, '$v')),
        },
      ),
      data: body,
      options: Options(
        method: body == null ? 'GET' : 'POST',
        contentType: body is FormData
            ? Headers.multipartFormDataContentType
            : Headers.formUrlEncodedContentType,
        listFormat: ListFormat.multi,
        // Decode here so malformed replies don't fail inside Dio before we
        // can distinguish an empty response, an AJAX envelope and JSON.
        responseType: ResponseType.plain,
      ),
    );
    return ForumReply.decode(response.data);
  }

  Future<void> addPostComment({
    required int tid,
    required int pid,
    required int uid,
    required String message,
    required bool Function() sameAccount,
  }) async {
    final text = message.trim();
    if (tid <= 0 ||
        pid <= 0 ||
        uid <= 0 ||
        text.isEmpty ||
        text.runes.length > 200) {
      throw const ForumApiException('invalid_comment', '');
    }
    final fresh = await request('viewthread', {'tid': tid, 'viewpid': pid});
    fresh.requireData('formhash');
    final vars = fresh.variables;
    final targetExists = forumRows(vars['postlist']).any(
      (post) =>
          discuzInt(discuzMap(post)['pid']) == pid &&
          discuzInt(discuzMap(post)['tid']) == tid,
    );
    if (!sameAccount() ||
        discuzInt(vars['member_uid']) != uid ||
        !discuzIds(vars['allowpostcomment']).contains('1') ||
        !targetExists ||
        discuzString(vars['formhash']).isEmpty) {
      throw const ForumApiException('comment_unavailable', '');
    }
    final result = await request(
      'sendreply',
      {'tid': tid, 'pid': pid, 'comment': 1},
      body: {
        'commentsubmit': 'yes', 'formhash': vars['formhash'], 'message': text,
        // Never send replysubmit: a disabled comment feature must not create a reply.
      },
    );
    result.requireSuccess({'comment_add_succeed'});
  }

  Future<void> uploadAvatar(List<int> bytes, String hash) async {
    if (bytes.isEmpty || hash.isEmpty)
      throw const ForumApiException('invalid_avatar', '');
    final result = await request(
      'uploadavatar',
      {},
      body: FormData.fromMap({
        'formhash': hash,
        'Filedata': MultipartFile.fromBytes(bytes, filename: 'avatar.png'),
      }),
    );
    result.requireData('uploadavatar');
    if (result.variables['uploadavatar'] != 'api_uploadavatar_success') {
      throw ForumApiException(
        discuzString(result.variables['uploadavatar']),
        result.message,
        fromForum: true,
      );
    }
  }

  Future<void> bestAnswer(int tid, int pid, String hash) async {
    if (tid <= 0 || pid <= 0 || hash.isEmpty)
      throw const ForumApiException('invalid_answer', '');
    final result = await request(
      'bestanswer',
      {'tid': tid, 'pid': pid},
      body: {'formhash': hash, 'bestanswersubmit': 'yes'},
    );
    result.requireSuccess({'reward_completion'});
  }

  Future<void> setReplyPinned({
    required int tid,
    required int pid,
    required int uid,
    required bool pinned,
    required bool Function() sameAccount,
  }) async {
    final fresh = await request('viewthread', {'tid': tid, 'viewpid': pid});
    fresh.requireData('postlist');
    final thread = discuzMap(fresh.variables['thread']);
    final hash = discuzString(fresh.variables['formhash']);
    final fid = discuzInt(fresh.variables['fid']);
    final validReply = forumRows(fresh.variables['postlist']).map(discuzMap).any(
      (post) => discuzInt(post['pid']) == pid &&
          discuzInt(post['tid']) == tid &&
          discuzPermission(post['first']) == false,
    );
    if (!sameAccount() || uid <= 0 || discuzInt(fresh.variables['member_uid']) != uid ||
        discuzInt(thread['authorid']) != uid || !validReply || hash.isEmpty || fid <= 0) {
      throw const ForumApiException('no_privilege_stickreply', '');
    }
    final result = await request('topicadmin', {
      'action': 'stickreply', 'tid': tid, 'fid': fid,
    }, body: {
      'formhash': hash, 'modsubmit': 'yes', 'topiclist[]': [pid],
      'stickreply': pinned ? '1' : '0',
    });
    result.requireSuccess({'admin_succeed'});
  }

  Future<bool?> replyPinStatus(int tid, int pid) async {
    final url = endpoint.resolve('../../forum.php').replace(queryParameters: {
      'mod': 'viewthread', 'tid': '$tid', 'page': '1', 'mobile': 'no',
    });
    final response = await dio.getUri<String>(url, options: Options(responseType: ResponseType.plain));
    final document = parse(response.data);
    if (document.querySelector('#postlist') == null) return null;
    final header = document.querySelector('#postnum$pid');
    return header == null ? null : header.querySelector('.replystick') != null;
  }

  Future<List<Map<String, dynamic>>> myThreads(
    String type,
    int page, {
    String? filter,
    int? uid,
  }) async {
    if (!{'thread', 'reply', 'postcomment'}.contains(type) || page < 1) {
      throw ArgumentError('Invalid list');
    }
    final ForumReply reply;
    try {
      reply = await request('mythread', {
        'type': type,
        'page': page,
        if (filter != null && type != 'postcomment') 'filter': filter,
      });
    } on DioException catch (error) {
      final response = error.response;
      final body = response?.data;
      if (response?.statusCode == 503 && body is String &&
          body.contains('mythread.php') && body.contains('array_values')) {
        throw const ForumApiException('my_content_unavailable', '', fromForum: true);
      }
      rethrow;
    }
    reply.requireData('data');
    if (uid != null && discuzInt(reply.variables['member_uid']) != uid) {
      throw const ForumApiException('account_changed', '');
    }
    return forumRows(reply.variables['data'])
        .map(discuzMap)
        .where((row) => discuzInt(row['tid']) > 0)
        .toList();
  }

  Future<Map<int, String>> profileNames(Set<int> uids, {required int uid}) async {
    final ids = uids.where((id) => id > 0).toList();
    final names = <int, String>{};
    for (var start = 0; start < ids.length; start += 30) {
      final batch = ids.skip(start).take(30).toSet();
      final reply = await request('profiles', {'uids': batch.join(',')});
      reply.requireData('profiles');
      if (discuzInt(reply.variables['member_uid']) != uid) {
        throw const ForumApiException('account_changed', '');
      }
      for (final item in forumRows(reply.variables['profiles'])) {
        final row = discuzMap(item);
        final id = discuzInt(row['uid']);
        final name = discuzString(row['username']).trim();
        if (batch.contains(id) && name.isNotEmpty) names[id] = name;
      }
    }
    return names;
  }

  Future<ForumReply> comments(int tid, int pid, int page) async {
    final reply = await request('viewcomment', {
      'tid': tid,
      'pid': pid,
      'page': page,
    });
    reply.requireData('comments');
    return reply;
  }

  Future<void> recommend(int tid, String hash, {bool positive = true}) async {
    if (hash.isEmpty) throw const ForumApiException('missing_formhash', '');
    final result = await request(
      'threadrecommend',
      {'tid': tid, 'do': positive ? 'add' : 'sub', 'hash': hash},
      body: {'formhash': hash},
    );
    result.requireSuccess({
      'recommend_succeed',
      'recommend_daycount_succeed',
      'recommend_succed',
      'recommend_daycount_succed',
    });
  }

  Future<PurchaseQuote> quote(int tid, {int? aid}) async {
    final result = await request(aid == null ? 'buythread' : 'buyattachment', {
      'tid': tid,
      if (aid != null) 'aid': aid,
    });
    result.requireData('price');
    return PurchaseQuote.fromJson(result.variables);
  }

  Future<void> purchase(int tid, PurchaseQuote quote, {int? aid}) async {
    if (quote.formhash.isEmpty || quote.balance < 0)
      throw const ForumApiException('invalid_quote', '');
    final result = await request(
      aid == null ? 'buythread' : 'buyattachment',
      {'tid': tid, if (aid != null) 'aid': aid},
      body: {'paysubmit': 'yes', 'formhash': quote.formhash},
    );
    result.requireSuccess(
      aid == null
          ? {'thread_pay_succeed'}
          : {'attachment_mobile_buy', 'attachment_buy'},
    );
  }
}

class ForumPurchaseTarget {
  final int tid;
  final int? aid;
  const ForumPurchaseTarget(this.tid, this.aid);
  static ForumPurchaseTarget? parse(
    String baseUrl,
    String? href,
    int? currentTid,
  ) {
    if (href == null) return null;
    final base = Uri.tryParse('${baseUrl.replaceAll(RegExp(r'/+$'), '')}/');
    final relative = Uri.tryParse(href.replaceAll('&amp;', '&'));
    if (base == null || relative == null) return null;
    final url = base.resolveUri(relative);
    if (!{'http', 'https'}.contains(url.scheme) ||
        url.origin != base.origin ||
        url.path != base.resolve('forum.php').path ||
        url.queryParameters['mod'] != 'misc')
      return null;
    final action = url.queryParameters['action'];
    if (action != 'pay' && action != 'attachpay') return null;
    final tid =
        int.tryParse(url.queryParameters['tid'] ?? '') ?? currentTid ?? 0;
    final aid = int.tryParse(url.queryParameters['aid'] ?? '');
    if (tid <= 0 || (action == 'attachpay' && (aid == null || aid <= 0)))
      return null;
    return ForumPurchaseTarget(tid, action == 'attachpay' ? aid : null);
  }
}
