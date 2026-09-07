import 'package:discuz_flutter/JsonResult/PrivateMessageDetailResult.dart';
import 'package:discuz_flutter/utility/private_message_pagination.dart';
import 'package:flutter_test/flutter_test.dart';

PrivateMessageDetailVariables response(int page, {int count = 35}) =>
    PrivateMessageDetailVariables()
      ..page = page
      ..count = count
      ..perPage = 10
      ..pmList = [PrivateMessageDetail()..pmId = page * 10];

void main() {
  test('opens latest messages then walks backwards to the oldest page', () {
    final pagination = PrivateMessagePagination();
    expect(pagination.pageFor(), 0);
    pagination.accept(response(4));
    expect(pagination.pageFor(), 3);
    expect(pagination.hasMore, isTrue);
    pagination.accept(response(3));
    expect(pagination.pageFor(), 2);
    pagination.accept(response(2));
    expect(pagination.pageFor(), 1);
    pagination.accept(response(1));
    expect(pagination.hasMore, isFalse);
  });

  test('refresh discovers a new latest page after history was exhausted', () {
    final pagination = PrivateMessagePagination()..accept(response(1));
    expect(pagination.pageFor(latest: true), 0);
    pagination.accept(response(5, count: 41));
    expect(pagination.pageFor(), 4);
    expect(pagination.hasMore, isTrue);
  });

  test(
      'empty conversation and empty history stop without requesting page zero again',
      () {
    for (final page in [0, 1, 3]) {
      final pagination = PrivateMessagePagination()
        ..accept(response(page)..pmList = []);
      expect(pagination.hasMore, isFalse);
      expect(pagination.pageFor(latest: true), 0);
    }
  });

  test(
      'single page is complete even when server count includes hidden messages',
      () {
    final pagination = PrivateMessagePagination()..accept(response(1));
    expect(pagination.hasMore, isFalse);
  });

  test('failed request leaves older-page cursor available for retry', () {
    final pagination = PrivateMessagePagination()..accept(response(4));
    expect(pagination.pageFor(), 3);
    // No accepted response: neither a history request nor a refresh may move it.
    expect(pagination.pageFor(latest: true), 0);
    expect(pagination.pageFor(), 3);
    expect(pagination.hasMore, isTrue);
  });
}
