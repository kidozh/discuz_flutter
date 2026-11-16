import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/client/ForumInteractionClient.dart';
import 'package:discuz_flutter/client/discuz_web_client.dart';
import 'package:discuz_flutter/client/forum_web_features.dart';
import 'package:discuz_flutter/entity/Post.dart';
import 'package:discuz_flutter/utility/post_editor_controller.dart';
import 'package:discuz_flutter/utility/reply_draft_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'forum search identifies a verification form before parsing results',
    () async {
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              expect(options.method, 'POST');
              expect(options.data['srchfid'], '17');
              expect(options.data['srchtxt'], 'quiz');
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: '''
            <form action="search.php">
              <input name="srchtxt" value="quiz">
              <input name="seccodehash" value="local">
              <input name="seccodeverify">
            </form>
          ''',
                ),
              );
            },
          ),
        );
      addTearDown(dio.close);
      final client = ForumSearchClient(
        DiscuzWebClient(
          ForumInteractionClient(dio, 'https://forum.test/community'),
        ),
      );
      await expectLater(
        client.search('quiz', 17),
        throwsA(
          isA<ForumApiException>().having(
            (error) => error.code,
            'code',
            'forum_search_captcha',
          ),
        ),
      );
      expect(
        ForumSearchClient.website(client.web.base, 'quiz', 17).path,
        '/community/search.php',
      );
      expect(
        ForumSearchClient.website(
          client.web.base,
          'quiz',
          17,
        ).queryParameters['srchtxt'],
        'quiz',
      );
    },
  );

  test(
    'the website client does not follow redirects outside the forum install',
    () async {
      var count = 0;
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              count++;
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 302,
                  headers: Headers.fromMap({
                    'location': [
                      'https://forum.test/other/search.php?searchid=1',
                    ],
                  }),
                ),
              );
            },
          ),
        );
      addTearDown(dio.close);
      final web = DiscuzWebClient(
        ForumInteractionClient(dio, 'https://forum.test/community'),
      );
      await expectLater(
        ForumSearchClient(web).search('quiz', null),
        throwsA(
          isA<ForumApiException>().having(
            (error) => error.code,
            'code',
            'forum_webpage_redirect',
          ),
        ),
      );
      expect(count, 1);
    },
  );

  test('a reopened draft restores its quote and attachment bytes in the same scope', () async {
    final folder = await Directory.systemTemp.createTemp('reply-draft-test-');
    addTearDown(() => folder.delete(recursive: true));
    Future<Directory> root() async => folder;
    const site = 'https://forum.test/community';
    final store = ReplyDraftStore(site, 1, 42, root: root);
    final file = await store.add(
      name: 'notes.txt',
      image: false,
      bytes: Stream.value(utf8.encode('draft file')),
    );
    final image = await store.add(
      name: 'image.png',
      image: true,
      bytes: Stream.value([1, 2, 3]),
    );
    final quote = Post()
      ..tid = 42
      ..pid = 31
      ..author = 'Reader'
      ..message = 'Earlier reply';
    final text = 'My reply\n${file.token}\n${image.token}';
    await store.write(
      ReplyDraft(text: text, quote: quote, attachments: [file, image]),
    );
    final same = ReplyDraftStore(site, 1, 42, root: root);
    final restored = (await same.read())!;
    expect(restored.quote?.pid, 31);
    expect(restored.quote?.message, 'Earlier reply');
    expect(restored.text, text);
    final tokens = PostEditorToken.inText(restored.text).toList();
    expect(tokens.map((token) => token.isPending), [true, true]);
    expect(tokens.first.isFile, isTrue);
    expect(tokens.last.isAttachment, isTrue);
    expect(
      await (await same.file(restored.attachments[0])).readAsString(),
      'draft file',
    );
    expect(await (await same.file(restored.attachments[1])).readAsBytes(), [
      1,
      2,
      3,
    ]);
    expect(await ReplyDraftStore(site, 2, 42, root: root).read(), isNull);
    expect(await ReplyDraftStore(site, 1, 43, root: root).read(), isNull);
    expect(
      await ReplyDraftStore(
        'https://forum.test/another',
        1,
        42,
        root: root,
      ).read(),
      isNull,
    );
    await same.write(const ReplyDraft(text: ''));
    expect(await store.read(), isNull);
  });
}
