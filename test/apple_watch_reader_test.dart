import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/client/ForumInteractionClient.dart';
import 'package:discuz_flutter/utility/AiPostText.dart';
import 'package:discuz_flutter/utility/apple_watch_reader.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeForum extends ForumInteractionClient {
  FakeForum() : super(Dio(), 'https://forum.example');
  int uid = 7;
  Object? permission = '1';
  bool closed = false;
  String responseCode = 'post_reply_succeed';
  void Function(String)? afterRead;
  final writes = <Map<String, dynamic>>[];
  final reads = <String>[];
  @override
  Future<ForumReply> request(
    String module,
    Map<String, dynamic> params, {
    Object? body,
  }) async {
    if (body != null) {
      writes.add(Map<String, dynamic>.of(body as Map<String, dynamic>));
      return ForumReply({
        'Message': {'messageval': responseCode},
      });
    }
    reads.add(module);
    afterRead?.call(module);
    return ForumReply({
      'Variables': {
        'member_uid': uid,
        'formhash': 'phone-only-formhash',
        'fid': 2,
        'ppp': 3,
        if (module == 'viewthread') ...{
          'thread': {
            'tid': 42,
            'fid': 2,
            'subject': 'Thread',
            'closed': closed ? 1 : 0,
            'replies': 8,
          },
          'postlist': [
            {'pid': 1, 'author': 'Author', 'message': '<p>Full post</p>'},
          ],
        },
        if (module == 'checkpost') 'allowperm': {'allowreply': permission},
        if (module == 'mypm') ...{
          'list': [
            {'pmid': 1, 'msgfrom': 'Alice', 'message': 'Private text'},
          ],
          'count': 21,
          'perpage': 10,
        },
      },
    });
  }
}

void main() {
  test('notification links resolve only forum-local thread identifiers', () {
    expect(
      watchNotificationThreadID(
        'https://forum.example',
        0,
        'post',
        '<a href="forum.php?mod=redirect&amp;ptid=42&amp;pid=1">Thread</a>',
      ),
      42,
    );
    expect(
      watchNotificationThreadID(
        'https://forum.example',
        0,
        '',
        '<a href="thread-43-1-1.html">Thread</a>',
      ),
      43,
    );
    expect(
      watchNotificationThreadID(
        'https://forum.example',
        0,
        '',
        '<a href="https://other.example/?tid=99">Other</a>',
      ),
      0,
    );
  });
  final item = <String, Object>{'id': 42, 'title': 'Thread'};
  late FakeForum forum;
  late bool current;
  late WatchReader reader;
  setUp(() {
    forum = FakeForum();
    current = true;
    reader = WatchReader(forum, 7, () => current);
  });
  tearDown(() => forum.dio.close(force: true));

  test('long Unicode text is readable across bounded parts without truncation', () {
    final source =
        '<p>${List.filled(3000, '中文😀 &amp; text ').join()}</p><script>hidden</script>';
    final output = StringBuffer();
    for (var part = 0; ; part++) {
      final page = watchReadingPart(
        [
          {'id': 1, 'author': 'Author', 'body': source},
        ],
        part: part,
        title: 'Title',
        page: 1,
        hasNextPage: false,
        canReply: false,
      );
      expect(utf8.encode(jsonEncode(page)).length, lessThan(60000));
      for (final block in page['blocks'] as List) {
        output.write(block['body']);
      }
      if (page['hasNextPart'] == false) break;
    }
    expect(output.toString(), AiPostText.plainText(source));
    expect(output.toString(), isNot(contains('hidden')));
  });

  test('full reading returns pagination and no credentials', () async {
    final page = await reader.load('threads', item, 1, 0);
    expect(page['hasNextPage'], true);
    expect(page['canReply'], true);
    expect(jsonEncode(page), isNot(contains('phone-only-formhash')));
    expect((page['blocks'] as List).first['body'], 'Full post');
  });

  test('expired session cannot read or send another account content', () async {
    forum.uid = 8;
    await expectLater(
      reader.load('messages', item, 1, 0),
      throwsA(isA<WatchSessionExpired>()),
    );
    await expectLater(
      reader.send('messages', item, 'Hello'),
      throwsA(isA<WatchSessionExpired>()),
    );
    expect(forum.writes, isEmpty);
  });

  test('account change during permission check prevents the POST', () async {
    forum.afterRead = (module) {
      if (module == 'checkpost') current = false;
    };
    await expectLater(reader.send('threads', item, 'Hello'), throwsStateError);
    expect(forum.writes, isEmpty);
  });

  test('closed thread and denied or unknown permissions never post', () async {
    for (final permission in [null, '0']) {
      forum.permission = permission;
      await expectLater(
        reader.send('threads', item, 'Hello'),
        throwsStateError,
      );
    }
    forum.permission = '1';
    forum.closed = true;
    await expectLater(reader.send('threads', item, 'Hello'), throwsStateError);
    expect(forum.writes, isEmpty);
  });

  test(
    'reply uses a fresh phone-only formhash and performs one write',
    () async {
      await reader.send('threads', item, ' Hello 😀 ');
      expect(forum.reads, ['viewthread', 'checkpost']);
      expect(forum.writes.single, {
        'fid': 2,
        'tid': 42,
        'formhash': 'phone-only-formhash',
        'message': 'Hello 😀',
      });
    },
  );

  test(
    'private reply targets the selected conversation and reads older pages',
    () async {
      final page = await reader.load('messages', item, 1, 0);
      expect(page['hasNextPage'], true);
      forum.responseCode = 'do_success';
      await reader.send('messages', item, 'Watch message');
      expect(forum.writes.single['touid'], 42);
      expect(forum.writes.single['message'], 'Watch message');
    },
  );

  test('verification rejection and invalid drafts are never retried', () async {
    forum.responseCode = 'submit_seccode_invalid';
    await expectLater(
      reader.send('threads', item, 'Hello'),
      throwsA(isA<ForumApiException>()),
    );
    expect(forum.writes, hasLength(1));
    await expectLater(reader.send('threads', item, ' '), throwsStateError);
    await expectLater(
      reader.send('threads', item, List.filled(1001, 'a').join()),
      throwsStateError,
    );
    expect(forum.writes, hasLength(1));
  });
}
