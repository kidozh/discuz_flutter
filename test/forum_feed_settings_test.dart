import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:discuz_flutter/client/ForumInteractionClient.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/ForumFeedSettingsPage.dart';
import 'package:discuz_flutter/utility/ForumFeedPreferences.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';

Discuz site(String name) => Discuz(
  'https://$name.test',
  'X3.5',
  'utf-8',
  4,
  '',
  '',
  false,
  '',
  '',
  name,
  '',
  '',
  '',
);
void main() {
  testWidgets(
    'switch forums and save individual and bulk changes without confirmation',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final a = site('A'), b = site('B');
      final clients = <Dio>[];
      await tester.pumpWidget(
        PlatformProvider(
          style: AppVisualStyle.cupertino,
          builder: (_) => MaterialApp(
            localizationsDelegates: const [
              S.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            home: ForumFeedSettingsPage(
              discuz: a,
              user: null,
              loadSites: () async => [a, b],
              loadUsers: () async => [],
              createClient: (discuz, user) async {
                final dio = Dio()
                  ..interceptors.add(
                    InterceptorsWrapper(
                      onRequest: (request, handler) {
                        handler.resolve(
                          Response(
                            requestOptions: request,
                            data: {
                              'Variables': {
                                'forumlist': [
                                  {
                                    'fid': '1',
                                    'name': '${discuz.siteName} Forum 1',
                                  },
                                  {
                                    'fid': '2',
                                    'name': '${discuz.siteName} Forum 2',
                                  },
                                ],
                              },
                            },
                          ),
                        );
                      },
                    ),
                  );
                clients.add(dio);
                return ForumInteractionClient(dio, discuz.baseURL);
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(S.current.forumConfirm), findsNothing);
      await tester.tap(find.text('A Forum 1'));
      await tester.pumpAndSettle();
      expect(
        await ForumFeedPreferences.selectedFor(
          ForumFeedPreferences.scope(a, null),
          ['1', '2'],
        ),
        {'2'},
      );
      await tester.tap(find.byKey(const ValueKey('feed-site-selector')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('B').last);
      await tester.pumpAndSettle();
      expect(find.text('B Forum 1'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.deselect));
      await tester.pumpAndSettle();
      expect(
        await ForumFeedPreferences.selectedFor(
          ForumFeedPreferences.scope(b, null),
          ['1', '2'],
        ),
        isEmpty,
      );
      expect(
        await ForumFeedPreferences.selectedFor(
          ForumFeedPreferences.scope(a, null),
          ['1', '2'],
        ),
        {'2'},
      );
      await tester.tap(find.byIcon(Icons.select_all));
      await tester.pumpAndSettle();
      expect(
        await ForumFeedPreferences.selectedFor(
          ForumFeedPreferences.scope(b, null),
          ['1', '2', '3'],
        ),
        {'1', '2', '3'},
      );
      expect(tester.takeException(), isNull);
      for (final dio in clients) {
        dio.close();
      }
    },
  );
}
