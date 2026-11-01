import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/JsonResult/DiscuzIndexResult.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:discuz_flutter/client/ForumInteractionClient.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/widget/PortalHighlights.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';

void main() {
  testWidgets(
    'index loads only the first four hot forums using the shared partition',
    (tester) async {
      final discuz = Discuz(
        'https://forum.test',
        'X3.5',
        'utf-8',
        4,
        '',
        '',
        false,
        '',
        '',
        'Forum',
        '',
        '',
        '',
      );
      final modules = <String>[];
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (request, handler) {
              final module = request.uri.queryParameters['module']!;
              modules.add(module);
              handler.resolve(
                Response(
                  requestOptions: request,
                  data: {
                    'Variables': {
                      'data': module == 'hotforum'
                          ? [
                              for (var i = 1; i <= 6; i++)
                                {'fid': '$i', 'name': 'Popular forum $i'},
                            ]
                          : [
                              {
                                'tid': '10',
                                'subject': 'Popular thread',
                                'author': 'Author',
                              },
                            ],
                    },
                  },
                ),
              );
            },
          ),
        );
      await tester.pumpWidget(
        PlatformProvider(
          style: AppVisualStyle.cupertino,
          builder: (_) => MaterialApp(
            localizationsDelegates: const [
              S.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(320, 700),
                padding: EdgeInsets.only(top: 44),
              ),
              child: Scaffold(
                body: SafeArea(
                  child: SingleChildScrollView(
                    child: SizedBox(
                      width: 320,
                      child: PortalHighlights(
                        discuz: discuz,
                        refresh: 0,
                        createClient: () async =>
                            ForumInteractionClient(dio, discuz.baseURL),
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
      expect(modules, ['hotforum']);
      for (var i = 1; i <= 4; i++) {
        expect(find.text('Popular forum $i'), findsOneWidget);
      }
      expect(find.text('Popular forum 5'), findsNothing);
      expect(find.text('Popular forum 6'), findsNothing);
      expect(find.text('Popular thread'), findsNothing);
      expect(
        tester.getTopLeft(find.byType(PortalHighlights)).dy,
        greaterThanOrEqualTo(44),
      );
      expect(tester.takeException(), isNull);
      dio.close();
    },
  );

  testWidgets(
    'hot forums reuse arriving index details without refetching or changing rank',
    (tester) async {
      final discuz = Discuz(
        'https://forum.test',
        'X3.5',
        'utf-8',
        4,
        '',
        '',
        false,
        '',
        '',
        'Forum',
        '',
        '',
        '',
      );
      final known = ValueNotifier<List<Forum>>([]);
      addTearDown(known.dispose);
      final modules = <String>[];
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (request, handler) {
              modules.add(request.uri.queryParameters['module']!);
              handler.resolve(
                Response(
                  requestOptions: request,
                  data: {
                    'Variables': {
                      'data': [
                        {'fid': 2, 'name': 'Hot second', 'todayposts': '7'},
                        {
                          'fid': '1',
                          'name': 'Hot first',
                          'description': '<p>Description from hot forum</p>',
                          'icon': 'https://forum.test/first.png',
                        },
                        {'fid': '3', 'name': 'Unknown forum'},
                      ],
                    },
                  },
                ),
              );
            },
          ),
        );
      addTearDown(dio.close);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            S.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 320,
                child: ValueListenableBuilder<List<Forum>>(
                  valueListenable: known,
                  builder: (_, forums, _) => PortalHighlights(
                    discuz: discuz,
                    refresh: 0,
                    knownForums: forums,
                    createClient: () async =>
                        ForumInteractionClient(dio, discuz.baseURL),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Hot second'), findsOneWidget);
      expect(find.text('Description from hot forum'), findsOneWidget);

      final second = Forum()
        ..fid = '2'
        ..name = 'Existing &amp; second'
        ..description = '<p>Existing board description</p>'
        ..iconUrl = 'https://forum.test/second.png'
        ..todayPosts = '99';
      known.value = [
        Forum()..fid = '1',
        Forum()
          ..fid = '99'
          ..subForumList = [second],
      ];
      await tester.pump();
      expect(find.text('Existing & second'), findsOneWidget);
      expect(find.text('Existing board description'), findsOneWidget);
      expect(find.text('Hot second'), findsNothing);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('99'), findsNothing);
      expect(find.text('Description from hot forum'), findsOneWidget);
      expect(
        tester
            .widgetList<CachedNetworkImage>(find.byType(CachedNetworkImage))
            .map((image) => image.imageUrl)
            .toList(),
        ['https://forum.test/second.png', 'https://forum.test/first.png'],
      );
      final names = ['Existing & second', 'Hot first', 'Unknown forum'];
      expect(
        tester
            .widgetList<Text>(find.byType(Text))
            .map((text) => text.data)
            .where(names.contains)
            .toList(),
        names,
      );
      expect(modules, ['hotforum']);
      expect(second.todayPosts, '99');
      expect(second.description, '<p>Existing board description</p>');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
