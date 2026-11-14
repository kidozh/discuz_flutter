import 'dart:io';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/BlockUser.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/HotThread.dart';
import 'package:discuz_flutter/entity/NewThread.dart';
import 'package:discuz_flutter/entity/Post.dart';
import 'package:discuz_flutter/entity/ViewHistory.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/ViewThreadSliverPage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/provider/DiscuzNotificationProvider.dart';
import 'package:discuz_flutter/provider/SelectedTidNotifierProvider.dart';
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/provider/TypeSettingNotifierProvider.dart';
import 'package:discuz_flutter/provider/UserPreferenceNotifierProvider.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/widget/ForumThreadWidget.dart';
import 'package:discuz_flutter/widget/HotThreadWidget.dart';
import 'package:discuz_flutter/widget/LoadingStateWidget.dart';
import 'package:discuz_flutter/widget/NewThreadWidget.dart';
import 'package:discuz_flutter/widget/PostWidget.dart';
import 'package:discuz_flutter/widget/UserAvatar.dart';
import 'package:discuz_flutter/widget/post_action_row.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Directory directory;

  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('forum_thread_refresh_');
    Hive.init(directory.path);
    Hive.registerAdapter(ViewHistoryAdapter());
    Hive.registerAdapter(BlockUserAdapter());
    await AppDatabase.getViewHistoryDao();
    await AppDatabase.getBlockUserDao();
    await AppDatabase.getFavoriteThreadDao();
    await AppDatabase.getViewThreadCacheDao();
    await AppDatabase.getViewThreadScrollDistanceDao();
  });

  tearDownAll(() async {
    AppDatabase.viewHistoryBox = null;
    AppDatabase.blockUserBox = null;
    AppDatabase.favoriteThreadBox = null;
    AppDatabase.viewThreadCacheBox = null;
    AppDatabase.viewThreadScrollDistanceBox = null;
    await Hive.close();
    await directory.delete(recursive: true);
  });

  testWidgets('the initial loading card shows the selected thread title', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final forum = Discuz(
      'https://example.test',
      'X3.5',
      'utf-8',
      4,
      '',
      '',
      false,
      '',
      '',
      'Example',
      '1',
      '',
      '',
    );
    final account = DiscuzAndUserNotifier()..initDiscuz(forum);
    addTearDown(account.dispose);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: account),
          ChangeNotifierProvider(create: (_) => DiscuzNotificationProvider()),
          ChangeNotifierProvider(
            create: (_) => UserPreferenceNotifierProvider(),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            S.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          home: ViewThreadSliverPage(
            forum,
            null,
            17,
            passedSubject: 'Tips &amp; fixes',
          ),
        ),
      ),
    );
    expect(
      find.descendant(
        of: find.byType(LoadingStateWidget),
        matching: find.text('Tips & fixes'),
      ),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(Duration.zero);
  });

  testWidgets(
    'first post aligns avatar, author and timestamp on narrow screens',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final forum = Discuz(
        'https://example.test',
        'X3.5',
        'utf-8',
        4,
        '',
        '',
        false,
        '',
        '',
        'Example',
        '1',
        'https://example.test/ucenter',
        '',
      );
      final post = Post()
        ..first = true
        ..author = 'Thread author'
        ..authorId = 7
        ..publishAt = DateTime(2025, 1, 15)
        ..message = '<p>Body</p>';
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => DiscuzAndUserNotifier()..initDiscuz(forum),
            ),
            ChangeNotifierProvider(create: (_) => DiscuzNotificationProvider()),
            ChangeNotifierProvider(
              create: (_) => TypeSettingNotifierProvider(),
            ),
            ChangeNotifierProvider(create: (_) => ThemeNotifierProvider()),
            ChangeNotifierProvider(
              create: (_) => UserPreferenceNotifierProvider(),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              S.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            home: Scaffold(
              body: SizedBox(width: 260, child: PostWidget(forum, post, 7, '')),
            ),
          ),
        ),
      );
      await tester.pump();
      final header = find.byType(PostActionRow);
      final author = find.descendant(
        of: header,
        matching: find.textContaining('Thread author', findRichText: true),
      );
      final timestamp = find.descendant(
        of: header,
        matching: find.textContaining('2025', findRichText: true),
      );
      final avatar = find.descendant(
        of: header,
        matching: find.byType(UserAvatar),
      );
      final authorRect = tester.getRect(author);
      final timestampRect = tester.getRect(timestamp);
      expect(timestampRect.top - authorRect.bottom, closeTo(2, 0.1));
      expect(timestampRect.left, authorRect.left);
      expect(
        tester.getCenter(avatar).dy,
        closeTo((authorRect.top + timestampRect.bottom) / 2, 0.1),
      );
      expect(tester.takeException(), isNull);
    },
  );

  for (final hot in [false, true]) {
    testWidgets('${hot ? 'hot' : 'latest'} feed rows update in place', (
      tester,
    ) async {
      final forum = Discuz(
        'https://example.test',
        'X3.5',
        'utf-8',
        4,
        '',
        '',
        false,
        '',
        '',
        'Example',
        '1',
        'https://example.test/ucenter',
        '',
      );
      final avatar = CachedNetworkImageProvider(
        URLUtils.getAvatarURL(forum, '7'),
      );
      final recorder = ui.PictureRecorder();
      ui.Canvas(recorder);
      final frame = recorder.endRecording();
      final image = frame.toImageSync(1, 1);
      frame.dispose();
      final cache = PaintingBinding.instance.imageCache;
      cache.putIfAbsent(
        avatar,
        () => OneFrameImageStreamCompleter(
          SynchronousFuture(ImageInfo(image: image)),
        ),
      );
      addTearDown(() => cache.evict(avatar));

      final selected = <(int, String?)>[];
      void select(int tid, {String? subject}) => selected.add((tid, subject));
      Widget row(int tid, String subject) => hot
          ? HotThreadWidget(
              forum,
              null,
              HotThread()
                ..tid = tid
                ..authorId = 7
                ..subject = subject,
              select,
            )
          : NewThreadWidget(
              forum,
              null,
              NewThread()
                ..tid = tid
                ..authorId = 7
                ..subject = subject,
              select,
            );

      Future<void> show(int tid, String subject) => tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => DiscuzAndUserNotifier()..initDiscuz(forum),
            ),
            ChangeNotifierProvider(
              create: (_) => SelectedTidNotifierProvider(),
            ),
            ChangeNotifierProvider(
              create: (_) => UserPreferenceNotifierProvider(),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              S.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            home: Scaffold(body: row(tid, subject)),
          ),
        ),
      );

      await show(1, 'Original title');
      final rowFinder = find.byType(ForumThreadStatefulWidget);
      final firstRow = tester.state<ForumThreadState>(rowFinder);
      expect(find.text('Original title'), findsOneWidget);
      await tester.tap(find.text('Original title'));
      await tester.pump();
      expect(firstRow.read, isTrue);

      await show(1, 'Edited title');
      expect(find.text('Edited title'), findsOneWidget);
      expect(tester.state<ForumThreadState>(rowFinder), same(firstRow));

      await show(2, 'Newest thread');
      expect(find.text('Edited title'), findsNothing);
      expect(tester.state<ForumThreadState>(rowFinder).read, isFalse);
      await tester.tap(find.text('Newest thread'));
      expect(selected, [(1, 'Original title'), (2, 'Newest thread')]);
    });
  }
}
