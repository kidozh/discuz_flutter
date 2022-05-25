
import 'package:discuz_flutter/entity/FavoriteThreadInDatabase.dart';
import 'package:hive/hive.dart';

import '../entity/Discuz.dart';

class FavoriteThreadDao{
  Box<FavoriteThreadInDatabase> favoriteThreadBox;

  FavoriteThreadDao(this.favoriteThreadBox);

  List<FavoriteThreadInDatabase> getFavoriteThreadList(Discuz discuz){
    return favoriteThreadBox.values.where((element) => element.discuz == discuz).toList();
  }


  Stream<List<FavoriteThreadInDatabase>> getFavoriteThreadListStream(Discuz discuz){
    return favoriteThreadBox.watch().map((event) => favoriteThreadBox.values.where((element) => element.discuz == discuz).toList());
  }

  Future<int> insertFavoriteThread(FavoriteThreadInDatabase favoriteThreadInDatabase){
    return favoriteThreadBox.add(favoriteThreadInDatabase);
  }

  Future<void> removeFavoriteThread(FavoriteThreadInDatabase favoriteThreadInDatabase) async{
    favoriteThreadBox.values.where((element) => element == favoriteThreadInDatabase).forEach((element) {
      favoriteThreadBox.delete(favoriteThreadInDatabase.key);
    });
  }

  FavoriteThreadInDatabase? getFavoriteThreadByTid(int idInServer, Discuz discuz){
    if(favoriteThreadBox.values.where((element) => element.idInServer == idInServer && element.discuz == discuz).isNotEmpty){
      return favoriteThreadBox.values.where((element) => element.idInServer == idInServer && element.discuz == discuz).first;
    }
    else{
      return null;
    }
  }

  Stream<FavoriteThreadInDatabase?> getFavoriteThreadStreamByTid(int idInServer, Discuz discuz){
    return favoriteThreadBox.watch().map((event) => favoriteThreadBox.values.where((element) => element.idInServer == idInServer && element.discuz == discuz).first);
  }

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