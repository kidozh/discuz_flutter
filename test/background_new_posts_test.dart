import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/background_new_posts_settings_page.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/utility/background_new_posts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Discuz site(String url, String name) =>
    Discuz(url, 'X3.4', 'utf-8', 4, '', '', false, '', '', name, '', '', '');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('test/background_new_posts');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final monitor = BackgroundNewPosts(channel: channel, supported: true);
  final calls = <MethodCall>[];
  late bool enabled;
  late bool failSave;
  late Map<String, bool> selection;

  Map<String, Object> state() => {
    'enabled': enabled,
    'notificationsAllowed': true,
    'sites': [
      for (final entry in selection.entries)
        {
          'url': entry.key,
          'name': entry.key.contains('one') ? 'Forum One' : 'Forum Two',
          'enabled': entry.value,
          'seeded': false,
          'lastCheck': 0,
          'failed': false,
        },
    ],
  };

  setUp(() {
    enabled = false;
    failSave = false;
    selection = {
      'https://one.example': false,
      'https://two.example/forum': false,
    };
    calls.clear();
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      if (call.method == 'takeNotification') {
        return {'site_url': 'https://two.example/forum/', 'tid': '42'};
      }
      if (call.method == 'setEnabled') {
        if (failSave) throw PlatformException(code: 'monitor_error');
        enabled = call.arguments as bool;
      }
      if (call.method == 'setSiteEnabled') {
        final args = call.arguments as Map;
        selection[args['url'] as String] = args['enabled'] as bool;
      }
      return state();
    });
  });
  tearDown(() {
    monitor.listen(null);
    messenger.setMockMethodCallHandler(channel, null);
  });

  test(
    'canonical URLs keep different installations on the same host distinct',
    () {
      expect(
        canonicalMonitorUrl('https://one.example/forum///?page=1#top'),
        'https://one.example/forum',
      );
      expect(
        canonicalMonitorUrl('https://one.example/other/'),
        'https://one.example/other',
      );
      expect(
        () => canonicalMonitorUrl('javascript:alert(1)'),
        throwsFormatException,
      );
      expect(
        () => canonicalMonitorUrl('https://user:pass@one.example'),
        throwsFormatException,
      );
    },
  );

  test(
    'monitor sends site settings and parses persisted state and taps',
    () async {
      await monitor.synchronize([site('https://one.example/', 'Forum One')]);
      expect(calls.single.arguments, [
        {'url': 'https://one.example', 'name': 'Forum One', 'charset': 'utf-8'},
      ]);
      final selected = await monitor.setSiteEnabled(
        'https://one.example/',
        true,
      );
      expect(selected.enabled, isFalse);
      expect(
        selected.sites
            .singleWhere((s) => s.url == 'https://one.example')
            .enabled,
        isTrue,
      );
      expect(
        selected.sites.singleWhere((s) => s.url.contains('two')).enabled,
        isFalse,
      );
      expect((await monitor.setEnabled(true)).enabled, isTrue);
      final target = await monitor.takeNotification();
      expect(target!.url, 'https://two.example/forum');
      expect(target.tid, 42);
      expect(
        NewPostNotificationTarget.parse({
          'site_url': 'file:///tmp/test',
          'tid': 1,
        }),
        isNull,
      );
      expect(
        NewPostNotificationTarget.parse({
          'site_url': 'https://one.example',
          'tid': -1,
        }),
        isNull,
      );
    },
  );

  test('other platforms never call the Android monitor', () async {
    final unsupported = BackgroundNewPosts(channel: channel, supported: false);
    await unsupported.load();
    await unsupported.setEnabled(true);
    await unsupported.removeSite('https://one.example');
    expect(await unsupported.takeNotification(), isNull);
    expect(calls, isEmpty);
  });

  Widget host({required Future<bool> Function() permission}) =>
      PlatformProvider(
        style: AppVisualStyle.material,
        builder: (_) => MaterialApp(
          locale: const Locale('zh', 'CN'),
          supportedLocales: S.delegate.supportedLocales,
          localizationsDelegates: const [
            S.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          home: BackgroundNewPostsSettingsPage(
            monitor: monitor,
            loadSites: () async => [
              site('https://one.example', 'Forum One'),
              site('https://two.example/forum', 'Forum Two'),
            ],
            requestNotifications: permission,
          ),
        ),
      );

  testWidgets(
    'settings start off, allow separate sites and request permission only on opt-in',
    (tester) async {
      var permissionRequests = 0;
      await tester.pumpWidget(
        host(
          permission: () async {
            permissionRequests++;
            return true;
          },
        ),
      );
      await tester.pumpAndSettle();
      expect(permissionRequests, 0);
      final master = find.byKey(const ValueKey('new-posts-master'));
      expect(tester.widget<PlatformSwitch>(master).value, isFalse);
      final first = find.byKey(
        const ValueKey('new-posts-site:https://one.example'),
      );
      await tester.ensureVisible(first);
      await tester.tap(first);
      await tester.pumpAndSettle();
      expect(selection['https://one.example'], isTrue);
      expect(selection['https://two.example/forum'], isFalse);
      expect(permissionRequests, 0);
      await tester.ensureVisible(master);
      await tester.tap(master);
      await tester.pumpAndSettle();
      expect(enabled, isTrue);
      expect(permissionRequests, 1);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('denied permission and failed saves leave the switch off', (
    tester,
  ) async {
    await tester.pumpWidget(host(permission: () async => false));
    await tester.pumpAndSettle();
    final master = find.byKey(const ValueKey('new-posts-master'));
    await tester.tap(master);
    await tester.pumpAndSettle();
    expect(enabled, isFalse);
    expect(calls.where((call) => call.method == 'setEnabled'), isEmpty);
    expect(find.text('请在系统设置中允许新帖通知。'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    failSave = true;
    await tester.pumpWidget(host(permission: () async => true));
    await tester.pumpAndSettle();
    await tester.tap(master);
    await tester.pumpAndSettle();
    expect(tester.widget<PlatformSwitch>(master).value, isFalse);
    expect(find.text('未能更新后台提醒设置，请重试。'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
