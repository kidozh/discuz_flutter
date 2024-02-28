

import 'package:hive/hive.dart';

import '../entity/Discuz.dart';
import '../entity/ViewThreadCache.dart';

class ViewThreadCacheDao{
  Box<ViewThreadCache> viewThreadCacheBox;

  ViewThreadCacheDao(this.viewThreadCacheBox);

  List<ViewThreadCache> findAllViewThreadCacheListByDiscuz(Discuz discuz, int tid, bool isAscend){
    List<ViewThreadCache> viewThreadCacheList = viewThreadCacheBox.values.where(
            (element) =>
            element.discuz == discuz &&
            element.tid == tid &&
            element.isAscend == isAscend
    )
        .toList();
    viewThreadCacheList.sort((a,b) => a.page.compareTo(b.page));
    return viewThreadCacheList;
  }

  Future<void> insertViewThreadCache(ViewThreadCache viewThreadCache){
    // check with existing records
    int existingThreadCacheRecordListLength = viewThreadCacheBox.values.where((element) =>
    element.discuz == viewThreadCache.discuz
        && element.tid == viewThreadCache.tid
        && element.isAscend == viewThreadCache.isAscend
        && element.page == viewThreadCache.page).length;

    if(existingThreadCacheRecordListLength == 1){
      // replace it
      ViewThreadCache element = viewThreadCacheBox.values.where((element) =>
      element.discuz == viewThreadCache.discuz
          && element.tid == viewThreadCache.tid
          && element.isAscend == viewThreadCache.isAscend
          && element.page == viewThreadCache.page).first;

      return viewThreadCacheBox.put(element.key, viewThreadCache);

    }
    else if(existingThreadCacheRecordListLength > 1){
      viewThreadCacheBox.values.where((element) =>
      element.discuz == viewThreadCache.discuz
          && element.tid == viewThreadCache.tid
          && element.isAscend == viewThreadCache.isAscend
          && element.page == viewThreadCache.page
      ).forEach((element) => viewThreadCacheBox.delete(element.key));

      return viewThreadCacheBox.add(viewThreadCache);
    }
    else{
      return viewThreadCacheBox.add(viewThreadCache);
    }

  }

  Future<void> deleteAllViewThreadCacheByTid(Discuz discuz, int tid) async{
    return viewThreadCacheBox.values.where(
            (element) => element.discuz == discuz && element.tid == tid
    ).forEach((element) {
      viewThreadCacheBox.delete(element.key);
    });
  }

  Future<void> deleteAllExpiredViewThreadCache() async{
    DateTime oneWeekAgo = DateTime.now().subtract(Duration(days:7));

    return viewThreadCacheBox.values.where(
            (element) => element.updateTime.isBefore(oneWeekAgo)
    ).forEach((element) {
      viewThreadCacheBox.delete(element.key);
    });
  }

}