import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:hive/hive.dart';

class DiscuzDao{
  Box<Discuz> discuzBox;

  DiscuzDao(this.discuzBox);

  Future<List<Discuz>> findAllDiscuzs() async{
    return discuzBox.values.toList();
  }

  Stream<List<Discuz>> findAllDiscuzStream(){
    return discuzBox.watch().map((event) => discuzBox.values.toList());
  }

  Discuz? findDiscuzByBaseURL(String baseURL){
    if (discuzBox.values.where((element) => element.baseURL == baseURL).isEmpty){
      return null;
    }
    else{
      return discuzBox.values.where((element) => element.baseURL == baseURL).first;
    }
  }

  Future<int> insertDiscuz(Discuz discuz){
    return discuzBox.add(discuz);
  }

  Future<void> deleteDiscuz(Discuz discuz) async{
    discuzBox.values.where((element) => element == discuz).forEach((element) {
      discuzBox.delete(discuz.key);
    });
  }

}


// @dao
// abstract class DiscuzDao {
//   @Query('SELECT * FROM Discuz')
//   Future<List<Discuz>> findAllDiscuzs();
//
//   @Query('SELECT * FROM Discuz')
//   Stream<List<Discuz>> findAllDiscuzStream();
//
//   @Query('SELECT * FROM Discuz WHERE baseURL = :baseURL LIMIT 1')
//   Future<Discuz?> findDiscuzByBaseURL(String baseURL);
//
//   @Insert(onConflict: OnConflictStrategy.replace)
//   Future<int> insertDiscuz(Discuz discuz);
//
//   @delete
//   Future<void> deleteDiscuz(Discuz discuz);
// }