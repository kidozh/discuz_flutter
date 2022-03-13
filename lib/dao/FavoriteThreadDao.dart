

import 'package:discuz_flutter/entity/FavoriteForumInDatabase.dart';
import 'package:discuz_flutter/entity/FavoriteThreadInDatabase.dart';
import 'package:floor/floor.dart';

@dao
abstract class FavoriteThreadDao{
  @Query("SELECT * FROM FavoriteThreadInDatabase WHERE discuz_id=:discuzId")
  Future<List<FavoriteThreadInDatabase>> getFavoriteThreadList(int discuzId);

  @Query("SELECT * FROM FavoriteThreadInDatabase WHERE discuz_id=:discuzId ORDER BY date DESC")
  Stream<List<FavoriteThreadInDatabase>> getFavoriteThreadListStream(int discuzId);


  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertFavoriteThread(FavoriteThreadInDatabase favoriteThreadInDatabase);

  @delete
  Future<void> removeFavoriteThread(FavoriteThreadInDatabase favoriteThreadInDatabase);

  @Query("SELECT * FROM FavoriteThreadInDatabase WHERE idInServer=:idInServer AND discuz_id=:discuzId  LIMIT 1")
  Future<FavoriteThreadInDatabase?> getFavoriteThreadByTid(int idInServer, int discuzId);

  @Query("SELECT * FROM FavoriteThreadInDatabase WHERE idInServer=:idInServer AND discuz_id=:discuzId LIMIT 1")
  Stream<FavoriteThreadInDatabase?> getFavoriteThreadStreamByTid(int idInServer, int discuzId);
}