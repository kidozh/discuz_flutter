import 'dart:convert';
import 'package:dio/dio.dart';
import '../utility/discuz_json.dart';

Iterable<dynamic> forumRows(Object? value) => value is Map
    ? value.values
    : value is List
    ? value
    : const [];

class ForumApiException implements Exception {
  final String code;
  final String message;
  const ForumApiException(this.code, this.message);
  @override
  String toString() => message.isEmpty ? code : message;
}

class ForumReply {
  final Map<String, dynamic> variables;
  final String code, message;
  ForumReply(Object? data)
    : variables = discuzMap(discuzMap(data)['Variables']),
      code = discuzString(discuzMap(discuzMap(data)['Message'])['messageval']),
      message = discuzString(
        discuzMap(discuzMap(data)['Message'])['messagestr'],
      );
  void requireSuccess(Set<String> codes) {
    if (!codes.contains(code)) {
      throw ForumApiException(
        code.isEmpty ? 'invalid_response' : code,
        message,
      );
    }
  }

  void requireData(String field) {
    if (code.isNotEmpty || !variables.containsKey(field)) {
      throw ForumApiException(
        code.isEmpty ? 'invalid_response' : code,
        message,
      );
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
      throw const ForumApiException('invalid_quote', '');
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
    : endpoint = Uri.parse(
        '${baseUrl.replaceAll(RegExp(r'/+$'), '')}/',
      ).resolve('api/mobile/index.php');

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
        responseType: ResponseType.json,
      ),
    );
    final data = response.data is String
        ? jsonDecode(response.data as String)
        : response.data;
    if (data is! Map) throw const ForumApiException('invalid_response', '');
    return ForumReply(data);
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

  Future<List<Map<String, dynamic>>> myThreads(String type, int page) async {
    if (!{'thread', 'reply'}.contains(type) || page < 1)
      throw ArgumentError('Invalid list');
    final reply = await request('mythread', {'type': type, 'page': page});
    reply.requireData('data');
    return forumRows(
      reply.variables['data'],
    ).map(discuzMap).where((row) => discuzInt(row['tid']) > 0).toList();
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
