import 'dart:convert';

import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/utility/forum_attachment_history.dart';
import 'package:discuz_flutter/utility/forum_feed_filters.dart';
import 'package:discuz_flutter/utility/forum_local_records.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Discuz forum(String url) =>
    Discuz(url, '', 'utf-8', 4, '', '', false, '', '', '', '', '', '');

User member(Discuz site, int uid) =>
    User('', '', 'Tester', '', 1, uid, 0, site);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'local list serializes concurrent records and isolates member and site',
    () async {
      SharedPreferences.setMockInitialValues({});
      final site = forum('https://forum.test/bbs');
      final user = member(site, 1);
      final records = ForumLocalRecords('history-test', site, user);
      await Future.wait([
        records.put({'id': 'first', 'query': 'Riverside'}),
        records.put({'id': 'second', 'query': 'Library'}),
        records.put({'id': 'first', 'query': 'Riverside', 'fids': 4}),
      ]);
      expect(records.value.map((row) => row['id']), ['first', 'second']);
      expect(records.value.first['fids'], 4);
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(prefs.getKeys().single)!;
      expect(saved.map((row) => jsonDecode(row)['id']), ['first', 'second']);
      final guest = ForumLocalRecords('history-test', site, null);
      final otherUser = ForumLocalRecords(
        'history-test',
        site,
        member(site, 2),
      );
      final otherSite = ForumLocalRecords(
        'history-test',
        forum('https://forum.test/other'),
        user,
      );
      await Future.wait([guest.ready, otherUser.ready, otherSite.ready]);
      expect([
        guest.value,
        otherUser.value,
        otherSite.value,
      ], everyElement(isEmpty));
      await records.remove('first');
      expect(records.value.single['id'], 'second');
    },
  );

  test('muted IDs and normalized keywords can coexist with board scope', () {
    final rules = <ForumRecord>[
      {'tid': 13},
      {'word': normalizeForumKeyword('  TRAIL   meetup ')},
      {'word': 'photography', 'fid': 7},
    ];
    expect(hidesForumThread(rules, 13, 'Anything'), isTrue);
    expect(hidesForumThread(rules, 14, 'Next Trail Meetup'), isTrue);
    expect(
      hidesForumThread(
        rules,
        14,
        'Community calendar',
        excerpt: 'Trail meetup',
      ),
      isTrue,
    );
    expect(hidesForumThread(rules, 14, 'Photography', fid: 7), isTrue);
    expect(hidesForumThread(rules, 14, 'Photography', fid: 8), isFalse);
    expect(hidesForumThread(rules, 14, 'Unrelated'), isFalse);
  });

  test('signed download references retain IDs and discard the signed URL', () {
    final token = base64Encode(ascii.encode('15|sample-token|100|1|42'));
    final url = Uri.https('forum.test', '/bbs/forum.php', {
      'mod': 'attachment',
      'aid': token,
    });
    final ref = ForumAttachmentReference.fromUrl(url, pid: 125)!;
    expect((ref.tid, ref.pid, ref.aid, ref.id), (42, 125, 15, '42:15'));
    final crossThread = ForumAttachmentReference.fromUrl(
      url,
      tid: 43,
      pid: 126,
    )!;
    expect((crossThread.tid, crossThread.pid), (42, 0));
    expect(
      ForumAttachmentReference.fromUrl(url.replace(query: 'aid=%21')),
      isNull,
    );
  });
}
