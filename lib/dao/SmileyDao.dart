

import 'package:discuz_flutter/entity/Smiley.dart';
import 'package:floor/floor.dart';

@dao
abstract class SmileyDao{

  @Query('SELECT * FROM SMILEY WHERE discuz_id=:discuzId ORDER BY dateTime DESC LIMIT 20')
  Future<List<Smiley>> findAllSmileyByDiscuzId(int discuzId);

  @Query('SELECT * FROM SMILEY WHERE discuz_id=:discuzId ORDER BY dateTime DESC LIMIT 20')
  Stream<List<Smiley>> findAllSmileyStreamByDiscuzId(int discuzId);

  @Query('SELECT * FROM SMILEY WHERE discuz_id=:discuzId AND code=:code LIMIT 1')
  Future<Smiley?> findSmileyByDiscuzIdAndCode(int discuzId, String code);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertSmiley(Smiley smiley);

  @delete
  Future<int> deleteSmiley(Smiley smiley);
}