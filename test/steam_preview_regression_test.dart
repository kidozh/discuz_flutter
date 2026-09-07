import 'dart:convert';
import 'dart:async';
import 'package:discuz_flutter/JsonResult/SteamGameDataResult.dart';
import 'package:discuz_flutter/client/SteamApiClient.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/widget/SteamGameWidget.dart';
import 'package:discuz_flutter/widget/BilibiliWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeSteamClient implements SteamApiClient {
  final requests = <String>[];
  final response = Completer<String>();
  @override
  Future<String> getSteamGameResultByAppId(String appId, String language) {
    requests.add(appId);
    return response.future;
  }
}

Widget host(Widget child) => PlatformProvider(
      style: AppVisualStyle.material,
      builder: (_) => MaterialApp(
        localizationsDelegates: const [S.delegate],
        home: Scaffold(body: child),
      ),
    );

void main() {
  test('unavailable and sparse Steam types tolerate missing data', () {
    expect(SteamGameDataResult.fromJson({'success': false}).success, isFalse);
    for (final type in ['game', 'dlc', 'demo', 'music', 'unknown']) {
      final result = SteamGameDataResult.fromJson({
        'success': true,
        'data': {'type': type, 'name': 'Example', 'developers': null},
      });
      expect(result.data.name, 'Example');
      expect(result.data.developers, isEmpty);
      expect(result.data.screenshots, isEmpty);
      expect(result.data.price_overview.final_formatted, isEmpty);
    }
  });
  for (final fail in [false, true]) {
    testWidgets('Steam completion after dispose is safe: error=$fail',
        (tester) async {
      final client = FakeSteamClient();
      await tester.pumpWidget(host(SteamGameWidget(
          'https://store.steampowered.com/app/123/',
          client: client)));
      await tester.pump();
      expect(client.requests, ['123']);
      await tester.pumpWidget(const SizedBox());
      if (fail) {
        client.response
            .completeError(const FormatException('invalid response'));
      } else {
        client.response.complete('{"123":{"success":false}}');
      }
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  }
  for (final type in ['dlc', 'music', 'demo', 'unknown']) {
    testWidgets('sparse $type shows type and honest availability',
        (tester) async {
      final client = FakeSteamClient();
      await tester.pumpWidget(host(SteamGameWidget(
          'https://store.steampowered.com/app/123/',
          client: client)));
      client.response.complete(
          '{"123":{"success":true,"data":{"name":"Example","type":"$type",'
          '"release_date":{"coming_soon":true,"date":"2027"},'
          '"fullgame":{"appid":"456","name":"Base game"}}}}');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Example'));
      await tester.pumpAndSettle();
      expect(find.text('See Steam for pricing'), findsOneWidget);
      expect(find.text('Related game: Base game'), findsOneWidget);
      expect(find.text('Coming soon'), findsOneWidget);
      expect(
          find.text(switch (type) {
            'dlc' => 'DLC',
            'music' => 'Soundtrack / Music',
            'demo' => 'Demo',
            _ => 'Steam content',
          }),
          findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });
  }
  test('missing platforms are unknown and soundtrack parent is optional', () {
    final data = SteamGameData.fromJson({'type': 'music', 'name': 'Album'});
    expect(data.isSoundtrack, isTrue);
    expect(data.hasPlatforms, isFalse);
    expect(data.hasPrice, isFalse);
    expect(data.parentAppId, isNull);
    expect(data.is_free, isFalse);
    final dlc = SteamGameData.fromJson({
      'type': 'dlc',
      'fullgame': {'appid': 42, 'name': 'Base'},
      'is_free': true,
    });
    expect(dlc.parentAppId, 42);
    expect(
        SteamGameData.fromJson(jsonDecode(jsonEncode(dlc.toJson()))).parentName,
        'Base');
  });
  testWidgets('embedded widget URLs load their app preview', (tester) async {
    final client = FakeSteamClient();
    await tester.pumpWidget(host(SteamGameWidget(
        'https://store.steampowered.com/widget/123/?l=schinese',
        client: client)));
    await tester.pump();
    expect(client.requests, ['123']);
    client.response.complete(
        '{"123":{"success":true,"data":{"name":"Widget preview","type":"music"}}}');
    await tester.pumpAndSettle();
    expect(find.text('Widget preview'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('changing a Steam link ignores the previous response',
      (tester) async {
    final client = FakeSteamClient();
    await tester.pumpWidget(host(SteamGameWidget(
        'https://store.steampowered.com/app/123/',
        client: client)));
    await tester.pump();
    await tester.pumpWidget(host(SteamGameWidget(
        'https://store.steampowered.com/sub/456/',
        client: client)));
    client.response
        .complete('{"123":{"success":true,"data":{"name":"Old game"}}}');
    await tester.pump();
    expect(find.text('Old game'), findsNothing);
    expect(
        find.text('https://store.steampowered.com/sub/456/'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('packages and incomplete Bilibili URLs remain links',
      (tester) async {
    final client = FakeSteamClient();
    await tester.pumpWidget(host(SteamGameWidget(
        'https://store.steampowered.com/bundle/123/',
        client: client)));
    await tester.pump();
    expect(client.requests, isEmpty);
    for (final path in ['video/', 'opus/', 'opus/not-an-id']) {
      await tester
          .pumpWidget(host(BilibiliWidget('https://www.bilibili.com/$path')));
      await tester.pump();
      expect(tester.takeException(), isNull);
    }
  });
}
