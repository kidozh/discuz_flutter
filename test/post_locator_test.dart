import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:discuz_flutter/utility/post_locator.dart';

void main() {
  test(
    'notification and quote links preserve PID across the common URL forms',
    () {
      for (final url in [
        'https://forum.test/forum.php?mod=redirect&goto=findpost&ptid=20&pid=31',
        'https://forum.test/forum.php?mod=viewthread&tid=20#pid31',
        'https://forum.test/forum.php?mod=viewthread&tid=20#post_31',
        'https://forum.test/forum.php?mod=viewthread&tid=20&viewpid=31',
      ]) {
        final target = PostLinkTarget.parse(Uri.parse(url))!;
        expect(target.tid, 20);
        expect(target.pid, 31);
      }
    },
  );
  test(
    'deleted post redirect and foreign destinations cannot silently open a wrong floor',
    () {
      final base = Uri.parse('https://forum.test/');
      expect(
        PostLocator.parseDestination(
          base,
          'forum.php?mod=viewthread&tid=20',
          20,
          31,
        ),
        isNull,
      );
      expect(
        PostLocator.parseDestination(
          base,
          'https://other.test/forum.php?mod=viewthread&tid=20&page=3#pid31',
          20,
          31,
        ),
        isNull,
      );
      expect(
        PostLocator.parseDestination(
          base,
          'forum.php?mod=viewthread&tid=21&page=3#pid31',
          20,
          31,
        ),
        isNull,
      );
      expect(
        PostLocator.parseDestination(
          base,
          'forum.php?mod=viewthread&tid=20&page=3#pid31',
          20,
          31,
        ),
        3,
      );
    },
  );
  test(
    'server chooses page and default ppp, not the client floor-number approximation',
    () async {
      final requests = <RequestOptions>[];
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              requests.add(options);
              if (options.uri.path.endsWith('forum.php')) {
                handler.resolve(
                  Response(
                    requestOptions: options,
                    statusCode: 301,
                    headers: Headers.fromMap({
                      'location': [
                        'forum.php?mod=viewthread&tid=20&page=4#pid31',
                      ],
                    }),
                    data: '',
                  ),
                );
              } else {
                handler.resolve(
                  Response(
                    requestOptions: options,
                    statusCode: 200,
                    data: {
                      'Variables': {
                        'ppp': '10',
                        'thread': {'tid': '20'},
                        'postlist': [
                          {'tid': '20', 'pid': '31', 'position': '77'},
                        ],
                      },
                    },
                  ),
                );
              }
            },
          ),
        );
      final result = await PostLocator.locate(
        dio,
        'https://forum.test/bbs',
        20,
        31,
      );
      expect(result.page, 4);
      expect(result.result.threadVariables.ppp, '10');
      expect(requests.last.uri.path, '/bbs/api/mobile/index.php');
      expect(requests.last.uri.queryParameters['page'], '4');
      expect(requests.last.uri.queryParameters.containsKey('ppp'), false);
      expect(requests.first.followRedirects, false);
      expect(requests.last.uri.queryParameters['ordertype'], '0');
      dio.close();
    },
  );
  test('middle-page pagination stops at the absolute last page', () {
    expect(hasMoreThreadPages(page: 4, postsPerPage: 10, replies: 40), true);
    expect(hasMoreThreadPages(page: 5, postsPerPage: 10, replies: 40), false);
    expect(hasMoreThreadPages(page: 4, postsPerPage: 10, replies: 39), false);
  });
  test('permission errors containing placeholder posts are rejected', () async {
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                headers: Headers.fromMap({
                  'location': ['forum.php?mod=viewthread&tid=20&page=1#pid31'],
                }),
                data: options.uri.path.endsWith('forum.php')
                    ? ''
                    : {'error': 'permission_denied'},
              ),
            );
          },
        ),
      );
    await expectLater(
      PostLocator.locate(dio, 'https://forum.test', 20, 31),
      throwsFormatException,
    );
    dio.close();
  });
}
