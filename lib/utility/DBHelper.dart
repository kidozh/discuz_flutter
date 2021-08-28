import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/database/TrustHostDatabase.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

final discuzDBName = "discuz.db";
final appDBName = "app.db";
final trustHostDBName = "trustHost.db";

class DBHelper {
  static Future<AppDatabase> getAppDb() async {
    // create migration
    var directory = await getApplicationDocumentsDirectory();
    String path = p.join(directory.toString(),appDBName);

    final appDb = await $FloorAppDatabase.databaseBuilder(path)
        .addMigrations([AppDatabase.migration1to2])
        .build();

    return appDb;
  }

  static Future<TrustHostDatabase> getTrustHostDb() async {
    // create migration
    var directory = await getApplicationDocumentsDirectory();
    String path = p.join(directory.toString(),trustHostDBName);
    final appDb = await $FloorTrustHostDatabase.databaseBuilder(path)
        .build();

    return appDb;
  }
}
