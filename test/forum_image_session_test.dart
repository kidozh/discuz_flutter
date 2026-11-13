import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/Post.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/entity/forum_display_preferences.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/FullImagePage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/provider/UserPreferenceNotifierProvider.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/utility/forum_image_session.dart';
import 'package:discuz_flutter/utility/forum_image_site.dart';
import 'package:discuz_flutter/widget/AttachmentWidget.dart';
import 'package:discuz_flutter/widget/forum_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';

void main() {
  test(
    'forum requests use the thread referer and path-matched cookies only on the same origin',
    () => HttpOverrides.runWithHttpOverrides(
      _verifyScopedCookies,
      _LoopbackHttpOverrides(),
    ),
  );

  test(
    'switching sessions stops pending requests and discards late image bytes',
    () => HttpOverrides.runWithHttpOverrides(
      _verifyStaleSession,
      _LoopbackHttpOverrides(),
    ),
  );

  test(
    'attachment downloads use the same scoped cookies across redirects',
    () async {
      final forum = Uri.parse('https://forum.example.com/bbs/');
      final endpoint = forum.resolve('forum.php?mod=attachment&aid=token');
      final cdn = Uri.parse('https://cdn.example.com/files/report.zip');
      final external = Uri.parse('https://files.example.net/report.zip');
      final directory = await Directory.systemTemp.createTemp(
        'forum-attachment-test-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final jar = CookieJar();
      await jar.saveFromResponse(forum, [
        Cookie('login', 'forum')..path = '/bbs/',
        Cookie('shared', 'same-site')
          ..domain = '.example.com'
          ..path = '/',
      ]);
      await jar.saveFromResponse(cdn, [Cookie('cdn', 'own')..path = '/files/']);
      await jar.saveFromResponse(external, [
        Cookie('external', 'own')..path = '/',
      ]);

      final seen = <(Uri, String?, String?)>[];
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (request, handler) {
              seen.add((
                request.uri,
                request.headers['cookie'] as String?,
                request.headers['referer'] as String?,
              ));
              expect(request.responseType, ResponseType.stream);
              final target = request.uri == endpoint
                  ? cdn
                  : request.uri == cdn
                  ? external
                  : null;
              final isLoginPage = request.uri.path.endsWith('login');
              final headers = <String, List<String>>{
                if (target != null) 'location': [target.toString()],
                if (target == null)
                  'content-type': [
                    isLoginPage
                        ? 'text/html; charset=utf-8'
                        : 'application/zip',
                  ],
                if (target == null && !isLoginPage)
                  'content-disposition': [
                    "attachment; filename*=utf-8''%E9%99%84%E4%BB%B6.zip",
                  ],
              };
              final status = target == null ? 200 : 302;
              handler.resolve(
                Response<ResponseBody>(
                  requestOptions: request,
                  statusCode: status,
                  headers: Headers.fromMap(headers),
                  data: ResponseBody.fromBytes(
                    [1, 2, 3],
                    status,
                    headers: headers,
                  ),
                ),
              );
            },
          ),
        );
      addTearDown(dio.close);
      var jarReads = 0;
      Future<File> download(Uri uri, ForumImageCookiePolicy policy) =>
          downloadForumAttachment(
            uri,
            directory,
            forum: forum,
            threadId: 42,
            policy: policy,
            cookieJar: () async {
              jarReads++;
              return jar;
            },
            dio: dio,
          );

      const referer =
          'https://forum.example.com/bbs/forum.php?mod=viewthread&tid=42';
      final file = await download(endpoint, ForumImageCookiePolicy.sameSite);
      expect(file.uri.pathSegments.last, '附件.zip');
      expect(await file.readAsBytes(), [1, 2, 3]);
      expect(seen, [
        (endpoint, 'login=forum; shared=same-site', referer),
        (cdn, 'shared=same-site', 'https://forum.example.com/'),
        (external, null, null),
      ]);
      expect(jarReads, 2);

      seen.clear();
      await download(endpoint, ForumImageCookiePolicy.always);
      expect(seen, [
        (endpoint, 'login=forum; shared=same-site', referer),
        (cdn, 'cdn=own; shared=same-site', 'https://forum.example.com/'),
        (external, 'external=own', null),
      ]);
      expect(jarReads, 5);

      seen.clear();
      await download(endpoint, ForumImageCookiePolicy.never);
      expect(seen, [
        (endpoint, null, null),
        (cdn, null, null),
        (external, null, null),
      ]);
      expect(jarReads, 5);

      final existing = await directory.list().length;
      await expectLater(
        download(forum.resolve('login'), ForumImageCookiePolicy.sameSite),
        throwsA(isA<HttpException>()),
      );
      expect(await directory.list().length, existing);
    },
  );

  test('Stage1st shares only domain cookies with its image host', () async {
    final forum = Uri.parse('https://stage1st.com/2b/');
    final image = Uri.parse(
      'https://img.stage1st.com/forum/202611/11/175641hhinhrq7aghn7jec.png',
    );
    final other = Uri.parse('https://static.stage1st.com/image/post.png');
    final jar = CookieJar();
    await jar.saveFromResponse(forum, [
      Cookie('shared', 'valid')
        ..domain = '.stage1st.com'
        ..secure = true
        ..path = '/',
      Cookie('forum_only', 'private')..path = '/',
      Cookie('forum_path', 'private')
        ..domain = '.stage1st.com'
        ..path = '/2b/',
      Cookie('case_sensitive_path', 'private')
        ..domain = '.stage1st.com'
        ..path = '/Forum/',
      Cookie('public_suffix', 'private')
        ..domain = '.com'
        ..path = '/',
    ]);
    await jar.saveFromResponse(image, [
      Cookie('image_only', 'private')..path = '/',
    ]);
    final seen = <(Uri, String?, String?)>[];
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) {
            seen.add((
              request.uri,
              request.headers[HttpHeaders.cookieHeader] as String?,
              request.headers[HttpHeaders.refererHeader] as String?,
            ));
            final target = request.uri == image ? other : null;
            handler.resolve(
              Response<Uint8List>(
                requestOptions: request,
                statusCode: target == null ? 200 : 302,
                data: Uint8List.fromList([1]),
                headers: Headers.fromMap({
                  if (target != null)
                    HttpHeaders.locationHeader: [target.toString()],
                }),
              ),
            );
          },
        ),
      );
    addTearDown(dio.close);

    expect(
      await loadForumImage(
        image,
        forum: forum,
        cookieJar: () async => jar,
        dio: dio,
      ),
      [1],
    );
    expect(seen, [
      (image, 'shared=valid', 'https://stage1st.com/'),
      (other, 'shared=valid', 'https://stage1st.com/'),
    ]);
    seen.clear();
    final otherForum = Uri.parse('https://example.test/');
    await loadForumImage(
      image,
      forum: otherForum,
      cookieJar: () async => jar,
      dio: dio,
    );
    expect(seen, [(image, null, null), (other, null, null)]);
  });

  test('same site follows ICANN, private, wildcard and exception rules', () {
    bool sameSite(String forum, String image) =>
        sameForumImageSite(Uri.https(forum), Uri.https(image));

    expect(sameSite('forum.example.co.uk', 'images.example.co.uk'), isTrue);
    expect(sameSite('example.co.uk', 'different.co.uk'), isFalse);
    expect(sameSite('example.com', 'example.com.different.net'), isFalse);
    expect(sameSite('one.github.io', 'two.github.io'), isFalse);
    expect(sameSite('one.github.io', 'images.one.github.io'), isTrue);
    expect(sameSite('one.foo.kawasaki.jp', 'two.foo.kawasaki.jp'), isFalse);
    expect(sameSite('one.city.kawasaki.jp', 'two.city.kawasaki.jp'), isTrue);
    expect(sameSite('127.0.0.1', '127.0.0.2'), isFalse);
  });

  test('cookie policies limit what each image target receives', () async {
    final forum = Uri.parse('https://forum.example.com/bbs/');
    final image = Uri.parse('https://images.example.net/picture.png');
    final insecure = image.replace(scheme: 'http');
    final jar = CookieJar();
    await jar.saveFromResponse(forum, [
      Cookie('login', 'private')..path = '/',
      Cookie('forum_domain', 'private')
        ..domain = 'example.com'
        ..path = '/',
    ]);
    await jar.saveFromResponse(image, [
      Cookie('image', 'valid')..path = '/',
      Cookie('public_suffix', 'private')
        ..domain = 'net'
        ..path = '/',
    ]);
    final seen = <(String?, String?)>[];
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) {
            seen.add((
              request.headers[HttpHeaders.cookieHeader] as String?,
              request.headers[HttpHeaders.refererHeader] as String?,
            ));
            handler.resolve(
              Response<Uint8List>(
                requestOptions: request,
                statusCode: 200,
                data: Uint8List.fromList([1]),
              ),
            );
          },
        ),
      );
    addTearDown(dio.close);
    var jarReads = 0;
    Future<void> load(Uri target, ForumImageCookiePolicy policy) async {
      await loadForumImage(
        target,
        forum: forum,
        policy: policy,
        cookieJar: () async {
          jarReads++;
          return jar;
        },
        dio: dio,
      );
    }

    await load(image, ForumImageCookiePolicy.sameSite);
    await load(forum, ForumImageCookiePolicy.never);
    await load(insecure, ForumImageCookiePolicy.always);
    expect(jarReads, 0);
    await load(image, ForumImageCookiePolicy.always);
    expect(jarReads, 1);
    expect(seen, [
      (null, null),
      (null, null),
      (null, null),
      ('image=valid', null),
    ]);
  });

  test(
    'image attachment paths resolve from the forum or its attachment host',
    () {
      final forum = _forum('https://example.test/bbs');
      final image = Attachment()..attachmentPathName = '202611/post.png';
      final urls = {
        'data/attachment/forum':
            'https://example.test/bbs/data/attachment/forum/202611/post.png',
        '/files/': 'https://example.test/files/202611/post.png',
        '//images.example.test/files/':
            'https://images.example.test/files/202611/post.png',
        'http://example.test/files/':
            'https://example.test/files/202611/post.png',
      };
      for (final entry in urls.entries) {
        image.url = entry.key;
        expect(image.getAttachmentRealUrl(forum), entry.value);
      }
      image.url = 'forum.php?mod=attachment&aid=token%3D';
      expect(
        image.getAttachmentRealUrl(forum),
        'https://example.test/bbs/forum.php?mod=attachment&aid=token%3D',
      );
      image.url = 'https://images.example.test/files/post.png';
      expect(image.getAttachmentRealUrl(forum), image.url);
      image.attachmentPathName = '';
      expect(image.getAttachmentRealUrl(forum), image.url);
      image.url = '';
      expect(image.getAttachmentRealUrl(forum), isEmpty);
      final encoded = URLUtils.getAttachmentUrl(
        forum,
        'a%2Bb%3D',
        preview: true,
      )!;
      expect(encoded.path, '/bbs/forum.php');
      expect(encoded.queryParameters, {
        'mod': 'attachment',
        'aid': 'a+b=',
        'nothumb': 'yes',
        'noupdate': 'yes',
      });
    },
  );

  testWidgets(
    'HTML images use lazy sources without replacing a real thumbnail',
    (tester) async {
      final base = Uri.parse('https://example.test/bbs/');
      final sources = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          home: HtmlWidget(
            '<img src="static/image/common/none.gif" file="/private/one.png">'
            '<img data-src="files/two.png">'
            '<img src="http://example.test/three.thumb.jpg" file="/three.jpg">',
            baseUrl: base,
            factoryBuilder: () => _RecordingImageFactory(base, sources),
          ),
        ),
      );
      expect(sources, [
        'https://example.test/private/one.png',
        'https://example.test/bbs/files/two.png',
        'https://example.test/three.thumb.jpg',
      ]);
    },
  );

  testWidgets('attachment cards preview images with the post thread context', (
    tester,
  ) async {
    final forum = _forum('https://example.test/bbs');
    final attachment = Attachment()
      ..url = 'https://cdn.example.test/files/'
      ..attachmentPathName = '202611/attachment'
      ..aidEncode = 'a%2Bb%3D';
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [S.delegate],
        home: Scaffold(
          body: AttachmentWidget(
            forum,
            attachment,
            threadId: 42,
            isListedImage: true,
          ),
        ),
      ),
    );
    final preview = tester.widget<ForumImage>(find.byType(ForumImage));
    expect(preview.threadId, 42);
    expect(preview.url, 'https://cdn.example.test/files/202611/attachment');
    final original = preview.fallbackUrl!;
    expect(Uri.parse(original).queryParameters['aid'], 'a+b=');

    await tester.tap(find.byType(ForumImage));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final gallery = tester.widget<FullImagePage>(find.byType(FullImagePage));
    expect(gallery.threadId, 42);
    expect(gallery.imageUrl, original);
    expect(gallery.fallbackUrls[original], preview.url);
  });

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
    ImageProvider? upgradedImage;
    ImageProvider? relativeImage;
    ImageProvider? differentPortImage;
    ImageProvider? otherThreadImage;
    ImageProvider? sameSiteImage;
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
            final session = ForumImageSession.of(context, forum, threadId: 12);
            image = session?.providerFor(url);
            upgradedImage = session?.providerFor(
              'http://example.test/forum/image',
            );
            relativeImage = session?.providerFor('image');
            differentPortImage = session?.providerFor(
              'https://example.test:8443/forum/image',
            );
            otherThreadImage = ForumImageSession.of(
              context,
              forum,
              threadId: 13,
            )?.providerFor(url);
            sameSiteImage = session?.providerFor('https://cdn.example.test/i');
            externalImage = session?.providerFor('https://cdn.example.net/i');
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
    expect(upgradedImage, image);
    expect(relativeImage, image);
    expect(differentPortImage, isNull);
    expect(otherThreadImage, isNot(image));
    expect(sameSiteImage, isNotNull);
    expect(externalImage, isNull);
    expect(otherForumImage, isNull);

    preferences.setForumDisplay(
      preferences.forumDisplay.copyWith(
        imageCookiePolicy: ForumImageCookiePolicy.never,
      ),
    );
    await tester.pump();
    expect(image, isNull);

    preferences.setForumDisplay(
      preferences.forumDisplay.copyWith(
        imageCookiePolicy: ForumImageCookiePolicy.sameSite,
      ),
    );
    await tester.pump();
    final firstLogin = image;
    expect(firstLogin, isNotNull);
    expect(externalImage, isNull);
    expect(otherForumImage, isNull);

    preferences.setForumDisplay(
      preferences.forumDisplay.copyWith(
        imageCookiePolicy: ForumImageCookiePolicy.always,
      ),
    );
    await tester.pump();
    final alwaysLogin = image;
    expect(alwaysLogin, isNot(firstLogin));
    expect(externalImage, isNotNull);

    account.setUser(_user(forum, 2));
    await tester.pump();
    expect(image, isNotNull);
    expect(image, isNot(alwaysLogin));

    account.setUser(null);
    await tester.pump();
    expect(image, isNull);

    account.setUser(_user(forum, 1));
    await tester.pump();
    expect(image, isNotNull);
    expect(image, isNot(alwaysLogin));
  });
}

