

import 'package:hive_ce/hive.dart';

import '../entity/Discuz.dart';
import '../entity/ViewThreadScrollDistance.dart';

class ViewThreadScrollDistanceDao{
  Box<ViewThreadScrollDistance> viewThreadScrollDistanceBox;
  ViewThreadScrollDistanceDao(this.viewThreadScrollDistanceBox);

  ViewThreadScrollDistance? findViewThreadCacheListByDiscuz(Discuz discuz, int tid, bool isAscend){

    return viewThreadScrollDistanceBox.values.where(
            (element) =>
        element.discuz == discuz &&
            element.tid == tid &&
            element.isAscend == isAscend
    ).firstOrNull;
  }

  Future<void> insertViewThreadScrollDistance(ViewThreadScrollDistance viewThreadCache){
    // check with existing records
    int existingThreadCacheRecordListLength = viewThreadScrollDistanceBox.values.where((element) =>
    element.discuz == viewThreadCache.discuz
        && element.tid == viewThreadCache.tid
        && element.isAscend == viewThreadCache.isAscend
    ).length;

    if(existingThreadCacheRecordListLength == 1){
      // replace it
      ViewThreadScrollDistance element = viewThreadScrollDistanceBox.values.where((element) =>
      element.discuz == viewThreadCache.discuz
          && element.tid == viewThreadCache.tid
          && element.isAscend == viewThreadCache.isAscend
          ).first;

      return viewThreadScrollDistanceBox.put(element.key, viewThreadCache);

    }
    else if(existingThreadCacheRecordListLength > 1){
      viewThreadScrollDistanceBox.values.where((element) =>
      element.discuz == viewThreadCache.discuz
          && element.tid == viewThreadCache.tid
          && element.isAscend == viewThreadCache.isAscend
      ).forEach((element) => viewThreadScrollDistanceBox.delete(element.key));

      return viewThreadScrollDistanceBox.add(viewThreadCache);
    }
    else{
      return viewThreadScrollDistanceBox.add(viewThreadCache);
    }

  }

  Future<void> deleteAllViewThreadScrollDistanceByTid(Discuz discuz, int tid) async{
    return viewThreadScrollDistanceBox.values.where(
            (element) => element.discuz == discuz && element.tid == tid
    ).forEach((element) {
      viewThreadScrollDistanceBox.delete(element.key);
    });
  }

  Future<void> deleteAllExpiredViewThreadCache() async{
    DateTime oneWeekAgo = DateTime.now().subtract(Duration(days:7));

    return viewThreadScrollDistanceBox.values.where(
            (element) => element.updateTime.isBefore(oneWeekAgo)
    ).forEach((element) {
      viewThreadScrollDistanceBox.delete(element.key);
    });
  }


}