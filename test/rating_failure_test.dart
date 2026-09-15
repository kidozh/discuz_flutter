import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:discuz_flutter/client/ForumInteractionClient.dart';
import 'package:discuz_flutter/utility/rating_failure.dart';

void main() {
  test('preserves a server rejection and code without inventing a cause', () {
    expect(
      ratingFailureMessage(
        const ForumApiException('thread_rate_ctrl', '今日评分额度不足'),
        '结果未知',
      ),
      '今日评分额度不足\n[thread_rate_ctrl]',
    );
    expect(
      ratingFailureMessage(
        const ForumApiException('post_review_unavailable', ''),
        '提交前检查失败',
      ),
      '提交前检查失败\n[post_review_unavailable]',
    );
  });

  test('network diagnostics do not expose request or response contents', () {
    final request = RequestOptions(
      path: 'https://private.test/?token=secret',
      headers: {'Cookie': 'secret'},
      data: {'reason': 'private reason', 'formhash': 'secret'},
    );
    final error = DioException(
      requestOptions: request,
      type: DioExceptionType.badResponse,
      message: 'private details',
      response: Response(
        requestOptions: request,
        statusCode: 403,
        data: 'private response',
      ),
    );
    expect(ratingFailureCode(error), 'network_badResponse_http_403');
    expect(
      ratingFailureCode(const FormatException('private response')),
      'invalid_response_format',
    );
  });

  test('mobile API top-level errors retain their server code', () {
    final response = ForumReply({'error': 'module_not_exists'});
    expect(
      () => response.requireSuccess({'thread_rate_succeed'}),
      throwsA(
        isA<ForumApiException>().having(
          (error) => error.code,
          'code',
          'module_not_exists',
        ),
      ),
    );
  });
}
