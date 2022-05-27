

import 'package:discuz_flutter/entity/Smiley.dart';
import 'package:hive/hive.dart';

import '../entity/Discuz.dart';

class SmileyDao{
  Box<Smiley> smileyBox;

  SmileyDao(this.smileyBox);

  List<Smiley> findAllSmileyByDiscuz(Discuz discuz){
    List<Smiley> smileyList = smileyBox.values.where((element) => element.discuz == discuz).toList();
    smileyList.sort((a,b) => - a.dateTime.compareTo(b.dateTime));
    return smileyList;
  }

  Smiley? findSmileyByDiscuzIdAndCode(Discuz discuz, String code){
    if(smileyBox.values.where((element) => element.discuz == discuz && element.code == code).isNotEmpty){
      return smileyBox.values.where((element) => element.discuz == discuz && element.code == code).first;
    }
    else{
      return null;
    }
  }

  Future<int> insertSmiley(Smiley smiley){
    return smileyBox.add(smiley);
  }

  Future<void> insertSmileyWithKey(dynamic key,Smiley smiley){
    return smileyBox.put(key,smiley);
  }

  Future<void> deleteSmiley(Smiley smiley) async{
    smileyBox.delete(smiley.key);
  }

}

// @dao
// abstract class SmileyDao{
//
//   @Query('SELECT * FROM SMILEY WHERE discuz_id=:discuzId ORDER BY dateTime DESC LIMIT 20')
//   Future<List<Smiley>> findAllSmileyByDiscuzId(int discuzId);
//
//   @Query('SELECT * FROM SMILEY WHERE discuz_id=:discuzId ORDER BY dateTime DESC LIMIT 20')
//   Stream<List<Smiley>> findAllSmileyStreamByDiscuzId(int discuzId);
//
//   @Query('SELECT * FROM SMILEY WHERE discuz_id=:discuzId AND code=:code LIMIT 1')
//   Future<Smiley?> findSmileyByDiscuzIdAndCode(int discuzId, String code);
//
//   @Insert(onConflict: OnConflictStrategy.replace)
//   Future<int> insertSmiley(Smiley smiley);
//
//   @delete
//   Future<int> deleteSmiley(Smiley smiley);
// }