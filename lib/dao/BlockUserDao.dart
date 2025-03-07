

import 'package:discuz_flutter/entity/BlockUser.dart';
import 'package:hive_ce/hive.dart';

import '../entity/Discuz.dart';

class BlockUserDao{
  Box<BlockUser> blockUserBox;

  BlockUserDao(this.blockUserBox);

  List<BlockUser> isUserBlocked(int uid, Discuz discuz){
    return blockUserBox.values.where((element) => element.uid == uid && element.discuz == discuz).toList();
  }

  Future<int> insertBlockUser(BlockUser blockUser){
    return blockUserBox.add(blockUser);
  }

  Future<void> deleteBlockUser(BlockUser blockUser) async{
    blockUserBox.values.where((element) => element == blockUser).forEach((element) {

      blockUserBox.delete(element.key);
    });

  }

  Future<void> deleteBlockUserByUid(int uid, Discuz discuz) async{
    blockUserBox.values.where((element) => element.uid == uid && element.discuz == discuz).forEach((element) {

      blockUserBox.delete(element.key);
    });

  }


  // Stream<List<BlockUser>> getBlockUserListStream(Discuz discuz){
  //   return blockUserBox.watch().map((event) => blockUserBox.values.where((element) => element.discuz == discuz).toList());
  // }

  List<BlockUser> getBlockUserListByDiscuz(Discuz discuz){
    return blockUserBox.values.where((element) => element.discuz == discuz).toList();
  }





}