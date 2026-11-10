import 'dart:io';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/BlockUser.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/HotThread.dart';
import 'package:discuz_flutter/entity/NewThread.dart';
import 'package:discuz_flutter/entity/ViewHistory.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/provider/SelectedTidNotifierProvider.dart';
import 'package:discuz_flutter/provider/UserPreferenceNotifierProvider.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/widget/ForumThreadWidget.dart';
import 'package:discuz_flutter/widget/HotThreadWidget.dart';
import 'package:discuz_flutter/widget/NewThreadWidget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:provider/provider.dart';

void main() {
  late Directory directory;

  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('forum_thread_refresh_');
    Hive.init(directory.path);
    Hive.registerAdapter(ViewHistoryAdapter());
    Hive.registerAdapter(BlockUserAdapter());
    await AppDatabase.getViewHistoryDao();
    await AppDatabase.getBlockUserDao();
  });

  tearDownAll(() async {
    AppDatabase.viewHistoryBox = null;
    AppDatabase.blockUserBox = null;
    await Hive.close();
    await directory.delete(recursive: true);
  });

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

      final selected = <int>[];
      Widget row(int tid, String subject) => hot
          ? HotThreadWidget(
              forum,
              null,
              HotThread()
                ..tid = tid
                ..authorId = 7
                ..subject = subject,
              selected.add,
            )
          : NewThreadWidget(
              forum,
              null,
              NewThread()
                ..tid = tid
                ..authorId = 7
                ..subject = subject,
              selected.add,
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
      expect(selected, [1, 2]);
    });
  }
}
