import 'dart:convert';
import 'dart:io';

import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/ForumThread.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/forum_image_session.dart';
import 'package:discuz_flutter/utility/thread_attachment_preview.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

Discuz _forum(String url) =>
    Discuz(url, 'X3.5', 'utf-8', 4, '', '', false, '', '', '', '', '', '');

void main() {
  test(
    'feed thumbnails preserve URLs, signed tokens and attachment identity',
    () {
      final forum = _forum('https://bbs.example.com/install');
      final attachment = AttachmentPreview.fromJson({
        'aid': '7',
        'tid': 42,
        'pid': '9',
        'attachment': '202611/01/cover.png',
        'url': '//cdn.example.com/forum/',
        'aidencode': 'a%2Bb%3D',
        'remote': '1',
      });
      expect((attachment.aid, attachment.tid, attachment.pid), (7, 42, 9));
      final roundTrip = AttachmentPreview.fromJson(attachment.toJson());
      expect(roundTrip.remote, isTrue);
      final urls = threadAttachmentPreviewUrls(forum, roundTrip)!;
      expect(
        urls.primary.toString(),
        'https://cdn.example.com/forum/202611/01/cover.png',
      );
      expect(urls.fallback?.path, '/install/forum.php');
      expect(urls.fallback?.queryParameters, {
        'mod': 'attachment',
        'aid': 'a+b=',
        'nothumb': 'yes',
        'noupdate': 'yes',
      });

      attachment.price = 3;
      expect(
        threadAttachmentPreviewUrls(forum, attachment)?.primary,
        urls.fallback,
      );
      attachment.aidEncode = '';
      expect(threadAttachmentPreviewUrls(forum, attachment), isNull);
      attachment.attachment = '/data/attachment/forum/202611/cover.png';
      attachment.url = 'forum.php?mod=attachment&aid=server-signed';
      expect(
        threadAttachmentPreviewUrls(
          forum,
          attachment,
        )?.primary.queryParameters['aid'],
        'server-signed',
      );
    },
  );

  test('legacy and full attachment paths resolve within the forum install', () {
    final forum = _forum('https://bbs.example.com/install');
    final attachment = AttachmentPreview()..attachment = '202611/image.png';
    expect(
      threadAttachmentPreviewUrls(forum, attachment)?.primary.path,
      '/install/data/attachment/forum/202611/image.png',
    );
    attachment.attachment = './data/attachment/forum/202611/image.png';
    expect(
      threadAttachmentPreviewUrls(forum, attachment)?.primary.path,
      '/install/data/attachment/forum/202611/image.png',
    );
    attachment.attachment = 'forum.php?mod=attachment&aid=encoded';
    expect(
      threadAttachmentPreviewUrls(forum, attachment)?.primary.path,
      '/install/forum.php',
    );
    attachment.attachment = 'https://cdn.example.com/202611/image.png';
    expect(
      threadAttachmentPreviewUrls(forum, attachment)?.primary.host,
      'cdn.example.com',
    );
    attachment.attachment = '202611/image.png';
    attachment.remote = true;
    expect(threadAttachmentPreviewUrls(forum, attachment), isNull);
  });

  test(
    'remote preview lookup and image retrieval use the same cookie',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      final base = Uri.parse('http://127.0.0.1:${server.port}/bbs/');
      final imagePath = '/bbs/private/202611/cover.png';
      final referer = base
          .resolve('forum.php?mod=viewthread&tid=42')
          .toString();
      final requests = <(String, String?, String?)>[];
      const sessionCookie = 'auth=preview-session';
      final png = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADElEQVR4nGMQmPkBAAJWAZogwV3tAAAAAElFTkSuQmCC',
      );
      server.listen((request) async {
        final uri = request.uri;
        final cookie = request.headers.value(HttpHeaders.cookieHeader);
        final from = request.headers.value(HttpHeaders.refererHeader);
        requests.add((uri.path, cookie, from));
        if (cookie != sessionCookie) {
          request.response.statusCode = HttpStatus.forbidden;
        } else if (uri.path == '/bbs/api/mobile/index.php' &&
            uri.queryParameters['module'] == 'viewthread' &&
            uri.queryParameters['tid'] == '42' &&
            uri.queryParameters['viewpid'] == '9') {
          request.response.headers.contentType = ContentType.json;
          request.response.write(
            jsonEncode({
              'Variables': {
                'member_uid': '2',
                'thread': {'tid': '42'},
                'postlist': [
                  {
                    'tid': '42',
                    'pid': '9',
                    'message':
                        '<img src="/bbs/private/other/cover.png" attach="9">'
                        '<img src="$imagePath" attach="9">',
                  },
                ],
              },
            }),
          );
        } else if (uri.path == imagePath && from == referer) {
          request.response.headers.contentType = ContentType('image', 'png');
          request.response.add(png);
        } else {
          request.response.statusCode = HttpStatus.notFound;
        }
        await request.response.close();
      });

      final directory = await Directory.systemTemp.createTemp(
        'discuz-preview-cookie-',
      );
      final previousPaths = PathProviderPlatform.instance;
      PathProviderPlatform.instance = _TestPaths(directory.path);
      addTearDown(() async {
        PathProviderPlatform.instance = previousPaths;
        await directory.delete(recursive: true);
      });
      final forum = _forum(base.toString());
      final user = User('auth', '', 'Reader', '', 1, 2, 10, forum);
      await NetworkUtils.replacePersistentCookiesForUser(user, base, [
        Cookie('auth', 'preview-session')..path = '/bbs/',
      ]);

      await HttpOverrides.runWithHttpOverrides(() async {
        final preview = AttachmentPreview.fromJson({
          'aid': '7',
          'tid': '42',
          'pid': '9',
          'attachment': '202611/cover.png',
          'remote': '1',
        });
        final urls = await loadThreadAttachmentPreview(
          forum: forum,
          user: user,
          tid: 42,
          preview: preview,
          isCurrent: () => true,
        );
        expect(urls?.primary.path, imagePath);
        final image = await loadForumImage(
          urls!.primary,
          forum: base,
          threadId: 42,
          cookieJar: () => NetworkUtils.getPersistentCookieJarByUser(user),
        );
        expect(image, png);
      }, _LoopbackOverrides());
      expect(requests, [
        ('/bbs/api/mobile/index.php', sessionCookie, null),
        (imagePath, sessionCookie, referer),
      ]);
    },
  );
}

class _TestPaths extends PathProviderPlatform {
  _TestPaths(this.path);
  final String path;

  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}

class _LoopbackOverrides extends HttpOverrides {}
