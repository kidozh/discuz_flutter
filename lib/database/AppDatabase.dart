// database.dart

// required package imports
import 'dart:async';
import 'package:discuz_flutter/converter/FloorDateTimeConverter.dart';
import 'package:discuz_flutter/dao/DiscuzDao.dart';
import 'package:discuz_flutter/dao/SmileyDao.dart';
import 'package:discuz_flutter/dao/UserDao.dart';
import 'package:discuz_flutter/dao/ViewHistoryDao.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/FavoriteThreadInDatabase.dart';
import 'package:discuz_flutter/entity/Smiley.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/entity/ViewHistory.dart';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;



part 'AppDatabase.g.dart'; // the generated code will be there

@Database(version: 2, entities: [User, Discuz, ViewHistory, FavoriteThreadInDatabase, Smiley])
abstract class AppDatabase extends FloorDatabase {
  UserDao get userDao;
  DiscuzDao get discuzDao;
  ViewHistoryDao get viewHistoryDao;
  SmileyDao get smileyDao;

  static final migration1to2 = Migration(1, 2, (database) async {
    await database.execute('CREATE TABLE IF NOT EXISTS `Smiley` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `code` TEXT NOT NULL, `relativePath` TEXT NOT NULL, `discuz_id` INTEGER NOT NULL, FOREIGN KEY (`discuz_id`) REFERENCES `Discuz` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE)');
  });

  static final migration2to3 = Migration(2, 3, (database) async {
    await database.execute('CREATE TABLE IF NOT EXISTS `ViewHistory` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `title` TEXT NOT NULL, `subject` TEXT NOT NULL, `description` TEXT NOT NULL, `type` TEXT NOT NULL, `identification` INTEGER NOT NULL, `author` TEXT NOT NULL, `authorId` INTEGER NOT NULL, `insertTime` INTEGER NOT NULL, `updateTime` INTEGER NOT NULL, `discuz_id` INTEGER NOT NULL, FOREIGN KEY (`discuz_id`) REFERENCES `Discuz` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE)');
  });

}