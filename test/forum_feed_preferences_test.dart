import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:discuz_flutter/client/ForumInteractionClient.dart';
import 'package:discuz_flutter/utility/ForumFeedPreferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('dynamic catalog, default all, selection and explicit none', () async {
    var calls = 0;
    var fids = ['3', '1'];
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) {
            calls++;
            handler.resolve(
              Response(
                requestOptions: request,
                data: {
                  'Variables': {
                    'forumlist': [
                      for (final fid in fids)
                        {'fid': fid, 'name': 'Forum $fid'},
                    ],
                  },
                },
              ),
            );
          },
        ),
      );
    final client = ForumInteractionClient(dio, 'https://forum.test');
    expect(await ForumFeedPreferences.resolveFids('site:1', client), '1,3');
    expect(await ForumFeedPreferences.resolveFids('site:1', client), '1,3');
    expect(calls, 1);
    await ForumFeedPreferences.saveSelection('site:1', ['3', '3', '99']);
    expect(await ForumFeedPreferences.resolveFids('site:1', client), '3');
    await ForumFeedPreferences.saveSelection('site:1', []);
    expect(await ForumFeedPreferences.resolveFids('site:1', client), '');
    expect(calls, 1);
    await ForumFeedPreferences.saveSelection('site:1', null);
    fids = ['1', '3', '7'];
    await ForumFeedPreferences.forums('site:1', client, refresh: true);
    expect(await ForumFeedPreferences.resolveFids('site:1', client), '1,3,7');
    dio.close();
  });
  test('nested forums refresh older catalogs, deduplicate and keep independent choices', () async {
    const scope = 'site:1';
    SharedPreferences.setMockInitialValues({
      'forum_feed_v1:$scope:selection': ['9'],
      'forum_feed_v1:$scope:forums': jsonEncode({
        'time': DateTime.now().millisecondsSinceEpoch,
        'rows': [
          {'fid': '1', 'name': 'Parent'},
          {'fid': '9', 'name': 'Other'},
        ],
      }),
    });
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) {
            handler.resolve(
              Response(
                requestOptions: request,
                data: {
                  'Variables': {
                    'forumlist': [
                      {'fid': 2, 'name': 'Child'},
                      {
                        'fid': '1',
                        'name': 'Parent',
                        'sublist': {
                          '2': {
                            'fid': '2',
                            'name': 'Child',
                            'sublist': [
                              {'fid': 3, 'name': 'Grandchild'},
                            ],
                          },
                        },
                      },
                      {'fid': 9, 'name': 'Other'},
                    ],
                  },
                },
              ),
            );
          },
        ),
      );
    addTearDown(dio.close);
    final client = ForumInteractionClient(dio, 'https://forum.test');
    expect(await ForumFeedPreferences.forums(scope, client), [
      {'fid': '1', 'name': 'Parent'},
      {'fid': '2', 'name': 'Child', 'depth': 1},
      {'fid': '3', 'name': 'Grandchild', 'depth': 2},
      {'fid': '9', 'name': 'Other'},
    ]);
    expect(await ForumFeedPreferences.resolveFids(scope, client), '2,3,9');
    await ForumFeedPreferences.saveSelection(scope, ['1', '3', '9']);
    expect(await ForumFeedPreferences.resolveFids(scope, client), '1,3,9');
  });
  test(
    'feed cache is scoped by account and exact selection and cleared on edit',
    () async {
      await ForumFeedPreferences.saveFeed('site:1', '1,3', {
        'data': 'first account',
      });
      expect(await ForumFeedPreferences.cachedFeed('site:2', '1,3'), isNull);
      expect(await ForumFeedPreferences.cachedFeed('other:1', '1,3'), isNull);
      expect(await ForumFeedPreferences.cachedFeed('site:1', '3'), isNull);
      expect(await ForumFeedPreferences.cachedFeed('site:1', '1,3'), {
        'data': 'first account',
      });
      await ForumFeedPreferences.saveSelection('site:1', ['3']);
      expect(await ForumFeedPreferences.cachedFeed('site:1', '1,3'), isNull);
      expect(await ForumFeedPreferences.selection('site:2'), isNull);
    },
  );
  test(
    'new forums default on while previous opt-outs survive disappearance',
    () async {
      await ForumFeedPreferences.saveSelection(
        'site:1',
        [],
        knownIds: ['1', '2'],
      );
      expect(
        await ForumFeedPreferences.selectedFor('site:1', ['1', '2', '3']),
        {'3'},
      );
      await ForumFeedPreferences.saveSelection(
        'site:1',
        ['3'],
        knownIds: ['2', '3'],
      );
      expect(
        await ForumFeedPreferences.selectedFor('site:1', ['1', '2', '3', '4']),
        {'3', '4'},
      );
      expect(await ForumFeedPreferences.selectedFor('site:2', ['1', '2']), {
        '1',
        '2',
      });
    },
  );
  test(
    'legacy choices migrate against previous catalog, not new forums',
    () async {
      SharedPreferences.setMockInitialValues({
        'forum_feed_v1:site:1:selection': ['1'],
        'forum_feed_v1:site:1:forums': jsonEncode({
          'rows': [
            {'fid': '1'},
            {'fid': '2'},
          ],
          'time': 0,
        }),
      });
      expect(
        await ForumFeedPreferences.selectedFor('site:1', ['1', '2', '3']),
        {'1', '3'},
      );
    },
  );
}
