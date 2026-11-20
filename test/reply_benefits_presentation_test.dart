import 'package:discuz_flutter/entity/reply_benefits.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/widget/post_status_badges.dart';
import 'package:discuz_flutter/widget/reply_benefits_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final (platform, icon) in [
    (AppVisualStyle.material, Icons.card_giftcard_outlined),
    (AppVisualStyle.cupertino, CupertinoIcons.gift),
  ]) {
    testWidgets(
      'offer, optional rush rules and awarded floor at large type: $platform',
      (tester) async {
        final credit = ReplyCreditRule.parse({
          'extcredits': '2',
          'remaining': '2',
          'membertimes': '1',
          'random': '30',
        });
        final rush = RushReplyInfo.parse({
          'stopfloor': '20',
          'rewardfloor': '2,5',
          'creditlimit': '-996',
          'timer': '185400',
          'timertype': 'end',
        });
        await tester.pumpWidget(
          PlatformProvider(
            style: platform,
            builder: (_) => MaterialApp(
              theme: ThemeData.dark(),
              locale: const Locale('zh', 'CN'),
              supportedLocales: S.delegate.supportedLocales,
              localizationsDelegates: [
                S.delegate,
                ...GlobalMaterialLocalizations.delegates,
              ],
              home: Scaffold(
                body: Builder(
                  builder: (context) => MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: TextScaler.linear(2)),
                    child: SingleChildScrollView(
                      child: SizedBox(
                        width: 240,
                        child: Column(
                          children: [
                            ReplyBenefitsCard(
                              pool: 4,
                              credit: credit,
                              creditName: '金钱',
                              rush: rush,
                              closed: false,
                            ),
                            const PostStatusBadges(
                              blocked: false,
                              warned: false,
                              revised: false,
                              replyCredit: 2,
                              winningFloor: true,
                            ),
                            const ReplyBenefitsCard(
                              pool: 0,
                              credit: null,
                              rush: null,
                              closed: false,
                            ),
                            const PostStatusBadges(
                              blocked: false,
                              warned: false,
                              revised: false,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byIcon(icon), findsNWidgets(2));
        expect(find.text('回帖奖励 · 2 金钱'), findsOneWidget);
        expect(find.text('剩余 2 份'), findsOneWidget);
        expect(find.textContaining('奖励概率 30%'), findsOneWidget);
        expect(find.text('回帖奖励 +2'), findsOneWidget);
        expect(find.text('中奖楼层'), findsOneWidget);
        expect(find.text('中奖楼层 · 2,5'), findsOneWidget);
        expect(find.text('距离结束 2天 3时'), findsOneWidget);
        expect(find.text('到第 20 楼结束'), findsNothing);
        await tester.ensureVisible(find.text('抢楼'));
        await tester.tap(find.text('抢楼'));
        await tester.pumpAndSettle();
        expect(find.text('到第 20 楼结束'), findsOneWidget);
        expect(find.textContaining('积分门槛'), findsNothing);
        await tester.tap(find.text('抢楼'));
        await tester.pumpAndSettle();
        expect(find.text('到第 20 楼结束'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
