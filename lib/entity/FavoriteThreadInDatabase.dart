

import 'package:hive_ce/hive.dart';

import '../utility/ConstUtils.dart';
import 'Discuz.dart';

part 'FavoriteThreadInDatabase.g.dart';

@HiveType(typeId: ConstUtils.HIVE_TYPE_ID_FAVORITE_THREAD)
class FavoriteThreadInDatabase extends HiveObject{
  @HiveField(0)
  int favid = 0;
  @HiveField(1)
  int uid = 0;
  @HiveField(2)
  int idInServer = 0;
  @HiveField(3)
  String idType = "";
  @HiveField(4)
  int spaceUid = 0;
  @HiveField(5)
  String title = "";
  @HiveField(6)
  String description = "";
  @HiveField(7)
  String author = "";
  @HiveField(8)
  int replies = 0;
  @HiveField(9)
  DateTime date = DateTime.now();

  @HiveField(10)
  Discuz discuz;

  FavoriteThreadInDatabase(
      this.favid,
      this.uid,
      this.idInServer,
      this.idType,
      this.spaceUid,
      this.title,
      this.description,
      this.author,
      this.replies,
      this.date,
      this.discuz);
}