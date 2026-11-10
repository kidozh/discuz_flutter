import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/provider/UserPreferenceNotifierProvider.dart';
import 'package:discuz_flutter/utility/forum_image_session.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  test(
    'only same-origin image requests receive path-matched cookies',
    () => HttpOverrides.runWithHttpOverrides(
      _verifyScopedCookies,
      _LoopbackHttpOverrides(),
    ),
  );

  testWidgets('image cookies respect the setting and current login', (
    tester,
  ) async {
    final forum = _forum('https://example.test/forum');
    final otherForum = _forum('https://example.test/other');
    final account = DiscuzAndUserNotifier()
      ..initDiscuz(forum)
      ..setUser(_user(forum, 1));
    final preferences = UserPreferenceNotifierProvider();
    const url = 'https://example.test/forum/image';
    ImageProvider? image;
    ImageProvider? externalImage;
    ImageProvider? otherForumImage;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: account),
          ChangeNotifierProvider.value(value: preferences),
        ],
        child: Builder(
          builder: (context) {
            final session = ForumImageSession.of(context, forum);
            image = session?.providerFor(url);
            externalImage = session?.providerFor('https://cdn.example.test/i');
            otherForumImage = ForumImageSession.of(
              context,
              otherForum,
            )?.providerFor(url);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(image, isNotNull);
    expect(externalImage, isNull);
    expect(otherForumImage, isNull);

    preferences.setForumDisplay(
      preferences.forumDisplay.copyWith(useForumCookiesForImages: false),
    );
    await tester.pump();
    expect(image, isNull);

    preferences.setForumDisplay(
      preferences.forumDisplay.copyWith(useForumCookiesForImages: true),
    );
    await tester.pump();
    final firstLogin = image;
    expect(firstLogin, isNotNull);
    expect(externalImage, isNull);
    expect(otherForumImage, isNull);

    account.setUser(_user(forum, 2));
    await tester.pump();
    expect(image, isNotNull);
    expect(image, isNot(firstLogin));

    account.setUser(null);
    await tester.pump();
    expect(image, isNull);

    account.setUser(_user(forum, 1));
    await tester.pump();
    expect(image, isNotNull);
    expect(image, isNot(firstLogin));
  });
}

class _LoopbackHttpOverrides extends HttpOverrides {}

Future<void> _verifyScopedCookies() async {
  final forum = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  addTearDown(() => forum.close(force: true));
  final cdn = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  addTearDown(() => cdn.close(force: true));
  final forumUrl = Uri.http('127.0.0.1:${forum.port}', '/forum/');
  final cdnUrl = Uri.http('127.0.0.1:${cdn.port}', '/image');
  final seen = <(String, String?)>[];

  forum.listen((request) async {
    final path = request.uri.path;
    seen.add((path, request.headers.value(HttpHeaders.cookieHeader)));
    if (path == '/forum/redirect') {
      request.response.redirect(forumUrl.resolve('same-origin'));
    } else if (path == '/forum/same-origin') {
      request.response.redirect(cdnUrl);
    } else {
      request.response.add([1, 2, 3]);
      await request.response.close();
    }
  });
  cdn.listen((request) {
    seen.add(('cdn', request.headers.value(HttpHeaders.cookieHeader)));
    request.response.redirect(forumUrl.resolve('return'));
  });

  final jar = CookieJar();
  await jar.saveFromResponse(forumUrl, [
    Cookie('auth', 'test-session')..path = '/forum/',
    Cookie('secure', 'https-only')..secure = true,
  ]);
  Future<List<int>> get(Uri uri) =>
      loadForumImage(uri, forum: forumUrl, cookieJar: () async => jar);

  expect(await get(forumUrl.resolve('redirect')), [1, 2, 3]);
  expect(await get(forumUrl.resolve('/outside/image')), [1, 2, 3]);
  expect(await get(cdnUrl), [1, 2, 3]);
  expect(seen, [
    ('/forum/redirect', 'auth=test-session'),
    ('/forum/same-origin', 'auth=test-session'),
    ('cdn', null),
    ('/forum/return', null),
    ('/outside/image', null),
    ('cdn', null),
    ('/forum/return', null),
  ]);
}

Discuz _forum(String url) =>
    Discuz(url, 'X3.4', 'utf-8', 4, '', '', false, '', '', 'Forum', '', '', '');

User _user(Discuz forum, int id) =>
    User('', '', 'member', '', 10, id, 10, forum);
