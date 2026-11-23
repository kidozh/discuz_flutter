import 'dart:async';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/client/ForumInteractionClient.dart';
import 'package:discuz_flutter/client/forum_guide.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/ForumGuidePage.dart';
import 'package:discuz_flutter/page/ForumListsPage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

final site = Discuz(
  'https://stage1st.com/2b',
  'X3.5',
  'utf-8',
  4,
  '',
  '',
  false,
  '',
  '',
  'Stage1st',
  '',
  '',
  '',
);
Map<String, dynamic> row(String tid) => {
  'id': tid,
  'clicktype': 'tid',
  'clickvalue': tid,
  'title': 'Topic $tid &amp; discussion',
  'image': '',
  'fields': [
    {'id': 'author', 'value': 'Test author'},
    {'id': 'replies', 'value': '19'},
    {'id': 'views', 'value': '1748'},
    {'id': 'dateline', 'value': '1794883262'},
  ],
};
ForumInteractionClient client(
  FutureOr<Object> Function(RequestOptions) response, [
  List<RequestOptions>? requests,
]) {
  final dio = Dio()
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (o, h) async {
          requests?.add(o);
          h.resolve(
            Response(
              requestOptions: o,
              statusCode: 200,
              data: await response(o),
            ),
          );
        },
      ),
    );
  addTearDown(dio.close);
  return ForumInteractionClient(dio, site.baseURL);
}

Widget host(Widget child) => ChangeNotifierProvider.value(
  value: DiscuzAndUserNotifier()..initDiscuz(site),
  child: PlatformProvider(
    style: AppVisualStyle.cupertino,
    builder: (_) => MaterialApp(
      localizationsDelegates: const [
        S.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      home: child,
    ),
  ),
);

void main() {
  test(
    'official extends_data decodes all guide sections and preserves metadata',
    () async {
      final requests = <RequestOptions>[];
      final api = client(
        (_) => {
          'Variables': {
            'extends_data': {
              'page': '1',
              'perpage': '50',
              'list': [row('2294188')],
            },
          },
        },
        requests,
      );
      for (final section in ForumGuideSection.values) {
        final rows = await api.guideThreads(section.identifier, 1);
        expect(rows.single['tid'], '2294188');
        expect(rows.single['author'], 'Test author');
        expect(rows.single['views'], '1748');
        expect(rows.single['dateline'], '1794883262');
        final query = requests.last.uri.queryParameters;
        expect(requests.last.uri.path, '/2b/api/mobile/index.php');
        expect(query['module'], 'extends');
        expect(query['identifier'], section.identifier);
        expect(query['page'], '1');
      }
    },
  );
  test(
    'custom identifier-keyed responses and numeric-key lists remain supported',
    () async {
      final api = client(
        (_) => {
          'Variables': {
            'dz_digest': {
              'list': {'0': row('9')},
            },
          },
        },
      );
      expect((await api.guideThreads('dz_digest', 1)).single['tid'], '9');
    },
  );
  test('empty official lists are valid; malformed payloads and forum errors are not', () async {
    final empty = client(
      (_) => {
        'Variables': {
          'extends_data': {'list': []},
        },
      },
    );
    expect(await empty.guideThreads('dz_digest', 1), isEmpty);
    final invalid = client(
      (_) => {
        'Variables': {
          'extends_data': {'page': '1'},
        },
      },
    );
    await expectLater(
      invalid.guideThreads('dz_digest', 1),
      throwsFormatException,
    );
    final denied = client(
      (_) => {
        'Message': {'messageval': 'group_nopermission', 'messagestr': 'Denied'},
      },
    );
    await expectLater(
      denied.guideThreads('dz_digest', 1),
      throwsA(
        isA<ForumApiException>().having((e) => e.fromForum, 'from forum', true),
      ),
    );
  });
  testWidgets(
    'iOS discovery opens official results and stops on repeated pagination',
    (tester) async {
      final api = client(
        (o) => {
          'Variables': o.uri.queryParameters.containsKey('check')
              ? {
                  'extends': {
                    'extendlist': [
                      {'identifier': 'dz_newreply'},
                    ],
                  },
                }
              : {
                  'extends_data': {
                    'page': o.uri.queryParameters['page'],
                    'list': [row('9')],
                  },
                },
        },
      );
      await tester.pumpWidget(
        host(ForumGuidePage(site, createClient: () async => api)),
      );
      await tester.pumpAndSettle();
      expect(find.text(S.current.guideDigest), findsNothing);
      await tester.tap(find.text(S.current.guideRecentReplies));
      await tester.pumpAndSettle();
      expect(find.text('Topic 9 & discussion'), findsOneWidget);
      final pagination = tester
          .widget<EasyRefresh>(find.byType(EasyRefresh))
          .onLoad!();
      await tester.pumpAndSettle();
      expect(find.text('Topic 9 & discussion'), findsOneWidget);
      expect(await pagination, IndicatorResult.noMore);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'unavailable guide provides a website entry and can be refreshed',
    (tester) async {
      final requests = <RequestOptions>[];
      final api = client(
        (_) => {
          'Variables': {
            'extends': {'extendlist': []},
          },
        },
        requests,
      );
      await tester.pumpWidget(
        host(ForumGuidePage(site, createClient: () async => api)),
      );
      await tester.pumpAndSettle();
      expect(find.text(S.current.forumApiUnavailable), findsOneWidget);
      expect(find.text(S.current.navigateToWebPage), findsOneWidget);
      expect(find.text(S.current.refresh), findsNothing);
      await tester.drag(find.byType(ListView), const Offset(0, 300));
      await tester.pumpAndSettle();
      expect(requests, hasLength(2));
    },
  );
  testWidgets(
    'guide list uses an iOS spinner while waiting and renders an empty result',
    (tester) async {
      final pending = Completer<Object>();
      final api = client((_) => pending.future);
      await tester.pumpWidget(
        host(
          ForumListsPage(
            discuz: site,
            user: null,
            guide: ForumGuideSection.digest,
            createClient: () async => api,
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      pending.complete({
        'Variables': {
          'extends_data': {'list': []},
        },
      });
      await tester.pumpAndSettle();
      expect(find.text(S.current.forumEmpty), findsOneWidget);
      expect(find.byType(CupertinoActivityIndicator), findsNothing);
    },
  );
}
