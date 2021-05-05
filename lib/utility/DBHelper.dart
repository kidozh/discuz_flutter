import 'package:discuz_flutter/database/DiscuzDatabase.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/database/TrustHostDatabase.dart';
import 'package:floor/floor.dart';

final discuzDBName = "discuz.db";
final appDBName = "app.db";
final trustHostDBName = "trustHost.db";

class DBHelper {
  static Future<AppDatabase> getAppDb() async {
    // create migration
    final appDb = await $FloorAppDatabase.databaseBuilder(appDBName)
        .addMigrations([AppDatabase.migration1to2])
        .build();

    return appDb;
  }

  static Future<TrustHostDatabase> getTrustHostDb() async {
    // create migration
    final appDb = await $FloorTrustHostDatabase.databaseBuilder(trustHostDBName)
        .build();

    return appDb;
  }
}
