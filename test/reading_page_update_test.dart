import 'package:discuz_flutter/JsonResult/ErrorResult.dart';
import 'package:discuz_flutter/JsonResult/ViewThreadResult.dart';
import 'package:discuz_flutter/entity/Post.dart';
import 'package:discuz_flutter/utility/reading_page_update.dart';
import 'package:flutter_test/flutter_test.dart';

Post _post(int id) => Post()..pid = id;

void main() {
  test('permission errors cannot append their placeholder posts', () {
    final current = [_post(1)];
    final response = ViewThreadResult()
      ..errorResult = (ErrorResult()
        ..key = 'permission_denied'
        ..content = 'Membership required');
    response.threadVariables.postList = List.generate(30, (i) => _post(i + 2));
    final update = ReadingPageUpdate.fromResponse(response,
        currentPosts: current,
        requestedPage: 2,
        initialPage: 1,
        cachedPrefixCount: 0);
    expect(update, isNull);
    expect(current.map((p) => p.pid), [1]);
  });

  test('plain error strings also reject first-page replacement', () {
    final current = [_post(1)];
    final response = ViewThreadResult()..error = 'Unavailable';
    response.threadVariables.postList = [_post(2)];
    expect(
        ReadingPageUpdate.fromResponse(response,
            currentPosts: current,
            requestedPage: 1,
            initialPage: 1,
            cachedPrefixCount: 0),
        isNull);
    expect(current.single.pid, 1);
  });

  test('a successful retry appends once and advances the requested page', () {
    final current = [_post(1)];
    final response = ViewThreadResult();
    response.threadVariables.postList = [_post(2), _post(3)];
    final update = ReadingPageUpdate.fromResponse(response,
        currentPosts: current,
        requestedPage: 2,
        initialPage: 1,
        cachedPrefixCount: 0)!;
    expect(update.posts.map((p) => p.pid), [1, 2, 3]);
    expect(update.nextPage, 3);
    expect(current.map((p) => p.pid), [1]);
  });

  test('refreshing page one replaces rather than duplicates old posts', () {
    final response = ViewThreadResult();
    response.threadVariables.postList = [_post(10)];
    final update = ReadingPageUpdate.fromResponse(response,
        currentPosts: [_post(1), _post(2)],
        requestedPage: 1,
        initialPage: 1,
        cachedPrefixCount: 0)!;
    expect(update.posts.single.pid, 10);
    expect(update.nextPage, 2);
  });

  test('refreshing the last cached page preserves the earlier-page prefix', () {
    final response = ViewThreadResult();
    response.threadVariables.postList = [_post(30), _post(40)];
    final update = ReadingPageUpdate.fromResponse(response,
        currentPosts: [_post(1), _post(2), _post(3)],
        requestedPage: 3,
        initialPage: 3,
        cachedPrefixCount: 2)!;
    expect(update.posts.map((p) => p.pid), [1, 2, 30, 40]);
    expect(update.nextPage, 4);
  });
}
