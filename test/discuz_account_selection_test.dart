import 'dart:async';
import 'dart:io';

import 'package:discuz_flutter/JsonResult/BaseVariableResult.dart';
import 'package:discuz_flutter/dao/DiscuzDao.dart';
import 'package:discuz_flutter/dao/UserDao.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/provider/DiscuzNotificationProvider.dart';
import 'package:discuz_flutter/provider/SelectedTidNotifierProvider.dart';
import 'package:discuz_flutter/utility/DiscuzWebviewCookieManager.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final first = _forum('https://forum.example/first');
  final second = _forum('https://forum.example/second');
  final alice = _user(first, 7);
  final bob = _user(second, 7);

  test(
    'forum and account are published together and mismatches are rejected',
    () {
      final selection = DiscuzAndUserNotifier();
      addTearDown(selection.dispose);
      final changes = <(Discuz?, User?)>[];
      selection.addListener(
        () => changes.add((selection.discuz, selection.user)),
      );

      selection.initDiscuz(first, user: alice);
      final staleLogin = selection.sessionIdentity;
      selection.initDiscuz(second, user: bob);
      expect(selection.setUser(alice), isFalse);
      expect(selection.userFor(first), isNull);
      expect(selection.userFor(second), same(bob));
      selection.setDiscuz(first);
      expect(selection.setUser(alice, expectedSession: staleLogin), isFalse);
      final login = selection.sessionIdentity;
      expect(selection.setUser(alice, expectedSession: login), isTrue);
      expect(selection.sessionIdentity, isNot(same(login)));
      expect(changes, [
        (first, alice),
        (second, bob),
        (first, null),
        (first, alice),
      ]);
    },
  );

  test('relogin invalidates pending callbacks even for the same UID', () {
    final selection = DiscuzAndUserNotifier()..initDiscuz(first, user: alice);
    addTearDown(selection.dispose);
    final session = selection.sessionIdentity;
    final relogged = _user(first, 7)..auth = 'new-cookie';
    selection.setUser(relogged);
    expect(selection.setUser(null, expectedSession: session), isFalse);
    expect(selection.setUser(alice, expectedSession: session), isFalse);
    expect(selection.user, same(relogged));
  });

  test('notification state and thread highlights follow their scope', () {
    final selection = DiscuzAndUserNotifier()..initDiscuz(first, user: alice);
    final notices = DiscuzNotificationProvider(account: selection);
    final selectedThread = SelectedTidNotifierProvider();
    addTearDown(selection.dispose);
    addTearDown(notices.dispose);
    addTearDown(selectedThread.dispose);
    notices.setNotificationCount(NoticeCount()..newprompt = 3);
    notices.setBaseVariableResult(BaseVariableResult()..isModerator = 1);
    selectedThread.setTid(42, first);

    selection.initDiscuz(second, user: bob);
    expect(notices.noticeCount.newprompt, 0);
    expect(notices.baseVariableResult.isModerator, 0);
    expect(selectedThread.tidFor(second), 0);
    expect(selectedThread.tidFor(first), 42);
  });

  test(
    'saved users and notification targets resolve by full forum address',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'forum-accounts-',
      );
      final hive = Hive;
      hive.init(directory.path);
      hive.registerAdapter(DiscuzAdapter());
      hive.registerAdapter(UserAdapter());
      addTearDown(() async {
        await hive.close();
        await directory.delete(recursive: true);
      });
      final forums = DiscuzDao(await hive.openBox<Discuz>('forums'));
      final users = UserDao(await hive.openBox<User>('users'));
      await forums.insertDiscuz(first);
      await forums.insertDiscuz(second);
      await users.insert(alice);
      await users.insert(bob);

      final updated = _forum('https://FORUM.example:443/first/')
        ..siteName = 'New forum name';
      expect(users.findAllUsersByDiscuz(updated), [alice]);
      expect(users.findUsersByDiscuzAndUid(second, 7), same(bob));
      expect(
        users.findUsersByDiscuzAndUid(_forum('http://forum.example/first'), 7),
        isNull,
      );
      expect(forums.findDiscuzByBaseURL(updated.baseURL), same(first));
      expect(forums.findDiscuzByBaseURL('https://forum.example'), isNull);
      expect(forums.findDiscuzByRealHost('forum.example'), isNull);
      expect(updated.isSameSite(first), isTrue);
      expect(updated.isSameSite(second), isFalse);
      expect(alice.hashCode, _user(updated, 7).hashCode);
    },
  );

  test(
    'stale WebView operations cannot install cookies for a previous account',
    () async {
      const channel = MethodChannel(
        'com.kidozh.discuz_flutter/webview_cookies',
      );
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      final firstClear = Completer<void>();
      final clearStarted = Completer<void>();
      final calls = <String>[];
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call.method);
        if (calls.length == 1) {
          clearStarted.complete();
          await firstClear.future;
        }
        return null;
      });
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
      const manager = DiscuzWebviewCookieManager();
      var firstIsCurrent = true;
      final stale = manager.loadWithCookies(
        [Cookie('auth', 'first')],
        origin: first.baseURL,
        isCurrent: () => firstIsCurrent,
        load: () async => calls.add('first page'),
      );
      await clearStarted.future;
      firstIsCurrent = false;
      final current = manager.loadWithCookies(
        [Cookie('auth', 'second')],
        origin: second.baseURL,
        isCurrent: () => true,
        load: () async => calls.add('second page'),
      );
      firstClear.complete();
      await Future.wait([stale, current]);
      expect(calls, [
        'clearCookies',
        'clearCookies',
        'setCookies',
        'second page',
      ]);
    },
  );
}

Discuz _forum(String url) =>
    Discuz(url, 'X3.5', 'utf-8', 4, '', '', false, '', '', '', '', '', '');

User _user(Discuz forum, int uid) =>
    User('', '', 'user', '', 1, uid, 10, forum);
