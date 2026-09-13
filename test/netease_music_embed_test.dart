import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/netease_music_embed.dart';
import 'package:discuz_flutter/widget/NeteaseMusicWidget.dart';

void main() {
  test('recognizes the provided iframe and preserves its song ID', () {
    final html = parseFragment(
      '<iframe width=330 height=86 src="//music.163.com/outchain/player?type=2&id=3348657303&auto=0&height=66"></iframe>',
    );
    final embed = NeteaseMusicEmbed.parse(
      html.querySelector('iframe')!.attributes['src'],
    )!;
    expect(embed.songId, '3348657303');
    expect(embed.playerUrl.scheme, 'https');
    expect(embed.playerUrl.queryParameters['auto'], '0');
    expect(
      embed.songUrl.toString(),
      'https://music.163.com/song?id=3348657303',
    );
  });
  test(
    'normalizes HTTP and entities and never preserves autoplay or injected attributes',
    () {
      final embed = NeteaseMusicEmbed.parse(
        'http://music.163.com/outchain/player?type=2&amp;id=12&amp;auto=1&extra=%22onload%3Dalert(1)',
      )!;
      expect(embed.playerUrl.queryParameters['auto'], '0');
      expect(embed.songUrl.toString(), isNot(contains('alert(1)')));
      expect(embed.playerUrl.queryParameters.containsKey('extra'), false);
    },
  );
  test(
    'ignores unrelated iframe providers, malformed IDs and unsupported types',
    () {
      for (final url in [
        null,
        'javascript:alert(1)',
        '//music.163.com.evil.test/outchain/player?type=2&id=12',
        'https://music.163.com/song?id=12',
        '//music.163.com/outchain/player?type=0&id=12',
        '//music.163.com/outchain/player?type=2&id=0',
        '//music.163.com/outchain/player?type=2&id=x',
      ]) {
        expect(NeteaseMusicEmbed.parse(url), isNull);
      }
    },
  );
  testWidgets(
    'iframe becomes an accessible song link without narrow overflow',
    (tester) async {
      tester.view.physicalSize = const Size(240, 600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [S.delegate],
          home: Scaffold(
            body: NeteaseMusicWidget(
              NeteaseMusicEmbed.parse(
                '//music.163.com/outchain/player?type=2&id=12',
              )!,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(S.current.neteaseOpenSong), findsOneWidget);
      expect(find.text('https://music.163.com/song?id=12'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
