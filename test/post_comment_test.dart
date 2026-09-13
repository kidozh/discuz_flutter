import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:discuz_flutter/client/ForumInteractionClient.dart';
import 'package:discuz_flutter/JsonResult/ViewThreadResult.dart';

void main() {
  test(
    'comment mode survives cache serialization and malformed values deny',
    () {
      for (final raw in [
        ['1'],
        [1, 2],
        {'0': '1'},
      ]) {
        final value = ThreadVariables.fromJson({'allowpostcomment': raw});
        expect(value.commentsEnabled, isTrue);
        expect(
          ThreadVariables.fromJson(value.toJson()).commentsEnabled,
          isTrue,
        );
      }
      for (final raw in [
        null,
        false,
        '1',
        ['2'],
      ]) {
        expect(
          ThreadVariables.fromJson({'allowpostcomment': raw}).commentsEnabled,
          isFalse,
        );
      }
    },
  );
  for (final scenario in [
    'success',
    'expired',
    'missing_target',
    'disabled',
    'switched',
    'rejected',
  ]) {
    test('post comment $scenario', () async {
      final calls = <RequestOptions>[];
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (request, handler) {
              calls.add(request);
              handler.resolve(
                Response(
                  requestOptions: request,
                  data: request.method == 'GET'
                      ? {
                          'Variables': {
                            'member_uid': scenario == 'expired' ? '0' : '7',
                            'formhash': 'fresh-token',
                            'allowpostcomment': scenario == 'disabled'
                                ? []
                                : ['1'],
                            'postlist': scenario == 'missing_target'
                                ? []
                                : [
                                    {'tid': '10', 'pid': '20'},
                                  ],
                          },
                        }
                      : {
                          'Message': {
                            'messageval': scenario == 'rejected'
                                ? 'postcomment_error'
                                : 'comment_add_succeed',
                          },
                        },
                ),
              );
            },
          ),
        );
      final result = ForumInteractionClient(dio, 'https://forum.example')
          .addPostComment(
            tid: 10,
            pid: 20,
            uid: 7,
            message: ' hello ',
            sameAccount: () => scenario != 'switched',
          );
      if (scenario == 'success') {
        await result;
      } else {
        await expectLater(result, throwsA(isA<ForumApiException>()));
      }
      final writes = calls
          .where((request) => request.method == 'POST')
          .toList();
      expect(writes.length, ['success', 'rejected'].contains(scenario) ? 1 : 0);
      if (writes.isNotEmpty) {
        final request = writes.single;
        expect(request.uri.queryParameters['module'], 'sendreply');
        expect(request.uri.queryParameters['pid'], '20');
        expect(request.uri.queryParameters['comment'], '1');
        expect(request.data, {
          'commentsubmit': 'yes',
          'formhash': 'fresh-token',
          'message': 'hello',
        });
        expect(request.uri.queryParameters.containsKey('replysubmit'), isFalse);
      }
      dio.close();
    });
  }
}
