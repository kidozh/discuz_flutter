

import 'package:hive_ce/hive.dart';

import '../utility/ConstUtils.dart';
import 'Discuz.dart';

part 'FavoriteForumInDatabase.g.dart';

@HiveType(typeId: ConstUtils.HIVE_TYPE_ID_FAVORITE_FORUM)
class FavoriteForumInDatabase extends HiveObject{
  @HiveField(0)
  int favid = 0;
  @HiveField(1)
  int uid = 0;
  @HiveField(2)
  int idKey = 0;
  @HiveField(3)
  String idType = "";
  @HiveField(4)
  String title = "";
  @HiveField(5)
  String description = "";
  @HiveField(6)
  DateTime date = DateTime.now();
  @HiveField(7)
  Discuz discuz;

  FavoriteForumInDatabase(
      this.favid,
      this.uid,
      this.idKey,
      this.idType,
      this.title,
      this.description,
      this.date,
      this.discuz);
}