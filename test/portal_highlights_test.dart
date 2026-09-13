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
}
