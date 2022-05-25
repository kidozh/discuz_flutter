import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:hive/hive.dart';

class UserDao{
  Box<User> userBox;

  UserDao(this.userBox);

  List<User> findAllUsers(){
    return userBox.values.toList();
  }

  Stream<List<User>> findAllDiscuzStream(){
    return userBox.watch().map((event) => userBox.values.toList());
  }

  List<User> findAllUsersByDiscuz(Discuz discuz){
    return userBox.values.where((element) => element.discuz == discuz).toList();
  }

  Stream<List<User>> findAllUsersStreamByDiscuz(Discuz discuz){
    return userBox.watch().map((event) => userBox.values.where((element) => element.discuz == discuz).toList());
  }

  Future<int> insert(User user){
    return userBox.add(user);
  }

  User? findUsersByDiscuzAndUid(Discuz discuz, int uid){
    if(userBox.values.where((element) => element.discuz == discuz && element.uid == uid).isNotEmpty){
      return userBox.values.where((element) => element.discuz == discuz && element.uid == uid).first;
    }
    else {
      return null;
    }
  }

  Future<void> deleteUser(User user) async{
    return userBox.values.where((element) => element == User).forEach((element) {
      userBox.delete(user.key);
    });
  }

}
