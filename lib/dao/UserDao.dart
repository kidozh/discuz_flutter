import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:hive_ce/hive.dart';

class UserDao{
  Box<User> userBox;

  UserDao(this.userBox);

  List<User> findAllUsers(){
    return userBox.values.toList();
  }

  // Stream<List<User>> findAllDiscuzStream(){
  //   return userBox.watch().map((event) => userBox.values.toList());
  // }

  List<User> findAllUsersByDiscuz(Discuz discuz){
    return userBox.values.where((user) => discuz.isSameSite(user.discuz)).toList();
  }

  // Stream<List<User>> findAllUsersStreamByDiscuz(Discuz discuz){
  //   return userBox.watch().map((event) => userBox.values.where((element) => element.discuz == discuz).toList());
  // }

  Future<int> insert(User user){
    return userBox.add(user);
  }

  Future<void> insertWithKey(dynamic key,User user){
    return userBox.put(key, user);
  }

  User? findUsersByDiscuzAndUid(Discuz discuz, int uid){
    return userBox.values.where((user) =>
        user.uid == uid && discuz.isSameSite(user.discuz)).firstOrNull;
  }

  Future<void> deleteUser(User user) async{
    return userBox.delete(user.key);
  }

}
