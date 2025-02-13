import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/ViewHistory.dart';
import 'package:hive_ce/hive.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class ViewHistoryDao{
  Box<ViewHistory> viewHistoryBox;

  ViewHistoryDao(this.viewHistoryBox);

  List<ViewHistory> findAllViewHistoriesByDiscuz(Discuz discuz){
    List<ViewHistory> viewHistoryList= viewHistoryBox.values.where((element) => element.discuz == discuz).toList();
    viewHistoryList.sort((a,b) => -a.updateTime.compareTo(b.updateTime));
    return viewHistoryList;
  }

  // Stream<List<ViewHistory>> findAllViewHistoriesStreamByDiscuz(Discuz discuz){
  //
  //   return viewHistoryBox.watch().map((event) => viewHistoryBox.values
  //       .where((element) => element.discuz == discuz)
  //       .toList());
  // }

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

  bool threadHistoryExistInDatabase(Discuz discuz, int tid){
    return viewHistoryBox.values.where((element) => element.identification == tid && element.discuz == discuz && element.type == "thread").isNotEmpty;
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