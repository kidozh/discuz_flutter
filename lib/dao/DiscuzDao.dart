import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:floor/floor.dart';


@dao
abstract class DiscuzDao {
  @Query('SELECT * FROM Discuz')
  Future<List<Discuz>> findAllDiscuzs();

  @Query('SELECT * FROM Discuz')
  Stream<List<Discuz>> findAllDiscuzStream();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertDiscuz(Discuz discuz);

  @delete
  Future<void> deleteDiscuz(Discuz discuz);
}