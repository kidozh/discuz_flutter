import 'dart:convert';
import 'dart:io';

import 'package:discuz_flutter/JsonResult/DiscuzIndexResult.dart';
import 'package:discuz_flutter/JsonResult/HotThreadResult.dart';
import 'package:discuz_flutter/app/MainApp.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/HotThread.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/main.dart' as app;
import 'package:discuz_flutter/page/DrawerPage.dart';
import 'package:discuz_flutter/page/SettingPage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/provider/UserPreferenceNotifierProvider.dart';
import 'package:discuz_flutter/utility/DashboardPreferences.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/widget/KeylolTopicTabs.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

Future<void> _finishNavigation(WidgetTester tester) async {
  // Give route transitions multiple rendered frames before native screenshots.
  // Background feeds can keep animating, so pumpAndSettle is inappropriate.
  for (var frame = 0; frame < 12; frame++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Liquid Glass home remains visible on iPad startup', (
    tester,
  ) async {
    expect(
      (await DeviceInfoPlugin().iosInfo).isPhysicalDevice,
      isFalse,
      reason: 'Run this startup fixture only on a dedicated iPad simulator.',
    );
    final package = await PackageInfo.fromPlatform();
    await UserPreferencesUtils.putPlatformPreference('liquid_glass');
    await UserPreferencesUtils.putAcceptVersionCodeFlag(package.version);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    addTearDown(() => SystemChrome.setPreferredOrientations([]));
    app.main();
    for (var attempt = 0; attempt < 20; attempt++) {
      await tester.pump(const Duration(milliseconds: 250));
    }
    expect(find.byType(app.StartupErrorApp), findsNothing);
    expect(find.byType(MyHomePage), findsOneWidget);
    final home = tester.element(find.byType(MyHomePage));
    expect(visualStyle(home), AppVisualStyle.liquidGlass);
    expect(usesAppleTranslucentSurface(home), isTrue);
    expect(usesLiquidGlass(home), isFalse);
    expect(find.byType(UiKitView), findsNothing);
    expect(tester.getSize(find.byType(MyHomePage)).width, greaterThan(0));
    expect(tester.takeException(), isNull);
    await File('${Directory.systemTemp.path}/ipad-empty-home.png')
        .writeAsBytes(await binding.takeScreenshot('ipad-empty-home'));

    // Exercise the production home with deterministic loopback forum data.
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    final forum = Forum()
      ..fid = '161'
      ..name = 'iPad QA forum';
    final index = DiscuzIndexVariables()
      ..forumList = [forum]
      ..forumPartitionList = [
        ForumPartition()
          ..fid = '1'
          ..name = 'QA'
          ..forumIdList = ['161'],
      ]
      ..groupInfo = (GroupInfo()..groupId = '1');
    final threads = HotThreadVariables()
      ..perPage = 20
      ..hotThreadList = [
        HotThread()
          ..tid = 100
          ..fid = 161
          ..subject = 'iPad startup QA thread'
          ..author = 'QA'
          ..message = 'Synthetic forum content',
      ];
    server.listen((request) async {
      final module = request.uri.queryParameters['module'];
      request.response.headers.contentType = ContentType.json;
      request.response.write(
        jsonEncode({
          'Variables': module == 'forumindex'
              ? index.toJson()
              : threads.toJson(),
        }),
      );
      await request.response.close();
    });
    final discuz = Discuz(
      'http://127.0.0.1:${server.port}',
      'X3.5',
      'utf-8',
      4,
      '',
      '',
      false,
      '',
      '',
      'iPad QA',
      'qa',
      '',
      '161',
    );
    home.read<UserPreferenceNotifierProvider>().adExemptHost = '127.0.0.1';
    DashboardPreferences.selectedSection.value = 'hot';
    home.read<DiscuzAndUserNotifier>().initDiscuz(discuz);
    for (var attempt = 0; attempt < 40; attempt++) {
      await tester.pump(const Duration(milliseconds: 250));
      if (find.text('iPad startup QA thread').evaluate().isNotEmpty) break;
    }
    expect(tester.takeException(), isNull);
    expect(find.text('iPad startup QA thread'), findsOneWidget);
    await _finishNavigation(tester);
    await File('${Directory.systemTemp.path}/ipad-forum-home.png')
        .writeAsBytes(await binding.takeScreenshot('ipad-forum-home'));

    // Match the four destinations in the real-device report without
    // accessing a real account or performing remote account operations.
    await UserPreferencesUtils.putLastMobileSignRecord(discuz, 42);
    index.member_uid = 42;
    threads.member_uid = 42;
    home.read<DiscuzAndUserNotifier>().setUser(
      User('', '', 'iPad QA', '', 1, 42, 10, discuz),
    );
    for (var attempt = 0; attempt < 40; attempt++) {
      await tester.pump(const Duration(milliseconds: 250));
      if (find.text('iPad startup QA thread').evaluate().isNotEmpty) break;
    }
    await File('${Directory.systemTemp.path}/ipad-four-tabs.png')
        .writeAsBytes(await binding.takeScreenshot('ipad-four-tabs'));
    expect(tester.takeException(), isNull);
    expect(find.text('iPad startup QA thread'), findsOneWidget);
    await _finishNavigation(tester);

    await tester.tap(find.byKey(const ValueKey('main_menu_button')));
    await _finishNavigation(tester);
    expect(find.byType(DrawerPage), findsOneWidget);
    final settingsLabel = S
        .of(tester.element(find.byType(DrawerPage)))
        .settingTitle;
    final settings = find.text(settingsLabel);
    await tester.ensureVisible(settings);
    await tester.tap(settings);
    await _finishNavigation(tester);
    expect(find.byType(SettingPage), findsOneWidget);
    expect(find.byType(UiKitView), findsNothing);
    expect(tester.takeException(), isNull);
    await File('${Directory.systemTemp.path}/ipad-settings.png')
        .writeAsBytes(await binding.takeScreenshot('ipad-settings'));
    Navigator.of(tester.element(find.byType(SettingPage)))
        .popUntil((route) => route.isFirst);
    await _finishNavigation(tester);

    // Keylol adds a second, horizontally scrolling category control above
    // the paged thread lists. Cover that production path as well.
    DashboardPreferences.selectedSection.value = 'keylol';
    home.read<DiscuzAndUserNotifier>().initDiscuz(app.exclusiveDiscuz);
    for (var attempt = 0; attempt < 120; attempt++) {
      await tester.pump(const Duration(milliseconds: 250));
      if (find.byType(KeylolTopicTabs).evaluate().isNotEmpty) break;
    }
    await _finishNavigation(tester);
    await File('${Directory.systemTemp.path}/ipad-keylol-home.png')
        .writeAsBytes(await binding.takeScreenshot('ipad-keylol-home'));
    expect(tester.takeException(), isNull);
    expect(find.byType(KeylolTopicTabs), findsOneWidget);
    expect(find.text('最新主题'), findsOneWidget);
    expect(find.byType(UiKitView), findsNothing);
    final topics = tester.widget<KeylolTopicTabs>(find.byType(KeylolTopicTabs));
    expect(topics.titles, contains('最新主题'));
    expect(
      find.descendant(
        of: find.byType(KeylolTopicTabs),
        matching: find.byType(ListView),
      ),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox.shrink());
  }, skip: !Platform.isIOS);
}
