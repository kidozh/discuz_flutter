import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/TrustHost.dart';
import 'package:floor/floor.dart';


@dao
abstract class TrustHostDao {
  @Query('SELECT * FROM TrustHost')
  Future<List<TrustHost>> findAllTrustHosts();

  @Query('SELECT * FROM TrustHost')
  Stream<List<TrustHost>> findAllTrustHostsStream();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertTrustHost(TrustHost trustHost);

  @delete
  Future<void> deleteTrustHost(TrustHost trustHost);

  @Query('SELECT * FROM TrustHost WHERE host=:host')
  Future<TrustHost?> findTrustHostByName(String host);
}