import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:hive_ce/hive.dart';
import '../utility/background_new_posts.dart';

class DiscuzDao{
  Box<Discuz> discuzBox;

  DiscuzDao(this.discuzBox);

  List<Discuz> findAllDiscuzs(){
    return discuzBox.values.toList();
  }


  // Stream<List<Discuz>> findAllDiscuzStream(){
  //   return discuzBox.watch().map((event) => discuzBox.values.toList());
  // }

  Discuz? findDiscuzByBaseURL(String baseURL){
    final site = Discuz.normalizeSiteUrl(baseURL);
    if (site.isEmpty) return null;
    return discuzBox.values.where((forum) => forum.siteIdentity == site).firstOrNull;
  }

  Discuz? findDiscuzByHost(String baseURL){

    if (discuzBox.values.where((element) => Uri.parse(element.baseURL).host == Uri.parse(baseURL).host).isEmpty){
      return null;
    }
    else{
      return discuzBox.values.where((element) => Uri.parse(element.baseURL).host == Uri.parse(baseURL).host).first;
    }
  }

  Discuz? findDiscuzByRealHost(String host){
    final matches = discuzBox.values.where((forum) => forum.host == host).toList();
    return matches.length == 1 ? matches.single : null;
  }

  Future<int> insertDiscuz(Discuz discuz){
    return discuzBox.add(discuz);
  }

  Discuz? getDiscuzByIndex(int index){
    return discuzBox.get(index);
  }

  Future<void> deleteDiscuz(Discuz discuz) async{
    await BackgroundNewPosts.instance.removeSite(discuz.baseURL);
    await discuzBox.delete(discuz.key);

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
