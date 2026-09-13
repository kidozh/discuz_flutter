import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:discuz_flutter/client/ForumInteractionClient.dart';
import 'package:discuz_flutter/JsonResult/ViewThreadResult.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/page/UploadAvatarPage.dart';
import 'package:discuz_flutter/widget/BestAnswerButton.dart';

Dio fake(Object Function(RequestOptions) data, List<RequestOptions> requests) =>
    Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requests.add(options);
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: data(options),
              ),
            );
          },
        ),
      );
Map<String, dynamic> variables({int price = 10}) => {
  'member_uid': '1',
  'formhash': 'fresh',
  'thread': {'tid': '10', 'special': '3', 'price': '$price', 'authorid': '1'},
  'postlist': [
    {
      'tid': '10',
      'pid': '20',
      'authorid': '2',
      'first': '0',
      'author': 'answerer',
    },
  ],
};
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'avatar uses Filedata multipart and checks uploadavatar status, not HTTP 200',
    () async {
      final requests = <RequestOptions>[];
      var success = false;
      final dio = fake(
        (_) => {
          'Variables': {
            'uploadavatar': success
                ? 'api_uploadavatar_success'
                : 'api_uploadavatar_uc_error',
          },
        },
        requests,
      );
      final client = ForumInteractionClient(dio, 'https://forum.test/bbs');
      await expectLater(
        client.uploadAvatar([1, 2, 3], 'hash'),
        throwsA(isA<ForumApiException>()),
      );
      expect(requests.length, 1);
      final form = requests.single.data as FormData;
      expect(form.files.single.key, 'Filedata');
      expect(form.files.single.value.filename, 'avatar.png');
      expect(Map.fromEntries(form.fields)['formhash'], 'hash');
      expect(requests.single.uri.queryParameters['module'], 'uploadavatar');
      success = true;
      await client.uploadAvatar([1, 2, 3], 'hash');
      dio.close();
    },
  );
  test(
    'best answer only available on other users replies in authors unresolved reward',
    () {
      final v = ThreadVariables.fromJson(variables());
      final post = v.postList.single;
      expect(canSelectBestAnswer(v.threadInfo, post, 1), true);
      for (final uid in [null, 0, 2, 3]) {
        expect(canSelectBestAnswer(v.threadInfo, post, uid), false);
      }
      post.first = true;
      expect(canSelectBestAnswer(v.threadInfo, post, 1), false);
      post.first = false;
      v.threadInfo.price = -10;
      expect(canSelectBestAnswer(v.threadInfo, post, 1), false);
      v.threadInfo.price = 10;
      v.threadInfo.special = 0;
      expect(canSelectBestAnswer(v.threadInfo, post, 1), false);
    },
  );
  test(
    'bestanswer posts pid and CSRF and does not accept empty response as success',
    () async {
      final requests = <RequestOptions>[];
      var success = false;
      final dio = fake(
        (_) => {
          'Message': {'messageval': success ? 'reward_completion' : ''},
        },
        requests,
      );
      final client = ForumInteractionClient(dio, 'https://forum.test');
      await expectLater(
        client.bestAnswer(10, 20, 'hash'),
        throwsA(isA<ForumApiException>()),
      );
      expect(requests.single.method, 'POST');
      expect(requests.single.uri.queryParameters['pid'], '20');
      expect(requests.single.data, {
        'formhash': 'hash',
        'bestanswersubmit': 'yes',
      });
      success = true;
      await client.bestAnswer(10, 20, 'hash');
      dio.close();
    },
  );
  test(
    'avatar preview conversion bounds output and generates actual PNG',
    () async {
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawRect(
        const Rect.fromLTWH(0, 0, 1024, 512),
        Paint()..color = Colors.blue,
      );
      final picture = recorder.endRecording();
      final image = await picture.toImage(1024, 512);
      final bytes = (await image.toByteData(
        format: ui.ImageByteFormat.png,
      ))!.buffer.asUint8List();
      final output = await prepareAvatar(bytes);
      expect(output.take(8).toList(), [137, 80, 78, 71, 13, 10, 26, 10]);
      final codec = await ui.instantiateImageCodec(output);
      final decoded = (await codec.getNextFrame()).image;
      expect(decoded.width, 512);
      expect(decoded.height, 256);
      decoded.dispose();
      codec.dispose();
      image.dispose();
      picture.dispose();
    },
  );

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
  final user = User('auth', 'salt', 'test', '', 1, 1, 10, discuz);
  Future<void> host(
    WidgetTester tester,
    ForumInteractionClient client,
    VoidCallback changed,
  ) async {
    final v = ThreadVariables.fromJson(variables());
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: DiscuzAndUserNotifier()
          ..discuz = discuz
          ..user = user,
        child: MaterialApp(
          localizationsDelegates: const [S.delegate],
          home: Scaffold(
            body: BestAnswerButton(
              discuz: discuz,
              variables: v,
              post: v.postList.single,
              onChanged: changed,
              createClient: (_) async => client,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('cancel adoption makes no request', (tester) async {
    final requests = <RequestOptions>[];
    final dio = fake((_) => {}, requests);
    await host(tester, ForumInteractionClient(dio, discuz.baseURL), () {});
    await tester.tap(find.text(S.current.selectBestAnswer));
    await tester.pumpAndSettle();
    await tester.tap(find.text(S.current.cancel));
    await tester.pumpAndSettle();
    expect(requests, isEmpty);
    dio.close();
  });
  testWidgets('settled reward after confirmation cannot be adopted again', (
    tester,
  ) async {
    final requests = <RequestOptions>[];
    final dio = fake((_) => {'Variables': variables(price: -10)}, requests);
    await host(tester, ForumInteractionClient(dio, discuz.baseURL), () {});
    await tester.tap(find.text(S.current.selectBestAnswer));
    await tester.pumpAndSettle();
    await tester.tap(find.text(S.current.forumConfirm));
    await tester.pumpAndSettle();
    expect(requests.where((r) => r.method == 'POST'), isEmpty);
    expect(find.text(S.current.bestAnswerChanged), findsOneWidget);
    await tester.tap(find.text(S.current.forumConfirm));
    await tester.pumpAndSettle();
    dio.close();
  });
  testWidgets('confirmation revalidates target and uses fresh token once', (
    tester,
  ) async {
    final requests = <RequestOptions>[];
    var changed = 0;
    final dio = fake(
      (o) => o.method == 'GET'
          ? {'Variables': variables()}
          : {
              'Message': {'messageval': 'reward_completion'},
            },
      requests,
    );
    await host(tester, ForumInteractionClient(dio, discuz.baseURL), () {
      changed++;
    });
    await tester.tap(find.text(S.current.selectBestAnswer));
    await tester.pumpAndSettle();
    await tester.tap(find.text(S.current.forumConfirm));
    await tester.pumpAndSettle();
    expect(requests.map((r) => r.method), ['GET', 'POST']);
    expect(requests.last.data['formhash'], 'fresh');
    expect(changed, 1);
    dio.close();
  });
  testWidgets(
    'avatar editor never uploads before choosing and submitting a preview',
    (tester) async {
      final requests = <RequestOptions>[];
      final dio = fake((_) => {}, requests);
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: DiscuzAndUserNotifier()
            ..discuz = discuz
            ..user = user,
          child: MaterialApp(
            localizationsDelegates: const [S.delegate],
            home: UploadAvatarPage(
              discuz: discuz,
              user: user,
              pickImage: () async => null,
              createClient: () async =>
                  ForumInteractionClient(dio, discuz.baseURL),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.uploadAvatar));
      await tester.pumpAndSettle();
      expect(requests, isEmpty);
      await tester.tap(find.text(S.current.chooseAvatar));
      await tester.pumpAndSettle();
      expect(requests, isEmpty);
      dio.close();
    },
  );
}
