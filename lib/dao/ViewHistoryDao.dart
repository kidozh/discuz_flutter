import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/entity/ViewHistory.dart';
import 'package:floor/floor.dart';


@dao
abstract class ViewHistoryDao {

  @Query('SELECT * FROM ViewHistory WHERE discuz_id=:discuzId ORDER BY updateTime DESC')
  Future<List<ViewHistory>> findAllViewHistoriesByDiscuzId(int discuzId);

  @Query('SELECT * FROM ViewHistory WHERE discuz_id=:discuzId ORDER BY updateTime DESC')
  Stream<List<ViewHistory>> findAllViewHistoriesStreamByDiscuzId(int discuzId);

  // @Insert(onConflict: OnConflictStrategy.replace)
  // Future<void> insertUser(User user);
  @insert
  Future<int> insertViewHistory(ViewHistory viewHistory);

  @delete
  Future<int> deleteViewHistory(ViewHistory viewHistory);

  @delete
  Future<int> deleteViewHistories(List<ViewHistory> viewHistories);

  @Query("DELETE FROM ViewHistory")
  Future<void> deleteAllViewHistory();

  @Query("DELETE FROM ViewHistory WHERE discuz_id=:discuzId")
  Future<void> deleteViewHistoryByBBSId(int discuzId);

  @transaction
  Future<void> deleteAllHistories() async {
    await deleteAllViewHistory();
    await deleteViewHistory(ViewHistory(0, "", "", "", "", 0, "", 0, 0, DateTime.now()));
  }

  @Query('SELECT * FROM ViewHistory WHERE discuz_id=:discuzId AND identification=:tid LIMIT 1')
  Stream<ViewHistory?> threadHistoryExistInDatabase(int discuzId, int tid);

}