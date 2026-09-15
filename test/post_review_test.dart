import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:discuz_flutter/client/ForumInteractionClient.dart';
import 'package:discuz_flutter/client/PostReviewClient.dart';

const source = '''<root><![CDATA[<form id="rateform">
<input name="formhash" value="fresh"><input name="tid" value="10"><input name="pid" value="20">
<table><tr><td>Coins</td><td><input name="score2" value="0"></td><td>-2 ~ 5</td><td>3</td></tr></table>
<div class="xg1">Deducts your own credits</div>
<input name="sendreasonpm" checked disabled></form>]]></root>''';
void main() {
  test(
    'rating form preserves limits, deduction notice and mandatory notification',
    () {
      final form = RatingForm.parse(source, 10, 20);
      expect(form.credits.single.field, 'score2');
      expect(form.credits.single.min, -2);
      expect(form.credits.single.max, 5);
      expect(form.credits.single.remaining, 3);
      expect(form.notifyRequired, isTrue);
      expect(form.notice, 'Deducts your own credits');
      expect(
        form.sameTerms(
          RatingForm.parse(source.replaceFirst('>3<', '>2<'), 10, 20),
        ),
        isFalse,
      );
      expect(
        () => RatingForm.parse(source, 10, 21),
        throwsA(isA<ForumApiException>()),
      );
      expect(
        () => RatingForm.parse('<html>login required</html>', 10, 20),
        throwsA(isA<ForumApiException>()),
      );
    },
  );
  for (final scenario in [
    'support',
    'against',
    'expired',
    'own',
    'first',
    'switched',
    'duplicate',
  ]) {
    test(
      'postreview $scenario validates target and writes only once',
      () async {
        final calls = <RequestOptions>[];
        final dio = Dio()
          ..interceptors.add(
            InterceptorsWrapper(
              onRequest: (r, h) {
                calls.add(r);
                h.resolve(
                  Response(
                    requestOptions: r,
                    data: r.method == 'GET'
                        ? {
                            'Variables': {
                              'member_uid': scenario == 'expired' ? 0 : 7,
                              'formhash': 'fresh',
                              'postlist': [
                                {
                                  'tid': 10,
                                  'pid': 20,
                                  'authorid': scenario == 'own' ? 7 : 9,
                                  'first': scenario == 'first' ? 1 : 0,
                                },
                              ],
                            },
                          }
                        : {
                            'Message': {
                              'messageval': scenario == 'duplicate'
                                  ? 'noreply_voted_error'
                                  : 'thread_poll_succeed',
                            },
                          },
                  ),
                );
              },
            ),
          );
        final future = PostReviewClient(
          ForumInteractionClient(dio, 'https://forum.test/bbs'),
        ).vote(10, 20, 7, scenario != 'against', () => scenario != 'switched');
        if (['support', 'against'].contains(scenario)) {
          await future;
        } else {
          await expectLater(future, throwsA(isA<ForumApiException>()));
        }
        final writes = calls.where((c) => c.method == 'POST').toList();
        expect(
          writes.length,
          ['support', 'against', 'duplicate'].contains(scenario) ? 1 : 0,
        );
        if (writes.isNotEmpty) {
          expect(writes.single.uri.queryParameters['module'], 'forummisc');
          expect(writes.single.uri.queryParameters['action'], 'postreview');
          expect(
            writes.single.uri.queryParameters['do'],
            scenario == 'against' ? 'against' : 'support',
          );
          expect(writes.single.uri.queryParameters['hash'], 'fresh');
          expect(writes.single.uri.queryParameters['pid'], '20');
        }
        dio.close();
      },
    );
  }
  test(
    'rating rejects exceeding allowance and submits exact chosen scores',
    () async {
      final calls = <RequestOptions>[];
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (r, h) {
              calls.add(r);
              h.resolve(
                Response(
                  requestOptions: r,
                  data: r.method == 'GET'
                      ? source
                      : {
                          'Message': {'messageval': 'thread_rate_succeed'},
                        },
                ),
              );
            },
          ),
        );
      final client = PostReviewClient(
        ForumInteractionClient(dio, 'https://forum.test/bbs'),
      );
      final form = await client.ratingForm(10, 20);
      expect(calls.single.uri.path, '/bbs/forum.php');
      await expectLater(
        client.rate(10, 20, form, {'score2': 4}, 'Thanks', false),
        throwsA(isA<ForumApiException>()),
      );
      expect(calls.length, 1);
      await client.rate(10, 20, form, {'score2': 2}, 'Thanks', false);
      expect(calls.last.data, {
        'formhash': 'fresh',
        'tid': 10,
        'pid': 20,
        'score2': 2,
        'reason': 'Thanks',
        'sendreasonpm': 'on',
      });
      expect(calls.last.uri.queryParameters['ratesubmit'], 'yes');
      expect(calls.last.uri.queryParameters['t'], 'output');
      dio.close();
    },
  );
}