class _LoopbackHttpOverrides extends HttpOverrides {}

class _RecordingImageFactory extends ForumHtmlImageFactory {
  _RecordingImageFactory(Uri base, this.sources) : super(null, baseUrl: base);

  final List<String> sources;

  @override
  Widget? buildImageWidget(BuildTree tree, ImageSource source) {
    sources.add(source.url);
    return const SizedBox(width: 10, height: 10);
  }
}

Future<void> _verifyScopedCookies() async {
  final forum = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  addTearDown(() => forum.close(force: true));
  final cdn = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  addTearDown(() => cdn.close(force: true));
  final forumUrl = Uri.http('127.0.0.1:${forum.port}', '/forum/');
  final cdnUrl = Uri.http('127.0.0.1:${cdn.port}', '/image');
  final referer = forumUrl
      .resolve('forum.php?mod=viewthread&tid=42')
      .toString();
  final seen = <(String, String?, String?)>[];

  forum.listen((request) async {
    final path = request.uri.path;
    final cookie = request.headers.value(HttpHeaders.cookieHeader);
    final from = request.headers.value(HttpHeaders.refererHeader);
    seen.add((path, cookie, from));
    if (path == '/forum/redirect') {
      if (cookie == 'auth=test-session' && from == referer) {
        await request.response.redirect(forumUrl.resolve('same-origin'));
      } else {
        request.response.statusCode = HttpStatus.forbidden;
        await request.response.close();
      }
    } else if (path == '/forum/same-origin') {
      await request.response.redirect(cdnUrl);
    } else {
      request.response.add([1, 2, 3]);
      await request.response.close();
    }
  });
  cdn.listen((request) {
    seen.add((
      'cdn',
      request.headers.value(HttpHeaders.cookieHeader),
      request.headers.value(HttpHeaders.refererHeader),
    ));
    request.response.redirect(forumUrl.resolve('return'));
  });

  final jar = CookieJar();
  await jar.saveFromResponse(forumUrl, [
    Cookie('auth', 'test-session')..path = '/forum/',
    Cookie('secure', 'https-only')..secure = true,
  ]);
  Future<List<int>> get(Uri uri) => loadForumImage(
    uri,
    forum: forumUrl,
    threadId: 42,
    cookieJar: () async => jar,
  );

  expect(await get(forumUrl.resolve('redirect')), [1, 2, 3]);
  expect(await get(forumUrl.resolve('/outside/image')), [1, 2, 3]);
  expect(await get(cdnUrl), [1, 2, 3]);
  expect(seen, [
    ('/forum/redirect', 'auth=test-session', referer),
    ('/forum/same-origin', 'auth=test-session', referer),
    ('cdn', null, null),
    ('/forum/return', null, null),
    ('/outside/image', null, referer),
    ('cdn', null, null),
    ('/forum/return', null, null),
  ]);
}

