import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/entity/ViewHistory.dart';
import 'package:hive/hive.dart';

class ViewHistoryDao{
  Box<ViewHistory> viewHistoryBox;

  ViewHistoryDao(this.viewHistoryBox);

  List<ViewHistory> findAllViewHistoriesByDiscuz(Discuz discuz){
    return viewHistoryBox.values.where((element) => element.discuz == discuz).toList();
  }

  Stream<List<ViewHistory>> findAllViewHistoriesStreamByDiscuz(Discuz discuz){
    return viewHistoryBox.watch().map((event) => viewHistoryBox.values.where((element) => element.discuz == discuz).toList());
  }

  Future<int> insertViewHistory(ViewHistory viewHistory){
    return viewHistoryBox.add(viewHistory);
  }

  Future<void> deleteViewHistory(ViewHistory viewHistory) async{
    return viewHistoryBox.values.where((element) => viewHistory == element).forEach((element) {
      viewHistoryBox.delete(viewHistory.key);
    });
  }

  void deleteViewHistories(List<ViewHistory> viewHistories){
    return viewHistoryBox.values.where((element) => viewHistories.contains(element)).forEach((element) {
      viewHistoryBox.delete(element.key);
    });
  }

  Future<int> deleteAllViewHistory() {
    return viewHistoryBox.clear();
  }

  Future<void> deleteViewHistoryByDiscuz(Discuz discuz) async{
    return viewHistoryBox.values.where((element) => element.discuz == discuz).forEach((element) {
      viewHistoryBox.delete(element.key);
    });
  }

  Stream<bool> threadHistoryExistInDatabase(Discuz discuz, int tid){
    return viewHistoryBox.watch().map((event) => viewHistoryBox.values.where((element) => element.identification == tid && element.discuz == discuz && element.type == "thread").isNotEmpty);
  }

  Stream<bool> forumHistoryExistInDatabase(Discuz discuz, int fid){
    return viewHistoryBox.watch().map((event) => viewHistoryBox.values.where((element) => element.identification == fid && element.discuz == discuz && element.type == "forum").isNotEmpty);
  }

  ViewHistory? forumExistInDatabase(Discuz discuz, int fid){
    if(viewHistoryBox.values.where((element) => element.identification == fid && element.discuz == discuz && element.type == "forum").isNotEmpty){
      return viewHistoryBox.values.where((element) => element.identification == fid && element.discuz == discuz && element.type == "forum").first;
    }
    else{
      return null;
    }
  }

}

// @dao
// abstract class ViewHistoryDao {
//
//   @Query('SELECT * FROM ViewHistory WHERE discuz_id=:discuzId ORDER BY updateTime DESC')
//   Future<List<ViewHistory>> findAllViewHistoriesByDiscuzId(int discuzId);
//
//   @Query('SELECT * FROM ViewHistory WHERE discuz_id=:discuzId ORDER BY updateTime DESC')
//   Stream<List<ViewHistory>> findAllViewHistoriesStreamByDiscuzId(int discuzId);
//
//   // @Insert(onConflict: OnConflictStrategy.replace)
//   // Future<void> insertUser(User user);
//   @insert
//   Future<int> insertViewHistory(ViewHistory viewHistory);
//
//   @delete
//   Future<int> deleteViewHistory(ViewHistory viewHistory);
//
//   @delete
//   Future<int> deleteViewHistories(List<ViewHistory> viewHistories);
//
//   @Query("DELETE FROM ViewHistory")
//   Future<void> deleteAllViewHistory();
//
//   @Query("DELETE FROM ViewHistory WHERE discuz_id=:discuzId")
//   Future<void> deleteViewHistoryByBBSId(int discuzId);
//
//   @transaction
//   Future<void> deleteAllHistories() async {
//     await deleteAllViewHistory();
//     await deleteViewHistory(ViewHistory(0, "", "", "", "", 0, "", 0, 0, DateTime.now()));
//   }
//
//   @Query("SELECT * FROM ViewHistory WHERE discuz_id=:discuzId AND identification=:tid LIMIT 1")
//   Stream<ViewHistory?> threadHistoryExistInDatabase(int discuzId, int tid);
//
//   @Query("SELECT * FROM ViewHistory WHERE discuz_id=:discuzId AND identification=:fid LIMIT 1")
//   Stream<ViewHistory?> forumExistInDatabaseStream(int discuzId, int fid);
//
//   @Query("SELECT * FROM ViewHistory WHERE discuz_id=:discuzId AND identification=:fid LIMIT 1")
//   Future<ViewHistory?> forumExistInDatabase(int discuzId, int fid);
//
// }