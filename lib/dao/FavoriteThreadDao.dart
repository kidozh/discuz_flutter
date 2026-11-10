import 'package:discuz_flutter/entity/FavoriteThreadInDatabase.dart';
import 'package:hive_ce/hive.dart';

import '../entity/Discuz.dart';

class FavoriteThreadDao {
  Box<FavoriteThreadInDatabase> favoriteThreadBox;

  FavoriteThreadDao(this.favoriteThreadBox);

  List<FavoriteThreadInDatabase> getFavoriteThreadList(
    Discuz discuz, {
    required int uid,
  }) {
    return favoriteThreadBox.values
        .where((entry) => entry.discuz == discuz && entry.uid == uid)
        .toList();
  }

  // Stream<List<FavoriteThreadInDatabase>> getFavoriteThreadListStream(Discuz discuz){
  //   return favoriteThreadBox.watch().map((event) => favoriteThreadBox.values.where((element) => element.discuz == discuz).toList());
  // }

  Future<int> insertFavoriteThread(
    FavoriteThreadInDatabase favoriteThreadInDatabase,
  ) {
    return favoriteThreadBox.add(favoriteThreadInDatabase);
  }

  Future<void> removeFavoriteThread(FavoriteThreadInDatabase favorite) =>
      favoriteThreadBox.delete(favorite.key);

  FavoriteThreadInDatabase? getFavoriteThreadByTid(
    int idInServer,
    Discuz discuz, {
    required int uid,
  }) {
    for (final entry in favoriteThreadBox.values) {
      if (entry.idInServer == idInServer &&
          entry.discuz == discuz &&
          entry.uid == uid) {
        return entry;
      }
    }
    return null;
  }

  // Stream<FavoriteThreadInDatabase?> getFavoriteThreadStreamByTid(int idInServer, Discuz discuz){
  //   return favoriteThreadBox.watch().map((event) => favoriteThreadBox.values.where((element) => element.idInServer == idInServer && element.discuz == discuz).first);
  // }
}

// @dao
// abstract class FavoriteThreadDao{
//   @Query("SELECT * FROM FavoriteThreadInDatabase WHERE discuz_id=:discuzId")
//   Future<List<FavoriteThreadInDatabase>> getFavoriteThreadList(int discuzId);
//
//   @Query("SELECT * FROM FavoriteThreadInDatabase WHERE discuz_id=:discuzId ORDER BY date DESC")
//   Stream<List<FavoriteThreadInDatabase>> getFavoriteThreadListStream(int discuzId);
//
//
//   @Insert(onConflict: OnConflictStrategy.replace)
//   Future<int> insertFavoriteThread(FavoriteThreadInDatabase favoriteThreadInDatabase);
//
//   @delete
//   Future<void> removeFavoriteThread(FavoriteThreadInDatabase favoriteThreadInDatabase);
//
//   @Query("SELECT * FROM FavoriteThreadInDatabase WHERE idInServer=:idInServer AND discuz_id=:discuzId  LIMIT 1")
//   Future<FavoriteThreadInDatabase?> getFavoriteThreadByTid(int idInServer, int discuzId);
//
//   @Query("SELECT * FROM FavoriteThreadInDatabase WHERE idInServer=:idInServer AND discuz_id=:discuzId LIMIT 1")
//   Stream<FavoriteThreadInDatabase?> getFavoriteThreadStreamByTid(int idInServer, int discuzId);
// }
