import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:floor/floor.dart';


@dao
abstract class DiscuzDao {
  @Query('SELECT * FROM Discuz')
  Future<List<Discuz>> findAllDiscuzs();

  @Query('SELECT * FROM Discuz')
  Stream<List<Discuz>> findAllDiscuzStream();

  @Query('SELECT * FROM Discuz WHERE baseURL = :baseURL LIMIT 1')
  Future<Discuz?> findDiscuzByBaseURL(String baseURL);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertDiscuz(Discuz discuz);

  @delete
  Future<void> deleteDiscuz(Discuz discuz);
}