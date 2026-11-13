import 'dart:io';

import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/FavoriteForumInDatabase.dart';
import 'package:discuz_flutter/entity/FavoriteThreadInDatabase.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/FavoriteForumPage.dart';
import 'package:discuz_flutter/page/FavoriteThreadPage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:provider/provider.dart';

void main() {
  final site = Discuz(
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
  late Directory directory;

  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('favorites_inset_');
    Hive.init(directory.path);
    Hive.registerAdapter(DiscuzAdapter());
    Hive.registerAdapter(FavoriteForumInDatabaseAdapter());
    Hive.registerAdapter(FavoriteThreadInDatabaseAdapter());
    final forums = await AppDatabase.getFavoriteForumDao();
    final threads = await AppDatabase.getFavoriteThreadDao();
    final date = DateTime(2024);
    for (var id = 1; id <= 20; id++) {
      await forums.insertFavoriteForum(
        FavoriteForumInDatabase(id, 0, id, 'fid', 'Board $id', '', date, site),
      );
      await threads.insertFavoriteThread(
        FavoriteThreadInDatabase(
          id,
          0,
          id,
          'tid',
          0,
          'Thread $id',
          '',
          'Author',
          0,
          date,
          site,
        ),
      );
    }
  });

  tearDownAll(() async {
    AppDatabase.favoriteForumBox = null;
    AppDatabase.favoriteThreadBox = null;
    await Hive.close();
    await directory.delete(recursive: true);
  });

  for (final (page, title) in [
    (FavoriteForumPage(), 'Board'),
    (FavoriteThreadPage(), 'Thread'),
  ]) {
    testWidgets('$title list scrolls through the inset and clears it at rest', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 640);
      tester.view.padding = const FakeViewPadding(bottom: 34);
      tester.view.viewPadding = const FakeViewPadding(bottom: 34);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => DiscuzAndUserNotifier()..initDiscuz(site),
          child: PlatformProvider(
            style: AppVisualStyle.cupertino,
            builder: (_) => MaterialApp(
              localizationsDelegates: const [
                S.delegate,
                ...GlobalMaterialLocalizations.delegates,
              ],
              supportedLocales: S.delegate.supportedLocales,
              home: page,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final list = find.byType(ListView);
      expect(tester.getBottomRight(list).dy, 640);
      final scrollable = find.descendant(
        of: list,
        matching: find.byType(Scrollable),
      );
      final lastItem = find.text('$title 20');
      await tester.scrollUntilVisible(lastItem, 280, scrollable: scrollable);
      final position = tester.state<ScrollableState>(scrollable).position;
      position.jumpTo(position.maxScrollExtent);
      await tester.pumpAndSettle();
      expect(lastItem.hitTestable(), findsOneWidget);
      expect(tester.getBottomRight(lastItem).dy, lessThan(640 - 34));
    }, variant: const TargetPlatformVariant({TargetPlatform.iOS}));
  }
}
