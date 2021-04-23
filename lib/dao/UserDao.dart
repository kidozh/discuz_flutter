import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:floor/floor.dart';


@dao
abstract class UserDao {
  @Query('SELECT * FROM User')
  Future<List<User>> findAllUsers();

  @Query('SELECT * FROM User')
  Stream<List<User>> findAllDiscuzStream();

  @Query('SELECT * FROM User WHERE discuz_id=:discuzId ')
  Future<List<User>> findAllUsersByDiscuzId(int discuzId);

  @Query('SELECT * FROM User WHERE discuz_id=:discuzId ')
  Stream<List<User>> findAllUsersStreamByDiscuzId(int discuzId);

  // @Insert(onConflict: OnConflictStrategy.replace)
  // Future<void> insertUser(User user);
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insert(User user);
}