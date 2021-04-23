import 'package:discuz_flutter/database/DiscuzDatabase.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:floor/floor.dart';

final discuzDBName = "discuz.db";
final appDBName = "app.db";

class DBHelper {
  static Future<AppDatabase> getAppDb() async {
    // create migration

    final appDb = await $FloorAppDatabase.databaseBuilder(appDBName)
        .build();
    return appDb;
  }
}
