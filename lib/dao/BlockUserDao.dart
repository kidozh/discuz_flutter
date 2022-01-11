

import 'package:discuz_flutter/entity/BlockUser.dart';
import 'package:floor/floor.dart';

@dao
abstract class BlockUserDao{
  @Query("SELECT * FROM BlockUser WHERE uid =:uid AND discuz_id=:discuzId LIMIT 2")
  Future<List<BlockUser>> isUserBlocked(int uid, int discuzId);

  @insert
  Future<int> insertBlockUser(BlockUser blockUser);

  @delete
  Future<int> deleteBlockUser(BlockUser blockUser);

  @Query("DELETE FROM BlockUser WHERE uid = :uid AND discuz_id = :discuzId")
  Future<void> deleteBlockUserByUid(int uid, int discuzId);

  @Query("SELECT * FROM BlockUser WHERE discuz_id=:discuzId")
  Stream<List<BlockUser>> getBlockUserListStream(int discuzId);
}