Future<void> _verifyStaleSession() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  addTearDown(() => server.close(force: true));
  final base = Uri.http('127.0.0.1:${server.port}', '/forum/');
  final jar = CookieJar();
  final requestArrived = Completer<void>();
  final sendResponse = Completer<void>();
  var active = true;
  var requests = 0;
  server.listen((request) async {
    requests++;
    requestArrived.complete();
    await sendResponse.future;
    request.response.add([1, 2, 3]);
    await request.response.close();
  });

  Future<List<int>> load(Future<CookieJar> Function() getJar) => loadForumImage(
    base.resolve('image.png'),
    forum: base,
    cookieJar: getJar,
    isCurrent: () => active,
  );
  await expectLater(
    load(() async {
      active = false;
      return jar;
    }),
    throwsStateError,
  );
  expect(requests, 0);

  active = true;
  final image = load(() async => jar);
  final rejected = expectLater(image, throwsStateError);
  await requestArrived.future;
  active = false;
  sendResponse.complete();
  await rejected;
  expect(requests, 1);
}

Discuz _forum(String url) =>
    Discuz(url, 'X3.4', 'utf-8', 4, '', '', false, '', '', 'Forum', '', '', '');

User _user(Discuz forum, int id) =>
    User('', '', 'member', '', 10, id, 10, forum);
