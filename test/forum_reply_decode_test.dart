import 'package:flutter_test/flutter_test.dart';
import 'package:discuz_flutter/client/ForumInteractionClient.dart';

void main() {
  const json = '{"Message":{"messageval":"thread_rate_succeed"}}';
  for (final response in [
    json,
    '\uFEFF$json',
    '<?xml version="1.0"?><root><![CDATA[$json]]></root>',
  ]) {
    test('accepts explicit success in a supported response envelope', () {
      ForumReply.decode(response).requireSuccess({'thread_rate_succeed'});
    });
  }
  for (final entry in {
    '': 'empty_response',
    '<html>thread_rate_succeed</html>': 'unexpected_markup_response',
    '<root><![CDATA[<script>success()</script>]]></root>':
        'unexpected_markup_response',
    '{broken': 'invalid_response_format',
  }.entries) {
    test('does not treat ${entry.value} as success', () {
      expect(
        () => ForumReply.decode(entry.key),
        throwsA(
          isA<ForumApiException>().having((e) => e.code, 'code', entry.value),
        ),
      );
    });
  }
  test('keeps rejection inside AJAX envelope', () {
    final reply = ForumReply.decode(
      '<root><![CDATA[{"Message":{"messageval":"thread_rate_ctrl","messagestr":"额度不足"}}]]></root>',
    );
    expect(
      () => reply.requireSuccess({'thread_rate_succeed'}),
      throwsA(
        isA<ForumApiException>().having((e) => e.message, 'message', '额度不足'),
      ),
    );
  });
}
