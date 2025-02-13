

import 'package:discuz_flutter/entity/FavoriteForumInDatabase.dart';
import 'package:hive_ce/hive.dart';

import '../entity/Discuz.dart';

class FavoriteForumDao{
  Box<FavoriteForumInDatabase> favoriteForumBox;

  FavoriteForumDao(this.favoriteForumBox);

  List<FavoriteForumInDatabase> getFavoriteForumList(Discuz discuz){
    return favoriteForumBox.values.where((element) => element.discuz == discuz).toList();
  }

  // Stream<List<FavoriteForumInDatabase>> getFavoriteForumListFStream(Discuz discuz){
  //   return favoriteForumBox.watch().map((event) {
  //     List<FavoriteForumInDatabase> list = favoriteForumBox.values.where((element) => element.discuz==discuz).toList();
  //     list.sort((a,b) => a.key > b.key);
  //     return list;
  //   }
  //   );
  // }

  Future<int> insertFavoriteForum(FavoriteForumInDatabase favoriteThreadInDatabase){
    return favoriteForumBox.add(favoriteThreadInDatabase);
  }

  Future<void> removeFavoriteForum(FavoriteForumInDatabase favoriteThreadInDatabase) async{
    favoriteForumBox.delete(favoriteThreadInDatabase.key);
  }

  FavoriteForumInDatabase? getFavoriteForumByFid(int idInServer, Discuz discuz){
    if(favoriteForumBox.values.where((element) => element.idKey == idInServer && element.discuz == discuz).isNotEmpty){
      return favoriteForumBox.values.where((element) => element.idKey == idInServer && element.discuz == discuz).first;
    }
    return null;
  }

  // Stream<FavoriteForumInDatabase?> getFavoriteForumStreamByFid(int idInServer, Discuz discuz){
  //   return favoriteForumBox.watch().map((event) => favoriteForumBox.values.where((element) => element.idKey == idInServer && element.discuz == discuz).first);
  // }

}

// @dao
// abstract class FavoriteForumDao{
//   @Query("SELECT * FROM FavoriteForumInDatabase WHERE discuz_id=:discuzId")
//   Future<List<FavoriteForumInDatabase>> getFavoriteForumList(int discuzId);
//
//   @Query("SELECT * FROM FavoriteForumInDatabase WHERE discuz_id=:discuzId ORDER BY date DESC")
//   Stream<List<FavoriteForumInDatabase>> getFavoriteForumListStream(int discuzId);
//
//
//   @Insert(onConflict: OnConflictStrategy.replace)
//   Future<int> insertFavoriteForum(FavoriteForumInDatabase favoriteThreadInDatabase);
//
//   @delete
//   Future<void> removeFavoriteForum(FavoriteForumInDatabase favoriteThreadInDatabase);
//
//   @Query("SELECT * FROM FavoriteForumInDatabase WHERE idKey=:idInServer AND discuz_id=:discuzId  LIMIT 1")
//   Future<FavoriteForumInDatabase?> getFavoriteForumByFid(int idInServer, int discuzId);
//
//   @Query("SELECT * FROM FavoriteForumInDatabase WHERE idKey=:idInServer AND discuz_id=:discuzId LIMIT 1")
//   Stream<FavoriteForumInDatabase?> getFavoriteForumStreamByFid(int idInServer, int discuzId);
// }