import 'dart:convert';

import 'package:discuz_flutter/JsonResult/CheckPostResult.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/forum_composer_capabilities.dart';
import 'package:discuz_flutter/utility/forum_voice.dart';
import 'package:discuz_flutter/widget/PostPermissionGate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const scope = (site: 'https://example.test/forum', uid: 3, fid: 2);
CheckPostResult permission({int uid = 3, int mp3 = -1, bool reply = true}) =>
    CheckPostResult.fromJson({
      'Variables': {
        'member_uid': '$uid',
        'formhash': 'never-cache-this',
        'allowperm': {
          'allowpost': '1',
          'allowreply': reply ? '1' : '0',
          'uploadhash': 'private-upload-hash',
          'allowupload': {'mp3': mp3},
          'attachremain': {'size': -1, 'count': -1},
        },
      },
    });

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test(
    'one-hour capability survives storage without persisting credentials',
    () async {
      final now = DateTime.utc(2026, 11, 17);
      await ForumComposerCapabilityCache.remember(
        scope,
        permission(),
        now: now,
      );
      final cached = await ForumComposerCapabilityCache.read(
        scope,
        now: now.add(const Duration(minutes: 59)),
      );
      expect(cached!.voice, (format: ForumVoiceFormat.mp3, maxSeconds: 60));
      expect(cached.permission.uploadHash, isEmpty);
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(prefs.getKeys().single)!;
      expect(stored, isNot(contains('uploadhash')));
      expect(stored, isNot(contains('formhash')));
      expect(stored, isNot(contains('private-upload-hash')));
      expect(
        await ForumComposerCapabilityCache.read(
          scope,
          now: now.add(const Duration(hours: 1)),
        ),
        isNull,
      );
      expect(
        await ForumComposerCapabilityCache.read(
          scope,
          now: now.subtract(const Duration(seconds: 1)),
        ),
        isNull,
      );
    },
  );
  test(
    'forum installation, account and board do not share capabilities',
    () async {
      await ForumComposerCapabilityCache.remember(scope, permission());
      for (final other in [
        (site: 'https://example.test/other', uid: 3, fid: 2),
        (site: scope.site, uid: 4, fid: 2),
        (site: scope.site, uid: 3, fid: 4),
      ]) {
        expect(await ForumComposerCapabilityCache.read(other), isNull);
      }
    },
  );
  test(
    'fresh lower limits and refusal replace the cached voice grant',
    () async {
      await ForumComposerCapabilityCache.remember(scope, permission());
      await ForumComposerCapabilityCache.remember(
        scope,
        permission(mp3: 14048),
      );
      expect(
        (await ForumComposerCapabilityCache.read(scope))!.voice!.maxSeconds,
        3,
      );
      await ForumComposerCapabilityCache.remember(scope, permission(mp3: 0));
      final denied = await ForumComposerCapabilityCache.read(scope);
      expect(denied, isNotNull); // Unsupported audio is cached too.
      expect(denied!.voice, isNull);
      await ForumComposerCapabilityCache.remember(
        scope,
        permission(reply: false),
      );
      expect(
        (await ForumComposerCapabilityCache.read(scope))!.permission.allowReply,
        false,
      );
    },
  );
  test(
    'wrong sessions, server errors and malformed responses invalidate hints',
    () async {
      for (final response in [
        permission(uid: 4),
        CheckPostResult.fromJson({
          'Message': {
            'messageval': 'group_nopermission',
            'messagestr': 'Denied',
          },
        }),
        CheckPostResult(),
      ]) {
        await ForumComposerCapabilityCache.remember(scope, permission());
        await ForumComposerCapabilityCache.remember(scope, response);
        expect(await ForumComposerCapabilityCache.read(scope), isNull);
      }
      await ForumComposerCapabilityCache.remember(scope, permission());
      final prefs = await SharedPreferences.getInstance();
      final key = prefs.getKeys().single;
      final map = jsonDecode(prefs.getString(key)!) as Map;
      map['voice']['seconds'] = 900;
      await prefs.setString(key, jsonEncode(map));
      expect(await ForumComposerCapabilityCache.read(scope), isNull);
    },
  );
  testWidgets(
    'reopening an editor uses cache; expiry performs one fresh check',
    (tester) async {
      var requests = 0;
      Future<void> open(int key) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: const [S.delegate],
            home: Scaffold(
              body: PostPermissionGate(
                key: ValueKey(key),
                reply: true,
                voiceScope: scope,
                load: () async {
                  requests++;
                  return permission();
                },
                child: const Text('Editor ready'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      await open(1);
      expect(find.text('Editor ready'), findsOneWidget);
      expect(requests, 1);
      await open(2);
      expect(find.text('Editor ready'), findsOneWidget);
      expect(requests, 1);
      await ForumComposerCapabilityCache.remember(
        scope,
        permission(),
        now: DateTime.now().subtract(const Duration(hours: 2)),
      );
      await open(3);
      expect(requests, 2);
    },
  );
}
