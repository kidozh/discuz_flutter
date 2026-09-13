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
