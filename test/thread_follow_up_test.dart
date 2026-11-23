import 'dart:io';

import 'package:discuz_flutter/dao/ViewThreadScrollDistanceDao.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/Post.dart';
import 'package:discuz_flutter/entity/ViewThreadScrollDistance.dart';
import 'package:discuz_flutter/utility/post_locator.dart';
import 'package:discuz_flutter/utility/thread_attachments.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

Discuz forum(String url) =>
    Discuz(url, 'X3.5', 'utf-8', 4, '', '', false, '', '', '', '', '', '');

void main() {
  test(
    'reading checkpoints persist independently for accounts and forums',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'thread-progress-',
      );
      final hive = Hive;
      hive.init(directory.path);
      hive.registerAdapter(DiscuzAdapter());
      hive.registerAdapter(ViewThreadScrollDistanceAdapter());
      addTearDown(() async {
        await hive.close();
        await directory.delete(recursive: true);
      });

      final first = forum('https://forum.example/first');
      final second = forum('https://forum.example/second');
      final now = DateTime.now();
      final box = await hive.openBox<ViewThreadScrollDistance>('progress');
      final dao = ViewThreadScrollDistanceDao(box);
      ViewThreadScrollDistance record(
        Discuz site,
        int uid,
        int pid,
        bool ascending,
        DateTime at,
      ) => ViewThreadScrollDistance(
        10,
        200,
        site,
        at,
        ascending,
        uid: uid,
        pid: pid,
        repliesAtRead: 0,
      );

      await dao.insertViewThreadScrollDistance(record(first, 1, 11, true, now));
      await dao.insertViewThreadScrollDistance(record(first, 2, 12, true, now));
      await dao.insertViewThreadScrollDistance(
        record(second, 1, 13, true, now),
      );
      await dao.insertViewThreadScrollDistance(
        record(first, 1, 14, false, now.add(const Duration(seconds: 1))),
      );
      await dao.insertViewThreadScrollDistance(
        record(first, 1, 15, true, now.subtract(const Duration(days: 1))),
      );
      await box.add(ViewThreadScrollDistance(10, 500, first, now, true));

      await box.close();
      final reopened = ViewThreadScrollDistanceDao(
        await hive.openBox('progress'),
      );
      final updated = forum('https://FORUM.example:443/first/')
        ..siteName = 'New name';
      final progress = reopened.latestProgress(updated, 1, 10)!;
      expect(progress.pid, 14);
      expect(progress.hasUpdates(1), isTrue);
      expect(progress.hasUpdates(0), isFalse);
      expect(
        reopened.findViewThreadCacheListByDiscuz(first, 10, true, uid: 1)?.pid,
        11,
      );
      expect(reopened.latestProgress(first, 2, 10)?.pid, 12);
      expect(reopened.latestProgress(second, 1, 10)?.pid, 13);
      expect(reopened.latestProgress(first, 0, 10), isNull);
    },
  );

  test('latest reply ignores the original post and an older pinned reply', () {
    Post post(int pid, int tid, int minute, {bool first = false}) => Post()
      ..pid = pid
      ..tid = tid
      ..publishAt = DateTime(2026, 11, 21, 10, minute)
      ..first = first;
    final original = post(5, 10, 0, first: true);
    final replies = [
      original,
      post(12, 10, 1),
      post(15, 10, 4),
      post(16, 10, 4),
      post(17, 20, 5),
    ];
    expect(latestVisiblePostPid(replies, tid: 10), 16);
    expect(latestVisiblePostPid([original], tid: 10), 5);
    expect(latestVisiblePostPid(replies, tid: 11), isNull);
  });

  test(
    'overview retains paid metadata and includes marked inline images once',
    () {
      final file = Attachment()
        ..tid = 42
        ..pid = 28
        ..aid = 2
        ..filename = 'paid.zip'
        ..price = 3
        ..aidEncode = 'purchase-required';
      final voice = Attachment()
        ..aid = 3
        ..filename = 'disfly-voice-qa-3s.mp3';
      final listedImage = Attachment()
        ..aid = 4
        ..url = 'data/attachment/forum/listed.jpg'
        ..filename = 'listed.jpg';
      final foreign = Attachment()
        ..pid = 100
        ..aid = 5;
      final post = Post()
        ..tid = 42
        ..pid = 28
        ..imageIdList = ['4']
        ..attachmentMapper = {
          '2': file,
          '3': voice,
          '4': listedImage,
          '5': foreign,
        }
        ..message =
            '<img src="data/attachment/forum/inline.jpg.thumb.jpg" '
            'file="data/attachment/forum/inline.jpg" attach="28"/>'
            '<img src="data/attachment/forum/listed.jpg" attach="28"/>'
            '<img src="https://external.example/a.jpg"/>'
            '<img src="data/attachment/forum/other.jpg" attach="90"/>';
      final attachments = ThreadAttachment.fromPost(
        forum('https://forum.example/install'),
        post,
      ).toList();
      expect(attachments.map((entry) => entry.attachment.filename), [
        'paid.zip',
        'disfly-voice-qa-3s.mp3',
        'listed.jpg',
        'inline.jpg',
      ]);
      expect(attachments.first.attachment, same(file));
      expect(attachments.first.attachment.payed, isFalse);
      expect(attachments.skip(2).every((entry) => entry.isListedImage), isTrue);
      expect(attachments.every((entry) => entry.post.pid == 28), isTrue);
      expect(
        attachments.last.inlineThumbnail.toString(),
        'https://forum.example/install/data/attachment/forum/inline.jpg.thumb.jpg',
      );
    },
  );
}
