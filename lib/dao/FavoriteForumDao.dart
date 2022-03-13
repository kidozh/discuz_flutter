

import 'package:discuz_flutter/entity/FavoriteForumInDatabase.dart';
import 'package:floor/floor.dart';

@dao
abstract class FavoriteForumDao{
  @Query("SELECT * FROM FavoriteForumInDatabase WHERE discuz_id=:discuzId")
  Future<List<FavoriteForumInDatabase>> getFavoriteForumList(int discuzId);

  @Query("SELECT * FROM FavoriteForumInDatabase WHERE discuz_id=:discuzId ORDER BY date DESC")
  Stream<List<FavoriteForumInDatabase>> getFavoriteForumListStream(int discuzId);


  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertFavoriteForum(FavoriteForumInDatabase favoriteThreadInDatabase);

  @delete
  Future<void> removeFavoriteForum(FavoriteForumInDatabase favoriteThreadInDatabase);

  @Query("SELECT * FROM FavoriteForumInDatabase WHERE idKey=:idInServer AND discuz_id=:discuzId  LIMIT 1")
  Future<FavoriteForumInDatabase?> getFavoriteForumByFid(int idInServer, int discuzId);

  @Query("SELECT * FROM FavoriteForumInDatabase WHERE idKey=:idInServer AND discuz_id=:discuzId LIMIT 1")
  Stream<FavoriteForumInDatabase?> getFavoriteForumStreamByFid(int idInServer, int discuzId);
}