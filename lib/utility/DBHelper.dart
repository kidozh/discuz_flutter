import 'package:discuz_flutter/database/DiscuzDatabase.dart';
import 'package:discuz_flutter/database/UserDatabase.dart';
import 'package:floor/floor.dart';

final discuzDBName = "discuz.db";

class DBHelper {
  static Future<DiscuzDatabase> getDiscuzDb() async {
    // create migration
    final migration1to2 = Migration(1, 2, (database) async {
      await database.execute('ALTER TABLE Discuz ADD COLUMN baseURL TEXT');
    });

    final migration2to3 = Migration(2, 3, (database) async {
      await database.execute('DROP TABLE Discuz');
    });

    final migration3to4 = Migration(3, 4, (database) async {

    });

    final discuzDB =
        await $FloorDiscuzDatabase.databaseBuilder(discuzDBName)
            .addMigrations([migration1to2,migration2to3,migration3to4])

            .build();
    return discuzDB;
  }

  static Future<UserDatabase> getUserDb() async {
    // create migration

    final discuzDB =
    await $FloorUserDatabase.databaseBuilder(discuzDBName)
        .build();
    return discuzDB;
  }
}
