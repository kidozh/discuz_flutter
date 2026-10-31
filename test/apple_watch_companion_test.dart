import 'dart:async';
import 'dart:convert';

import 'package:discuz_flutter/JsonResult/BaseVariableResult.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/utility/apple_watch_companion.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  const codec = StandardMethodCodec();
  late DiscuzAndUserNotifier selection;
  late AppleWatchCompanion companion;
  late Discuz discuz;
  late User user;
  late List<Map<Object?, Object?>> published;
  late List<String> requested;
  late WatchSectionLoader loader;
  late int opened;

  Future<Object?> fromWatch(String method, [Object? args]) async {
    final result = Completer<Object?>();
    binding.defaultBinaryMessenger.handlePlatformMessage(
      AppleWatchCompanion.channel.name,
      codec.encodeMethodCall(MethodCall(method, args)),
      (response) => result.complete(codec.decodeEnvelope(response!)),
    );
    return result.future;
  }

  WatchSection content(User? account, {String title = 'Preview'}) {
    final variables = BaseVariableResult()
      ..member_uid = account?.uid ?? 0
      ..auth = 'server-auth-secret'
      ..formHash = 'formhash-secret'
      ..noticeCount = (NoticeCount()
        ..newpm = 2
        ..newmypost = 3
        ..newprompt = 4);
    return WatchSection(variables, [
      {
        'id': 42,
        'title': title,
        'subtitle': '',
        'body': 'Text',
        'unread': false,
        'replies': 0,
      },
    ]);
  }

  setUp(() async {
    discuz = Discuz(
      'https://forum.example',
      'X3.5',
      'utf-8',
      4,
      '1',
      '',
      false,
      '',
      '',
      'Forum',
      '',
      '',
      '',
    );
    user = User(
      'account-auth-secret',
      'saltkey-secret',
      'Alice',
      '',
      1,
      7,
      10,
      discuz,
    );
    selection = DiscuzAndUserNotifier()
      ..initDiscuz(discuz)
      ..setUser(user);
    published = [];
    requested = [];
    opened = 0;
    loader = (_, account, section) async {
      requested.add(section);
      return content(account);
    };
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      AppleWatchCompanion.channel,
      (call) async {
        if (call.method == 'publishSnapshot') {
          published.add(Map<Object?, Object?>.from(call.arguments as Map));
        }
        return call.method == 'ready' ? false : null;
      },
    );
    companion = AppleWatchCompanion(
      selection: selection,
      loadSection: (site, account, section) => loader(site, account, section),
      openItem: (_, _, _, _) {
        opened++;
        return true;
      },
    );
    await companion.start();
  });

  tearDown(() {
    companion.dispose();
    selection.dispose();
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      AppleWatchCompanion.channel,
      null,
    );
  });

  test(
    'automatic refresh reads only hot threads and sends no credentials',
    () async {
      await companion.refresh();
      expect(requested, ['threads']);
      final snapshot = companion.snapshot;
      expect(snapshot['notices'], 7);
      expect(snapshot['messagesUnread'], 2);
      expect(snapshot['notifications'], isEmpty);
      expect(snapshot['messages'], isEmpty);
      expect(snapshot['loadedSections'], ['threads']);
      final serialized = jsonEncode(snapshot);
      for (final secret in [
        'account-auth-secret',
        'server-auth-secret',
        'saltkey-secret',
        'formhash-secret',
      ]) {
        expect(serialized, isNot(contains(secret)));
      }
      expect(published.last['revision'], greaterThan(0));
    },
  );

  test('inbox previews load only on explicit watch requests', () async {
    await fromWatch('refresh', {'section': 'messages'});
    expect(requested, ['messages']);
    expect(companion.snapshot['messages'], hasLength(1));
    expect(companion.snapshot['notifications'], isEmpty);
    await fromWatch('refresh', {'section': 'notifications'});
    expect(requested, ['messages', 'notifications']);
    expect(companion.snapshot['notifications'], hasLength(1));
  });

  test(
    'account switches clear previews and discard in-flight responses',
    () async {
      final pending = Completer<WatchSection>();
      loader = (_, _, _) => pending.future;
      final request = companion.refresh();
      selection.setUser(User('other', '', 'Bob', '', 1, 8, 10, discuz));
      expect(companion.snapshot['threads'], isEmpty);
      expect(companion.snapshot['notices'], 0);
      pending.complete(content(user, title: 'Private Alice content'));
      await request;
      expect(jsonEncode(companion.snapshot), isNot(contains('Private Alice')));
      expect(companion.snapshot['username'], 'Bob');
      expect(companion.snapshot['updatedAt'], 0);
    },
  );

  test('expired sessions remove all private previews and counts', () async {
    await companion.refresh('messages');
    loader = (_, _, _) async => content(null);
    await companion.refresh();
    expect(companion.snapshot['sessionExpired'], true);
    expect(companion.snapshot['messages'], isEmpty);
    expect(companion.snapshot['threads'], isEmpty);
    expect(companion.snapshot['messagesUnread'], 0);
  });

  test('only current-account items may be opened on iPhone', () async {
    await companion.refresh();
    final identity = companion.snapshot['contextID'];
    expect(
      await fromWatch('openItem', {
        'contextID': identity,
        'section': 'threads',
        'id': 42,
      }),
      true,
    );
    expect(
      await fromWatch('openItem', {
        'contextID': identity,
        'section': 'threads',
        'id': 999,
      }),
      false,
    );
    selection.setUser(null);
    expect(
      await fromWatch('openItem', {
        'contextID': identity,
        'section': 'threads',
        'id': 42,
      }),
      false,
    );
    expect(opened, 1);
  });

  test('session expiry invalidates successful responses from other in-flight sections', () async {
    final pending = Completer<WatchSection>();
    loader = (_, _, section) =>
        section == 'messages' ? pending.future : Future.value(content(null));
    final messages = companion.refresh('messages');
    await companion.refresh();
    pending.complete(content(user));
    await messages;
    expect(companion.snapshot['sessionExpired'], true);
    expect(companion.snapshot['messages'], isEmpty);
    expect(companion.snapshot['messagesUnread'], 0);
  });

  test('failed refresh preserves same-account content and sync time', () async {
    await companion.refresh();
    final updatedAt = companion.snapshot['updatedAt'];
    loader = (_, _, _) async => throw StateError('offline');
    await companion.refresh();
    expect(companion.snapshot['threads'], hasLength(1));
    expect(companion.snapshot['updatedAt'], updatedAt);
    expect(companion.snapshot['errors'], {'threads': 'load_failed'});
  });

  test(
    'guests cannot load private sections and repeated loads are coalesced',
    () async {
      selection.setUser(null);
      await companion.refresh('messages');
      await companion.refresh('notifications');
      expect(requested, isEmpty);
      final pending = Completer<WatchSection>();
      var loads = 0;
      loader = (_, _, _) {
        loads++;
        return pending.future;
      };
      final first = companion.refresh();
      final second = companion.refresh();
      pending.complete(content(null));
      await Future.wait([first, second]);
      expect(loads, 1);
    },
  );

  test(
    'late responses after disposal cannot publish private content',
    () async {
      final pending = Completer<WatchSection>();
      loader = (_, _, _) => pending.future;
      final request = companion.refresh();
      companion.dispose();
      final count = published.length;
      pending.complete(content(user));
      await request;
      expect(published.length, count);
    },
  );

  test('preview removes hidden HTML and truncates without splitting emoji', () {
    expect(
      watchPreview('<p>Hello &amp; 👋</p><script>secret</script>'),
      'Hello & 👋',
    );
    expect(watchPreview('A😀BC', 2), 'A😀…');
    expect(watchPreview('<span hidden>secret</span>Public'), 'Public');
  });
}
